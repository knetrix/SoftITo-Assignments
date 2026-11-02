import 'package:flutter/foundation.dart'; // ValueNotifier, ValueListenable ve Listenable Class'larını import Eder.

import '../../../core/data/mood_repository.dart'; // Kayıtlara Erişen MoodRepository Class'ını import Eder.
import '../../../core/utils/clock.dart'; // Tarih Hesapları İçin DateHelpers'ı import Eder.
import '../models/mood_calendar_model.dart'; // Takvim State'i, Hücre ve Kapsül Modellerini import Eder.

/// Harita sekmesi: Ay / Yıl ısı haritası ve kapsül açma kuralları.
class MoodCalendarController { // Harita Sekmesinin İş Mantığını Yöneten Controller Class'ıdır.
  final MoodRepository _repository; // Kayıtları Okuyup Yazan Repository Field'ıdır.
  final ValueListenable<DateTime> _today; // Bugünün Tarihini Dinlenebilir Olarak Tutan Field'dır.

  late final ValueNotifier<MoodCalendarState> state; // Görünüm Modunu ve Görünen Ayı Tutan ValueNotifier'dır.

  MoodCalendarController(this._repository, this._today) { // Repository ve Bugün Bilgisini Alan Constructor'dır.
    state = ValueNotifier( // State'i Başlangıç Değeriyle Oluşturur.
      MoodCalendarState(mode: CalendarMode.month, visibleMonth: DateHelpers.monthStart(_today.value)), // Ay Görünümüyle ve Bugünün Ayıyla Başlatır.
    );
  }

  Listenable get changes => Listenable.merge([state, _repository.entries, _repository.openedCapsules, _today]); // State, Kayıt, Açılan Kapsül ve Gün Değişimlerini Tek Listenable'da Birleştirir.

  DateTime get today => _today.value; // Bugünün Tarihini Döndüren Getter'dır.

  DateTime get _minMonth => DateTime.utc(_repository.earliestYear, 1, 1); // Gidilebilecek En Eski Ayı Döndürür.

  bool get canGoPrevious => state.value.visibleMonth.isAfter(_minMonth); // Önceki Aya Geçilebilir Mi Kontrol Eder.

  bool get canGoNext => !DateHelpers.shiftMonth(state.value.visibleMonth, 1).isAfter(today); // Sonraki Ay Gelecekte Değilse true Döndürür.

  void setMode(CalendarMode mode) => state.value = state.value.copyWith(mode: mode); // Ay / Yıl Görünüm Modunu Değiştirir.

  void previousMonth() { // Bir Önceki Aya Geçen Metottur.
    if (canGoPrevious) { // Önceki Aya Geçiş Mümkünse Çalışır.
      state.value = state.value.copyWith(visibleMonth: DateHelpers.shiftMonth(state.value.visibleMonth, -1)); // Görünen Ayı Bir Ay Geri Kaydırır.
    }
  }

  void nextMonth() { // Bir Sonraki Aya Geçen Metottur.
    if (canGoNext) { // Sonraki Aya Geçiş Mümkünse Çalışır.
      state.value = state.value.copyWith(visibleMonth: DateHelpers.shiftMonth(state.value.visibleMonth, 1)); // Görünen Ayı Bir Ay İleri Kaydırır.
    }
  }

  /// Yıl görünümünde bir mini aya dokunma: o ayın Ay görünümü açılır.
  void openMonth(int month) => // Seçilen Ayı Ay Görünümünde Açan Metottur.
      state.value = MoodCalendarState(mode: CalendarMode.month, visibleMonth: DateTime.utc(today.year, month, 1)); // Modu Ay Yapar ve Bu Yılın Seçilen Ayını Gösterir.

  int countForMonth(DateTime month) => _repository.entriesForMonth(month.year, month.month).length; // Verilen Aydaki Kayıt Sayısını Döndürür.

  int countForYear(int year) => _repository.countForYear(year); // Verilen Yıldaki Kayıt Sayısını Döndürür.

