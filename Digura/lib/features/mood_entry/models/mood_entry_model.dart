import 'package:flutter/widgets.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/clock.dart';

/// Günde bir kayıt: duygu rengi (zorunlu) + en fazla 140 karakterlik tek
/// cümle (isteğe bağlı). Kaydedildikten sonra düzenlenemez, silinemez.
@immutable
class MoodEntry {
  static const int maxNoteLength = 140;
  static const int lockDays = 30;
  static const int freshDays = 7;

  /// `YYYY-MM-DD` (`dayKey`).
  final String id;

  /// UTC gün başlangıcı (`dateOnly`).
  final DateTime entryDate;
  final Mood mood;
  final String note;

  const MoodEntry({required this.id, required this.entryDate, required this.mood, this.note = ''});

  factory MoodEntry.forDay(DateTime day, Mood mood, {String note = ''}) {
    final date = DateHelpers.dateOnly(day);
    return MoodEntry(id: DateHelpers.dayKey(date), entryDate: date, mood: mood, note: sanitizeNote(note));
  }

  /// Tek cümle kuralı: satır sonları boşluğa döner, baş/son boşluk atılır ve
  /// metin 140 karakterle (grafem) sınırlanır.
  static String sanitizeNote(String raw) {
    final single = raw.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    final chars = single.characters;
    return chars.length > maxNoteLength ? chars.take(maxNoteLength).toString() : single;
  }

  bool get hasNote => note.isNotEmpty;

  /// `entryDate + 30 gün`.
  DateTime get unlockDate => DateHelpers.addDays(entryDate, lockDays);

  bool isUnlocked(DateTime today) => !DateHelpers.dateOnly(today).isBefore(unlockDate);

  int remainingDays(DateTime today) {
    final diff = unlockDate.difference(DateHelpers.dateOnly(today)).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Kilit ilerlemesi (0 → 1).
  double lockProgress(DateTime today) => ((lockDays - remainingDays(today)) / lockDays).clamp(0.0, 1.0);

  /// Açılışının üzerinden 7 gün geçmemiş kapsül.
  bool isRecentlyUnlocked(DateTime today) {
    if (!isUnlocked(today)) return false;
    return DateHelpers.dateOnly(today).difference(unlockDate).inDays < freshDays;
  }

  MoodEntry copyWith({String? id, DateTime? entryDate, Mood? mood, String? note}) {
    return MoodEntry(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      mood: mood ?? this.mood,
      note: note ?? this.note,
    );
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return MoodEntry(
      id: id,
      entryDate: DateHelpers.fromDayKey(id),
      mood: Mood.fromId(json['mood'] as String?) ?? Mood.serene,
      note: sanitizeNote(json['note'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'mood': mood.id, 'note': note};

  @override
  bool operator ==(Object other) =>
      other is MoodEntry && other.id == id && other.entryDate == entryDate && other.mood == mood && other.note == note;

  @override
  int get hashCode => Object.hash(id, entryDate, mood, note);

  /// Not metni bilinçli olarak dışarıda bırakılır (log gizliliği).
  @override
  String toString() => 'MoodEntry($id, ${mood.id})';
}
