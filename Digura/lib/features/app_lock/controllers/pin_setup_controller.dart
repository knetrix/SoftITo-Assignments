import 'dart:async'; // Timer İçin Dart'ın async Kütüphanesini import Eder.

import 'package:flutter/foundation.dart'; // ValueNotifier İçin Flutter'ın foundation Kütüphanesini import Eder.

import '../../../core/constants/app_motion.dart'; // PIN Değerlendirme Gecikmesi İçin AppMotion'ı import Eder.
import '../../../core/constants/app_strings.dart'; // Hata Metinleri İçin AppStrings'i import Eder.
import '../../../core/data/app_lock_repository.dart'; // PIN ve Biyometri Ayarını Kaydetmek İçin AppLockRepository'yi import Eder.
import '../../../core/services/biometric_service.dart'; // BiometricAuthenticator ve İlgili enum'ları import Eder.
import '../../../core/utils/pin_validator.dart'; // PIN Uzunluğu ve Zayıflık Kontrolü İçin PinValidator'ı import Eder.
import '../models/pin_flow_model.dart'; // PinSetupState ve BiometricSetupStatus'u import Eder.

/// Kurulum 1/2: PIN oluştur ve doğrula. Zayıf PIN'ler reddedilir.
class PinSetupController { // PIN Oluşturma Akışını Yöneten Controller Class'ıdır.
  final AppLockRepository _lock; // PIN'i Kaydetmek İçin Repository'dir.
  final ValueNotifier<PinSetupState> state = ValueNotifier(const PinSetupState()); // Görünümün Dinlediği Kurulum Durumudur.

  String _first = ''; // İlk Girilen PIN'i Geçici Olarak Tutar.
  Timer? _timer; // Değerlendirmeyi Geciktiren Timer'dır.
  bool _disposed = false; // Controller'ın dispose Edilip Edilmediğini Tutar.

  PinSetupController(this._lock); // Repository'yi Alan Constructor'dır.

  PinSetupState get _s => state.value; // Mevcut Durumu Kısaca Döndüren Getter'dır.

  void _emit(PinSetupState next) { // Yeni Durumu Yayınlayan Yardımcı Metottur.
    if (!_disposed) state.value = next; // dispose Edilmemişse Durumu Günceller.
  }

  void inputDigit(String digit) { // Tuş Takımından Gelen Haneyi Ekler.
    if (_s.stage == PinSetupStage.done || _s.entered.length >= PinValidator.length) return; // Kurulum Bittiyse Ya Da PIN Doluysa Çıkar.
    _emit(_s.copyWith(entered: _s.entered + digit, error: () => null)); // Haneyi Ekleyip Hatayı Temizler.
    if (_s.entered.length == PinValidator.length) _timer = Timer(AppMotion.pinEvaluate, _evaluate); // PIN Tamamlandıysa Değerlendirmeyi Planlar.
  }

  void deleteDigit() { // Son Girilen Haneyi Siler.
    if (_s.entered.isEmpty || _timer?.isActive == true) return; // Silinecek Hane Yoksa Ya Da Değerlendirme Bekliyorsa Çıkar.
    _emit(_s.copyWith(entered: _s.entered.substring(0, _s.entered.length - 1))); // Son Haneyi Çıkarılmış Durumu Yayınlar.
  }

  /// "Baştan": doğrulama adımından ilk adıma döner.
  void restart() { // Kurulumu İlk Adıma Sıfırlar.
    _timer?.cancel(); // Bekleyen Değerlendirmeyi İptal Eder.
    _first = ''; // Saklanan İlk PIN'i Temizler.
    _emit(const PinSetupState()); // Varsayılan Başlangıç Durumunu Yayınlar.
  }

