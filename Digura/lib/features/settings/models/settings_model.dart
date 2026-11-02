import 'package:flutter/material.dart'; // ThemeMode ve immutable İçin Flutter'ın Material Kütüphanesini import Eder.

import '../../../core/constants/app_strings.dart'; // Tema Etiketleri İçin AppStrings'i import Eder.

/// Tema seçenekleri (Ayarlar › Görünüm › Tema).
enum ThemeOption { // Seçilebilir Tema Seçeneklerini Tanımlayan enum'dur.
  system(ThemeMode.system, AppStrings.themeSystem, AppStrings.themeSystemSub), // Sistem Temasını İzleyen Seçenektir.
  light(ThemeMode.light, AppStrings.themeLight, AppStrings.themeLightSub), // Açık Tema Seçeneğidir.
  dark(ThemeMode.dark, AppStrings.themeDark, AppStrings.themeDarkSub); // Koyu Tema Seçeneğidir.

  final ThemeMode mode; // Seçeneğe Karşılık Gelen ThemeMode'dur.
  final String label; // Seçeneğin Görünen Adıdır.
  final String description; // Seçeneğin Açıklama Metnidir.

  const ThemeOption(this.mode, this.label, this.description); // mode, label ve description Alan const Constructor'dır.

  static ThemeOption of(ThemeMode mode) => values.firstWhere((o) => o.mode == mode); // ThemeMode'a Karşılık Gelen Seçeneği Bulur.

  /// Ayarlar satırındaki alt yazı: "Sistem varsayılanı · telefonun ayarını izler".
  String get summary => this == system ? '$label${AppStrings.themeSystemSuffix}' : label; // Sistem Seçeneğinde Ek Açıklamalı Özet Döndürür.
}

/// Ayarlar ekranının anlık görüntüsü.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class SettingsModel { // Ayarların Anlık Durumunu Tutan Model Class'ıdır.
  final ThemeOption theme; // Seçili Tema Seçeneğidir.
  final bool reminderEnabled; // Günlük Hatırlatıcının Açık Olup Olmadığıdır.
  final bool biometricEnabled; // Biyometrik Kilidin Açık Olup Olmadığıdır.

  const SettingsModel({required this.theme, required this.reminderEnabled, required this.biometricEnabled}); // Tüm Field'ları required Yapan const Constructor'dır.

  SettingsModel copyWith({ThemeOption? theme, bool? reminderEnabled, bool? biometricEnabled}) => SettingsModel( // Belirtilen Field'ları Değiştirilmiş Kopya Üretir.
    theme: theme ?? this.theme, // Verilmezse Mevcut theme'i Korur.
    reminderEnabled: reminderEnabled ?? this.reminderEnabled, // Verilmezse Mevcut reminderEnabled'ı Korur.
    biometricEnabled: biometricEnabled ?? this.biometricEnabled, // Verilmezse Mevcut biometricEnabled'ı Korur.
  );

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel( // JSON'dan Model Oluşturan factory Constructor'dır.
    theme: ThemeOption.values.firstWhere((o) => o.name == json['theme'], orElse: () => ThemeOption.system), // Tema Adını Eşler, Bulunamazsa system Kullanır.
    reminderEnabled: json['reminderEnabled'] as bool? ?? false, // Hatırlatıcı Durumunu Okur, Yoksa false Kullanır.
    biometricEnabled: json['biometricEnabled'] as bool? ?? false, // Biyometri Durumunu Okur, Yoksa false Kullanır.
  );

  Map<String, dynamic> toJson() => { // Modeli JSON Map'ine Dönüştürür.
    'theme': theme.name, // Tema Adını Yazar.
    'reminderEnabled': reminderEnabled, // Hatırlatıcı Durumunu Yazar.
    'biometricEnabled': biometricEnabled, // Biyometri Durumunu Yazar.
  };

  @override // Object'teki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => // Değer Bazlı Eşitlik Karşılaştırması Yapar.
      other is SettingsModel && // Tipin SettingsModel Olduğunu Kontrol Eder.
      other.theme == theme && // Tema Eşitliğini Kontrol Eder.
      other.reminderEnabled == reminderEnabled && // Hatırlatıcı Eşitliğini Kontrol Eder.
      other.biometricEnabled == biometricEnabled; // Biyometri Eşitliğini Kontrol Eder.

  @override // Object'teki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash(theme, reminderEnabled, biometricEnabled); // Tüm Field'lardan hashCode Üretir.
}
