import 'package:flutter/foundation.dart'; // ValueNotifier Gibi Foundation Class'larını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood Enum'unu import Eder.
import '../../../core/data/preferences_service.dart'; // PreferencesService Class'ını import Eder.
import '../../../core/services/reminder_service.dart'; // ReminderService Arayüzünü import Eder.
import '../models/onboarding_model.dart'; // OnboardingState Modelini import Eder.

class OnboardingController { // Karşılama Akışının Durumunu Yöneten Controller'dır.
  final PreferencesService _prefs; // Adım Ve Tamamlanma Bilgisini Saklayan Servistir.
  final ReminderService _reminders; // Günlük Hatırlatıcıyı Açan Servistir.

  late final ValueNotifier<OnboardingState> state; // Karşılama Durumunu Yayınlayan ValueNotifier'dır.

  /// İlk açılış girişi (420 ms) yalnızca karşılama ilk kez gösterilirken oynar.
  late final bool playIntro; // Giriş Animasyonunun Oynatılıp Oynatılmayacağını Belirtir.

  OnboardingController(this._prefs, this._reminders) { // Servisleri Alan Ve Başlangıç Durumunu Kuran Constructor'dır.
    final step = _prefs.onboardingStep.clamp(0, OnboardingState.pageCount - 1); // Kayıtlı Adımı Geçerli Aralığa Sınırlar.
    playIntro = step == 0; // İlk Adımdaysa Giriş Animasyonunu Etkinleştirir.
    state = ValueNotifier(OnboardingState(page: step)); // Kayıtlı Adımla Başlangıç State'ini Oluşturur.
  }

  void setPage(int page) { // Etkin Sayfayı Günceller Ve Kaydeder.
    final clamped = page.clamp(0, OnboardingState.pageCount - 1); // Sayfa Numarasını Geçerli Aralığa Sınırlar.
    if (clamped == state.value.page) return; // Sayfa Değişmediyse Hiçbir Şey Yapmaz.
    state.value = state.value.copyWith(page: clamped); // Yeni Sayfayla State'i Günceller.
    _prefs.setOnboardingStep(clamped); // Kalınan Adımı Kalıcı Olarak Kaydeder.
  }

  void selectMood(Mood mood) => state.value = state.value.copyWith(previewMood: mood); // Önizlemede Seçilen Duyguyu State'e Yazar.

  void setReminder(bool on) => state.value = state.value.copyWith(reminder: on); // Hatırlatıcı Anahtarının Değerini State'e Yazar.

  /// Karşılama bitti: bir daha gösterilmez; hatırlatıcı seçildiyse izin istenir.
  Future<void> finish() async { // Karşılamayı Tamamlayan async Metottur.
    await _prefs.setOnboardingDone(true); // Karşılamanın Tamamlandığını Kaydeder.
    if (state.value.reminder) { // Hatırlatıcı Seçildiyse Bloğu Çalıştırır.
      final granted = await _reminders.enableDaily(); // Günlük Hatırlatıcıyı Açar Ve İzin Sonucunu Alır.
      await _prefs.setReminderEnabled(granted); // İzin Sonucunu Hatırlatıcı Ayarı Olarak Kaydeder.
    }
  }

  void dispose() => state.dispose(); // ValueNotifier'ı Serbest Bırakır.
}
