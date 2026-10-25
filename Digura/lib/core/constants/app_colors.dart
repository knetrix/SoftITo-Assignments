import 'package:flutter/material.dart';

import 'app_strings.dart';

/// Beş duygu ve renk çiftleri (DESIGN.md Bölüm 2.3, tek kaynak).
///
/// OKLCH değerleri sRGB'ye çevrilmiştir; duygu rengi yalnızca dolgudur,
/// üstündeki yazı/simge daima [onColorFor] çiftinden alınır.
enum Mood {
  joyful(
    id: 'joyful',
    label: AppStrings.moodJoyful,
    lightColor: Color(0xFFF6C835), // oklch(85% 0.16 90)
    onLightColor: Color(0xFF312103), // oklch(26% 0.05 80)
    darkColor: Color(0xFFF0C543), // oklch(84% 0.15 90)
    onDarkColor: AppColors.onMoodDark,
  ),
  calmSad(
    id: 'calmSad',
    label: AppStrings.moodCalmSad,
    lightColor: Color(0xFF1870C2), // oklch(54% 0.15 252)
    onLightColor: Color(0xFFFCFCFC), // oklch(99% 0 0)
    darkColor: Color(0xFF5AA3EC), // oklch(70% 0.13 250)
    onDarkColor: AppColors.onMoodDark,
  ),
  angryStressed(
    id: 'angryStressed',
    label: AppStrings.moodAngryStressed,
    lightColor: Color(0xFFD42F34), // oklch(57% 0.2 25)
    onLightColor: Color(0xFFFCFCFC), // oklch(99% 0 0)
    darkColor: Color(0xFFEF6661), // oklch(68% 0.17 25)
    onDarkColor: AppColors.onMoodDark,
  ),
  serene(
    id: 'serene',
    label: AppStrings.moodSerene,
    lightColor: Color(0xFF47B777), // oklch(70% 0.14 155)
    onLightColor: Color(0xFF032110), // oklch(22% 0.05 155)
    darkColor: Color(0xFF63BE86), // oklch(73% 0.12 155)
    onDarkColor: AppColors.onMoodDark,
  ),
  tired(
    id: 'tired',
    label: AppStrings.moodTired,
    lightColor: Color(0xFF9499A0), // oklch(68% 0.012 260)
    onLightColor: Color(0xFF13161B), // oklch(20% 0.01 260)
    darkColor: Color(0xFF82868E), // oklch(62% 0.012 260)
    onDarkColor: AppColors.onMoodDark,
  );

  final String id;
  final String label;
  final Color lightColor;
  final Color onLightColor;
  final Color darkColor;
  final Color onDarkColor;

  const Mood({
    required this.id,
    required this.label,
    required this.lightColor,
    required this.onLightColor,
    required this.darkColor,
    required this.onDarkColor,
  });

  /// Seçicideki iki satırlı etiket: "Sakin /\nHüzünlü".
  String get stackedLabel => label.replaceAll(' / ', ' /\n');

  Color colorFor(Brightness brightness) => brightness == Brightness.dark ? darkColor : lightColor;

  Color onColorFor(Brightness brightness) => brightness == Brightness.dark ? onDarkColor : onLightColor;

  static Mood? fromId(String? id) {
    for (final mood in values) {
      if (mood.id == id) return mood;
    }
    return null;
  }
}

