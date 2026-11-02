import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../constants/app_colors.dart'; // palette Erişimi İçin AppColors'ı import Eder.
import '../constants/app_icons.dart'; // AppIconData Tipini import Eder.
import '../constants/app_motion.dart'; // Basma Süre Ve Curve'leri İçin AppMotion'ı import Eder.
import '../theme/app_theme.dart'; // Yazı Stilleri İçin AppTypography'yi import Eder.
import 'app_icon.dart'; // Simge Çizen AppIcon Widget'ını import Eder.
import 'pressable.dart'; // Basma Geri Bildirimi Sağlayan Pressable Widget'ını import Eder.

/// Ana düğme: tam genişlik, min 52, hap. Basılıyken vurgu %14 koyulaşır ve
/// 0.97 ölçeklenir; pasifken `borderSoft` zemin + `muted` yazı.
class PrimaryButton extends StatelessWidget { // Tam Genişlikte Ana Eylem Düğmesi StatelessWidget'ıdır.
  final String label; // Düğme Metnidir.
  final VoidCallback? onPressed; // Basıldığında Çağrılan Callback'tir; null İse Düğme Pasiftir.

  /// Metin değişimini çapraz soldurmak için (onboarding "Devam" → "Günün rengini seç").
  final bool animateLabel; // Metin Değişiminin Animasyonlu Olup Olmayacağını Belirtir.

  const PrimaryButton({super.key, required this.label, required this.onPressed, this.animateLabel = false}); // label Ve onPressed'i required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Ana Düğmeyi Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    final enabled = onPressed != null; // onPressed Verildiyse Düğmeyi Etkin Sayar.
    final text = Text( // Düğme Metni Widget'ını Oluşturur.
      label, // Düğme Metnini Verir.
      key: ValueKey(label), // AnimatedSwitcher'ın Değişimi Algılaması İçin Metne Göre key Verir.
      textAlign: TextAlign.center, // Metni Ortalar.
      style: AppTypography.body( // Gövde Yazı Stilini Uygular.
        16, // Font Boyutunu 16 Yapar.
        weight: FontWeight.w500, // Font Kalınlığını w500 Yapar.
        height: 1.5, // Satır Yüksekliğini 1.5 Yapar.
        tracking: 0.02, // Harf Aralığını 0.02 Yapar.
        color: enabled ? p.accentOn : p.muted, // Etkinliğe Göre Metin Rengini Seçer.
      ),
    );
    return Pressable( // Basma Geri Bildirimli Düğmeyi Döndürür.
      onTap: onPressed, // Dokunma Callback'ini Bağlar.
      semanticLabel: label, // Ekran Okuyucu Etiketini Verir.
      builder: (context, pressed) => AnimatedContainer( // Basılı Durumuna Göre Rengi Animasyonla Değiştirir.
        duration: AppMotion.press, // Basma Animasyon Süresini Belirler.
        curve: AppMotion.easeOut, // Animasyon Curve'ünü Belirler.
        constraints: const BoxConstraints(minHeight: 52), // En Az 52 Yükseklik Verir.
        width: double.infinity, // Tam Genişlik Kaplar.
        alignment: Alignment.center, // İçeriği Ortalar.
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Düğmenin İç Boşluğunu Belirler.
        decoration: ShapeDecoration( // Hap Şekilli Dekorasyonu Tanımlar.
          shape: const StadiumBorder(), // Şekli Hap Yapar.
          color: !enabled ? p.borderSoft : (pressed ? p.accentActive : p.accent), // Pasif, Basılı Ya Da Normal Duruma Göre Zemin Rengini Seçer.
        ),
        child: ExcludeSemantics( // Metnin Ayrıca Okunmasını Engeller.
          child: animateLabel // animateLabel Açıksa Animasyonlu Metin Kullanır.
              ? AnimatedSwitcher( // Metin Değişimini Çapraz Soldurur.
                  duration: AppMotion.ctaSwap, // Metin Geçiş Süresini Belirler.
                  switchInCurve: AppMotion.easeOut, // Giriş Curve'ünü Belirler.
                  switchOutCurve: AppMotion.easeOut, // Çıkış Curve'ünü Belirler.
                  child: text, // Değişen Metni Verir.
                )
              : text, // Aksi Halde Metni Doğrudan Gösterir.
        ),
      ),
    );
  }
}

/// Metin düğmesi: min 44, hap. İsteğe bağlı baş/son simge.
class AppTextButton extends StatelessWidget { // İsteğe Bağlı Simgeli Metin Düğmesi StatelessWidget'ıdır.
  final String label; // Düğme Metnidir.
  final VoidCallback? onPressed; // Basıldığında Çağrılan Callback'tir.
  final AppIconData? leadingIcon; // Metnin Önündeki İsteğe Bağlı Simgedir.
  final AppIconData? trailingIcon; // Metnin Arkasındaki İsteğe Bağlı Simgedir.
  final double fontSize; // Metin Font Boyutudur.
  final FontWeight weight; // Metin Font Kalınlığıdır.
  final double tracking; // Metin Harf Aralığıdır.
  final Color? color; // Metin Ve Simge Rengidir.
  final Color? background; // Düğme Zemin Rengidir.
  final EdgeInsets padding; // Düğmenin İç Boşluğudur.
  final double iconSize; // Simge Boyutudur.

