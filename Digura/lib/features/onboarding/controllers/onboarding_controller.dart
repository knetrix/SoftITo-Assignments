import 'package:flutter/foundation.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/preferences_service.dart';
import '../../../core/services/reminder_service.dart';
import '../models/onboarding_model.dart';

class OnboardingController {
  final PreferencesService _prefs;
  final ReminderService _reminders;

  late final ValueNotifier<OnboardingState> state;

  /// İlk açılış girişi (420 ms) yalnızca karşılama ilk kez gösterilirken oynar.
  late final bool playIntro;

  OnboardingController(this._prefs, this._reminders) {
    final step = _prefs.onboardingStep.clamp(0, OnboardingState.pageCount - 1);
    playIntro = step == 0;
    state = ValueNotifier(OnboardingState(page: step));
  }

  void setPage(int page) {
    final clamped = page.clamp(0, OnboardingState.pageCount - 1);
    if (clamped == state.value.page) return;
    state.value = state.value.copyWith(page: clamped);
    _prefs.setOnboardingStep(clamped);
  }

  void selectMood(Mood mood) => state.value = state.value.copyWith(previewMood: mood);

  void setReminder(bool on) => state.value = state.value.copyWith(reminder: on);

  /// Karşılama bitti: bir daha gösterilmez; hatırlatıcı seçildiyse izin istenir.
  Future<void> finish() async {
    await _prefs.setOnboardingDone(true);
    if (state.value.reminder) {
      final granted = await _reminders.enableDaily();
      await _prefs.setReminderEnabled(granted);
    }
  }

  void dispose() => state.dispose();
}
