import 'dart:math' as math; // sqrt ve sqrt2 İçin dart:math Kütüphanesini math Adıyla import Eder.

import 'package:flutter/widgets.dart'; // CustomClipper, Animation ve Path İçin Flutter Widget'larını import Eder.

/// Kapsül açılış anı (ANIMATION.md 5.3): not paneli renk kutusunun
/// merkezinden dairesel olarak açılır (`clip-path: circle(0 → 170%)`).
///
/// CSS'teki yüzde yarıçap `√(w² + h²) / √2` referansına göredir.
class CircleReveal extends CustomClipper<Path> { // Animasyona Bağlı Dairesel Kırpma Yapan CustomClipper'dır.
  final Animation<double> reveal; // Dairenin Büyümesini Süren Animasyondur.
  final Offset center; // Dairenin Merkez Noktasıdır.
  final double maxFactor; // Referans Yarıçapın En Fazla Kaç Katına Çıkılacağıdır.

  CircleReveal(this.reveal, this.center, {this.maxFactor = 1.7}) : super(reclip: reveal); // Animasyon Her Değiştiğinde Yeniden Kırpan Constructor'dır.

  @override // Superclass'taki getClip Metodunun Override Edildiğini Belirtir.
  Path getClip(Size size) { // Verilen Boyut İçin Kırpma Path'ini Üretir.
    final reference = math.sqrt(size.width * size.width + size.height * size.height) / math.sqrt2; // CSS Yüzde Yarıçap Referansını Hesaplar.
    return Path()..addOval(Rect.fromCircle(center: center, radius: reveal.value * reference * maxFactor)); // Animasyon Değerine Göre Büyüyen Daire Path'i Döndürür.
  }

  @override // Superclass'taki shouldReclip Metodunun Override Edildiğini Belirtir.
  bool shouldReclip(CircleReveal oldClipper) => // Yeniden Kırpma Gerekip Gerekmediğini Belirler.
      oldClipper.center != center || oldClipper.reveal != reveal || oldClipper.maxFactor != maxFactor; // Parametrelerden Biri Değiştiyse true Döndürür.
}
