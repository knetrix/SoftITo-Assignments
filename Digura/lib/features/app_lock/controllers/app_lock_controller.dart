import 'dart:async'; // Timer ve unawaited İçin Dart'ın async Kütüphanesini import Eder.

import 'package:flutter/foundation.dart'; // ValueNotifier İçin Flutter'ın foundation Kütüphanesini import Eder.

import '../../../core/constants/app_motion.dart'; // PIN Değerlendirme ve Onay Süreleri İçin AppMotion'ı import Eder.
import '../../../core/constants/app_strings.dart'; // Hata ve Bekleme Metinleri İçin AppStrings'i import Eder.
import '../../../core/data/app_lock_repository.dart'; // PIN ve Biyometri Ayarlarını Tutan AppLockRepository'yi import Eder.
import '../../../core/data/preferences_service.dart'; // Kilitlenme ve Askıya Alma Bilgilerini Saklayan PreferencesService'i import Eder.
import '../../../core/services/biometric_service.dart'; // BiometricAuthenticator ve İlgili enum'ları import Eder.
import '../../../core/utils/clock.dart'; // Test Edilebilir Zaman İçin Clock Class'ını import Eder.
import '../../../core/utils/pin_validator.dart'; // PIN Uzunluğu İçin PinValidator'ı import Eder.
import '../models/app_lock_model.dart'; // AppLockState ve FingerprintSheetStatus'u import Eder.

/// Açılış kilidi: 4 haneli PIN (5 yanlışta 30 sn bekleme) ve parmak izi
/// (3 hatada sensör geçici olarak kapanır, PIN ile girişte yeniden açılır).
class AppLockController { // Açılış Kilidi Mantığını Yöneten Controller Class'ıdır.
  final AppLockRepository _lock; // PIN Doğrulama ve Biyometri Ayarı İçin Repository'dir.
  final PreferencesService _prefs; // Kilitlenme Süresi ve Biyometri Askısını Saklayan Servistir.
  final BiometricAuthenticator _biometrics; // Parmak İzi Doğrulamasını Yapan Servistir.
  final Clock _clock; // Şu Anki Zamanı Veren Clock'tur.

  late final ValueNotifier<AppLockState> state; // Görünümün Dinlediği Kilit Durumu ValueNotifier'ıdır.

  Timer? _evaluateTimer; // Dört Hane Girildikten Sonra Değerlendirmeyi Geciktiren Timer'dır.
  Timer? _lockoutTimer; // Kilitlenme Geri Sayımını Her Saniye Güncelleyen Timer'dır.
  Timer? _verifiedTimer; // Parmak İzi Onayından Sonra Kilidi Açmayı Geciktiren Timer'dır.
  bool _disposed = false; // Controller'ın dispose Edilip Edilmediğini Tutar.

  AppLockController(this._lock, this._prefs, this._biometrics, this._clock) { // Bağımlılıkları Alan ve Başlangıç Durumunu Kuran Constructor'dır.
    state = ValueNotifier( // Başlangıç Durumuyla ValueNotifier Oluşturur.
      AppLockState( // Kayıtlı Ayarlardan İlk AppLockState'i Üretir.
        hasPin: _lock.hasPin.value, // PIN Tanımlı Olup Olmadığını Repository'den Alır.
        biometricEnabled: _lock.biometricEnabled.value, // Biyometrinin Açık Olup Olmadığını Repository'den Alır.
        biometricTemporarilyDisabled: _prefs.biometricSuspended, // Biyometrinin Askıda Olup Olmadığını Tercihlerden Alır.
        biometricFailCount: _prefs.biometricSuspended ? AppLockState.maxBiometricFailures : 0, // Askıdaysa Hata Sayısını Maksimuma Ayarlar.
      ),
    );
    final until = _prefs.lockoutUntil; // Kayıtlı Kilitlenme Bitiş Zamanını Okur.
    if (until != null && until.isAfter(_clock.now())) { // Kilitlenme Hâlâ Sürüyorsa Kontrol Eder.
      _startLockout(until, shake: false); // Sallama Olmadan Geri Sayımı Yeniden Başlatır.
    } else if (until != null) { // Süresi Dolmuş Bir Kilitlenme Kaydı Varsa Kontrol Eder.
      unawaited(_prefs.setLockoutUntil(null)); // Eski Kilitlenme Kaydını Temizler.
    }
  }

  AppLockState get _s => state.value; // Mevcut Durumu Kısaca Döndüren Getter'dır.

  void _emit(AppLockState next) { // Yeni Durumu Yayınlayan Yardımcı Metottur.
    if (!_disposed) state.value = next; // dispose Edilmemişse Durumu Günceller.
  }

  // ─── PIN ───

