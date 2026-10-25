import 'package:flutter/widgets.dart';

import '../data/app_lock_repository.dart';
import '../data/mood_repository.dart';
import '../data/preferences_service.dart';
import '../services/biometric_service.dart';
import '../services/reminder_service.dart';
import '../utils/clock.dart';

/// Uygulama genelindeki tekil servisler. Durum yönetimi paketi yerine
/// çekirdek `InheritedWidget` ile ağaca verilir; testlerde sahteleri geçilir.
class AppServices {
  final Clock clock;
  final TodayNotifier today;
  final PreferencesService prefs;
  final MoodRepository moods;
  final AppLockRepository lock;
  final BiometricAuthenticator biometrics;
  final ReminderService reminders;

  AppServices({
    required this.clock,
    required this.today,
    required this.prefs,
    required this.moods,
    required this.lock,
    required this.biometrics,
    required this.reminders,
  });

  void dispose() {
    today.dispose();
    moods.dispose();
    lock.dispose();
    prefs.dispose();
  }
}

class AppScope extends InheritedWidget {
  final AppServices services;

  const AppScope({super.key, required this.services, required super.child});

  static AppServices of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope bulunamadı');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
