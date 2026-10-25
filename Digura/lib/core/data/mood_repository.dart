import 'package:flutter/foundation.dart';

import '../../features/mood_entry/models/mood_entry_model.dart';
import '../constants/app_colors.dart';
import '../utils/clock.dart';
import 'mock_mood_data.dart';
import 'preferences_service.dart';

/// Günlük kayıtlar için tek veri erişim noktası.
///
/// Günde yalnızca bir kayıt yapılır; kayıtlar düzenlenemez ve silinemez
/// (yalnızca "Her şeyi sil" ve "Örnek veriye dön" toplu işlemleri hariç).
class MoodRepository {
  final PreferencesService _prefs;
  final Clock _clock;

  final ValueNotifier<Map<String, MoodEntry>> entries;

  /// Açılış anı (`CircleReveal`) oynatılmış kapsül kimlikleri.
  final ValueNotifier<Set<String>> openedCapsules;

  MoodRepository(this._prefs, this._clock, {bool seedMockData = true})
    : entries = ValueNotifier(const {}),
      openedCapsules = ValueNotifier(const {}) {
    if (!_prefs.hasStoredEntries && seedMockData) {
      entries.value = Map.unmodifiable(MockMoodData.generate(_clock.today()));
      _persist();
    } else {
      entries.value = Map.unmodifiable({
        for (final json in _prefs.readEntries()) (json['id'] as String): MoodEntry.fromJson(json),
      });
    }
    openedCapsules.value = Set.unmodifiable(_prefs.openedCapsules);
  }

  MoodEntry? getByDayKey(String dayKey) => entries.value[dayKey];

  MoodEntry? entryFor(DateTime day) => entries.value[DateHelpers.dayKey(day)];

  /// Günde yalnızca bir kayıt; mevcut kaydın üzerine yazılmaz.
  Future<bool> addEntry(MoodEntry entry) async {
    if (entries.value.containsKey(entry.id)) return false;
    final clean = entry.copyWith(note: MoodEntry.sanitizeNote(entry.note));
    entries.value = Map.unmodifiable({...entries.value, clean.id: clean});
    await _persist();
    return true;
  }

  Future<bool> saveToday(Mood mood, String note) => addEntry(MoodEntry.forDay(_clock.today(), mood, note: note));

  List<MoodEntry> entriesForMonth(int year, int month) =>
      entries.value.values.where((e) => e.entryDate.year == year && e.entryDate.month == month).toList(growable: false);

  int countForYear(int year) => entries.value.values.where((e) => e.entryDate.year == year).length;

  /// Kaydı olan en eski yıl (yoksa bugünün yılı).
  int get earliestYear {
    var year = _clock.today().year;
    for (final e in entries.value.values) {
      if (e.entryDate.year < year) year = e.entryDate.year;
    }
    return year;
  }

  bool isOpened(String id) => openedCapsules.value.contains(id);

  Future<void> markOpened(String id) async {
    if (isOpened(id)) return;
    openedCapsules.value = Set.unmodifiable({...openedCapsules.value, id});
    await _prefs.setOpenedCapsules(openedCapsules.value);
  }

  /// Ayarlar › "Örnek veriye dön".
  Future<void> resetToMockData() async {
    entries.value = Map.unmodifiable(MockMoodData.generate(_clock.today()));
    openedCapsules.value = const {};
    await _prefs.setOpenedCapsules(const {});
    await _persist();
  }

  /// "Her şeyi sil ve sıfırla" sonrası bellek durumunu boşaltır.
  void clearInMemory() {
    entries.value = const {};
    openedCapsules.value = const {};
  }

  Future<void> _persist() {
    final list = entries.value.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    return _prefs.writeEntries([for (final e in list) e.toJson()]);
  }

  void dispose() {
    entries.dispose();
    openedCapsules.dispose();
  }
}
