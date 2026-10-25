import 'package:digura/core/constants/app_colors.dart';
import 'package:digura/core/utils/clock.dart';
import 'package:digura/features/mood_entry/models/mood_entry_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Clock', () {
    test('today() yerel takvim gününü UTC gece yarısına sabitler', () {
      final clock = Clock.fixed(DateTime(2026, 10, 25, 23, 59));
      expect(clock.today(), DateTime.utc(2026, 10, 25));
      expect(clock.today().isUtc, isTrue);
    });

    test('MutableClock ileri sarılabilir', () {
      final clock = MutableClock(DateTime(2026, 10, 25, 12));
      clock.advance(const Duration(days: 30));
      expect(clock.today(), DateTime.utc(2026, 11, 24));
    });
  });

  group('DateHelpers', () {
    test('dayKey YYYY-MM-DD üretir ve geri çözer', () {
      final d = DateTime.utc(2026, 3, 7);
      expect(DateHelpers.dayKey(d), '2026-03-07');
      expect(DateHelpers.fromDayKey('2026-03-07'), d);
    });

    test('Pazartesi başlangıçlı boş hücre sayısı', () {
      expect(DateHelpers.leadingBlanks(2026, 10), 3); // 1 Ekim 2026 Perşembe
      expect(DateHelpers.leadingBlanks(2026, 6), 0); // 1 Haziran 2026 Pazartesi
      expect(DateHelpers.leadingBlanks(2026, 11), 6); // 1 Kasım 2026 Pazar
    });

    test('ay uzunlukları ve kaydırma', () {
      expect(DateHelpers.daysInMonth(2026, 2), 28);
      expect(DateHelpers.daysInMonth(2028, 2), 29);
      expect(DateHelpers.shiftMonth(DateTime.utc(2026, 1, 1), -1), DateTime.utc(2025, 12, 1));
    });

    test('Türkçe biçimlendirme ve büyük harf', () {
      final d = DateTime.utc(2026, 10, 25);
      expect(DateHelpers.formatWithWeekday(d), '25 Ekim 2026 · Pazar');
      expect(trUpper(DateHelpers.formatWithWeekday(d)), '25 EKİM 2026 · PAZAR');
      expect(trUpper('Yalnızca renkler'), 'YALNIZCA RENKLER');
    });
  });

  group('MoodEntry · 30 günlük zaman kapsülü', () {
    final entry = MoodEntry.forDay(DateTime(2026, 9, 25), Mood.serene, note: 'Gizli not');

    test('unlockDate = entryDate + 30 gün', () {
      expect(entry.unlockDate, DateTime.utc(2026, 10, 25));
    });

    test('29. günde kilitli, 30. günde açık', () {
      final day29 = Clock.fixed(DateTime(2026, 10, 24, 23, 59)).today();
      final day30 = Clock.fixed(DateTime(2026, 10, 25, 0, 1)).today();
      expect(entry.isUnlocked(day29), isFalse);
      expect(entry.remainingDays(day29), 1);
      expect(entry.isUnlocked(day30), isTrue);
      expect(entry.remainingDays(day30), 0);
    });

    test('kayıt günü 30 gün kalır, ilerleme 0 → 1', () {
      final today = DateTime.utc(2026, 9, 25);
      expect(entry.remainingDays(today), 30);
      expect(entry.lockProgress(today), 0);
      expect(entry.lockProgress(DateTime.utc(2026, 10, 10)), 0.5);
      expect(entry.lockProgress(DateTime.utc(2026, 12, 1)), 1);
    });

    test('yeni açılan (fresh) kapsül: açılıştan sonraki 7 gün', () {
      expect(entry.isRecentlyUnlocked(DateTime.utc(2026, 10, 24)), isFalse);
      expect(entry.isRecentlyUnlocked(DateTime.utc(2026, 10, 25)), isTrue);
      expect(entry.isRecentlyUnlocked(DateTime.utc(2026, 10, 31)), isTrue);
      expect(entry.isRecentlyUnlocked(DateTime.utc(2026, 11, 1)), isFalse);
    });

    test('ay sonu ve yıl geçişinde kilit doğru hesaplanır', () {
      final dec = MoodEntry.forDay(DateTime(2026, 12, 15), Mood.joyful);
      expect(dec.unlockDate, DateTime.utc(2027, 1, 14));
      expect(dec.remainingDays(DateTime.utc(2027, 1, 13)), 1);
    });
  });

  group('MoodEntry · tek cümle kuralı', () {
    test('satır sonları boşluğa döner, baş/son boşluk atılır', () {
      expect(MoodEntry.sanitizeNote('  Bir\nİki\r\nÜç  '), 'Bir İki Üç');
    });

    test('140 karakterle sınırlanır', () {
      final long = 'a' * 200;
      expect(MoodEntry.sanitizeNote(long).length, MoodEntry.maxNoteLength);
    });

    test('JSON gidiş-dönüş ve toString notu içermez', () {
      final e = MoodEntry.forDay(DateTime(2026, 10, 1), Mood.calmSad, note: 'özel');
      expect(MoodEntry.fromJson(e.toJson()), e);
      expect(e.toString(), isNot(contains('özel')));
    });
  });
}