  const AppTextButton({ // Varsayılan Metin Düğmesi Ayarlarıyla const Constructor'dır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.label, // label Field'ını required Yapar.
    required this.onPressed, // onPressed Field'ını required Yapar.
    this.leadingIcon, // İsteğe Bağlı Baş Simgeyi Alır.
    this.trailingIcon, // İsteğe Bağlı Son Simgeyi Alır.
    this.fontSize = 14, // Varsayılan Font Boyutunu 14 Yapar.
    this.weight = FontWeight.w500, // Varsayılan Font Kalınlığını w500 Yapar.
    this.tracking = 0.02, // Varsayılan Harf Aralığını 0.02 Yapar.
    this.color, // İsteğe Bağlı Rengi Alır.
    this.background, // İsteğe Bağlı Zemin Rengini Alır.
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Varsayılan İç Boşluğu Belirler.
    this.iconSize = 18, // Varsayılan Simge Boyutunu 18 Yapar.
  });

  /// `digura-prototip.html` metin düğmesi: 15 / 600, yatay 14.
  const AppTextButton.strong({ // Daha Belirgin Metin Düğmesi İçin Named const Constructor'dır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.label, // label Field'ını required Yapar.
    required this.onPressed, // onPressed Field'ını required Yapar.
    this.leadingIcon, // İsteğe Bağlı Baş Simgeyi Alır.
    this.trailingIcon, // İsteğe Bağlı Son Simgeyi Alır.
    this.color, // İsteğe Bağlı Rengi Alır.
    this.background, // İsteğe Bağlı Zemin Rengini Alır.
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // Varsayılan İç Boşluğu Belirler.
  }) : fontSize = 15, // Font Boyutunu 15 Yapar.
       weight = FontWeight.w600, // Font Kalınlığını w600 Yapar.
       tracking = 0, // Harf Aralığını Sıfırlar.
       iconSize = 20; // Simge Boyutunu 20 Yapar.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Metin Düğmesini Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    final fg = color ?? p.fg2; // Renk Verilmediyse fg2 Rengini Kullanır.
    return Pressable( // Basma Geri Bildirimli Düğmeyi Döndürür.
      onTap: onPressed, // Dokunma Callback'ini Bağlar.
      semanticLabel: label, // Ekran Okuyucu Etiketini Verir.
      child: Container( // Düğme Yüzeyini Çizer.
        constraints: const BoxConstraints(minHeight: 44), // En Az 44 Yükseklik Verir.
        padding: padding, // İç Boşluğu Uygular.
        decoration: ShapeDecoration(shape: const StadiumBorder(), color: background ?? Colors.transparent), // Hap Şekli Ve Zemin Rengini Verir.
        child: ExcludeSemantics( // İçeriğin Ayrıca Okunmasını Engeller.
          child: Row( // Simge Ve Metni Yan Yana Dizer.
            mainAxisSize: MainAxisSize.min, // Row'u İçeriği Kadar Genişletir.
            children: [ // Row'un Çocuklarını Tanımlar.
              if (leadingIcon != null) ...[AppIcon(leadingIcon!, size: iconSize, color: fg), const SizedBox(width: 6)], // Baş Simge Varsa Simge Ve Boşluk Ekler.
              Flexible( // Metnin Taşmadan Sığmasını Sağlar.
                child: Text( // Düğme Metnini Yazar.
                  label, // Düğme Metnini Verir.
                  textAlign: TextAlign.center, // Metni Ortalar.
                  style: AppTypography.body(fontSize, weight: weight, height: 1.4, tracking: tracking, color: fg), // Metne Gövde Yazı Stilini Uygular.
                ),
              ),
              if (trailingIcon != null) ...[ // Son Simge Varsa.
                const SizedBox(width: 6), // Metin İle Simge Arasına 6 Boşluk Koyar.
                AppIcon(trailingIcon!, size: iconSize, color: fg), // Son Simgeyi Çizer.
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Yuvarlak simge düğmesi (44 veya 48). Pasifken saydamlık 0.35.
class AppIconButton extends StatelessWidget { // Yuvarlak Simge Düğmesi StatelessWidget'ıdır.
  final AppIconData icon; // Gösterilecek Simgedir.
  final VoidCallback? onPressed; // Basıldığında Çağrılan Callback'tir.
  final String tooltip; // Ekran Okuyucu Etiketi Olarak Kullanılan Açıklamadır.
  final double size; // Düğmenin Kare Boyutudur.
  final double iconSize; // Simge Boyutudur.
  final Color? color; // Simge Rengidir.

  const AppIconButton({ // Varsayılan Simge Düğmesi Ayarlarıyla const Constructor'dır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.icon, // icon Field'ını required Yapar.
    required this.onPressed, // onPressed Field'ını required Yapar.
    required this.tooltip, // tooltip Field'ını required Yapar.
    this.size = 44, // Varsayılan Düğme Boyutunu 44 Yapar.
    this.iconSize = 20, // Varsayılan Simge Boyutunu 20 Yapar.
    this.color, // İsteğe Bağlı Simge Rengini Alır.
  });

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Simge Düğmesini Oluşturur.
    return Pressable( // Basma Geri Bildirimli Düğmeyi Döndürür.
      onTap: onPressed, // Dokunma Callback'ini Bağlar.
      semanticLabel: tooltip, // Ekran Okuyucu Etiketini Verir.
      child: AnimatedOpacity( // Pasiflik Durumunda Saydamlığı Animasyonla Değiştirir.
        duration: AppMotion.press, // Saydamlık Animasyon Süresini Belirler.
        opacity: onPressed == null ? 0.35 : 1, // Pasifse 0.35, Etkinse Tam Opak Yapar.
        child: SizedBox.square( // Kare Dokunma Alanı Oluşturur.
          dimension: size, // Kare Boyutunu Belirler.
          child: Center( // Simgeyi Ortalar.
            child: AppIcon(icon, size: iconSize, color: color ?? context.palette.fg), // Simgeyi Verilen Ya Da Varsayılan Renkle Çizer.
          ),
        ),
      ),
    );
  }
}
