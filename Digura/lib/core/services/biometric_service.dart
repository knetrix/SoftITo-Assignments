import 'package:flutter/foundation.dart'; // visibleForTesting Annotation'ını Sağlayan Flutter Foundation Kütüphanesini import Eder.
import 'package:local_auth/local_auth.dart'; // Cihaz Biyometrisi İçin LocalAuthentication API'sini import Eder.

import '../constants/app_motion.dart'; // Demo Sensör Gecikmeleri İçin AppMotion Sabitlerini import Eder.
import '../constants/app_strings.dart'; // Biyometrik Doğrulama Metni İçin AppStrings'i import Eder.

enum BiometricPurpose { enroll, unlock } // Doğrulamanın Kurulum mu Kilit Açma mı Olduğunu Belirten enum'dur.

enum BiometricResult { success, failure, unavailable } // Biyometrik Doğrulamanın Olası Sonuçlarını Tanımlayan enum'dur.

/// Biyometrik doğrulama soyutlaması. Eşleştirmeyi telefonun kendisi yapar;
/// parmak izi verisi uygulamaya hiçbir zaman ulaşmaz.
abstract interface class BiometricAuthenticator { // Biyometrik Doğrulayıcıların Uyması Gereken Interface'tir.
  Future<BiometricResult> authenticate(BiometricPurpose purpose); // Verilen Amaç İçin Doğrulama Yapıp Sonucu Future Olarak Döndürür.

  /// PIN ile başarılı giriş: sensör kilidi kalkar.
  void onPinUnlocked({required bool hadBiometricFailures}); // PIN İle Kilit Açıldığında Çağrılan Callback'tir.
}

/// `local_auth` ile gerçek Face ID / Touch ID / parmak izi.
class LocalAuthBiometricAuthenticator implements BiometricAuthenticator { // Gerçek Cihaz Biyometrisini Kullanan Doğrulayıcıdır.
  final LocalAuthentication _auth; // local_auth Paketinin Doğrulama Nesnesidir.

