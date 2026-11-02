import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını ve Tema Tiplerini import Eder.

import '../constants/app_colors.dart'; // AppColors ve AppPalette Renk Jetonlarını import Eder.
import '../constants/app_motion.dart'; // AppMotion Süre Jetonlarını import Eder.

/// Yazı tipi yığınları (DESIGN.md Bölüm 3). Google Sans lisanslı olduğundan
/// display rolünde de Roboto kullanılır; tamamı pakete gömülüdür.
abstract final class AppFonts { // Uygulamanın Yazı Tipi Ailelerini Tutan Class'tır.
  static const String display = 'Roboto'; // Başlık Yazı Tipi Ailesidir.
  static const String body = 'Roboto'; // Gövde Metni Yazı Tipi Ailesidir.
  static const String mono = 'RobotoMono'; // Eş Aralıklı Yazı Tipi Ailesidir.
}

/// CSS tipografi ölçülerini Flutter `TextStyle`'a çeviren yardımcılar.
///
/// `tracking` em cinsindendir (ör. `0.08` → `0.08em`); satır yüksekliği CSS'teki
/// gibi yarım aralıkla (`even`) dağıtılır.
abstract final class AppTypography { // Tipografi Stillerini Üreten Yardımcı Class'tır.
  static TextStyle display( // Başlık Yazı Stili Üretir.
    double size, { // Yazı Boyutu Parametresidir.
    FontWeight weight = FontWeight.w500, // Varsayılan Kalınlığı w500 Olarak Ayarlar.
    double height = 1.2, // Varsayılan Satır Yüksekliğini 1.2 Olarak Ayarlar.
    double tracking = 0, // em Cinsinden Harf Aralığıdır.
    Color? color, // İsteğe Bağlı Yazı Rengidir.
  }) => TextStyle( // Parametrelerle Yeni TextStyle Döndürür.
    fontFamily: AppFonts.display, // Başlık Yazı Tipini Kullanır.
    fontSize: size, // Yazı Boyutunu Ayarlar.
    fontWeight: weight, // Yazı Kalınlığını Ayarlar.
    height: height, // Satır Yüksekliğini Ayarlar.
    letterSpacing: tracking * size, // em Değerini Piksel Harf Aralığına Çevirir.
    color: color, // Yazı Rengini Ayarlar.
    leadingDistribution: TextLeadingDistribution.even, // Satır Aralığını Üst ve Alta Eşit Dağıtır.
  );

  static TextStyle body( // Gövde Metni Yazı Stili Üretir.
    double size, { // Yazı Boyutu Parametresidir.
    FontWeight weight = FontWeight.w400, // Varsayılan Kalınlığı w400 Olarak Ayarlar.
    double height = 1.5, // Varsayılan Satır Yüksekliğini 1.5 Olarak Ayarlar.
    double tracking = 0, // em Cinsinden Harf Aralığıdır.
    Color? color, // İsteğe Bağlı Yazı Rengidir.
  }) => TextStyle( // Parametrelerle Yeni TextStyle Döndürür.
    fontFamily: AppFonts.body, // Gövde Yazı Tipini Kullanır.
    fontSize: size, // Yazı Boyutunu Ayarlar.
    fontWeight: weight, // Yazı Kalınlığını Ayarlar.
    height: height, // Satır Yüksekliğini Ayarlar.
    letterSpacing: tracking * size, // em Değerini Piksel Harf Aralığına Çevirir.
    color: color, // Yazı Rengini Ayarlar.
    leadingDistribution: TextLeadingDistribution.even, // Satır Aralığını Üst ve Alta Eşit Dağıtır.
  );

