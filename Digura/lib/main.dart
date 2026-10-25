import 'package:flutter/material.dart';

import 'app.dart';
import 'core/constants/app_config.dart';
import 'core/data/app_lock_repository.dart';
import 'core/data/mock_mood_data.dart';
import 'core/data/mood_repository.dart';
import 'core/data/preferences_service.dart';
import 'core/services/biometric_service.dart';
import 'core/services/reminder_service.dart';
import 'core/utils/clock.dart';
import 'core/widgets/app_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DiguraApp(services: await bootstrap()));
}

/// Cihaz içi servisleri kurar. Hesap, sunucu ya da ağ isteği yoktur.
Future<AppServices> bootstrap() async {
  const clock = Clock();
  final prefs = await PreferencesService.init();
  final lock = AppLockRepository(const FlutterSecureStore());

  // iOS Anahtar Zinciri uygulama silinse de kalır: yeni kurulumda eski PIN temizlenir.
  if (prefs.isFirstLaunch) {
    await lock.wipe();
    if (AppConfig.demoMode) {
      await prefs.setOnboardingDone(true);
      await lock.setPin(MockMoodData.demoPin);
    }
    await prefs.markInstalled();
  }
  await lock.load();

  return AppServices(
    clock: clock,
    today: TodayNotifier(clock),
    prefs: prefs,
    moods: MoodRepository(prefs, clock, seedMockData: AppConfig.seedMockData),
    lock: lock,
    biometrics: AdaptiveBiometricAuthenticator(),
    reminders: LocalReminderService(clock),
  );
}
