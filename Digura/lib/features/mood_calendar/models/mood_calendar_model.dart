import 'package:flutter/foundation.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/clock.dart';

enum CalendarMode { month, year }

/// Harita sekmesinin görünüm durumu.
@immutable
class MoodCalendarState {
  final CalendarMode mode;

  /// Ay görünümünde gösterilen ayın ilk günü (UTC).
  final DateTime visibleMonth;

  const MoodCalendarState({required this.mode, required this.visibleMonth});

  MoodCalendarState copyWith({CalendarMode? mode, DateTime? visibleMonth}) =>
      MoodCalendarState(mode: mode ?? this.mode, visibleMonth: visibleMonth ?? this.visibleMonth);

  factory MoodCalendarState.fromJson(Map<String, dynamic> json) => MoodCalendarState(
    mode: json['mode'] == CalendarMode.year.name ? CalendarMode.year : CalendarMode.month,
    visibleMonth: DateHelpers.fromDayKey(json['month'] as String),
  );

  Map<String, dynamic> toJson() => {'mode': mode.name, 'month': DateHelpers.dayKey(visibleMonth)};

  @override
  bool operator ==(Object other) =>
      other is MoodCalendarState && other.mode == mode && other.visibleMonth == visibleMonth;

  @override
  int get hashCode => Object.hash(mode, visibleMonth);
}

/// Ay ısı haritasındaki tek gün. Not metni bilinçli olarak taşınmaz.
@immutable
class DayCellModel {
  final int day;
  final String? entryId;
  final Mood? mood;
  final bool isToday;
  final bool isFuture;
  final bool isLocked;
  final bool isFresh;

  const DayCellModel({
    required this.day,
    this.entryId,
    this.mood,
    this.isToday = false,
    this.isFuture = false,
    this.isLocked = false,
    this.isFresh = false,
  });

  bool get hasEntry => mood != null;

  @override
  bool operator ==(Object other) =>
      other is DayCellModel &&
      other.day == day &&
      other.entryId == entryId &&
      other.mood == mood &&
      other.isToday == isToday &&
      other.isFuture == isFuture &&
      other.isLocked == isLocked &&
      other.isFresh == isFresh;

  @override
  int get hashCode => Object.hash(day, entryId, mood, isToday, isFuture, isLocked, isFresh);
}

/// Yıl görünümündeki mini ay kartı.
@immutable
class MiniMonthModel {
  final DateTime month;
  final int count;
  final bool isFuture;
  final int leadingBlanks;

  /// Ayın her günü için duygu (kayıt yoksa `null`).
  final List<Mood?> days;

  const MiniMonthModel({
    required this.month,
    required this.count,
    required this.isFuture,
    required this.leadingBlanks,
    required this.days,
  });
}

/// Kapsül Detay Modalı içeriği.
///
/// Kilitli kapsül sınıfı not alanı **içermez**; böylece kilitli metin widget
/// katmanına hiçbir yoldan ulaşamaz.
@immutable
sealed class CapsuleDetail {
  final String id;
  final Mood mood;
  final DateTime entryDate;
  final DateTime unlockDate;

  const CapsuleDetail({required this.id, required this.mood, required this.entryDate, required this.unlockDate});
}

final class LockedCapsule extends CapsuleDetail {
  final int remainingDays;
  final double progress;

  const LockedCapsule({
    required super.id,
    required super.mood,
    required super.entryDate,
    required super.unlockDate,
    required this.remainingDays,
    required this.progress,
  });
}

final class OpenedCapsule extends CapsuleDetail {
  final String note;

  /// İlk açılış anı (`CircleReveal`) oynatılsın mı?
  final bool firstUnseal;

  const OpenedCapsule({
    required super.id,
    required super.mood,
    required super.entryDate,
    required super.unlockDate,
    required this.note,
    required this.firstUnseal,
  });
}
