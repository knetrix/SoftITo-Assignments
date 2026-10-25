import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/data/mock_mood_data.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/widgets/app_scope.dart';
import '../models/settings_model.dart';

/// Ayarlar: tema, 21:00 hatırlatıcı, parmak izi ve örnek veri.
/// Her eylem kullanıcıya gösterilecek bildirim metnini döndürür.
class SettingsController {
  final AppServices _services;

  SettingsController(this._services);

  Listenable get changes =>
      Listenable.merge([_services.prefs.themeMode, _services.prefs.reminderEnabled, _services.lock.biometricEnabled]);

  SettingsModel get model => SettingsModel(
    theme: ThemeOption.of(_services.prefs.themeMode.value),
    reminderEnabled: _services.prefs.reminderEnabled.value,
    biometricEnabled: _services.lock.biometricEnabled.value,
  );

  Future<String> setTheme(ThemeOption option) async {
    await _services.prefs.setThemeMode(option.mode);
    return AppStrings.themeSnack(option.label);
  }

  Future<String> setReminder(bool enabled) async {
    if (!enabled) {
      await _services.reminders.disable();
      await _services.prefs.setReminderEnabled(false);
      return AppStrings.reminderOffSnack;
    }
    final granted = await _services.reminders.enableDaily();
    await _services.prefs.setReminderEnabled(granted);
    return granted ? AppStrings.reminderOnSnack : AppStrings.reminderDeniedSnack;
  }

  /// Açarken önce cihazın sensörüyle doğrulanır.
  Future<String> setBiometric(bool enabled) async {
    if (enabled) {
      final result = await _services.biometrics.authenticate(BiometricPurpose.enroll);
      if (result == BiometricResult.unavailable) return AppStrings.bioUnavailable;
      if (result == BiometricResult.failure) return AppStrings.bioSetupFailed;
    }
    await _services.lock.setBiometricEnabled(enabled);
    return enabled ? AppStrings.bioOnSnack : AppStrings.bioOffSnack;
  }

  /// "Örnek veriye dön": kayıtlar örnek veriyle değişir, PIN 2580 olur.
  Future<String> resetToSampleData() async {
    await _services.moods.resetToMockData();
    await _services.lock.setPin(MockMoodData.demoPin);
    return AppStrings.resetSampleSnack;
  }
}