  /// Ay ısı haritası hücreleri (Pazartesi başlangıçlı; baştaki boşluklar `null`).
  List<DayCellModel?> monthCells(DateTime month) { // Ay Isı Haritasının Hücre Listesini Üretir.
    final cells = <DayCellModel?>[for (var i = 0; i < DateHelpers.leadingBlanks(month.year, month.month); i++) null]; // Ayın Başındaki Boş Günler İçin null Hücreler Ekler.
    final days = DateHelpers.daysInMonth(month.year, month.month); // Aydaki Gün Sayısını Hesaplar.
    for (var d = 1; d <= days; d++) { // Ayın Her Günü İçin Döner.
      final date = DateTime.utc(month.year, month.month, d); // O Günün UTC Tarihini Oluşturur.
      final entry = _repository.entryFor(date); // O Güne Ait Kaydı Getirir.
      if (entry == null) { // Kayıt Yoksa Çalışır.
        cells.add(DayCellModel(day: d, isToday: date == today, isFuture: date.isAfter(today))); // Kayıtsız Gün Hücresini Bugün / Gelecek Bilgisiyle Ekler.
        continue; // Sonraki Güne Geçer.
      }
      final unlocked = entry.isUnlocked(today); // Kaydın 30 Günlük Kilidinin Açılıp Açılmadığını Hesaplar.
      cells.add( // Kayıtlı Gün Hücresini Listeye Ekler.
        DayCellModel( // Not Metni Taşımayan Hücre Modelini Oluşturur.
          day: d, // Ayın Gün Numarasını Verir.
          entryId: entry.id, // Kaydın id'sini Verir.
          mood: entry.mood, // Kaydın Duygusunu Verir.
          isToday: date == today, // Bugün Olup Olmadığını Belirtir.
          isLocked: !unlocked, // Kilitli Olup Olmadığını Belirtir.
          isFresh: entry.isRecentlyUnlocked(today) && !_repository.isOpened(entry.id), // Yeni Açılmış ve Henüz Görülmemişse Fresh İşaretler.
        ),
      );
    }
    return cells; // Hücre Listesini Döndürür.
  }

  /// Yıl görünümü: 12 mini ay (3 × 4).
  List<MiniMonthModel> yearMonths(int year) => [ // Yıl Görünümü İçin 12 Mini Ay Modeli Üretir.
    for (var m = 1; m <= 12; m++) // Yılın Her Ayı İçin Döner.
      () { // Her Ay İçin Hemen Çağrılan Anonim Fonksiyondur.
        final month = DateTime.utc(year, m, 1); // Ayın İlk Gününü Oluşturur.
        final days = DateHelpers.daysInMonth(year, m); // Aydaki Gün Sayısını Hesaplar.
        final moods = [for (var d = 1; d <= days; d++) _repository.entryFor(DateTime.utc(year, m, d))?.mood]; // Her Günün Duygusunu (Yoksa null) Listeler.
        return MiniMonthModel( // Mini Ay Modelini Döndürür.
          month: month, // Ayın İlk Gününü Verir.
          count: moods.whereType<Object>().length, // null Olmayan Kayıt Sayısını Verir.
          isFuture: month.isAfter(today), // Ay Gelecekteyse true Verir.
          leadingBlanks: DateHelpers.leadingBlanks(year, m), // Ay Başındaki Boşluk Sayısını Verir.
          days: moods, // Günlük Duygu Listesini Verir.
        );
      }(), // Anonim Fonksiyonu Hemen Çağırır.
  ];

  /// Bir güne dokunma: kilitliyse not içermeyen [LockedCapsule]; açılmışsa
  /// notlu [OpenedCapsule]. İlk açılışta kapsül "açıldı" olarak işaretlenir.
  Future<CapsuleDetail?> openDay(String id) async { // Dokunulan Günün Kapsül Detayını Hazırlayan async Metottur.
    final entry = _repository.getByDayKey(id); // Gün Anahtarına Göre Kaydı Getirir.
    if (entry == null) return null; // Kayıt Yoksa null Döndürür.
    if (!entry.isUnlocked(today)) { // Kapsül Hâlâ Kilitliyse Çalışır.
      return LockedCapsule( // Not Alanı Olmayan Kilitli Kapsül Modelini Döndürür.
        id: entry.id, // Kaydın id'sini Verir.
        mood: entry.mood, // Kaydın Duygusunu Verir.
        entryDate: entry.entryDate, // Kayıt Tarihini Verir.
        unlockDate: entry.unlockDate, // Kilidin Açılacağı Tarihi Verir.
        remainingDays: entry.remainingDays(today), // Açılışa Kalan Gün Sayısını Verir.
        progress: entry.lockProgress(today), // Kilit İlerleme Oranını Verir.
      );
    }
    final first = !_repository.isOpened(entry.id); // Kapsülün İlk Kez Açılıp Açılmadığını Hesaplar.
    if (first) await _repository.markOpened(entry.id); // İlk Açılışsa Kapsülü Açıldı Olarak Kaydeder.
    return OpenedCapsule( // Notu İçeren Açılmış Kapsül Modelini Döndürür.
      id: entry.id, // Kaydın id'sini Verir.
      mood: entry.mood, // Kaydın Duygusunu Verir.
      entryDate: entry.entryDate, // Kayıt Tarihini Verir.
      unlockDate: entry.unlockDate, // Kilidin Açıldığı Tarihi Verir.
      note: entry.note, // Kilidi Açılmış Notu Verir.
      firstUnseal: first, // İlk Açılış Animasyonunun Oynatılıp Oynatılmayacağını Verir.
    );
  }

  void dispose() => state.dispose(); // State ValueNotifier'ını Serbest Bırakır.
}
