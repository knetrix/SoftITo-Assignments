import 'dart:math' as math; // pi Sabiti İçin dart:math Kütüphanesini math Önekiyle import Eder.

import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../constants/app_colors.dart'; // Mood enum'ını Ve palette Erişimini import Eder.
import '../constants/app_motion.dart'; // Animasyon Süre Ve Curve'leri İçin AppMotion'ı import Eder.
import '../constants/app_strings.dart'; // Uygulama Adı Ve Adım Metinleri İçin AppStrings'i import Eder.
import '../theme/app_theme.dart'; // Yazı Stilleri İçin AppTypography'yi import Eder.

/// Beş duygu renginden oluşan konik nokta (`conic-gradient`, tepe noktasından
/// saat yönünde %20'lik dilimler).
class MoodConicDot extends StatelessWidget { // Beş Duygu Rengini Konik Dilimlerle Gösteren StatelessWidget'tır.
  final double size; // Noktanın Çapıdır.

  const MoodConicDot({super.key, this.size = 14}); // key Parametresini Superclass'a İleten, Varsayılan Boyutu 14 Olan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Konik Renkli Noktayı Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    final colors = <Color>[]; // Gradient Renk Listesini Oluşturur.
    final stops = <double>[]; // Gradient Durak Listesini Oluşturur.
    for (var i = 0; i < Mood.values.length; i++) { // Her Duygu İçin Döngü Kurar.
      final c = p.mood(Mood.values[i]); // Duygunun Rengini Paletten Alır.
      colors.addAll([c, c]); // Keskin Dilim İçin Rengi İki Kez Ekler.
      stops.addAll([i / Mood.values.length, (i + 1) / Mood.values.length]); // Dilimin Başlangıç Ve Bitiş Duraklarını Ekler.
    }
    return Container( // Noktayı Çizen Container'ı Döndürür.
      width: size, // Genişliği Belirler.
      height: size, // Yüksekliği Belirler.
      decoration: BoxDecoration( // Daire Şekli Ve Gradient Dekorasyonunu Tanımlar.
        shape: BoxShape.circle, // Şekli Daire Yapar.
        gradient: SweepGradient(colors: colors, stops: stops, transform: const GradientRotation(-math.pi / 2)), // Tepe Noktasından Başlayan Konik Gradient Uygular.
      ),
    );
  }
}

/// "● Digura" marka yazısı.
class Wordmark extends StatelessWidget { // Konik Nokta Ve Uygulama Adından Oluşan Marka Yazısı StatelessWidget'ıdır.
  final double fontSize; // Marka Yazısının Font Boyutudur.

  const Wordmark({super.key, this.fontSize = 18}); // key Parametresini Superclass'a İleten, Varsayılan Boyutu 18 Olan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Marka Yazısını Oluşturur.
    return Row( // Nokta Ve Metni Yan Yana Dizer.
      mainAxisSize: MainAxisSize.min, // Row'u İçeriği Kadar Genişletir.
      children: [ // Row'un Çocuklarını Tanımlar.
        const MoodConicDot(), // Konik Renkli Noktayı Gösterir.
        const SizedBox(width: 8), // Nokta İle Metin Arasına 8 Boşluk Koyar.
        Text(AppStrings.appName, style: AppTypography.display(fontSize, height: 1.5, color: context.palette.fg)), // Uygulama Adını Display Stiliyle Yazar.
      ],
    );
  }
}

/// Sayfa noktaları (ANIMATION.md 4.6): etkin nokta 8 → 24 dp genişler.
class PageDots extends StatelessWidget { // Sayfa Göstergesi Noktalarını Çizen StatelessWidget'tır.
  final int count; // Toplam Sayfa Sayısıdır.
  final int index; // Etkin Sayfanın index'idir.

  const PageDots({super.key, required this.count, required this.index}); // count Ve index'i required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Sayfa Noktalarını Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    return Semantics( // Ekran Okuyucu İçin Adım Bilgisini Ekler.
      label: AppStrings.stepOf(index + 1, count), // "Adım X / N" Etiketini Verir.
      child: Row( // Noktaları Yan Yana Dizer.
        mainAxisAlignment: MainAxisAlignment.center, // Noktaları Ortalar.
        children: [ // Row'un Çocuklarını Tanımlar.
          for (var i = 0; i < count; i++) ...[ // Her Sayfa İçin Nokta Üretir.
            if (i > 0) const SizedBox(width: 8), // İlk Nokta Hariç Araya 8 Boşluk Koyar.
            AnimatedContainer( // Genişlik Ve Renk Değişimini Animasyonlu Yapar.
              duration: AppMotion.ui, // Animasyon Süresini Belirler.
              curve: AppMotion.easeOut, // Animasyon Curve'ünü Belirler.
              width: i == index ? 24 : 8, // Etkin Noktayı 24, Diğerlerini 8 Genişlikte Yapar.
              height: 8, // Nokta Yüksekliğini 8 Yapar.
              decoration: ShapeDecoration(shape: const StadiumBorder(), color: i == index ? p.fg : p.border), // Hap Şekli Ve Etkinliğe Göre Renk Verir.
            ),
          ],
        ],
      ),
    );
  }
}
