import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../constants/app_motion.dart';
import '../constants/app_strings.dart';

enum BiometricPurpose { enroll, unlock }

enum BiometricResult { success, failure, unavailable }

/// Biyometrik doğrulama soyutlaması. Eşleştirmeyi telefonun kendisi yapar;
/// parmak izi verisi uygulamaya hiçbir zaman ulaşmaz.
abstract interface class BiometricAuthenticator {
  Future<BiometricResult> authenticate(BiometricPurpose purpose);

  /// PIN ile başarılı giriş: sensör kilidi kalkar.
  void onPinUnlocked({required bool hadBiometricFailures});
}

/// `local_auth` ile gerçek Face ID / Touch ID / parmak izi.
class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  final LocalAuthentication _auth;

  LocalAuthBiometricAuthenticator([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      if (!await _auth.canCheckBiometrics) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on Exception {
      return false;
    }
  }

  @override
  Future<BiometricResult> authenticate(BiometricPurpose purpose) async {
    try {
      final ok = await _auth.authenticate(localizedReason: AppStrings.biometricReason, biometricOnly: true);
      return ok ? BiometricResult.success : BiometricResult.failure;
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable => BiometricResult.unavailable,
        _ => BiometricResult.failure,
      };
    } on Exception {
      return BiometricResult.failure;
    }
  }

  @override
  void onPinUnlocked({required bool hadBiometricFailures}) {}
}

/// Biyometrisi olmayan cihaz/simülatör için prototipteki demo sensör
/// (`digura-kilit.html`): kurulumda tanır; kilitte 3 hatalı denemeyle sensör
/// kapanır, PIN ile açıldıktan sonraki ilk deneme tanınır.
class SimulatedBiometricAuthenticator implements BiometricAuthenticator {
  bool _recognizeNext = false;

  @visibleForTesting
  bool get recognizesNext => _recognizeNext;

  @override
  Future<BiometricResult> authenticate(BiometricPurpose purpose) async {
    if (purpose == BiometricPurpose.enroll) {
      await Future<void>.delayed(AppMotion.simulatedEnroll);
      return BiometricResult.success;
    }
    await Future<void>.delayed(AppMotion.simulatedScan);
    if (_recognizeNext) {
      _recognizeNext = false;
      return BiometricResult.success;
    }
    return BiometricResult.failure;
  }

  @override
  void onPinUnlocked({required bool hadBiometricFailures}) {
    if (hadBiometricFailures) _recognizeNext = true;
  }
}

/// Cihazda biyometri varsa gerçeğini, yoksa demo sensörü kullanır.
class AdaptiveBiometricAuthenticator implements BiometricAuthenticator {
  final LocalAuthBiometricAuthenticator _real;
  final SimulatedBiometricAuthenticator _simulated = SimulatedBiometricAuthenticator();
  Future<bool>? _available;

  AdaptiveBiometricAuthenticator([LocalAuthBiometricAuthenticator? real])
    : _real = real ?? LocalAuthBiometricAuthenticator();

  Future<BiometricAuthenticator> _delegate() async => await (_available ??= _real.isAvailable()) ? _real : _simulated;

  @override
  Future<BiometricResult> authenticate(BiometricPurpose purpose) async => (await _delegate()).authenticate(purpose);

  @override
  void onPinUnlocked({required bool hadBiometricFailures}) {
    _real.onPinUnlocked(hadBiometricFailures: hadBiometricFailures);
    _simulated.onPinUnlocked(hadBiometricFailures: hadBiometricFailures);
  }
}
