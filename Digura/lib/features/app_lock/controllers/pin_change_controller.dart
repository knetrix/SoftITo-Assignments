import 'dart:async'; // Timer İçin Dart'ın async Kütüphanesini import Eder.

import 'package:flutter/foundation.dart'; // ValueNotifier İçin Flutter'ın foundation Kütüphanesini import Eder.

import '../../../core/constants/app_motion.dart'; // PIN Değerlendirme Gecikmesi İçin AppMotion'ı import Eder.
import '../../../core/constants/app_strings.dart'; // Hata Metinleri İçin AppStrings'i import Eder.
import '../../../core/data/app_lock_repository.dart'; // PIN Doğrulama ve Kaydetme İçin AppLockRepository'yi import Eder.
import '../../../core/utils/pin_validator.dart'; // PIN Uzunluğu ve Zayıflık Kontrolü İçin PinValidator'ı import Eder.
import '../models/pin_flow_model.dart'; // PinChangeState ve PinChangeStep'i import Eder.

/// PIN değiştirme: 1/3 mevcut PIN → 2/3 yeni PIN → 3/3 yeni PIN tekrar.
class PinChangeController { // PIN Değiştirme Akışını Yöneten Controller Class'ıdır.
  final AppLockRepository _lock; // PIN İşlemleri İçin Repository'dir.
  final ValueNotifier<PinChangeState> state = ValueNotifier(const PinChangeState()); // Görünümün Dinlediği Akış Durumudur.

  String _current = ''; // Doğrulanan Mevcut PIN'i Geçici Olarak Tutar.
  String _first = ''; // İlk Girilen Yeni PIN'i Geçici Olarak Tutar.
  Timer? _timer; // Değerlendirmeyi Geciktiren Timer'dır.
  bool _disposed = false; // Controller'ın dispose Edilip Edilmediğini Tutar.

  PinChangeController(this._lock); // Repository'yi Alan Constructor'dır.

  PinChangeState get _s => state.value; // Mevcut Durumu Kısaca Döndüren Getter'dır.

  void _emit(PinChangeState next) { // Yeni Durumu Yayınlayan Yardımcı Metottur.
    if (!_disposed) state.value = next; // dispose Edilmemişse Durumu Günceller.
  }

  void inputDigit(String digit) { // Tuş Takımından Gelen Haneyi Ekler.
    if (_s.completed || _s.entered.length >= PinValidator.length) return; // Akış Bittiyse Ya Da PIN Doluysa Çıkar.
    _emit(_s.copyWith(entered: _s.entered + digit, error: () => null)); // Haneyi Ekleyip Hatayı Temizler.
    if (_s.entered.length == PinValidator.length) _timer = Timer(AppMotion.pinEvaluate, _evaluate); // PIN Tamamlandıysa Değerlendirmeyi Planlar.
  }

  void deleteDigit() { // Son Girilen Haneyi Siler.
    if (_s.entered.isEmpty || _timer?.isActive == true) return; // Silinecek Hane Yoksa Ya Da Değerlendirme Bekliyorsa Çıkar.
    _emit(_s.copyWith(entered: _s.entered.substring(0, _s.entered.length - 1))); // Son Haneyi Çıkarılmış Durumu Yayınlar.
  }

  PinChangeState _fail(String message, {PinChangeStep? step}) => // Hata Mesajlı ve Sallamalı Yeni Durum Üretir.
      _s.copyWith(step: step, entered: '', error: () => message, shakeTick: _s.shakeTick + 1); // Haneleri Temizleyip Hatayı ve Sallamayı Ayarlar.

  Future<void> _evaluate() async { // Girilen PIN'i Mevcut Adıma Göre Değerlendirir.
    final value = _s.entered; // Girilen PIN Değerini Alır.
    switch (_s.step) { // Mevcut Adıma Göre Dallanır.
      case PinChangeStep.current: // Mevcut PIN Adımıdır.
        if (!await _lock.verifyPin(value)) { // Mevcut PIN Yanlışsa Kontrol Eder.
          _emit(_fail(AppStrings.currentPinWrong)); // Yanlış Mevcut PIN Hatasını Gösterir.
          return; // Metottan Çıkar.
        }
        _current = value; // Doğrulanan Mevcut PIN'i Saklar.
        _emit(_s.copyWith(step: PinChangeStep.next, entered: '')); // Yeni PIN Adımına Geçer.
      case PinChangeStep.next: // Yeni PIN Adımıdır.
        if (value == _current) { // Yeni PIN Eskisiyle Aynıysa Kontrol Eder.
          _emit(_fail(AppStrings.samePin)); // Aynı PIN Hatasını Gösterir.
        } else if (PinValidator.isWeak(value)) { // Yeni PIN Zayıfsa Kontrol Eder.
          _emit(_fail(AppStrings.weakPin)); // Zayıf PIN Hatasını Gösterir.
        } else { // Yeni PIN Geçerliyse Çalışır.
          _first = value; // Yeni PIN'i Tekrar Kontrolü İçin Saklar.
          _emit(_s.copyWith(step: PinChangeStep.confirm, entered: '')); // Tekrar Girme Adımına Geçer.
        }
      case PinChangeStep.confirm: // Yeni PIN'i Tekrar Girme Adımıdır.
        if (value != _first) { // Tekrar Girilen PIN Eşleşmiyorsa Kontrol Eder.
          _first = ''; // Saklanan Yeni PIN'i Temizler.
          _emit(_fail(AppStrings.pinMismatch, step: PinChangeStep.next)); // Eşleşmeme Hatasıyla Yeni PIN Adımına Döner.
          return; // Metottan Çıkar.
        }
        await _lock.setPin(value); // Yeni PIN'i Kalıcı Olarak Kaydeder.
        _current = ''; // Geçici Mevcut PIN'i Temizler.
        _first = ''; // Geçici Yeni PIN'i Temizler.
        _emit(_s.copyWith(entered: '', completed: true)); // Akışın Tamamlandığını Yayınlar.
    }
  }

  void dispose() { // Timer'ı ve ValueNotifier'ı Serbest Bırakır.
    _disposed = true; // dispose Edildiğini İşaretler.
    _timer?.cancel(); // Bekleyen Değerlendirmeyi İptal Eder.
    state.dispose(); // Durum ValueNotifier'ını dispose Eder.
  }
}
