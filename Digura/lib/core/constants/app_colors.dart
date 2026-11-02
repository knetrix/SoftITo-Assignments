import 'package:flutter/material.dart'; // Color, ThemeExtension ve BoxShadow Tiplerini Sağlayan Material Kütüphanesini import Eder.

import 'app_strings.dart'; // Duygu Etiketleri İçin AppStrings'i import Eder.

/// Beş duygu ve renk çiftleri (DESIGN.md Bölüm 2.3, tek kaynak).
///
/// OKLCH değerleri sRGB'ye çevrilmiştir; duygu rengi yalnızca dolgudur,
/// üstündeki yazı/simge daima [onColorFor] çiftinden alınır.
enum Mood { // Beş Duyguyu ve Renk Çiftlerini Tanımlayan Enum'dur.
  joyful( // Neşeli Duygu Değeridir.
    id: 'joyful', // Kalıcı Depoda Kullanılan id'dir.
    label: AppStrings.moodJoyful, // Kullanıcıya Görünen Etikettir.
    lightColor: Color(0xFFF6C835), // oklch(85% 0.16 90)
    onLightColor: Color(0xFF312103), // oklch(26% 0.05 80)
    darkColor: Color(0xFFF0C543), // oklch(84% 0.15 90)
    onDarkColor: AppColors.onMoodDark, // Koyu Temada Üstteki Yazı Rengidir.
  ),
  calmSad( // Sakin / Hüzünlü Duygu Değeridir.
    id: 'calmSad', // Kalıcı Depoda Kullanılan id'dir.
    label: AppStrings.moodCalmSad, // Kullanıcıya Görünen Etikettir.
    lightColor: Color(0xFF1870C2), // oklch(54% 0.15 252)
    onLightColor: Color(0xFFFCFCFC), // oklch(99% 0 0)
    darkColor: Color(0xFF5AA3EC), // oklch(70% 0.13 250)
    onDarkColor: AppColors.onMoodDark, // Koyu Temada Üstteki Yazı Rengidir.
  ),
  angryStressed( // Öfkeli / Stresli Duygu Değeridir.
    id: 'angryStressed', // Kalıcı Depoda Kullanılan id'dir.
    label: AppStrings.moodAngryStressed, // Kullanıcıya Görünen Etikettir.
    lightColor: Color(0xFFD42F34), // oklch(57% 0.2 25)
    onLightColor: Color(0xFFFCFCFC), // oklch(99% 0 0)
    darkColor: Color(0xFFEF6661), // oklch(68% 0.17 25)
    onDarkColor: AppColors.onMoodDark, // Koyu Temada Üstteki Yazı Rengidir.
  ),
  serene( // Dingin Duygu Değeridir.
    id: 'serene', // Kalıcı Depoda Kullanılan id'dir.
    label: AppStrings.moodSerene, // Kullanıcıya Görünen Etikettir.
    lightColor: Color(0xFF47B777), // oklch(70% 0.14 155)
    onLightColor: Color(0xFF032110), // oklch(22% 0.05 155)
    darkColor: Color(0xFF63BE86), // oklch(73% 0.12 155)
    onDarkColor: AppColors.onMoodDark, // Koyu Temada Üstteki Yazı Rengidir.
  ),
  tired( // Yorgun Duygu Değeridir.
    id: 'tired', // Kalıcı Depoda Kullanılan id'dir.
    label: AppStrings.moodTired, // Kullanıcıya Görünen Etikettir.
    lightColor: Color(0xFF9499A0), // oklch(68% 0.012 260)
    onLightColor: Color(0xFF13161B), // oklch(20% 0.01 260)
    darkColor: Color(0xFF82868E), // oklch(62% 0.012 260)
    onDarkColor: AppColors.onMoodDark, // Koyu Temada Üstteki Yazı Rengidir.
  );

  final String id; // Duygunun Benzersiz id'sidir.
  final String label; // Duygunun Görünen Etiketidir.
  final Color lightColor; // Açık Temadaki Dolgu Rengidir.
  final Color onLightColor; // Açık Temada Dolgu Üstündeki Yazı Rengidir.
  final Color darkColor; // Koyu Temadaki Dolgu Rengidir.
  final Color onDarkColor; // Koyu Temada Dolgu Üstündeki Yazı Rengidir.

  const Mood({ // Tüm Field'ları Alan const Constructor'dır.
    required this.id, // id Field'ını required Yapar.
    required this.label, // label Field'ını required Yapar.
    required this.lightColor, // lightColor Field'ını required Yapar.
    required this.onLightColor, // onLightColor Field'ını required Yapar.
    required this.darkColor, // darkColor Field'ını required Yapar.
    required this.onDarkColor, // onDarkColor Field'ını required Yapar.
  });

