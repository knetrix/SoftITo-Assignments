import 'package:flutter/widgets.dart'; // immutable Anotasyonu ve characters Uzantısı İçin Flutter Widgets Kütüphanesini import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'unu import Eder.
import 'mood_entry_model.dart'; // maxNoteLength Sabiti İçin MoodEntry Class'ını import Eder.

/// Bugün sekmesindeki kaydedilmemiş seçim: renk zorunlu, not isteğe bağlı.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class MoodEntryDraftModel { // Kaydedilmemiş Duygu Seçimini Temsil Eden Model Class'ıdır.
  static const int maxNoteLength = MoodEntry.maxNoteLength; // Notun Azami Karakter Sayısıdır.

  final Mood? selectedMood; // Seçili Duygudur, Seçim Yoksa null'dır.
  final String note; // Kullanıcının Yazdığı Not Metnidir.

  const MoodEntryDraftModel({this.selectedMood, this.note = ''}); // Varsayılan Olarak Boş Taslak Oluşturan const Constructor'dır.

  bool get canSave => selectedMood != null; // Duygu Seçilmişse Kaydın Mümkün Olduğunu Belirtir.

  int get noteLength => note.characters.length; // Notun Grafem Bazlı Uzunluğunu Döndürür.

  bool get atLimit => noteLength >= maxNoteLength; // Notun Karakter Sınırına Ulaşıp Ulaşmadığını Döndürür.

  bool get hasNote => note.trim().isNotEmpty; // Boşluk Dışında Not İçeriği Olup Olmadığını Döndürür.

  MoodEntryDraftModel copyWith({Mood? selectedMood, String? note}) { // Belirtilen Field'ları Değiştirilmiş Kopya Üreten Metottur.
    return MoodEntryDraftModel(selectedMood: selectedMood ?? this.selectedMood, note: note ?? this.note); // Verilmeyen Field'ları Mevcut Değerlerle Doldurur.
  }

  factory MoodEntryDraftModel.fromJson(Map<String, dynamic> json) { // JSON'dan Taslak Oluşturan factory Constructor'dır.
    return MoodEntryDraftModel(selectedMood: Mood.fromId(json['mood'] as String?), note: json['note'] as String? ?? ''); // mood ve note Alanlarını Okuyarak Model Oluşturur.
  }

  Map<String, dynamic> toJson() => {'mood': selectedMood?.id, 'note': note}; // Taslağı JSON Map'ine Dönüştürür.

  @override // Object'teki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => // Değer Bazlı Eşitlik Karşılaştırması Yapar.
      other is MoodEntryDraftModel && other.selectedMood == selectedMood && other.note == note; // Tip, Duygu ve Not Eşitse true Döndürür.

  @override // Object'teki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash(selectedMood, note); // Duygu ve Nottan hashCode Üretir.
}
