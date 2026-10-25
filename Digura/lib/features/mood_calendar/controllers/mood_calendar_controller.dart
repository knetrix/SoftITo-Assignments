import 'package:flutter/foundation.dart';

import '../../../core/data/mood_repository.dart';
import '../../../core/utils/clock.dart';
import '../models/mood_calendar_model.dart';

/// Harita sekmesi: Ay / Yıl ısı haritası ve kapsül açma kuralları.
class MoodCalendarController {
  final MoodRepository _repository;
  final ValueListenable<DateTime> _today;

  late final ValueNotifier<MoodCalendarState> state;

  MoodCalendarController(this._repository, this._today) {
    state = ValueNotifier(
      MoodCalendarState(mode: CalendarMode.month, visibleMonth: DateHelpers.monthStart(_today.value)),
    );
  }

  Listenable get changes => Listenable.merge([state, _repository.entries, _repository.openedCapsules, _today]);

  DateTime get today => _today.value;

  DateTime get _minMonth => DateTime.utc(_repository.earliestYear, 1, 1);

  bool get canGoPrevious => state.value.visibleMonth.isAfter(_minMonth);

  bool get canGoNext => !DateHelpers.shiftMonth(state.value.visibleMonth, 1).isAfter(today);

  void setMode(CalendarMode mode) => state.value = state.value.copyWith(mode: mode);

  void previousMonth() {
    if (canGoPrevious) {
      state.value = state.value.copyWith(visibleMonth: DateHelpers.shiftMonth(state.value.visibleMonth, -1));
    }
  }

  void nextMonth() {
    if (canGoNext) {
      state.value = state.value.copyWith(visibleMonth: DateHelpers.shiftMonth(state.value.visibleMonth, 1));
    }
  }

  /// Yıl görünümünde bir mini aya dokunma: o ayın Ay görünümü açılır.
  void openMonth(int month) =>
      state.value = MoodCalendarState(mode: CalendarMode.month, visibleMonth: DateTime.utc(today.year, month, 1));

  int countForMonth(DateTime month) => _repository.entriesForMonth(month.year, month.month).length;

  int countForYear(int year) => _repository.countForYear(year);

  /// Ay ısı haritası hücreleri (Pazartesi başlangıçlı; baştaki boşluklar `null`).
  List<DayCellModel?> monthCells(DateTime month) {
    final cells = <DayCellModel?>[for (var i = 0; i < DateHelpers.leadingBlanks(month.year, month.month); i++) null];
    final days = DateHelpers.daysInMonth(month.year, month.month);
    for (var d = 1; d <= days; d++) {
      final date = DateTime.utc(month.year, month.month, d);
      final entry = _repository.entryFor(date);
      if (entry == null) {
        cells.add(DayCellModel(day: d, isToday: date == today, isFuture: date.isAfter(today)));
        continue;
      }
      final unlocked = entry.isUnlocked(today);
      cells.add(
        DayCellModel(
          day: d,
          entryId: entry.id,
          mood: entry.mood,
          isToday: date == today,
          isLocked: !unlocked,
          isFresh: entry.isRecentlyUnlocked(today) && !_repository.isOpened(entry.id),
        ),
      );
    }
    return cells;
  }

  /// Yıl görünümü: 12 mini ay (3 × 4).
  List<MiniMonthModel> yearMonths(int year) => [
    for (var m = 1; m <= 12; m++)
      () {
        final month = DateTime.utc(year, m, 1);
        final days = DateHelpers.daysInMonth(year, m);
        final moods = [for (var d = 1; d <= days; d++) _repository.entryFor(DateTime.utc(year, m, d))?.mood];
        return MiniMonthModel(
          month: month,
          count: moods.whereType<Object>().length,
          isFuture: month.isAfter(today),
          leadingBlanks: DateHelpers.leadingBlanks(year, m),
          days: moods,
        );
      }(),
  ];

  /// Bir güne dokunma: kilitliyse not içermeyen [LockedCapsule]; açılmışsa
  /// notlu [OpenedCapsule]. İlk açılışta kapsül "açıldı" olarak işaretlenir.
  Future<CapsuleDetail?> openDay(String id) async {
    final entry = _repository.getByDayKey(id);
    if (entry == null) return null;
    if (!entry.isUnlocked(today)) {
      return LockedCapsule(
        id: entry.id,
        mood: entry.mood,
        entryDate: entry.entryDate,
        unlockDate: entry.unlockDate,
        remainingDays: entry.remainingDays(today),
        progress: entry.lockProgress(today),
      );
    }
    final first = !_repository.isOpened(entry.id);
    if (first) await _repository.markOpened(entry.id);
    return OpenedCapsule(
      id: entry.id,
      mood: entry.mood,
      entryDate: entry.entryDate,
      unlockDate: entry.unlockDate,
      note: entry.note,
      firstUnseal: first,
    );
  }

  void dispose() => state.dispose();
}
