import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_motion.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';

/// Beş duygu renginden oluşan konik nokta (`conic-gradient`, tepe noktasından
/// saat yönünde %20'lik dilimler).
class MoodConicDot extends StatelessWidget {
  final double size;

  const MoodConicDot({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final colors = <Color>[];
    final stops = <double>[];
    for (var i = 0; i < Mood.values.length; i++) {
      final c = p.mood(Mood.values[i]);
      colors.addAll([c, c]);
      stops.addAll([i / Mood.values.length, (i + 1) / Mood.values.length]);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(colors: colors, stops: stops, transform: const GradientRotation(-math.pi / 2)),
      ),
    );
  }
}

/// "● Digura" marka yazısı.
class Wordmark extends StatelessWidget {
  final double fontSize;

  const Wordmark({super.key, this.fontSize = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MoodConicDot(),
        const SizedBox(width: 8),
        Text(AppStrings.appName, style: AppTypography.display(fontSize, height: 1.5, color: context.palette.fg)),
      ],
    );
  }
}

/// Sayfa noktaları (ANIMATION.md 4.6): etkin nokta 8 → 24 dp genişler.
class PageDots extends StatelessWidget {
  final int count;
  final int index;

  const PageDots({super.key, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: AppStrings.stepOf(index + 1, count),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            AnimatedContainer(
              duration: AppMotion.ui,
              curve: AppMotion.easeOut,
              width: i == index ? 24 : 8,
              height: 8,
              decoration: ShapeDecoration(shape: const StadiumBorder(), color: i == index ? p.fg : p.border),
            ),
          ],
        ],
      ),
    );
  }
}