  /// Seçicideki iki satırlı etiket: "Sakin /\nHüzünlü".
  String get stackedLabel => label.replaceAll(' / ', ' /\n'); // Etiketi Eğik Çizgiden Sonra Alt Satıra Böler.

  Color colorFor(Brightness brightness) => brightness == Brightness.dark ? darkColor : lightColor; // Parlaklığa Göre Dolgu Rengini Döndürür.

  Color onColorFor(Brightness brightness) => brightness == Brightness.dark ? onDarkColor : onLightColor; // Parlaklığa Göre Üstteki Yazı Rengini Döndürür.

  static Mood? fromId(String? id) { // id'ye Göre Mood Değerini Bulur.
    for (final mood in values) { // Tüm Mood Değerlerini Gezer.
      if (mood.id == id) return mood; // id Eşleşirse O Mood'u Döndürür.
    }
    return null; // Eşleşme Yoksa null Döndürür.
  }
}

/// Nötr yüzey ve durum jetonları (DESIGN.md Bölüm 2.1 ve 2.2).
abstract final class AppColors { // Nötr Yüzey ve Durum Renk Sabitlerini Tutan Class'tır.
  // Açık tema (Material jetonları)
  static const Color lightBg = Color(0xFFF8FAFD); // Açık Temanın Arka Plan Rengidir.
  static const Color lightSurface = Color(0xFFFFFFFF); // Açık Temanın Yüzey Rengidir.
  static const Color lightSurfaceWarm = Color(0xFFE8F0FE); // Açık Temanın Sıcak Yüzey Rengidir.
  static const Color lightFg = Color(0xFF202124); // Açık Temanın Ana Yazı Rengidir.
  static const Color lightFg2 = Color(0xFF3C4043); // Açık Temanın İkincil Yazı Rengidir.
  static const Color lightMuted = Color(0xFF5F6368); // Açık Temanın Soluk Yazı Rengidir.
  static const Color lightBorder = Color(0xFFDADCE0); // Açık Temanın Kenarlık Rengidir.
  static const Color lightBorderSoft = Color(0xFFEDF0F2); // Açık Temanın Yumuşak Kenarlık Rengidir.
  static const Color lightAccent = Color(0xFF1A73E8); // Açık Temanın Vurgu Rengidir.
  static const Color lightAccentOn = Color(0xFFFFFFFF); // Açık Temada Vurgu Üstündeki Yazı Rengidir.
  static const Color lightAccentActive = Color(0xFF135DBE); // vurgu + %14 siyah (oklab)
  static const Color lightEmpty = Color(0xFFEBEDEF); // oklch(94.5% 0.004 255)
  static const Color lightKey = Color(0xFFF2F4F6); // oklch(96.5% 0.004 255)
  static const Color lightKeyActive = Color(0xFFC7CBD0); // oklch(84% 0.008 255)
  static const Color lightKeyDisabled = Color(0xFFABAEB2); // oklch(75% 0.006 255)
  static const Color lightSuccess = Color(0xFF188038); // Açık Temanın Başarı Rengidir.
  static const Color lightWarn = Color(0xFFF9AB00); // Açık Temanın Uyarı Rengidir.
  static const Color lightDanger = Color(0xFFD93025); // Açık Temanın Tehlike Rengidir.
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
  static const Color darkWarn = Color(0xFFF9AB00); // Koyu Temanın Uyarı Rengidir.
  static const Color darkDanger = Color(0xFFFC7A73); // oklch(73% 0.16 25)
  static const Color darkSuccessSoft = Color(0xFF1A3520); // oklch(30% 0.05 150)
  static const Color darkDangerSoft = Color(0xFF442321); // oklch(30% 0.05 25)
  static const Color darkScrim = Color(0x99000000); // oklch(5% 0 0 / 0.6)
  static const Color darkShadow = Color(0x66000000); // siyah %40
  static const Color darkRaisedSheet = Color(0xFF1A1D21); // oklch(23% 0.009 255)

  /// Koyu temada her duygu renginin üstündeki yazı: oklch(18% 0.02 255).
  static const Color onMoodDark = Color(0xFF0C121A); // Koyu Temada Duygu Rengi Üstündeki Yazı Rengidir.

  /// Odak halkası: 0 0 0 4px rgba(26,115,232,.24).
  static const Color focusRing = Color(0x3D1A73E8); // Odak Halkasının Yarı Saydam Rengidir.

