import 'package:flutter/foundation.dart'; // immutable Annotation'ını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'ını import Eder.
import '../../../core/utils/clock.dart'; // Gün Anahtarı Dönüşümleri İçin DateHelpers'ı import Eder.

enum CalendarMode { month, year } // Takvimin Ay ve Yıl Görünüm Modlarını Tanımlar.

/// Harita sekmesinin görünüm durumu.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class MoodCalendarState { // Harita Sekmesinin Görünüm State'ini Tutan Class'tır.
  final CalendarMode mode; // Aktif Görünüm Modudur.

  /// Ay görünümünde gösterilen ayın ilk günü (UTC).
  final DateTime visibleMonth; // Gösterilen Ayın İlk Günüdür.

  const MoodCalendarState({required this.mode, required this.visibleMonth}); // mode ve visibleMonth Field'larını required Yapan const Constructor'dır.

  MoodCalendarState copyWith({CalendarMode? mode, DateTime? visibleMonth}) => // Seçili Field'ları Değiştirilmiş Kopya Üreten Metottur.
      MoodCalendarState(mode: mode ?? this.mode, visibleMonth: visibleMonth ?? this.visibleMonth); // Verilmeyen Field'larda Mevcut Değeri Korur.

  factory MoodCalendarState.fromJson(Map<String, dynamic> json) => MoodCalendarState( // JSON'dan State Oluşturan factory Constructor'dır.
    mode: json['mode'] == CalendarMode.year.name ? CalendarMode.year : CalendarMode.month, // mode Değeri year Değilse Ay Moduna Döner.
    visibleMonth: DateHelpers.fromDayKey(json['month'] as String), // Gün Anahtarından Ay Tarihini Çözer.
  );

  Map<String, dynamic> toJson() => {'mode': mode.name, 'month': DateHelpers.dayKey(visibleMonth)}; // State'i JSON Map'ine Dönüştürür.

  @override // Superclass'taki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => // İki State'in Eşitliğini Karşılaştırır.
      other is MoodCalendarState && other.mode == mode && other.visibleMonth == visibleMonth; // Tip, Mod ve Ay Aynıysa true Döndürür.

  @override // Superclass'taki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash(mode, visibleMonth); // mode ve visibleMonth'tan hashCode Üretir.
}

/// Ay ısı haritasındaki tek gün. Not metni bilinçli olarak taşınmaz.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class DayCellModel { // Isı Haritasındaki Bir Gün Hücresinin Modelidir.
  final int day; // Ayın Gün Numarasıdır.
  final String? entryId; // Varsa Kaydın id'sidir.
  final Mood? mood; // Varsa Günün Duygusudur.
  final bool isToday; // Hücre Bugünse true Olur.
  final bool isFuture; // Hücre Gelecekteyse true Olur.
  final bool isLocked; // Kapsül Kilitliyse true Olur.
  final bool isFresh; // Kapsül Yeni Açılmış ve Görülmemişse true Olur.

  const DayCellModel({ // Hücre Field'larını Alan const Constructor'dır.
    required this.day, // day Field'ını required Yapar.
    this.entryId, // Opsiyonel entryId Field'ını Atar.
    this.mood, // Opsiyonel mood Field'ını Atar.
    this.isToday = false, // isToday Varsayılan Olarak false'tur.
    this.isFuture = false, // isFuture Varsayılan Olarak false'tur.
    this.isLocked = false, // isLocked Varsayılan Olarak false'tur.
    this.isFresh = false, // isFresh Varsayılan Olarak false'tur.
  });

  bool get hasEntry => mood != null; // Hücrede Kayıt Olup Olmadığını Döndürür.

  @override // Superclass'taki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => // İki Hücrenin Eşitliğini Karşılaştırır.
      other is DayCellModel && // Diğer Nesnenin DayCellModel Olduğunu Kontrol Eder.
      other.day == day && // Gün Numaraları Eşit Mi Bakar.
      other.entryId == entryId && // entryId Değerleri Eşit Mi Bakar.
      other.mood == mood && // Duygular Eşit Mi Bakar.
      other.isToday == isToday && // isToday Değerleri Eşit Mi Bakar.
      other.isFuture == isFuture && // isFuture Değerleri Eşit Mi Bakar.
      other.isLocked == isLocked && // isLocked Değerleri Eşit Mi Bakar.
      other.isFresh == isFresh; // isFresh Değerleri Eşit Mi Bakar.

  @override // Superclass'taki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash(day, entryId, mood, isToday, isFuture, isLocked, isFresh); // Tüm Field'lardan hashCode Üretir.
}

