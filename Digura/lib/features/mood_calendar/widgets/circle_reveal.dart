import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Kapsül açılış anı (ANIMATION.md 5.3): not paneli renk kutusunun
/// merkezinden dairesel olarak açılır (`clip-path: circle(0 → 170%)`).
///
/// CSS'teki yüzde yarıçap `√(w² + h²) / √2` referansına göredir.
class CircleReveal extends CustomClipper<Path> {
  final Animation<double> reveal;
  final Offset center;
  final double maxFactor;

  CircleReveal(this.reveal, this.center, {this.maxFactor = 1.7}) : super(reclip: reveal);

  @override
  Path getClip(Size size) {
    final reference = math.sqrt(size.width * size.width + size.height * size.height) / math.sqrt2;
    return Path()..addOval(Rect.fromCircle(center: center, radius: reveal.value * reference * maxFactor));
  }

  @override
  bool shouldReclip(CircleReveal oldClipper) =>
      oldClipper.center != center || oldClipper.reveal != reveal || oldClipper.maxFactor != maxFactor;
}