  /// Yerel açılış ekranı koyu zemini (PROJECT_NEW.md 7.2).
  static const Color splashDark = Color(0xFF0B0D12); // Koyu Splash Ekranının Arka Plan Rengidir.
}

/// Etkin temanın jeton seti. Widget'lar renkleri yalnızca buradan okur:
/// `context.palette.surface`.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class AppPalette extends ThemeExtension<AppPalette> { // Etkin Temanın Renk Setini Taşıyan ThemeExtension'dır.
  final Brightness brightness; // Paletin Açık ya da Koyu Olduğunu Belirtir.
  final Color bg; // Arka Plan Rengidir.
  final Color surface; // Yüzey Rengidir.
  final Color surfaceWarm; // Sıcak Yüzey Rengidir.
  final Color fg; // Ana Yazı Rengidir.
  final Color fg2; // İkincil Yazı Rengidir.
  final Color muted; // Soluk Yazı Rengidir.
  final Color border; // Kenarlık Rengidir.
  final Color borderSoft; // Yumuşak Kenarlık Rengidir.
  final Color accent; // Vurgu Rengidir.
  final Color accentOn; // Vurgu Üstündeki Yazı Rengidir.
  final Color accentActive; // Basılı Vurgu Rengidir.
  final Color empty; // Boş Gün Hücresi Rengidir.
  final Color key; // Tuş Takımı Tuş Rengidir.
  final Color keyActive; // Basılı Tuş Rengidir.
  final Color keyDisabled; // Devre Dışı Tuş Rengidir.
  final Color success; // Başarı Rengidir.
  final Color warn; // Uyarı Rengidir.
  final Color danger; // Tehlike Rengidir.
  final Color successSoft; // Yumuşak Başarı Arka Plan Rengidir.
  final Color dangerSoft; // Yumuşak Tehlike Arka Plan Rengidir.
  final Color scrim; // Karartma Katmanı Rengidir.
  final Color shadow; // Gölge Rengidir.
  final Color raisedSheet; // Yükseltilmiş Panel Rengidir.

  const AppPalette({ // Tüm Renk Field'larını Alan const Constructor'dır.
    required this.brightness, // brightness Field'ını required Yapar.
    required this.bg, // bg Field'ını required Yapar.
    required this.surface, // surface Field'ını required Yapar.
    required this.surfaceWarm, // surfaceWarm Field'ını required Yapar.
    required this.fg, // fg Field'ını required Yapar.
    required this.fg2, // fg2 Field'ını required Yapar.
    required this.muted, // muted Field'ını required Yapar.
    required this.border, // border Field'ını required Yapar.
    required this.borderSoft, // borderSoft Field'ını required Yapar.
    required this.accent, // accent Field'ını required Yapar.
    required this.accentOn, // accentOn Field'ını required Yapar.
    required this.accentActive, // accentActive Field'ını required Yapar.
    required this.empty, // empty Field'ını required Yapar.
    required this.key, // key Field'ını required Yapar.
    required this.keyActive, // keyActive Field'ını required Yapar.
    required this.keyDisabled, // keyDisabled Field'ını required Yapar.
    required this.success, // success Field'ını required Yapar.
    required this.warn, // warn Field'ını required Yapar.
    required this.danger, // danger Field'ını required Yapar.
    required this.successSoft, // successSoft Field'ını required Yapar.
    required this.dangerSoft, // dangerSoft Field'ını required Yapar.
    required this.scrim, // scrim Field'ını required Yapar.
    required this.shadow, // shadow Field'ını required Yapar.
    required this.raisedSheet, // raisedSheet Field'ını required Yapar.
  });

  static const AppPalette light = AppPalette( // Açık Temanın Renk Paletidir.
    brightness: Brightness.light, // Paleti Açık Parlaklık Olarak İşaretler.
    bg: AppColors.lightBg, // Açık Arka Plan Rengini Atar.
    surface: AppColors.lightSurface, // Açık Yüzey Rengini Atar.
    surfaceWarm: AppColors.lightSurfaceWarm, // Açık Sıcak Yüzey Rengini Atar.
    fg: AppColors.lightFg, // Açık Ana Yazı Rengini Atar.
    fg2: AppColors.lightFg2, // Açık İkincil Yazı Rengini Atar.
    muted: AppColors.lightMuted, // Açık Soluk Yazı Rengini Atar.
    border: AppColors.lightBorder, // Açık Kenarlık Rengini Atar.
    borderSoft: AppColors.lightBorderSoft, // Açık Yumuşak Kenarlık Rengini Atar.
    accent: AppColors.lightAccent, // Açık Vurgu Rengini Atar.
    accentOn: AppColors.lightAccentOn, // Açık Vurgu Üstü Yazı Rengini Atar.
    accentActive: AppColors.lightAccentActive, // Açık Basılı Vurgu Rengini Atar.
    empty: AppColors.lightEmpty, // Açık Boş Hücre Rengini Atar.
    key: AppColors.lightKey, // Açık Tuş Rengini Atar.
    keyActive: AppColors.lightKeyActive, // Açık Basılı Tuş Rengini Atar.
    keyDisabled: AppColors.lightKeyDisabled, // Açık Devre Dışı Tuş Rengini Atar.
    success: AppColors.lightSuccess, // Açık Başarı Rengini Atar.
    warn: AppColors.lightWarn, // Açık Uyarı Rengini Atar.
    danger: AppColors.lightDanger, // Açık Tehlike Rengini Atar.
    successSoft: AppColors.lightSuccessSoft, // Açık Yumuşak Başarı Rengini Atar.
    dangerSoft: AppColors.lightDangerSoft, // Açık Yumuşak Tehlike Rengini Atar.
    scrim: AppColors.lightScrim, // Açık Karartma Rengini Atar.
    shadow: AppColors.lightShadow, // Açık Gölge Rengini Atar.
    raisedSheet: AppColors.lightSurface, // Açık Temada Yükseltilmiş Paneli Yüzey Rengi Yapar.
  );

  static const AppPalette dark = AppPalette( // Koyu Temanın Renk Paletidir.
    brightness: Brightness.dark, // Paleti Koyu Parlaklık Olarak İşaretler.
    bg: AppColors.darkBg, // Koyu Arka Plan Rengini Atar.
    surface: AppColors.darkSurface, // Koyu Yüzey Rengini Atar.
    surfaceWarm: AppColors.darkSurfaceWarm, // Koyu Sıcak Yüzey Rengini Atar.
    fg: AppColors.darkFg, // Koyu Ana Yazı Rengini Atar.
    fg2: AppColors.darkFg2, // Koyu İkincil Yazı Rengini Atar.
    muted: AppColors.darkMuted, // Koyu Soluk Yazı Rengini Atar.
    border: AppColors.darkBorder, // Koyu Kenarlık Rengini Atar.
    borderSoft: AppColors.darkBorderSoft, // Koyu Yumuşak Kenarlık Rengini Atar.
    accent: AppColors.darkAccent, // Koyu Vurgu Rengini Atar.
    accentOn: AppColors.darkAccentOn, // Koyu Vurgu Üstü Yazı Rengini Atar.
    accentActive: AppColors.darkAccentActive, // Koyu Basılı Vurgu Rengini Atar.
    empty: AppColors.darkEmpty, // Koyu Boş Hücre Rengini Atar.
    key: AppColors.darkKey, // Koyu Tuş Rengini Atar.
    keyActive: AppColors.darkKeyActive, // Koyu Basılı Tuş Rengini Atar.
    keyDisabled: AppColors.darkKeyDisabled, // Koyu Devre Dışı Tuş Rengini Atar.
    success: AppColors.darkSuccess, // Koyu Başarı Rengini Atar.
    warn: AppColors.darkWarn, // Koyu Uyarı Rengini Atar.
    danger: AppColors.darkDanger, // Koyu Tehlike Rengini Atar.
    successSoft: AppColors.darkSuccessSoft, // Koyu Yumuşak Başarı Rengini Atar.
    dangerSoft: AppColors.darkDangerSoft, // Koyu Yumuşak Tehlike Rengini Atar.
    scrim: AppColors.darkScrim, // Koyu Karartma Rengini Atar.
    shadow: AppColors.darkShadow, // Koyu Gölge Rengini Atar.
    raisedSheet: AppColors.darkRaisedSheet, // Koyu Yükseltilmiş Panel Rengini Atar.
  );

  bool get isDark => brightness == Brightness.dark; // Paletin Koyu Olup Olmadığını Döndürür.

  Color mood(Mood mood) => mood.colorFor(brightness); // Temaya Uygun Duygu Dolgu Rengini Döndürür.
  Color onMood(Mood mood) => mood.onColorFor(brightness); // Temaya Uygun Duygu Üstü Yazı Rengini Döndürür.

  /// Öne çıkan kart gölgesi (`--elev-raised`).
  List<BoxShadow> get raised => [ // Yükseltilmiş Kart Gölgesini Döndüren Getter'dır.
    isDark ? cssShadow(color: shadow, y: 3, blur: 12) : cssShadow(color: shadow, y: 3, blur: 8), // Temaya Göre Bulanıklığı Farklı Gölge Üretir.
  ];

  @override // Superclass'taki copyWith Metodunun Override Edildiğini Belirtir.
  AppPalette copyWith() => this; // Değişiklik Desteklenmediği İçin Aynı Paleti Döndürür.

  @override // Superclass'taki lerp Metodunun Override Edildiğini Belirtir.
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) { // İki Palet Arasında Tema Geçişi İçin Ara Değer Üretir.
    if (other is! AppPalette) return this; // Diğeri AppPalette Değilse Mevcut Paleti Döndürür.
    Color l(Color a, Color b) => Color.lerp(a, b, t)!; // İki Renk Arasında t Oranında Ara Renk Hesaplar.
    return AppPalette( // Ara Renklerle Yeni AppPalette Döndürür.
      brightness: t < 0.5 ? brightness : other.brightness, // Geçişin Yarısında Parlaklığı Değiştirir.
      bg: l(bg, other.bg), // Arka Plan Rengini Ara Değerler.
      surface: l(surface, other.surface), // Yüzey Rengini Ara Değerler.
      surfaceWarm: l(surfaceWarm, other.surfaceWarm), // Sıcak Yüzey Rengini Ara Değerler.
      fg: l(fg, other.fg), // Ana Yazı Rengini Ara Değerler.
      fg2: l(fg2, other.fg2), // İkincil Yazı Rengini Ara Değerler.
      muted: l(muted, other.muted), // Soluk Yazı Rengini Ara Değerler.
      border: l(border, other.border), // Kenarlık Rengini Ara Değerler.
      borderSoft: l(borderSoft, other.borderSoft), // Yumuşak Kenarlık Rengini Ara Değerler.
      accent: l(accent, other.accent), // Vurgu Rengini Ara Değerler.
      accentOn: l(accentOn, other.accentOn), // Vurgu Üstü Yazı Rengini Ara Değerler.
      accentActive: l(accentActive, other.accentActive), // Basılı Vurgu Rengini Ara Değerler.
      empty: l(empty, other.empty), // Boş Hücre Rengini Ara Değerler.
      key: l(key, other.key), // Tuş Rengini Ara Değerler.
      keyActive: l(keyActive, other.keyActive), // Basılı Tuş Rengini Ara Değerler.
      keyDisabled: l(keyDisabled, other.keyDisabled), // Devre Dışı Tuş Rengini Ara Değerler.
      success: l(success, other.success), // Başarı Rengini Ara Değerler.
      warn: l(warn, other.warn), // Uyarı Rengini Ara Değerler.
      danger: l(danger, other.danger), // Tehlike Rengini Ara Değerler.
      successSoft: l(successSoft, other.successSoft), // Yumuşak Başarı Rengini Ara Değerler.
      dangerSoft: l(dangerSoft, other.dangerSoft), // Yumuşak Tehlike Rengini Ara Değerler.
      scrim: l(scrim, other.scrim), // Karartma Rengini Ara Değerler.
      shadow: l(shadow, other.shadow), // Gölge Rengini Ara Değerler.
      raisedSheet: l(raisedSheet, other.raisedSheet), // Yükseltilmiş Panel Rengini Ara Değerler.
    );
  }
}

/// CSS `box-shadow` değerini Flutter gölgesine çevirir.
///
/// CSS bulanıklık yarıçapı `2σ`, Flutter'ın `blurRadius` değeri ise
/// `σ = r · 0.57735 + 0.5` ile çevrilir; bu yardımcı ikisini eşler.
BoxShadow cssShadow({required Color color, double x = 0, double y = 0, double blur = 0, double spread = 0}) { // CSS Gölge Değerlerinden BoxShadow Üretir.
  final sigma = blur / 2; // CSS Bulanıklığından Sigma Değerini Hesaplar.
  final radius = sigma <= 0.5 ? 0.0 : (sigma - 0.5) / 0.57735; // Sigma'yı Flutter blurRadius Değerine Çevirir.
  return BoxShadow(color: color, offset: Offset(x, y), blurRadius: radius, spreadRadius: spread); // Hesaplanan Değerlerle BoxShadow Döndürür.
}

extension PaletteContext on BuildContext { // BuildContext'e palette Getter'ı Ekleyen Extension'dır.
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light; // Etkin Temanın Paletini, Yoksa Açık Paleti Döndürür.
}
