import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_motion.dart';

/// Yazı tipi yığınları (DESIGN.md Bölüm 3). Google Sans lisanslı olduğundan
/// display rolünde de Roboto kullanılır; tamamı pakete gömülüdür.
abstract final class AppFonts {
  static const String display = 'Roboto';
  static const String body = 'Roboto';
  static const String mono = 'RobotoMono';
}

/// CSS tipografi ölçülerini Flutter `TextStyle`'a çeviren yardımcılar.
///
/// `tracking` em cinsindendir (ör. `0.08` → `0.08em`); satır yüksekliği CSS'teki
/// gibi yarım aralıkla (`even`) dağıtılır.
abstract final class AppTypography {
  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w500,
    double height = 1.2,
    double tracking = 0,
    Color? color,
  }) => TextStyle(
    fontFamily: AppFonts.display,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: tracking * size,
    color: color,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
    double tracking = 0,
    Color? color,
  }) => TextStyle(
    fontFamily: AppFonts.body,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: tracking * size,
    color: color,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Mono: tarih, sayaç, adım etiketleri. Rakamlar `tabular-nums`.
  static TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w400,
    double height = 1.4,
    double tracking = 0,
    Color? color,
  }) => TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: tracking * size,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Mono üstbilgi etiketi: BÜYÜK HARF + 0,08em izleme.
  static TextStyle eyebrow(double size, Color color) => mono(size, tracking: 0.08, color: color);
}

/// Material 3 açık/koyu tema (DESIGN.md Bölüm 11).
abstract final class AppTheme {
  static ThemeData light() => _build(AppPalette.light);

  static ThemeData dark() => _build(AppPalette.dark);

  static ThemeData _build(AppPalette p) {
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.accent,
      onPrimary: p.accentOn,
      secondary: p.accent,
      onSecondary: p.accentOn,
      error: p.danger,
      onError: p.surface,
      surface: p.surface,
      onSurface: p.fg,
      onSurfaceVariant: p.muted,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.bg,
      surfaceContainer: p.borderSoft,
      surfaceContainerHigh: p.surfaceWarm,
      surfaceContainerHighest: p.surfaceWarm,
      outline: p.border,
      outlineVariant: p.borderSoft,
      scrim: p.scrim,
      shadow: p.shadow,
      inverseSurface: p.fg,
      onInverseSurface: p.surface,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      fontFamily: AppFonts.body,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.surface,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: AppColors.focusRing,
      extensions: [p],
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: AppFonts.body, bodyColor: p.fg, displayColor: p.fg),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.fg,
        selectionColor: p.fg.withValues(alpha: 0.18),
        selectionHandleColor: p.fg,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accentOn : p.muted),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accent : p.borderSoft),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accent : p.muted,
        ),
        trackOutlineWidth: const WidgetStatePropertyAll(2),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.fg,
        contentTextStyle: AppTypography.body(14, height: 1.4, color: p.surface),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
      ),
    );
  }

  /// Tema değişiminde (Açık ↔ Koyu) renklerin geçiş süresi.
  static const Duration themeAnimation = AppMotion.ui;
}