/// Yıl görünümündeki mini ay kartı.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class MiniMonthModel { // Yıl Görünümündeki Mini Ay Kartının Modelidir.
  final DateTime month; // Ayın İlk Günüdür.
  final int count; // Aydaki Kayıt Sayısıdır.
  final bool isFuture; // Ay Gelecekteyse true Olur.
  final int leadingBlanks; // Ay Başındaki Boş Hücre Sayısıdır.

  /// Ayın her günü için duygu (kayıt yoksa `null`).
  final List<Mood?> days; // Günlük Duygu Listesidir.

  const MiniMonthModel({ // Tüm Field'ları required Alan const Constructor'dır.
    required this.month, // month Field'ını required Yapar.
    required this.count, // count Field'ını required Yapar.
    required this.isFuture, // isFuture Field'ını required Yapar.
    required this.leadingBlanks, // leadingBlanks Field'ını required Yapar.
    required this.days, // days Field'ını required Yapar.
  });
}

/// Kapsül Detay Modalı içeriği.
///
/// Kilitli kapsül sınıfı not alanı **içermez**; böylece kilitli metin widget
/// katmanına hiçbir yoldan ulaşamaz.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
sealed class CapsuleDetail { // Kilitli ve Açılmış Kapsüllerin Ortak sealed Base Class'ıdır.
  final String id; // Kaydın id'sidir.
  final Mood mood; // Kaydın Duygusudur.
  final DateTime entryDate; // Kayıt Tarihidir.
  final DateTime unlockDate; // Kilidin Açılma Tarihidir.

  const CapsuleDetail({required this.id, required this.mood, required this.entryDate, required this.unlockDate}); // Ortak Field'ları required Alan const Constructor'dır.
}

final class LockedCapsule extends CapsuleDetail { // Not Alanı Taşımayan Kilitli Kapsül Class'ıdır.
  final int remainingDays; // Açılışa Kalan Gün Sayısıdır.
  final double progress; // Kilit Süresinin İlerleme Oranıdır.

  const LockedCapsule({ // Kilitli Kapsül Field'larını Alan const Constructor'dır.
    required super.id, // id'yi Superclass'a İletir.
    required super.mood, // mood'u Superclass'a İletir.
    required super.entryDate, // entryDate'i Superclass'a İletir.
    required super.unlockDate, // unlockDate'i Superclass'a İletir.
    required this.remainingDays, // remainingDays Field'ını required Yapar.
    required this.progress, // progress Field'ını required Yapar.
  });
}

final class OpenedCapsule extends CapsuleDetail { // Kilidi Açılmış, Notu İçeren Kapsül Class'ıdır.
  final String note; // Kilidi Açılmış Not Metnidir.

  /// İlk açılış anı (`CircleReveal`) oynatılsın mı?
  final bool firstUnseal; // İlk Açılış Animasyonu Bayrağıdır.

  const OpenedCapsule({ // Açılmış Kapsül Field'larını Alan const Constructor'dır.
    required super.id, // id'yi Superclass'a İletir.
    required super.mood, // mood'u Superclass'a İletir.
    required super.entryDate, // entryDate'i Superclass'a İletir.
    required super.unlockDate, // unlockDate'i Superclass'a İletir.
    required this.note, // note Field'ını required Yapar.
    required this.firstUnseal, // firstUnseal Field'ını required Yapar.
  });
}
