import 'package:flutter/foundation.dart'; // immutable Annotation'ını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood Enum'unu import Eder.
import '../../../core/constants/app_strings.dart'; // AppStrings Metin Sabitlerini import Eder.

/// 3 adımlı karşılama durumu.
@immutable // Class'ın Değişmez Olduğunu Belirtir.
class OnboardingState { // Karşılama Ekranının Durumunu Tutan Modeldir.
  static const int pageCount = 3; // Toplam Karşılama Sayfası Sayısıdır.
  static const List<String> ctaLabels = [AppStrings.next, AppStrings.next, AppStrings.startToday]; // Her Sayfanın Ana Düğme Metinleridir.

  final int page; // Etkin Sayfanın İndeksidir.

  /// 1. adımdaki "denemek için bir renge dokun" seçimi (varsayılan Dingin).
  final Mood previewMood; // Önizlemede Seçili Olan Duygudur.

  /// 3. adımdaki "Her akşam 21:00'de hatırlat" anahtarı.
  final bool reminder; // Hatırlatıcının Açık Olup Olmadığını Belirtir.

  const OnboardingState({this.page = 0, this.previewMood = Mood.serene, this.reminder = false}); // Varsayılan Değerli const Constructor'dır.

  bool get isLast => page == pageCount - 1; // Son Sayfada Olunup Olunmadığını Döndüren Getter'dır.

  String get ctaLabel => ctaLabels[page]; // Etkin Sayfanın Düğme Metnini Döndüren Getter'dır.

  OnboardingState copyWith({int? page, Mood? previewMood, bool? reminder}) => OnboardingState( // Verilen Alanları Değiştirilmiş Yeni Kopya Döndürür.
    page: page ?? this.page, // Yeni page Verilmediyse Mevcudu Korur.
    previewMood: previewMood ?? this.previewMood, // Yeni previewMood Verilmediyse Mevcudu Korur.
    reminder: reminder ?? this.reminder, // Yeni reminder Verilmediyse Mevcudu Korur.
  );

  factory OnboardingState.fromJson(Map<String, dynamic> json) => OnboardingState( // JSON'dan State Oluşturan factory Constructor'dır.
    page: (json['page'] as int? ?? 0).clamp(0, pageCount - 1), // Sayfayı Okuyup Geçerli Aralığa Sınırlar.
    previewMood: Mood.fromId(json['mood'] as String?) ?? Mood.serene, // Duyguyu id'den Çözer, Yoksa serene Kullanır.
    reminder: json['reminder'] as bool? ?? false, // Hatırlatıcı Değerini Okur, Yoksa false Kullanır.
  );

  Map<String, dynamic> toJson() => {'page': page, 'mood': previewMood.id, 'reminder': reminder}; // State'i JSON Map'ine Dönüştürür.

  @override // Superclass'taki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => // Değer Bazlı Eşitlik Karşılaştırması Yapar.
      other is OnboardingState && other.page == page && other.previewMood == previewMood && other.reminder == reminder; // Tüm Alanlar Eşitse true Döndürür.

  @override // Superclass'taki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash(page, previewMood, reminder); // Alanlardan hashCode Üretir.
}