  /// Mono: tarih, sayaç, adım etiketleri. Rakamlar `tabular-nums`.
  static TextStyle mono( // Eş Aralıklı Yazı Stili Üretir.
    double size, { // Yazı Boyutu Parametresidir.
    FontWeight weight = FontWeight.w400, // Varsayılan Kalınlığı w400 Olarak Ayarlar.
    double height = 1.4, // Varsayılan Satır Yüksekliğini 1.4 Olarak Ayarlar.
    double tracking = 0, // em Cinsinden Harf Aralığıdır.
    Color? color, // İsteğe Bağlı Yazı Rengidir.
  }) => TextStyle( // Parametrelerle Yeni TextStyle Döndürür.
    fontFamily: AppFonts.mono, // Mono Yazı Tipini Kullanır.
    fontSize: size, // Yazı Boyutunu Ayarlar.
    fontWeight: weight, // Yazı Kalınlığını Ayarlar.
    height: height, // Satır Yüksekliğini Ayarlar.
    letterSpacing: tracking * size, // em Değerini Piksel Harf Aralığına Çevirir.
    color: color, // Yazı Rengini Ayarlar.
    fontFeatures: const [FontFeature.tabularFigures()], // Rakamları Eşit Genişlikte Gösterir.
    leadingDistribution: TextLeadingDistribution.even, // Satır Aralığını Üst ve Alta Eşit Dağıtır.
  );

  /// Mono üstbilgi etiketi: BÜYÜK HARF + 0,08em izleme.
  static TextStyle eyebrow(double size, Color color) => mono(size, tracking: 0.08, color: color); // 0.08em Aralıklı Mono Üstbilgi Stili Döndürür.
}

/// Material 3 açık/koyu tema (DESIGN.md Bölüm 11).
abstract final class AppTheme { // Uygulamanın Açık ve Koyu Temalarını Üreten Class'tır.
  static ThemeData light() => _build(AppPalette.light); // Açık Paletle ThemeData Döndürür.

  static ThemeData dark() => _build(AppPalette.dark); // Koyu Paletle ThemeData Döndürür.

