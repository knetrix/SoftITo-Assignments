import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Tema seçenekleri (Ayarlar › Görünüm › Tema).
enum ThemeOption {
  system(ThemeMode.system, AppStrings.themeSystem, AppStrings.themeSystemSub),
  light(ThemeMode.light, AppStrings.themeLight, AppStrings.themeLightSub),
  dark(ThemeMode.dark, AppStrings.themeDark, AppStrings.themeDarkSub);

  final ThemeMode mode;
  final String label;
  final String description;

  const ThemeOption(this.mode, this.label, this.description);

  static ThemeOption of(ThemeMode mode) => values.firstWhere((o) => o.mode == mode);

  /// Ayarlar satırındaki alt yazı: "Sistem varsayılanı · telefonun ayarını izler".
  String get summary => this == system ? '$label${AppStrings.themeSystemSuffix}' : label;
}

/// Ayarlar ekranının anlık görüntüsü.
@immutable
class SettingsModel {
  final ThemeOption theme;
  final bool reminderEnabled;
  final bool biometricEnabled;

  const SettingsModel({required this.theme, required this.reminderEnabled, required this.biometricEnabled});

  SettingsModel copyWith({ThemeOption? theme, bool? reminderEnabled, bool? biometricEnabled}) => SettingsModel(
    theme: theme ?? this.theme,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
  );

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    theme: ThemeOption.values.firstWhere((o) => o.name == json['theme'], orElse: () => ThemeOption.system),
    reminderEnabled: json['reminderEnabled'] as bool? ?? false,
    biometricEnabled: json['biometricEnabled'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'theme': theme.name,
    'reminderEnabled': reminderEnabled,
    'biometricEnabled': biometricEnabled,
  };

  @override
  bool operator ==(Object other) =>
      other is SettingsModel &&
      other.theme == theme &&
      other.reminderEnabled == reminderEnabled &&
      other.biometricEnabled == biometricEnabled;

  @override
  int get hashCode => Object.hash(theme, reminderEnabled, biometricEnabled);
}
