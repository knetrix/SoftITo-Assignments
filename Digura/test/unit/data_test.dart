import 'package:digura/core/constants/app_colors.dart';
import 'package:digura/core/data/mock_mood_data.dart';
import 'package:digura/core/data/mood_repository.dart';
import 'package:digura/core/data/preferences_service.dart';
import 'package:digura/core/utils/clock.dart';
import 'package:digura/core/utils/pin_validator.dart';
import 'package:digura/features/mood_stats/models/mood_stats_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

void main() {
  group('PinValidator', () {
    test('tekrarlayan ve sıralı PIN zayıftır', () {
      for (final pin in ['0000', '1111', '9999', '1234', '2345', '6789', '9876', '3210', '0123']) {
        expect(PinValidator.isWeak(pin), isTrue, reason: pin);
      }
    });

    test('güçlü PIN kabul edilir', () {
      for (final pin in ['2580', '1357', '9024', '1123', '4317']) {
        expect(PinValidator.isWeak(pin), isFalse, reason: pin);
      }
    });

    test('biçim: tam 4 rakam', () {
      expect(PinValidator.isWellFormed('2580'), isTrue);
      expect(PinValidator.isWellFormed('258'), isFalse);
      expect(PinValidator.isWellFormed('25a0'), isFalse);
    });
  });

  group('MockMoodData · prototip ile birebir', () {
    final data = MockMoodData.generate(kToday);
    final today = DateHelpers.dateOnly(kToday);

    test('1 Ağustos – 24 Ekim 2026 arası 69 kayıt (26 / 26 / 17)', () {
      expect(data.length, 69);
      int month(int m) => data.values.where((e) => e.entryDate.month == m).length;
      expect([month(8), month(9), month(10)], [26, 26, 17]);
      expect(data.keys.reduce((a, b) => a.compareTo(b) < 0 ? a : b), '2026-08-02');
      expect(data.containsKey('2026-10-25'), isFalse);
    });

    test('ilk ve son kayıtlar prototip üreteciyle aynı', () {
      expect(data['2026-08-02']!.mood, Mood.serene);
      expect(data['2026-08-02']!.note, MockMoodData.notes[Mood.serene]![3]);
      expect(data['2026-08-04']!.mood, Mood.tired);
      expect(data['2026-10-22']!.mood, Mood.angryStressed);
      expect(data['2026-10-24']!.note, MockMoodData.notes[Mood.joyful]![4]);
    });

    test('Ekim dağılımı', () {
      final counts = <Mood, int>{};
      for (final e in data.values.where((e) => e.entryDate.month == 10)) {
        counts[e.mood] = (counts[e.mood] ?? 0) + 1;
      }
      expect(counts, {Mood.angryStressed: 2, Mood.calmSad: 3, Mood.serene: 4, Mood.tired: 4, Mood.joyful: 4});
    });

    test('açılmış, yeni açılmış, notsuz ve kilitli kapsüller bulunur', () {
      final unlocked = data.values.where((e) => e.isUnlocked(today)).toList();
      final fresh = data.values.where((e) => e.isRecentlyUnlocked(today)).map((e) => e.id).toList()..sort();
      expect(unlocked.length, 48);
      expect(fresh, [for (var d = 19; d <= 25; d++) '2026-09-$d']);
      expect(data.values.where((e) => !e.isUnlocked(today)).length, 21);
      expect(data.values.where((e) => e.note.isEmpty).map((e) => e.id).toList()..sort(), [
        '2026-08-04', '2026-08-15', '2026-08-30', '2026-08-31', '2026-09-03', '2026-09-26',
        '2026-09-27', '2026-09-28', '2026-10-09', '2026-10-12', '2026-10-18', //
      ]);
    });

    test('deterministiktir', () {
      expect(MockMoodData.generate(kToday), data);
      expect(MockMoodData.demoPin, '2580');
    });
  });

  group('MoodRepository', () {
    late PreferencesService prefs;
    final clock = Clock.fixed(kToday);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await PreferencesService.init();
    });

    test('ilk açılışta örnek veri yüklenir ve kalıcı yazılır', () {
      final repo = MoodRepository(prefs, clock);
      expect(repo.entries.value.length, 69);
      expect(prefs.hasStoredEntries, isTrue);
      expect(MoodRepository(prefs, clock).entries.value.length, 69);
    });

    test('örnek veri kapalıyken boş başlar', () {
      expect(MoodRepository(prefs, clock, seedMockData: false).entries.value, isEmpty);
    });

    test('günde yalnızca bir kayıt; üzerine yazılamaz', () async {
      final repo = MoodRepository(prefs, clock, seedMockData: false);
      expect(await repo.saveToday(Mood.joyful, 'ilk\nsatır'), isTrue);
      expect(await repo.saveToday(Mood.tired, 'ikinci'), isFalse);
      final saved = repo.entryFor(clock.today())!;
      expect(saved.mood, Mood.joyful);
      expect(saved.note, 'ilk satır');
    });

    test('açılış anı işaretleri ve örnek veriye dönüş', () async {
      final repo = MoodRepository(prefs, clock);
      await repo.markOpened('2026-09-19');
      expect(repo.isOpened('2026-09-19'), isTrue);
      expect(MoodRepository(prefs, clock).isOpened('2026-09-19'), isTrue);
      await repo.saveToday(Mood.serene, '');
      await repo.resetToMockData();
      expect(repo.entries.value.length, 69);
      expect(repo.isOpened('2026-09-19'), isFalse);
    });

    test('her şeyi sil: örnek veri yeniden yüklenmez', () async {
      MoodRepository(prefs, clock);
      await prefs.wipe();
      expect(MoodRepository(prefs, clock).entries.value, isEmpty);
    });
  });

  group('MoodStatsModel', () {
    test('yüzdeler yuvarlanır ve azalan sıralanır (eşitlikte duygu sırası)', () {
      final stats = MoodStatsModel.fromCounts(DateTime.utc(2026, 10), const {
        Mood.angryStressed: 2,
        Mood.calmSad: 3,
        Mood.serene: 4,
        Mood.tired: 4,
        Mood.joyful: 4,
      });
      expect(stats.total, 17);
      expect(stats.shares.map((s) => s.mood).toList(), [
        Mood.joyful, Mood.serene, Mood.tired, Mood.calmSad, Mood.angryStressed, //
      ]);
      expect(stats.shares.map((s) => s.percent).toList(), [24, 24, 24, 18, 12]);
      expect(stats.top!.mood, Mood.joyful);
    });

    test('boş ay', () {
      final stats = MoodStatsModel.fromCounts(DateTime.utc(2026, 7), const {});
      expect(stats.isEmpty, isTrue);
      expect(stats.top, isNull);
      expect(stats.shares.every((s) => s.percent == 0), isTrue);
    });
  });
}
