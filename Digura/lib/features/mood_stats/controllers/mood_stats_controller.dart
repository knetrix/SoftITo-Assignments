import 'package:flutter/foundation.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/mood_repository.dart';
import '../../../core/utils/clock.dart';
import '../models/mood_stats_model.dart';

/// İstatistik sekmesi: seçilen ayın duygu dağılımı (yalnızca renkler).
class MoodStatsController {
  final MoodRepository _repository;
  final ValueListenable<DateTime> _today;

  late final ValueNotifier<DateTime> visibleMonth;

  MoodStatsController(this._repository, this._today) {
    visibleMonth = ValueNotifier(DateHelpers.monthStart(_today.value));
  }

  Listenable get changes => Listenable.merge([visibleMonth, _repository.entries, _today]);

  bool get canGoPrevious => visibleMonth.value.isAfter(DateTime.utc(_repository.earliestYear, 1, 1));

  bool get canGoNext => !DateHelpers.shiftMonth(visibleMonth.value, 1).isAfter(_today.value);

  void previousMonth() {
    if (canGoPrevious) visibleMonth.value = DateHelpers.shiftMonth(visibleMonth.value, -1);
  }

  void nextMonth() {
    if (canGoNext) visibleMonth.value = DateHelpers.shiftMonth(visibleMonth.value, 1);
  }

  MoodStatsModel get stats {
    final month = visibleMonth.value;
    final counts = <Mood, int>{};
    for (final entry in _repository.entriesForMonth(month.year, month.month)) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }
    return MoodStatsModel.fromCounts(month, counts);
  }

  void dispose() => visibleMonth.dispose();
}