  LocalAuthBiometricAuthenticator([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication(); // Verilmezse Varsayılan LocalAuthentication Oluşturan Constructor'dır.

  Future<bool> isAvailable() async { // Cihazda Kullanılabilir Biyometri Olup Olmadığını Kontrol Eder.
    try { // Platform Hatalarını Yakalamak İçin try Bloğu Başlatır.
      if (!await _auth.isDeviceSupported()) return false; // Cihaz Desteklemiyorsa false Döndürür.
      if (!await _auth.canCheckBiometrics) return false; // Biyometri Kontrol Edilemiyorsa false Döndürür.
      return (await _auth.getAvailableBiometrics()).isNotEmpty; // Kayıtlı Biyometri Varsa true Döndürür.
    } on Exception { // Herhangi Bir Exception Durumunu Yakalar.
      return false; // Hata Durumunda Biyometriyi Kullanılamaz Sayar.
    }
  }

  @override // Superclass'taki authenticate Metodunun Override Edildiğini Belirtir.
  Future<BiometricResult> authenticate(BiometricPurpose purpose) async { // Gerçek Biyometrik Doğrulamayı Çalıştırır.
    try { // Doğrulama Hatalarını Yakalamak İçin try Bloğu Başlatır.
      final ok = await _auth.authenticate(localizedReason: AppStrings.biometricReason, biometricOnly: true); // Yalnızca Biyometri İle Sistem Doğrulama Penceresini Açar.
      return ok ? BiometricResult.success : BiometricResult.failure; // Sonuca Göre success Ya Da failure Döndürür.
    } on LocalAuthException catch (e) { // local_auth Kaynaklı Hataları Yakalar.
      return switch (e.code) { // Hata Koduna Göre Sonucu Eşler.
        LocalAuthExceptionCode.noBiometricHardware || // Biyometrik Donanım Yoksa.
        LocalAuthExceptionCode.noBiometricsEnrolled || // Kayıtlı Biyometri Yoksa.
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable => BiometricResult.unavailable, // Donanım Geçici Olarak Kapalıysa unavailable Döndürür.
        _ => BiometricResult.failure, // Diğer Tüm Hata Kodlarında failure Döndürür.
      };
    } on Exception { // Diğer Exception'ları Yakalar.
      return BiometricResult.failure; // Beklenmeyen Hatada failure Döndürür.
    }
  }

  @override // Superclass'taki onPinUnlocked Metodunun Override Edildiğini Belirtir.
  void onPinUnlocked({required bool hadBiometricFailures}) {} // Gerçek Sensörde PIN Sonrası Yapılacak İş Olmadığı İçin Boştur.
}

/// Biyometrisi olmayan cihaz/simülatör için prototipteki demo sensör
/// (`digura-kilit.html`): kurulumda tanır; kilitte 3 hatalı denemeyle sensör
/// kapanır, PIN ile açıldıktan sonraki ilk deneme tanınır.
class SimulatedBiometricAuthenticator implements BiometricAuthenticator { // Biyometrisi Olmayan Cihazlar İçin Demo Doğrulayıcıdır.
  bool _recognizeNext = false; // Bir Sonraki Denemenin Tanınıp Tanınmayacağını Tutar.

  @visibleForTesting // Bu Getter'ın Yalnızca Testler İçin Açık Olduğunu Belirtir.
  bool get recognizesNext => _recognizeNext; // _recognizeNext Değerini Testlere Açan Getter'dır.

  @override // Superclass'taki authenticate Metodunun Override Edildiğini Belirtir.
  Future<BiometricResult> authenticate(BiometricPurpose purpose) async { // Demo Sensör Doğrulamasını Simüle Eder.
    if (purpose == BiometricPurpose.enroll) { // Amaç Kurulumsa.
      await Future<void>.delayed(AppMotion.simulatedEnroll); // Kurulum Taramasını Simüle Etmek İçin Bekler.
      return BiometricResult.success; // Kurulumda Her Zaman success Döndürür.
    }
    await Future<void>.delayed(AppMotion.simulatedScan); // Kilit Taramasını Simüle Etmek İçin Bekler.
    if (_recognizeNext) { // Bir Sonraki Deneme Tanınacaksa.
      _recognizeNext = false; // Tanıma Hakkını Tüketir.
      return BiometricResult.success; // Başarılı Sonuç Döndürür.
    }
    return BiometricResult.failure; // Aksi Halde failure Döndürür.
  }

  @override // Superclass'taki onPinUnlocked Metodunun Override Edildiğini Belirtir.
  void onPinUnlocked({required bool hadBiometricFailures}) { // PIN İle Açıldığında Sensör Durumunu Günceller.
    if (hadBiometricFailures) _recognizeNext = true; // Önceden Hatalı Deneme Varsa Sonraki Denemeyi Tanınır Yapar.
  }
}

/// Cihazda biyometri varsa gerçeğini, yoksa demo sensörü kullanır.
class AdaptiveBiometricAuthenticator implements BiometricAuthenticator { // Gerçek Ve Demo Doğrulayıcı Arasında Seçim Yapan Doğrulayıcıdır.
  final LocalAuthBiometricAuthenticator _real; // Gerçek Cihaz Doğrulayıcısıdır.
  final SimulatedBiometricAuthenticator _simulated = SimulatedBiometricAuthenticator(); // Yedek Demo Doğrulayıcıdır.
  Future<bool>? _available; // Biyometri Uygunluk Sonucunu Önbelleğe Alan Future'dır.

  AdaptiveBiometricAuthenticator([LocalAuthBiometricAuthenticator? real]) // İsteğe Bağlı Gerçek Doğrulayıcı Alan Constructor'dır.
    : _real = real ?? LocalAuthBiometricAuthenticator(); // Verilmezse Varsayılan Gerçek Doğrulayıcıyı Oluşturur.

  Future<BiometricAuthenticator> _delegate() async => await (_available ??= _real.isAvailable()) ? _real : _simulated; // Biyometri Varsa Gerçeğini Yoksa Demo Doğrulayıcıyı Döndürür.

  @override // Superclass'taki authenticate Metodunun Override Edildiğini Belirtir.
  Future<BiometricResult> authenticate(BiometricPurpose purpose) async => (await _delegate()).authenticate(purpose); // Doğrulamayı Seçilen Doğrulayıcıya İletir.

  @override // Superclass'taki onPinUnlocked Metodunun Override Edildiğini Belirtir.
  void onPinUnlocked({required bool hadBiometricFailures}) { // PIN İle Açılışı Her İki Doğrulayıcıya Bildirir.
    _real.onPinUnlocked(hadBiometricFailures: hadBiometricFailures); // Gerçek Doğrulayıcıya PIN Açılışını İletir.
    _simulated.onPinUnlocked(hadBiometricFailures: hadBiometricFailures); // Demo Doğrulayıcıya PIN Açılışını İletir.
  }
}
