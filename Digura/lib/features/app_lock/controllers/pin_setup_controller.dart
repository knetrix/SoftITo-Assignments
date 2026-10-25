import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/data/app_lock_repository.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/pin_validator.dart';
import '../models/pin_flow_model.dart';

/// Kurulum 1/2: PIN oluştur ve doğrula. Zayıf PIN'ler reddedilir.
class PinSetupController {
  final AppLockRepository _lock;
  final ValueNotifier<PinSetupState> state = ValueNotifier(const PinSetupState());

  String _first = '';
  Timer? _timer;
  bool _disposed = false;

  PinSetupController(this._lock);

  PinSetupState get _s => state.value;

  void _emit(PinSetupState next) {
    if (!_disposed) state.value = next;
  }

  void inputDigit(String digit) {
    if (_s.stage == PinSetupStage.done || _s.entered.length >= PinValidator.length) return;
    _emit(_s.copyWith(entered: _s.entered + digit, error: () => null));
    if (_s.entered.length == PinValidator.length) _timer = Timer(AppMotion.pinEvaluate, _evaluate);
  }

  void deleteDigit() {
    if (_s.entered.isEmpty || _timer?.isActive == true) return;
    _emit(_s.copyWith(entered: _s.entered.substring(0, _s.entered.length - 1)));
  }

  /// "Baştan": doğrulama adımından ilk adıma döner.
  void restart() {
    _timer?.cancel();
    _first = '';
    _emit(const PinSetupState());
  }

  Future<void> _evaluate() async {
    final value = _s.entered;
    if (_s.stage == PinSetupStage.create) {
      if (PinValidator.isWeak(value)) {
        _emit(_s.copyWith(entered: '', error: () => AppStrings.weakPin, shakeTick: _s.shakeTick + 1));
        return;
      }
      _first = value;
      _emit(_s.copyWith(stage: PinSetupStage.confirm, entered: ''));
      return;
    }
    if (value == _first) {
      await _lock.setPin(value);
      _first = '';
      _emit(_s.copyWith(stage: PinSetupStage.done, entered: ''));
      return;
    }
    _first = '';
    _emit(PinSetupState(error: AppStrings.pinMismatch, shakeTick: _s.shakeTick + 1));
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    state.dispose();
  }
}

/// Kurulum 2/2: isteğe bağlı parmak izi.
class BiometricSetupController {
  final AppLockRepository _lock;
  final BiometricAuthenticator _biometrics;
  final ValueNotifier<BiometricSetupStatus> status = ValueNotifier(BiometricSetupStatus.idle);
  bool _disposed = false;

  BiometricSetupController(this._lock, this._biometrics);

  Future<void> enable() async {
    if (status.value == BiometricSetupStatus.scanning) return;
    status.value = BiometricSetupStatus.scanning;
    final result = await _biometrics.authenticate(BiometricPurpose.enroll);
    if (_disposed) return;
    switch (result) {
      case BiometricResult.success:
        await _lock.setBiometricEnabled(true);
        if (!_disposed) status.value = BiometricSetupStatus.enabled;
      case BiometricResult.failure:
        status.value = BiometricSetupStatus.failed;
      case BiometricResult.unavailable:
        status.value = BiometricSetupStatus.unavailable;
    }
  }

  Future<void> skip() => _lock.setBiometricEnabled(false);

  void dispose() {
    _disposed = true;
    status.dispose();
  }
}
