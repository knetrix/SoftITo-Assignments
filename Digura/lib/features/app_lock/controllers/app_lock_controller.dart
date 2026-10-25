import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/data/app_lock_repository.dart';
import '../../../core/data/preferences_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/pin_validator.dart';
import '../models/app_lock_model.dart';

/// Açılış kilidi: 4 haneli PIN (5 yanlışta 30 sn bekleme) ve parmak izi
/// (3 hatada sensör geçici olarak kapanır, PIN ile girişte yeniden açılır).
class AppLockController {
  final AppLockRepository _lock;
  final PreferencesService _prefs;
  final BiometricAuthenticator _biometrics;
  final Clock _clock;

  late final ValueNotifier<AppLockState> state;

  Timer? _evaluateTimer;
  Timer? _lockoutTimer;
  Timer? _verifiedTimer;
  bool _disposed = false;

  AppLockController(this._lock, this._prefs, this._biometrics, this._clock) {
    state = ValueNotifier(
      AppLockState(
        hasPin: _lock.hasPin.value,
        biometricEnabled: _lock.biometricEnabled.value,
        biometricTemporarilyDisabled: _prefs.biometricSuspended,
        biometricFailCount: _prefs.biometricSuspended ? AppLockState.maxBiometricFailures : 0,
      ),
    );
    final until = _prefs.lockoutUntil;
    if (until != null && until.isAfter(_clock.now())) {
      _startLockout(until, shake: false);
    } else if (until != null) {
      unawaited(_prefs.setLockoutUntil(null));
    }
  }

  AppLockState get _s => state.value;

  void _emit(AppLockState next) {
    if (!_disposed) state.value = next;
  }

  // ─── PIN ───

  void inputDigit(String digit) {
    if (!_s.keypadEnabled || _s.entered.length >= PinValidator.length) return;
    _emit(_s.copyWith(entered: _s.entered + digit, error: () => null));
    if (_s.entered.length == PinValidator.length) {
      _evaluateTimer = Timer(AppMotion.pinEvaluate, _evaluate);
    }
  }

  void deleteDigit() {
    if (!_s.keypadEnabled || _s.entered.isEmpty || _evaluateTimer?.isActive == true) return;
    _emit(_s.copyWith(entered: _s.entered.substring(0, _s.entered.length - 1)));
  }

  Future<void> _evaluate() async {
    final ok = await _lock.verifyPin(_s.entered);
    if (_disposed) return;
    if (ok) {
      _biometrics.onPinUnlocked(hadBiometricFailures: _s.biometricFailCount > 0 || _s.biometricTemporarilyDisabled);
      _unlock();
      return;
    }
    final left = _s.remainingPinAttempts - 1;
    if (left <= 0) {
      _emit(_s.copyWith(entered: '', remainingPinAttempts: 0));
      final until = _clock.now().add(const Duration(seconds: AppLockState.lockoutSeconds));
      await _prefs.setLockoutUntil(until);
      _startLockout(until, shake: true);
      return;
    }
    _emit(
      _s.copyWith(
        entered: '',
        remainingPinAttempts: left,
        error: () => AppStrings.wrongPin(left),
        shakeTick: _s.shakeTick + 1,
      ),
    );
  }

  void _startLockout(DateTime until, {required bool shake}) {
    void tick() {
      final ms = until.difference(_clock.now()).inMilliseconds;
      final seconds = ms <= 0 ? 0 : (ms / 1000).ceil();
      if (seconds <= 0) {
        _lockoutTimer?.cancel();
        unawaited(_prefs.setLockoutUntil(null));
        _emit(
          _s.copyWith(lockoutRemainingSeconds: 0, remainingPinAttempts: AppLockState.maxPinAttempts, error: () => null),
        );
        return;
      }
      _emit(_s.copyWith(lockoutRemainingSeconds: seconds, error: () => AppStrings.lockoutWait(seconds)));
    }

    _lockoutTimer?.cancel();
    tick();
    if (shake) _emit(_s.copyWith(shakeTick: _s.shakeTick + 1));
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  // ─── Parmak izi ───

  Future<void> startBiometric() async {
    if (!_s.canUseBiometric || _s.unlocked || _s.sheet == FingerprintSheetStatus.scanning) return;
    _emit(_s.copyWith(sheet: () => FingerprintSheetStatus.scanning, error: () => null, entered: ''));
    final result = await _biometrics.authenticate(BiometricPurpose.unlock);
    if (_disposed || _s.sheet == null) return;
    if (result == BiometricResult.success) {
      _emit(_s.copyWith(biometricFailCount: 0, sheet: () => FingerprintSheetStatus.verified));
      _verifiedTimer = Timer(AppMotion.biometricOkHold, () {
        _emit(_s.copyWith(sheet: () => null));
        _unlock();
      });
      return;
    }
    final fails = _s.biometricFailCount + 1;
    if (fails >= AppLockState.maxBiometricFailures) {
      unawaited(_prefs.setBiometricSuspended(true));
      _emit(
        _s.copyWith(
          biometricFailCount: fails,
          biometricTemporarilyDisabled: true,
          sheet: () => FingerprintSheetStatus.lockout,
        ),
      );
      return;
    }
    _emit(_s.copyWith(biometricFailCount: fails, sheet: () => FingerprintSheetStatus.failed));
  }

  /// Panel kapatma ("PIN kullan" / scrim). Tarama ve onay sırasında kapanmaz.
  bool closeSheet() {
    final sheet = _s.sheet;
    if (sheet == null) return true;
    if (sheet == FingerprintSheetStatus.scanning || sheet == FingerprintSheetStatus.verified) return false;
    _emit(_s.copyWith(sheet: () => null));
    return true;
  }

  void _unlock() {
    _lockoutTimer?.cancel();
    unawaited(_prefs.setLockoutUntil(null));
    unawaited(_prefs.setBiometricSuspended(false));
    _emit(
      _s.copyWith(
        unlocked: true,
        entered: '',
        error: () => null,
        remainingPinAttempts: AppLockState.maxPinAttempts,
        lockoutRemainingSeconds: 0,
        biometricFailCount: 0,
        biometricTemporarilyDisabled: false,
      ),
    );
  }

  void dispose() {
    _disposed = true;
    _evaluateTimer?.cancel();
    _lockoutTimer?.cancel();
    _verifiedTimer?.cancel();
    state.dispose();
  }
}
