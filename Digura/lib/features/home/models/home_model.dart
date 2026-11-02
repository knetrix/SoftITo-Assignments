import 'package:flutter/foundation.dart'; // immutable Annotation'ını Sağlayan Foundation Kütüphanesini import Eder.

import '../../../core/constants/app_icons.dart'; // AppIcons ve AppIconData Class'larını import Eder.
import '../../../core/constants/app_strings.dart'; // Sekme Etiketleri İçin AppStrings'i import Eder.

enum HomeTab { // Ana Kabuktaki Sekmeleri Tanımlayan Enum'dur.
  today(AppStrings.tabToday, AppIcons.sun), // Güneş Simgeli Bugün Sekmesidir.
  map(AppStrings.tabMap, AppIcons.grid), // Izgara Simgeli Harita Sekmesidir.
  stats(AppStrings.tabStats, AppIcons.chart); // Grafik Simgeli İstatistik Sekmesidir.

  final String label; // Sekmenin Görünen Etiketidir.
  final AppIconData icon; // Sekmenin Simgesidir.

  const HomeTab(this.label, this.icon); // label ve icon Alan const Enum Constructor'ıdır.
}

/// Kabuk durumu: seçili sekme ve sekme değişim sayacı (giriş animasyonu
/// yalnızca sekme **değişince** oynar).
@immutable // Class'ın Değişmez Olduğunu Belirtir.
class HomeShellState { // Ana Kabuğun Değişmez Durum Modelidir.
  final HomeTab tab; // Seçili Sekmedir.
  final int enterSequence; // Sekme Her Değiştiğinde Artan Sayaçtır.

  const HomeShellState({this.tab = HomeTab.today, this.enterSequence = 0}); // Varsayılan Olarak Bugün Sekmesi ve 0 Sayaçla const Constructor'dır.

  HomeShellState copyWith({HomeTab? tab, int? enterSequence}) => // Verilen Alanları Değiştirilmiş Yeni Kopya Döndürür.
      HomeShellState(tab: tab ?? this.tab, enterSequence: enterSequence ?? this.enterSequence); // Verilmeyen Alanlar İçin Mevcut Değerleri Korur.

  factory HomeShellState.fromJson(Map<String, dynamic> json) => HomeShellState( // JSON Map'ten Durum Oluşturan factory Constructor'dır.
    tab: HomeTab.values.firstWhere((t) => t.name == json['tab'], orElse: () => HomeTab.today), // İsme Göre Sekmeyi Bulur, Bulamazsa today Kullanır.
    enterSequence: json['enterSequence'] as int? ?? 0, // Sayacı Okur, Yoksa 0 Kullanır.
  );

  Map<String, dynamic> toJson() => {'tab': tab.name, 'enterSequence': enterSequence}; // Durumu JSON Map'e Dönüştürür.

  @override // Superclass'taki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => other is HomeShellState && other.tab == tab && other.enterSequence == enterSequence; // Sekme ve Sayaç Eşitse Durumları Eşit Sayar.

  @override // Superclass'taki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash(tab, enterSequence); // tab ve enterSequence'tan hashCode Üretir.
}