/// Nötr yüzey ve durum jetonları (DESIGN.md Bölüm 2.1 ve 2.2).
abstract final class AppColors {
  // Açık tema (Material jetonları)
  static const Color lightBg = Color(0xFFF8FAFD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceWarm = Color(0xFFE8F0FE);
  static const Color lightFg = Color(0xFF202124);
  static const Color lightFg2 = Color(0xFF3C4043);
  static const Color lightMuted = Color(0xFF5F6368);
  static const Color lightBorder = Color(0xFFDADCE0);
  static const Color lightBorderSoft = Color(0xFFEDF0F2);
  static const Color lightAccent = Color(0xFF1A73E8);
  static const Color lightAccentOn = Color(0xFFFFFFFF);
  static const Color lightAccentActive = Color(0xFF135DBE); // vurgu + %14 siyah (oklab)
  static const Color lightEmpty = Color(0xFFEBEDEF); // oklch(94.5% 0.004 255)
  static const Color lightKey = Color(0xFFF2F4F6); // oklch(96.5% 0.004 255)
  static const Color lightKeyActive = Color(0xFFC7CBD0); // oklch(84% 0.008 255)
  static const Color lightKeyDisabled = Color(0xFFABAEB2); // oklch(75% 0.006 255)
  static const Color lightSuccess = Color(0xFF188038);
  static const Color lightWarn = Color(0xFFF9AB00);
  static const Color lightDanger = Color(0xFFD93025);
  static const Color lightSuccessSoft = Color(0xFFD9F3DD); // oklch(94% 0.04 150)
  static const Color lightDangerSoft = Color(0xFFFFE7E4); // oklch(95% 0.03 25)
  static const Color lightScrim = Color(0x6B080B0F); // oklch(15% 0.01 255 / 0.42)
  static const Color lightShadow = Color(0x2E3C4043); // rgba(60,64,67,.18)

  // Koyu tema (Material'den türetilmiş OKLCH)
  static const Color darkBg = Color(0xFF0A0C0F); // oklch(15.5% 0.007 255)
  static const Color darkSurface = Color(0xFF111417); // oklch(19% 0.008 255)
  static const Color darkSurfaceWarm = Color(0xFF1B2A3C); // oklch(28% 0.04 255)
  static const Color darkFg = Color(0xFFE9EBEE); // oklch(94% 0.004 255)
  static const Color darkFg2 = Color(0xFFCED1D5); // oklch(86% 0.006 255)
  static const Color darkMuted = Color(0xFFA0A5AB); // oklch(72% 0.01 255)
  static const Color darkBorder = Color(0xFF3A3D42); // oklch(36% 0.01 255)
  static const Color darkBorderSoft = Color(0xFF212428); // oklch(26% 0.009 255)
  static const Color darkAccent = Color(0xFF7CB4FC); // oklch(76% 0.12 255)
  static const Color darkAccentOn = Color(0xFF08121F); // oklch(18% 0.03 255)
  static const Color darkAccentActive = Color(0xFF96C3FE); // vurgu + %20 beyaz (oklab)
  static const Color darkEmpty = Color(0xFF212428); // oklch(26% 0.009 255)
  static const Color darkKey = Color(0xFF1F2226); // oklch(25% 0.009 255)
  static const Color darkKeyActive = Color(0xFF3C4046); // oklch(37% 0.012 255)
  static const Color darkKeyDisabled = Color(0xFF4A4D51); // oklch(42% 0.008 255)
  static const Color darkSuccess = Color(0xFF6FD087); // oklch(78% 0.14 150)
  static const Color darkWarn = Color(0xFFF9AB00);
  static const Color darkDanger = Color(0xFFFC7A73); // oklch(73% 0.16 25)
  static const Color darkSuccessSoft = Color(0xFF1A3520); // oklch(30% 0.05 150)
  static const Color darkDangerSoft = Color(0xFF442321); // oklch(30% 0.05 25)
  static const Color darkScrim = Color(0x99000000); // oklch(5% 0 0 / 0.6)
  static const Color darkShadow = Color(0x66000000); // siyah %40
  static const Color darkRaisedSheet = Color(0xFF1A1D21); // oklch(23% 0.009 255)

  /// Koyu temada her duygu renginin üstündeki yazı: oklch(18% 0.02 255).
  static const Color onMoodDark = Color(0xFF0C121A);

  /// Odak halkası: 0 0 0 4px rgba(26,115,232,.24).
  static const Color focusRing = Color(0x3D1A73E8);

  /// Yerel açılış ekranı koyu zemini (PROJECT_NEW.md 7.2).
  static const Color splashDark = Color(0xFF0B0D12);
}

/// Etkin temanın jeton seti. Widget'lar renkleri yalnızca buradan okur:
/// `context.palette.surface`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Brightness brightness;
  final Color bg;
  final Color surface;
  final Color surfaceWarm;
  final Color fg;
  final Color fg2;
  final Color muted;
  final Color border;
  final Color borderSoft;
  final Color accent;
  final Color accentOn;
  final Color accentActive;
  final Color empty;
  final Color key;
  final Color keyActive;
  final Color keyDisabled;
  final Color success;
  final Color warn;
  final Color danger;
  final Color successSoft;
  final Color dangerSoft;
  final Color scrim;
  final Color shadow;
  final Color raisedSheet;

