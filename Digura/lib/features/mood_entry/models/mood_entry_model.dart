import 'package:flutter/widgets.dart'; // immutable Anotasyonu ve characters Uzantısı İçin Flutter Widgets Kütüphanesini import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'unu import Eder.
import '../../../core/utils/clock.dart'; // Gün Hesapları İçin DateHelpers'ı import Eder.

/// Günde bir kayıt: duygu rengi (zorunlu) + en fazla 140 karakterlik tek
/// cümle (isteğe bağlı). Kaydedildikten sonra düzenlenemez, silinemez.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class MoodEntry { // Bir Güne Ait Duygu Kaydını Temsil Eden Model Class'ıdır.
  static const int maxNoteLength = 140; // Notun Azami Karakter Sayısıdır.
  static const int lockDays = 30; // Notun Kilitli Kaldığı Gün Sayısıdır.
  static const int freshDays = 7; // Açılan Kapsülün Yeni Sayıldığı Gün Sayısıdır.

  /// `YYYY-MM-DD` (`dayKey`).
  final String id; // Kaydın Gün Anahtarı Olan Benzersiz id'sidir.

  /// UTC gün başlangıcı (`dateOnly`).
  final DateTime entryDate; // Kaydın Ait Olduğu Gündür.
  final Mood mood; // Kaydedilen Duygudur.
  final String note; // Kayda Eklenen Tek Cümlelik Nottur.

  const MoodEntry({required this.id, required this.entryDate, required this.mood, this.note = ''}); // id, entryDate ve mood'u required Yapan const Constructor'dır.

  factory MoodEntry.forDay(DateTime day, Mood mood, {String note = ''}) { // Verilen Gün İçin Kayıt Oluşturan factory Constructor'dır.
    final date = DateHelpers.dateOnly(day); // Günü UTC Gece Yarısına Normalize Eder.
    return MoodEntry(id: DateHelpers.dayKey(date), entryDate: date, mood: mood, note: sanitizeNote(note)); // Gün Anahtarı ve Temizlenmiş Notla Kayıt Döndürür.
  }

  /// Tek cümle kuralı: satır sonları boşluğa döner, baş/son boşluk atılır ve
  /// metin 140 karakterle (grafem) sınırlanır.
  static String sanitizeNote(String raw) { // Notu Tek Cümle Kuralına Göre Temizleyen static Metottur.
    final single = raw.replaceAll(RegExp(r'[\r\n]+'), ' ').trim(); // Satır Sonlarını Boşluğa Çevirip Kenar Boşluklarını Atar.
    final chars = single.characters; // Metni Grafem Bazlı Karakterlere Ayırır.
    return chars.length > maxNoteLength ? chars.take(maxNoteLength).toString() : single; // Sınırı Aşan Kısmı Keserek Döndürür.
  }

  bool get hasNote => note.isNotEmpty; // Kayıtta Not Olup Olmadığını Döndürür.

  /// `entryDate + 30 gün`.
  DateTime get unlockDate => DateHelpers.addDays(entryDate, lockDays); // Notun Açılacağı Tarihi Döndürür.

  bool isUnlocked(DateTime today) => !DateHelpers.dateOnly(today).isBefore(unlockDate); // Bugün Açılış Tarihine Ulaşıldıysa true Döndürür.

  int remainingDays(DateTime today) { // Açılışa Kalan Gün Sayısını Hesaplayan Metottur.
    final diff = unlockDate.difference(DateHelpers.dateOnly(today)).inDays; // Açılış Tarihiyle Bugün Arasındaki Gün Farkını Bulur.
    return diff < 0 ? 0 : diff; // Negatif Farkı Sıfıra Çekerek Döndürür.
  }

  /// Kilit ilerlemesi (0 → 1).
  double lockProgress(DateTime today) => ((lockDays - remainingDays(today)) / lockDays).clamp(0.0, 1.0); // Geçen Gün Oranını 0-1 Aralığında Döndürür.

  /// Açılışının üzerinden 7 gün geçmemiş kapsül.
  bool isRecentlyUnlocked(DateTime today) { // Kapsülün Yakın Zamanda Açılıp Açılmadığını Döndüren Metottur.
    if (!isUnlocked(today)) return false; // Henüz Açılmamışsa false Döndürür.
    return DateHelpers.dateOnly(today).difference(unlockDate).inDays < freshDays; // Açılıştan Bu Yana 7 Günden Az Geçtiyse true Döndürür.
  }

  MoodEntry copyWith({String? id, DateTime? entryDate, Mood? mood, String? note}) { // Belirtilen Field'ları Değiştirilmiş Kopya Üreten Metottur.
    return MoodEntry( // Yeni MoodEntry Örneği Döndürür.
      id: id ?? this.id, // Verilmezse Mevcut id'yi Korur.
      entryDate: entryDate ?? this.entryDate, // Verilmezse Mevcut entryDate'i Korur.
      mood: mood ?? this.mood, // Verilmezse Mevcut mood'u Korur.
      note: note ?? this.note, // Verilmezse Mevcut note'u Korur.
    );
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) { // JSON'dan Kayıt Oluşturan factory Constructor'dır.
    final id = json['id'] as String; // Gün Anahtarını JSON'dan Okur.
    return MoodEntry( // Okunan Değerlerle MoodEntry Döndürür.
      id: id, // Gün Anahtarını id Olarak Atar.
      entryDate: DateHelpers.fromDayKey(id), // Gün Anahtarından Tarihi Üretir.
      mood: Mood.fromId(json['mood'] as String?) ?? Mood.serene, // Duyguyu Okur, Bulunamazsa serene Kullanır.
      note: sanitizeNote(json['note'] as String? ?? ''), // Notu Okuyup Temizler.
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'mood': mood.id, 'note': note}; // Kaydı JSON Map'ine Dönüştürür.

  @override // Object'teki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => // Değer Bazlı Eşitlik Karşılaştırması Yapar.
      other is MoodEntry && other.id == id && other.entryDate == entryDate && other.mood == mood && other.note == note; // Tüm Field'lar Eşitse true Döndürür.

  @override // Object'teki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash(id, entryDate, mood, note); // Tüm Field'lardan hashCode Üretir.

  /// Not metni bilinçli olarak dışarıda bırakılır (log gizliliği).
  @override // Object'teki toString Metodunun Override Edildiğini Belirtir.
  String toString() => 'MoodEntry($id, ${mood.id})'; // Notu İçermeyen Metin Gösterimi Döndürür.
}