  static ThemeData _build(AppPalette p) { // Verilen Paletten ThemeData Oluşturur.
    final scheme = ColorScheme( // Paletten Material ColorScheme Oluşturur.
      brightness: p.brightness, // Tema Parlaklığını Ayarlar.
      primary: p.accent, // Birincil Rengi Vurgu Rengi Yapar.
      onPrimary: p.accentOn, // Birincil Renk Üstündeki Yazı Rengini Ayarlar.
      secondary: p.accent, // İkincil Rengi Vurgu Rengi Yapar.
      onSecondary: p.accentOn, // İkincil Renk Üstündeki Yazı Rengini Ayarlar.
      error: p.danger, // Hata Rengini Ayarlar.
      onError: p.surface, // Hata Rengi Üstündeki Yazı Rengini Ayarlar.
      surface: p.surface, // Yüzey Rengini Ayarlar.
      onSurface: p.fg, // Yüzey Üstündeki Yazı Rengini Ayarlar.
      onSurfaceVariant: p.muted, // İkincil Yüzey Yazı Rengini Soluk Renk Yapar.
      surfaceContainerLowest: p.surface, // En Alt Konteyner Yüzey Rengini Ayarlar.
      surfaceContainerLow: p.bg, // Alçak Konteyner Yüzey Rengini Ayarlar.
      surfaceContainer: p.borderSoft, // Konteyner Yüzey Rengini Ayarlar.
      surfaceContainerHigh: p.surfaceWarm, // Yüksek Konteyner Yüzey Rengini Ayarlar.
      surfaceContainerHighest: p.surfaceWarm, // En Yüksek Konteyner Yüzey Rengini Ayarlar.
      outline: p.border, // Kenarlık Rengini Ayarlar.
      outlineVariant: p.borderSoft, // Yumuşak Kenarlık Rengini Ayarlar.
      scrim: p.scrim, // Karartma Katmanı Rengini Ayarlar.
      shadow: p.shadow, // Gölge Rengini Ayarlar.
      inverseSurface: p.fg, // Ters Yüzey Rengini Ayarlar.
      onInverseSurface: p.surface, // Ters Yüzey Üstündeki Yazı Rengini Ayarlar.
      surfaceTint: Colors.transparent, // Yüzey Renk Tonlamasını Kapatır.
    );

    final base = ThemeData( // Temel ThemeData'yı Oluşturur.
      useMaterial3: true, // Material 3 Tasarımını Etkinleştirir.
      brightness: p.brightness, // Tema Parlaklığını Ayarlar.
      colorScheme: scheme, // Oluşturulan ColorScheme'i Uygular.
      fontFamily: AppFonts.body, // Varsayılan Yazı Tipini Ayarlar.
      scaffoldBackgroundColor: p.bg, // Scaffold Arka Plan Rengini Ayarlar.
      canvasColor: p.surface, // Canvas Rengini Ayarlar.
      splashFactory: NoSplash.splashFactory, // Dokunma Dalgalanma Efektini Kapatır.
      highlightColor: Colors.transparent, // Vurgulama Rengini Şeffaf Yapar.
      hoverColor: Colors.transparent, // Üzerine Gelme Rengini Şeffaf Yapar.
      focusColor: AppColors.focusRing, // Odak Halkası Rengini Ayarlar.
      extensions: [p], // AppPalette'i ThemeExtension Olarak Ekler.
    );

    return base.copyWith( // Temel Temayı Bileşen Temalarıyla Genişletip Döndürür.
      textTheme: base.textTheme.apply(fontFamily: AppFonts.body, bodyColor: p.fg, displayColor: p.fg), // Metin Temasına Yazı Tipi ve Renk Uygular.
      textSelectionTheme: TextSelectionThemeData( // Metin Seçimi Temasını Ayarlar.
        cursorColor: p.fg, // İmleç Rengini Ayarlar.
        selectionColor: p.fg.withValues(alpha: 0.18), // Seçim Vurgusu Rengini Ayarlar.
        selectionHandleColor: p.fg, // Seçim Tutamacı Rengini Ayarlar.
      ),
      switchTheme: SwitchThemeData( // Switch Bileşeni Temasını Ayarlar.
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accentOn : p.muted), // Seçim Durumuna Göre Topuz Rengini Belirler.
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accent : p.borderSoft), // Seçim Durumuna Göre Ray Rengini Belirler.
        trackOutlineColor: WidgetStateProperty.resolveWith( // Ray Kenarlık Rengini Duruma Göre Belirler.
          (s) => s.contains(WidgetState.selected) ? p.accent : p.muted, // Seçiliyse Vurgu, Değilse Soluk Renk Döndürür.
        ),
        trackOutlineWidth: const WidgetStatePropertyAll(2), // Ray Kenarlık Kalınlığını 2 Yapar.
        overlayColor: const WidgetStatePropertyAll(Colors.transparent), // Basma Katmanı Rengini Şeffaf Yapar.
        materialTapTargetSize: MaterialTapTargetSize.padded, // Dokunma Alanını Genişletilmiş Boyutta Tutar.
      ),
      snackBarTheme: SnackBarThemeData( // Snackbar Temasını Ayarlar.
        backgroundColor: p.fg, // Snackbar Arka Plan Rengini Ayarlar.
        contentTextStyle: AppTypography.body(14, height: 1.4, color: p.surface), // Snackbar Yazı Stilini Ayarlar.
        behavior: SnackBarBehavior.floating, // Snackbar'ı Yüzen Konumda Gösterir.
        elevation: 0, // Snackbar Gölgesini Kapatır.
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Snackbar Kenar Boşluklarını Ayarlar.
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))), // Snackbar Köşelerini 12 Yuvarlar.
      ),
      bottomSheetTheme: const BottomSheetThemeData( // Alt Panel Temasını Ayarlar.
        backgroundColor: Colors.transparent, // Alt Panel Arka Planını Şeffaf Yapar.
        elevation: 0, // Alt Panel Gölgesini Kapatır.
        modalElevation: 0, // Modal Alt Panel Gölgesini Kapatır.
        surfaceTintColor: Colors.transparent, // Yüzey Tonlamasını Kapatır.
        showDragHandle: false, // Sürükleme Tutamacını Gizler.
      ),
    );
  }

  /// Tema değişiminde (Açık ↔ Koyu) renklerin geçiş süresi.
  static const Duration themeAnimation = AppMotion.ui; // Tema Geçiş Süresini AppMotion.ui Olarak Tanımlar.
}
