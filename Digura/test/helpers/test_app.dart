import 'package:digura/core/data/app_lock_repository.dart';
import 'package:digura/core/data/mood_repository.dart';
import 'package:digura/core/data/preferences_service.dart';
import 'package:digura/core/services/biometric_service.dart';
import 'package:digura/core/services/reminder_service.dart';
import 'package:digura/core/theme/app_theme.dart';
import 'package:digura/core/utils/clock.dart';
import 'package:digura/core/widgets/app_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prototiplerdeki "bugün": 25 Ekim 2026, Pazar.
final DateTime kToday = DateTime(2026, 10, 25, 12);

/// Sırayla verilen sonuçları döndüren sahte sensör.
class FakeBiometricAuthenticator implements BiometricAuthenticator {
  final List<BiometricResult> results;
  int calls = 0;
  int pinUnlocks = 0;

  FakeBiometricAuthenticator([List<BiometricResult>? results]) : results = results ?? [BiometricResult.success];

  @override
  Future<BiometricResult> authenticate(BiometricPurpose purpose) async {
    final r = results[calls < results.length ? calls : results.length - 1];
    calls++;
    return r;
  }

  @override
  void onPinUnlocked({required bool hadBiometricFailures}) => pinUnlocks++;
}

Future<AppServices> buildTestServices({
  Clock? clock,
  bool seed = true,
  String? pin,
  bool biometric = false,
  BiometricAuthenticator? biometrics,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final c = clock ?? Clock.fixed(kToday);
  final p = await PreferencesService.init();
  final lock = AppLockRepository(InMemorySecureStore());
  if (pin != null) await lock.setPin(pin);
  if (biometric) await lock.setBiometricEnabled(true);
  await lock.load();
  return AppServices(
    clock: c,
    today: TodayNotifier(c, autoRefresh: false),
    prefs: p,
    moods: MoodRepository(p, c, seedMockData: seed),
    lock: lock,
    biometrics: biometrics ?? FakeBiometricAuthenticator(),
    reminders: NoopReminderService(),
  );
}

/// Ekranı tema, kapsam ve isteğe bağlı "Hareketi azalt" ile sarmalar.
Widget wrapApp(AppServices services, Widget child, {bool reduceMotion = false, ThemeMode mode = ThemeMode.light}) {
  return AppScope(
    services: services,
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      // Sekme görünümleri uygulamada HomeShell'in Scaffold'u içinde yaşar.
      home: Scaffold(body: child),
    ),
  );
}

/// iPhone 15 Pro mantıksal boyutu (390 × 844).
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}