  const AppPalette({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surfaceWarm,
    required this.fg,
    required this.fg2,
    required this.muted,
    required this.border,
    required this.borderSoft,
    required this.accent,
    required this.accentOn,
    required this.accentActive,
    required this.empty,
    required this.key,
    required this.keyActive,
    required this.keyDisabled,
    required this.success,
    required this.warn,
    required this.danger,
    required this.successSoft,
    required this.dangerSoft,
    required this.scrim,
    required this.shadow,
    required this.raisedSheet,
  });

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    bg: AppColors.lightBg,
    surface: AppColors.lightSurface,
    surfaceWarm: AppColors.lightSurfaceWarm,
    fg: AppColors.lightFg,
    fg2: AppColors.lightFg2,
    muted: AppColors.lightMuted,
    border: AppColors.lightBorder,
    borderSoft: AppColors.lightBorderSoft,
    accent: AppColors.lightAccent,
    accentOn: AppColors.lightAccentOn,
    accentActive: AppColors.lightAccentActive,
    empty: AppColors.lightEmpty,
    key: AppColors.lightKey,
    keyActive: AppColors.lightKeyActive,
    keyDisabled: AppColors.lightKeyDisabled,
    success: AppColors.lightSuccess,
    warn: AppColors.lightWarn,
    danger: AppColors.lightDanger,
    successSoft: AppColors.lightSuccessSoft,
    dangerSoft: AppColors.lightDangerSoft,
    scrim: AppColors.lightScrim,
    shadow: AppColors.lightShadow,
    raisedSheet: AppColors.lightSurface,
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    bg: AppColors.darkBg,
    surface: AppColors.darkSurface,
    surfaceWarm: AppColors.darkSurfaceWarm,
    fg: AppColors.darkFg,
    fg2: AppColors.darkFg2,
    muted: AppColors.darkMuted,
    border: AppColors.darkBorder,
    borderSoft: AppColors.darkBorderSoft,
    accent: AppColors.darkAccent,
    accentOn: AppColors.darkAccentOn,
    accentActive: AppColors.darkAccentActive,
    empty: AppColors.darkEmpty,
    key: AppColors.darkKey,
    keyActive: AppColors.darkKeyActive,
    keyDisabled: AppColors.darkKeyDisabled,
    success: AppColors.darkSuccess,
    warn: AppColors.darkWarn,
    danger: AppColors.darkDanger,
    successSoft: AppColors.darkSuccessSoft,
    dangerSoft: AppColors.darkDangerSoft,
    scrim: AppColors.darkScrim,
    shadow: AppColors.darkShadow,
    raisedSheet: AppColors.darkRaisedSheet,
  );

  bool get isDark => brightness == Brightness.dark;

  Color mood(Mood mood) => mood.colorFor(brightness);
  Color onMood(Mood mood) => mood.onColorFor(brightness);

  /// Öne çıkan kart gölgesi (`--elev-raised`).
  List<BoxShadow> get raised => [
    isDark ? cssShadow(color: shadow, y: 3, blur: 12) : cssShadow(color: shadow, y: 3, blur: 8),
  ];

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceWarm: l(surfaceWarm, other.surfaceWarm),
      fg: l(fg, other.fg),
      fg2: l(fg2, other.fg2),
      muted: l(muted, other.muted),
      border: l(border, other.border),
      borderSoft: l(borderSoft, other.borderSoft),
      accent: l(accent, other.accent),
      accentOn: l(accentOn, other.accentOn),
      accentActive: l(accentActive, other.accentActive),
      empty: l(empty, other.empty),
      key: l(key, other.key),
      keyActive: l(keyActive, other.keyActive),
      keyDisabled: l(keyDisabled, other.keyDisabled),
      success: l(success, other.success),
      warn: l(warn, other.warn),
      danger: l(danger, other.danger),
      successSoft: l(successSoft, other.successSoft),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      scrim: l(scrim, other.scrim),
      shadow: l(shadow, other.shadow),
      raisedSheet: l(raisedSheet, other.raisedSheet),
    );
  }
}

/// CSS `box-shadow` değerini Flutter gölgesine çevirir.
///
/// CSS bulanıklık yarıçapı `2σ`, Flutter'ın `blurRadius` değeri ise
/// `σ = r · 0.57735 + 0.5` ile çevrilir; bu yardımcı ikisini eşler.
BoxShadow cssShadow({required Color color, double x = 0, double y = 0, double blur = 0, double spread = 0}) {
  final sigma = blur / 2;
  final radius = sigma <= 0.5 ? 0.0 : (sigma - 0.5) / 0.57735;
  return BoxShadow(color: color, offset: Offset(x, y), blurRadius: radius, spreadRadius: spread);
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
