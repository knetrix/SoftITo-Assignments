import 'package:flutter/foundation.dart'; // Listenable Tipini Sağlayan Flutter Foundation Kütüphanesini import Eder.

import '../../../core/constants/app_strings.dart'; // Bildirim Metinleri İçin AppStrings'i import Eder.
import '../../../core/data/mock_mood_data.dart'; // Demo PIN'i İçeren MockMoodData'yı import Eder.
import '../../../core/services/biometric_service.dart'; // BiometricPurpose ve BiometricResult enum'larını import Eder.
import '../../../core/widgets/app_scope.dart'; // AppServices Servis Paketini import Eder.
import '../models/settings_model.dart'; // SettingsModel ve ThemeOption'ı import Eder.

/// Ayarlar: tema, 21:00 hatırlatıcı, parmak izi ve örnek veri.
/// Her eylem kullanıcıya gösterilecek bildirim metnini döndürür.
class SettingsController { // Ayarlar Ekranının İş Mantığını Yöneten Controller Class'ıdır.
  final AppServices _services; // Uygulama Servislerine Erişim Sağlayan Pakettir.

  SettingsController(this._services); // AppServices'i Alan Constructor'dır.

  Listenable get changes => // Ayar Değişikliklerini Tek Listenable'da Birleştiren Getter'dır.
      Listenable.merge([_services.prefs.themeMode, _services.prefs.reminderEnabled, _services.lock.biometricEnabled]); // Tema, Hatırlatıcı ve Biyometri Notifier'larını Birleştirir.

  SettingsModel get model => SettingsModel( // Güncel Ayarların Anlık Görüntüsünü Döndüren Getter'dır.
    theme: ThemeOption.of(_services.prefs.themeMode.value), // Kayıtlı ThemeMode'u ThemeOption'a Çevirir.
    reminderEnabled: _services.prefs.reminderEnabled.value, // Hatırlatıcı Durumunu Okur.
    biometricEnabled: _services.lock.biometricEnabled.value, // Biyometrik Kilit Durumunu Okur.
  );

  Future<String> setTheme(ThemeOption option) async { // Temayı Değiştirip Bildirim Metni Döndüren async Metottur.
    await _services.prefs.setThemeMode(option.mode); // Seçilen ThemeMode'u Kaydeder.
    return AppStrings.themeSnack(option.label); // Tema Değişti Bildirim Metnini Döndürür.
  }

  Future<String> setReminder(bool enabled) async { // Günlük Hatırlatıcıyı Açıp Kapatan async Metottur.
    if (!enabled) { // Hatırlatıcı Kapatılıyorsa Kontrol Eder.
      await _services.reminders.disable(); // Planlanmış Hatırlatıcıyı İptal Eder.
      await _services.prefs.setReminderEnabled(false); // Kapalı Durumunu Kaydeder.
      return AppStrings.reminderOffSnack; // Kapatıldı Bildirim Metnini Döndürür.
    }
    final granted = await _services.reminders.enableDaily(); // Günlük Hatırlatıcıyı Kurar ve İzin Sonucunu Alır.
    await _services.prefs.setReminderEnabled(granted); // İzin Verildiyse Açık Durumunu Kaydeder.
    return granted ? AppStrings.reminderOnSnack : AppStrings.reminderDeniedSnack; // İzin Sonucuna Göre Bildirim Metni Döndürür.
  }

  /// Açarken önce cihazın sensörüyle doğrulanır.
  Future<String> setBiometric(bool enabled) async { // Biyometrik Kilidi Açıp Kapatan async Metottur.
    if (enabled) { // Açılıyorsa Önce Doğrulama Yapar.
      final result = await _services.biometrics.authenticate(BiometricPurpose.enroll); // Kayıt Amaçlı Biyometrik Doğrulama İster.
      if (result == BiometricResult.unavailable) return AppStrings.bioUnavailable; // Sensör Yoksa Kullanılamıyor Metnini Döndürür.
      if (result == BiometricResult.failure) return AppStrings.bioSetupFailed; // Doğrulama Başarısızsa Hata Metnini Döndürür.
    }
    await _services.lock.setBiometricEnabled(enabled); // Biyometrik Kilit Tercihini Kaydeder.
    return enabled ? AppStrings.bioOnSnack : AppStrings.bioOffSnack; // Duruma Göre Bildirim Metni Döndürür.
  }

  /// "Örnek veriye dön": kayıtlar örnek veriyle değişir, PIN 2580 olur.
  Future<String> resetToSampleData() async { // Kayıtları Örnek Veriye Sıfırlayan async Metottur.
    await _services.moods.resetToMockData(); // Tüm Kayıtları Örnek Veriyle Değiştirir.
    await _services.lock.setPin(MockMoodData.demoPin); // PIN'i Demo PIN'e Ayarlar.
    return AppStrings.resetSampleSnack; // Sıfırlandı Bildirim Metnini Döndürür.
  }
}