  void inputDigit(String digit) { // Tuş Takımından Gelen Haneyi Ekler.
    if (!_s.keypadEnabled || _s.entered.length >= PinValidator.length) return; // Tuş Takımı Kapalıysa Ya Da PIN Doluysa Çıkar.
    _emit(_s.copyWith(entered: _s.entered + digit, error: () => null)); // Haneyi Ekleyip Hatayı Temizler.
    if (_s.entered.length == PinValidator.length) { // PIN Tamamlandıysa Kontrol Eder.
      _evaluateTimer = Timer(AppMotion.pinEvaluate, _evaluate); // Kısa Bir Gecikmeyle Değerlendirmeyi Planlar.
    }
  }

  void deleteDigit() { // Son Girilen Haneyi Siler.
    if (!_s.keypadEnabled || _s.entered.isEmpty || _evaluateTimer?.isActive == true) return; // Silinecek Hane Yoksa Ya Da Değerlendirme Bekliyorsa Çıkar.
    _emit(_s.copyWith(entered: _s.entered.substring(0, _s.entered.length - 1))); // Son Haneyi Çıkarılmış Durumu Yayınlar.
  }

  Future<void> _evaluate() async { // Girilen PIN'i Doğrulayıp Sonucu İşler.
    final ok = await _lock.verifyPin(_s.entered); // PIN'i Repository Üzerinden Doğrular.
    if (_disposed) return; // dispose Edildiyse İşlemi Bırakır.
    if (ok) { // PIN Doğruysa Kontrol Eder.
      _biometrics.onPinUnlocked(hadBiometricFailures: _s.biometricFailCount > 0 || _s.biometricTemporarilyDisabled); // Biyometri Servisine PIN İle Açıldığını Bildirir.
      _unlock(); // Kilidi Açar.
      return; // Metottan Çıkar.
    }
    final left = _s.remainingPinAttempts - 1; // Kalan Deneme Sayısını Bir Azaltır.
    if (left <= 0) { // Deneme Hakkı Bittiyse Kontrol Eder.
      _emit(_s.copyWith(entered: '', remainingPinAttempts: 0)); // Haneleri Temizleyip Hakkı Sıfırlar.
      final until = _clock.now().add(const Duration(seconds: AppLockState.lockoutSeconds)); // Kilitlenme Bitiş Zamanını Hesaplar.
      await _prefs.setLockoutUntil(until); // Bitiş Zamanını Kalıcı Olarak Kaydeder.
      _startLockout(until, shake: true); // Sallamayla Geri Sayımı Başlatır.
      return; // Metottan Çıkar.
    }
    _emit( // Yanlış PIN Durumunu Yayınlar.
      _s.copyWith( // Mevcut Durumun Güncellenmiş Kopyasını Oluşturur.
        entered: '', // Girilen Haneleri Temizler.
        remainingPinAttempts: left, // Kalan Deneme Sayısını Ayarlar.
        error: () => AppStrings.wrongPin(left), // Kalan Hakkı Gösteren Hata Metnini Ayarlar.
        shakeTick: _s.shakeTick + 1, // Sallama Animasyonunu Tetiklemek İçin Sayacı Artırır.
      ),
    );
  }

