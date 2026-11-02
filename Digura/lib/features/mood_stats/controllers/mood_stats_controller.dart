import 'package:flutter/foundation.dart'; // ValueNotifier, ValueListenable ve Listenable Class'larını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'ını import Eder.
import '../../../core/data/mood_repository.dart'; // Kayıtlara Erişen MoodRepository Class'ını import Eder.
import '../../../core/utils/clock.dart'; // Ay Hesapları İçin DateHelpers'ı import Eder.
import '../models/mood_stats_model.dart'; // MoodStatsModel Class'ını import Eder.

/// İstatistik sekmesi: seçilen ayın duygu dağılımı (yalnızca renkler).
class MoodStatsController { // İstatistik Sekmesinin İş Mantığını Yöneten Controller Class'ıdır.
  final MoodRepository _repository; // Kayıtları Okuyan Repository Field'ıdır.
  final ValueListenable<DateTime> _today; // Bugünün Tarihini Dinlenebilir Olarak Tutan Field'dır.

  late final ValueNotifier<DateTime> visibleMonth; // Görüntülenen Ayı Tutan ValueNotifier'dır.

  MoodStatsController(this._repository, this._today) { // Repository ve Bugün Bilgisini Alan Constructor'dır.
    visibleMonth = ValueNotifier(DateHelpers.monthStart(_today.value)); // Görünen Ayı Bugünün Ayıyla Başlatır.
  }

  Listenable get changes => Listenable.merge([visibleMonth, _repository.entries, _today]); // Ay, Kayıt ve Gün Değişimlerini Tek Listenable'da Birleştirir.

  bool get canGoPrevious => visibleMonth.value.isAfter(DateTime.utc(_repository.earliestYear, 1, 1)); // En Eski Aydan Sonraysa Geri Gidilebilir.

  bool get canGoNext => !DateHelpers.shiftMonth(visibleMonth.value, 1).isAfter(_today.value); // Sonraki Ay Gelecekte Değilse true Döndürür.

  void previousMonth() { // Bir Önceki Aya Geçen Metottur.
    if (canGoPrevious) visibleMonth.value = DateHelpers.shiftMonth(visibleMonth.value, -1); // Mümkünse Görünen Ayı Bir Ay Geri Kaydırır.
  }

  void nextMonth() { // Bir Sonraki Aya Geçen Metottur.
    if (canGoNext) visibleMonth.value = DateHelpers.shiftMonth(visibleMonth.value, 1); // Mümkünse Görünen Ayı Bir Ay İleri Kaydırır.
  }

  MoodStatsModel get stats { // Görünen Ayın Duygu Dağılımını Hesaplayan Getter'dır.
    final month = visibleMonth.value; // Görünen Ayı Alır.
    final counts = <Mood, int>{}; // Duygu Başına Sayaç Map'ini Oluşturur.
    for (final entry in _repository.entriesForMonth(month.year, month.month)) { // Aydaki Her Kayıt İçin Döner.
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1; // Yalnızca Duyguyu Sayar, Nota Erişmez.
    }
    return MoodStatsModel.fromCounts(month, counts); // Sayaçlardan İstatistik Modeli Üretir.
  }

  void dispose() => visibleMonth.dispose(); // visibleMonth ValueNotifier'ını Serbest Bırakır.
}
