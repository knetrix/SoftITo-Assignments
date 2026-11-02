import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import 'app.dart'; // DiguraApp Kök Widget'ını import Eder.
import 'core/constants/app_config.dart'; // Derleme Zamanı AppConfig Bayraklarını import Eder.
import 'core/data/app_lock_repository.dart'; // AppLockRepository ve FlutterSecureStore Class'larını import Eder.
import 'core/data/mock_mood_data.dart'; // MockMoodData Örnek Veri Class'ını import Eder.
import 'core/data/mood_repository.dart'; // MoodRepository Veri Erişim Class'ını import Eder.
import 'core/data/preferences_service.dart'; // PreferencesService Tercih Class'ını import Eder.
import 'core/services/biometric_service.dart'; // AdaptiveBiometricAuthenticator Class'ını import Eder.
import 'core/services/reminder_service.dart'; // LocalReminderService Class'ını import Eder.
import 'core/utils/clock.dart'; // Clock ve TodayNotifier Class'larını import Eder.
import 'core/widgets/app_scope.dart'; // AppServices Paketini Sağlayan AppScope Dosyasını import Eder.

Future<void> main() async { // Uygulamanın async Entry Point'idir.
  WidgetsFlutterBinding.ensureInitialized(); // Plugin Çağrılarından Önce Flutter Binding'ini Başlatır.
  runApp(DiguraApp(services: await bootstrap())); // Servisleri Kurup DiguraApp'i Çalıştırır.
}

/// Cihaz içi servisleri kurar. Hesap, sunucu ya da ağ isteği yoktur.
Future<AppServices> bootstrap() async { // Tüm Servisleri Oluşturan Composition Root Fonksiyonudur.
  const clock = Clock(); // Gerçek Zamanı Okuyan const Clock Nesnesini Oluşturur.
  final prefs = await PreferencesService.init(); // SharedPreferences Tabanlı Tercih Servisini Başlatır.
  final lock = AppLockRepository(const FlutterSecureStore()); // Güvenli Depo İle Kilit Repository'sini Oluşturur.

  // iOS Anahtar Zinciri uygulama silinse de kalır: yeni kurulumda eski PIN temizlenir.
  if (prefs.isFirstLaunch) { // Uygulama Bu Kurulumda İlk Kez Açılıyorsa Çalışır.
    await lock.wipe(); // Güvenli Depodaki Eski PIN ve Ayarları Siler.
    if (AppConfig.demoMode) { // Demo Modu Açıksa Kurulumu Atlar.
      await prefs.setOnboardingDone(true); // Karşılama Akışını Tamamlanmış Olarak İşaretler.
      await lock.setPin(MockMoodData.demoPin); // Demo PIN'ini Kilit PIN'i Olarak Kaydeder.
    }
    await prefs.markInstalled(); // Kurulumun Yapıldığını Tercihlere Yazar.
  }
  await lock.load(); // PIN ve Biyometrik Durumunu Depodan Yükler.

  return AppServices( // Tüm Servisleri Tek Bir AppServices Paketinde Döndürür.
    clock: clock, // Zaman Kaynağı Olarak clock'u Verir.
    today: TodayNotifier(clock), // Bugünün Tarihini Yayınlayan Notifier'ı Oluşturur.
    prefs: prefs, // Tercih Servisini Pakete Ekler.
    moods: MoodRepository(prefs, clock, seedMockData: AppConfig.seedMockData), // Kayıt Repository'sini Örnek Veri Bayrağıyla Oluşturur.
    lock: lock, // Kilit Repository'sini Pakete Ekler.
    biometrics: AdaptiveBiometricAuthenticator(), // Cihaza Uyumlu Biyometrik Doğrulayıcıyı Oluşturur.
    reminders: LocalReminderService(clock), // Yerel Bildirim Hatırlatıcı Servisini Oluşturur.
  );
}