  Future<void> _evaluate() async { // Girilen PIN'i Mevcut Aşamaya Göre Değerlendirir.
    final value = _s.entered; // Girilen PIN Değerini Alır.
    if (_s.stage == PinSetupStage.create) { // Oluşturma Aşamasındaysa Kontrol Eder.
      if (PinValidator.isWeak(value)) { // PIN Zayıfsa Kontrol Eder.
        _emit(_s.copyWith(entered: '', error: () => AppStrings.weakPin, shakeTick: _s.shakeTick + 1)); // Zayıf PIN Hatasını Sallamayla Gösterir.
        return; // Metottan Çıkar.
      }
      _first = value; // İlk PIN'i Doğrulama İçin Saklar.
      _emit(_s.copyWith(stage: PinSetupStage.confirm, entered: '')); // Doğrulama Aşamasına Geçer.
      return; // Metottan Çıkar.
    }
    if (value == _first) { // Tekrar Girilen PIN Eşleşiyorsa Kontrol Eder.
      await _lock.setPin(value); // PIN'i Kalıcı Olarak Kaydeder.
      _first = ''; // Geçici PIN'i Temizler.
      _emit(_s.copyWith(stage: PinSetupStage.done, entered: '')); // Kurulumun Tamamlandığını Yayınlar.
      return; // Metottan Çıkar.
    }
    _first = ''; // Eşleşmeme Durumunda Geçici PIN'i Temizler.
    _emit(PinSetupState(error: AppStrings.pinMismatch, shakeTick: _s.shakeTick + 1)); // Eşleşmeme Hatasıyla İlk Aşamaya Döner.
  }

  void dispose() { // Timer'ı ve ValueNotifier'ı Serbest Bırakır.
    _disposed = true; // dispose Edildiğini İşaretler.
    _timer?.cancel(); // Bekleyen Değerlendirmeyi İptal Eder.
    state.dispose(); // Durum ValueNotifier'ını dispose Eder.
  }
}

/// Kurulum 2/2: isteğe bağlı parmak izi.
class BiometricSetupController { // Parmak İzi Kurulumunu Yöneten Controller Class'ıdır.
  final AppLockRepository _lock; // Biyometri Ayarını Kaydetmek İçin Repository'dir.
  final BiometricAuthenticator _biometrics; // Parmak İzi Doğrulamasını Yapan Servistir.
  final ValueNotifier<BiometricSetupStatus> status = ValueNotifier(BiometricSetupStatus.idle); // Görünümün Dinlediği Kurulum Durumudur.
  bool _disposed = false; // Controller'ın dispose Edilip Edilmediğini Tutar.

  BiometricSetupController(this._lock, this._biometrics); // Repository ve Biyometri Servisini Alan Constructor'dır.

  Future<void> enable() async { // Parmak İzini Doğrulayarak Etkinleştirmeyi Dener.
    if (status.value == BiometricSetupStatus.scanning) return; // Tarama Zaten Sürüyorsa Çıkar.
    status.value = BiometricSetupStatus.scanning; // Durumu Taramaya Geçirir.
    final result = await _biometrics.authenticate(BiometricPurpose.enroll); // Kayıt Amacıyla Biyometrik Doğrulama İster.
    if (_disposed) return; // dispose Edildiyse İşlemi Bırakır.
    switch (result) { // Doğrulama Sonucuna Göre Dallanır.
      case BiometricResult.success: // Doğrulama Başarılı Durumudur.
        await _lock.setBiometricEnabled(true); // Biyometriyi Açık Olarak Kaydeder.
        if (!_disposed) status.value = BiometricSetupStatus.enabled; // dispose Edilmemişse Durumu Etkin Yapar.
      case BiometricResult.failure: // Doğrulama Başarısız Durumudur.
        status.value = BiometricSetupStatus.failed; // Durumu Başarısız Yapar.
      case BiometricResult.unavailable: // Cihazda Biyometri Olmama Durumudur.
        status.value = BiometricSetupStatus.unavailable; // Durumu Kullanılamaz Yapar.
    }
  }

  Future<void> skip() => _lock.setBiometricEnabled(false); // Kurulumu Atlayıp Biyometriyi Kapalı Kaydeder.

  void dispose() { // ValueNotifier'ı Serbest Bırakır.
    _disposed = true; // dispose Edildiğini İşaretler.
    status.dispose(); // Durum ValueNotifier'ını dispose Eder.
  }
}