  void _startLockout(DateTime until, {required bool shake}) { // Belirtilen Zamana Kadar Kilitlenme Geri Sayımını Başlatır.
    void tick() { // Her Saniye Çalışan Geri Sayım Fonksiyonudur.
      final ms = until.difference(_clock.now()).inMilliseconds; // Kalan Süreyi Milisaniye Olarak Hesaplar.
      final seconds = ms <= 0 ? 0 : (ms / 1000).ceil(); // Kalan Süreyi Yukarı Yuvarlanmış Saniyeye Çevirir.
      if (seconds <= 0) { // Süre Dolduysa Kontrol Eder.
        _lockoutTimer?.cancel(); // Geri Sayım Timer'ını Durdurur.
        unawaited(_prefs.setLockoutUntil(null)); // Kalıcı Kilitlenme Kaydını Siler.
        _emit( // Kilitlenmenin Bittiği Durumu Yayınlar.
          _s.copyWith(lockoutRemainingSeconds: 0, remainingPinAttempts: AppLockState.maxPinAttempts, error: () => null), // Deneme Haklarını Yenileyip Hatayı Temizler.
        );
        return; // Fonksiyondan Çıkar.
      }
      _emit(_s.copyWith(lockoutRemainingSeconds: seconds, error: () => AppStrings.lockoutWait(seconds))); // Kalan Saniyeyi ve Bekleme Metnini Yayınlar.
    }

    _lockoutTimer?.cancel(); // Varsa Önceki Geri Sayımı İptal Eder.
    tick(); // İlk Güncellemeyi Hemen Yapar.
    if (shake) _emit(_s.copyWith(shakeTick: _s.shakeTick + 1)); // İstenirse Sallama Animasyonunu Tetikler.
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick()); // Saniyede Bir tick Çağıran Periyodik Timer Kurar.
  }

  // ─── Parmak izi ───

  Future<void> startBiometric() async { // Parmak İzi İle Kilit Açmayı Başlatır.
    if (!_s.canUseBiometric || _s.unlocked || _s.sheet == FingerprintSheetStatus.scanning) return; // Biyometri Kullanılamıyorsa Ya Da Tarama Sürüyorsa Çıkar.
    _emit(_s.copyWith(sheet: () => FingerprintSheetStatus.scanning, error: () => null, entered: '')); // Paneli Tarama Durumunda Açar.
    final result = await _biometrics.authenticate(BiometricPurpose.unlock); // Kilit Açma Amacıyla Biyometrik Doğrulama İster.
    if (_disposed || _s.sheet == null) return; // dispose Edildiyse Ya Da Panel Kapandıysa Çıkar.
    if (result == BiometricResult.success) { // Doğrulama Başarılıysa Kontrol Eder.
      _emit(_s.copyWith(biometricFailCount: 0, sheet: () => FingerprintSheetStatus.verified)); // Hata Sayısını Sıfırlayıp Onay Durumunu Gösterir.
      _verifiedTimer = Timer(AppMotion.biometricOkHold, () { // Onay Görselini Kısa Süre Tutan Timer Kurar.
        _emit(_s.copyWith(sheet: () => null)); // Paneli Kapatır.
        _unlock(); // Kilidi Açar.
      });
      return; // Metottan Çıkar.
    }
    final fails = _s.biometricFailCount + 1; // Biyometrik Hata Sayısını Artırır.
    if (fails >= AppLockState.maxBiometricFailures) { // Hata Sınırına Ulaşıldıysa Kontrol Eder.
      unawaited(_prefs.setBiometricSuspended(true)); // Biyometriyi Kalıcı Olarak Askıya Alır.
      _emit( // Askıya Alınmış Durumu Yayınlar.
        _s.copyWith( // Mevcut Durumun Güncellenmiş Kopyasını Oluşturur.
          biometricFailCount: fails, // Yeni Hata Sayısını Ayarlar.
          biometricTemporarilyDisabled: true, // Biyometriyi Geçici Olarak Kapatır.
          sheet: () => FingerprintSheetStatus.lockout, // Paneli Kilitlenme Durumuna Geçirir.
        ),
      );
      return; // Metottan Çıkar.
    }
    _emit(_s.copyWith(biometricFailCount: fails, sheet: () => FingerprintSheetStatus.failed)); // Hata Sayısını Güncelleyip Başarısız Durumunu Gösterir.
  }

  /// Panel kapatma ("PIN kullan" / scrim). Tarama ve onay sırasında kapanmaz.
  bool closeSheet() { // Parmak İzi Panelini Kapatmayı Dener ve Sonucu bool Döndürür.
    final sheet = _s.sheet; // Mevcut Panel Durumunu Alır.
    if (sheet == null) return true; // Panel Zaten Kapalıysa true Döndürür.
    if (sheet == FingerprintSheetStatus.scanning || sheet == FingerprintSheetStatus.verified) return false; // Tarama Ya Da Onay Sırasında Kapatmayı Reddeder.
    _emit(_s.copyWith(sheet: () => null)); // Paneli Kapatır.
    return true; // Kapatmanın Başarılı Olduğunu Döndürür.
  }

  void _unlock() { // Kilidi Açıp İlgili Sayaçları Sıfırlar.
    _lockoutTimer?.cancel(); // Varsa Geri Sayımı Durdurur.
    unawaited(_prefs.setLockoutUntil(null)); // Kilitlenme Kaydını Temizler.
    unawaited(_prefs.setBiometricSuspended(false)); // Biyometri Askısını Kaldırır.
    _emit( // Kilidin Açıldığı Durumu Yayınlar.
      _s.copyWith( // Mevcut Durumun Güncellenmiş Kopyasını Oluşturur.
        unlocked: true, // Kilidin Açıldığını İşaretler.
        entered: '', // Girilen Haneleri Temizler.
        error: () => null, // Hata Metnini Kaldırır.
        remainingPinAttempts: AppLockState.maxPinAttempts, // Deneme Haklarını Yeniler.
        lockoutRemainingSeconds: 0, // Geri Sayımı Sıfırlar.
        biometricFailCount: 0, // Biyometrik Hata Sayısını Sıfırlar.
        biometricTemporarilyDisabled: false, // Biyometriyi Yeniden Kullanılabilir Yapar.
      ),
    );
  }

  void dispose() { // Timer'ları ve ValueNotifier'ı Serbest Bırakır.
    _disposed = true; // dispose Edildiğini İşaretler.
    _evaluateTimer?.cancel(); // Değerlendirme Timer'ını İptal Eder.
    _lockoutTimer?.cancel(); // Geri Sayım Timer'ını İptal Eder.
    _verifiedTimer?.cancel(); // Onay Timer'ını İptal Eder.
    state.dispose(); // Durum ValueNotifier'ını dispose Eder.
  }
}
