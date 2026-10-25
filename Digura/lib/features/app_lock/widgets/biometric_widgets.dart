import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';

/// "Taranıyor" halkası: doğrusal 900 ms/tur, en çok 60 sn döner sonra durur.
class ScanRing extends StatefulWidget {
  final double size;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  const ScanRing({
    super.key,
    required this.size,
    required this.color,
    this.trackColor = Colors.transparent,
    this.strokeWidth = 3,
  });

  @override
  State<ScanRing> createState() => _ScanRingState();
}

class _ScanRingState extends State<ScanRing> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: AppMotion.scanTurn)..repeat();
  Timer? _limit;

  @override
  void initState() {
    super.initState();
    _limit = Timer(AppMotion.scanMax, _spin.stop);
  }

  @override
  void dispose() {
    _limit?.cancel();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _spin,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _RingPainter(widget.color, widget.trackColor, widget.strokeWidth),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final Color track;
  final double stroke;

  _RingPainter(this.color, this.track, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    if (track.a > 0) canvas.drawOval(rect, paint..color = track);
    // CSS `border-top-color`: üst çeyrek yay.
    canvas.drawArc(rect, -3 * math.pi / 4, math.pi / 2, false, paint..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color || old.track != track || old.stroke != stroke;
}

/// Parmak izi kurulum görseli (168 px `surfaceWarm` daire, 76 px simge).
class BiometricHero extends StatelessWidget {
  final bool scanning;
  final bool enabled;
  final String semanticLabel;

  const BiometricHero({super.key, required this.scanning, required this.enabled, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox.square(
        dimension: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: AppMotion.ui,
              curve: AppMotion.easeOut,
              width: 168,
              height: 168,
              decoration: BoxDecoration(shape: BoxShape.circle, color: enabled ? p.successSoft : p.surfaceWarm),
              alignment: Alignment.center,
              child: AppIcon(
                enabled ? AppIcons.check : AppIcons.fingerprint,
                size: 76,
                strokeWidth: 1.6,
                color: enabled ? p.success : p.fg,
              ),
            ),
            if (scanning) ScanRing(size: 180, color: p.fg, trackColor: p.borderSoft),
          ],
        ),
      ),
    );
  }
}

/// Bilgi satırı (`.fact`): `bg` zemin, 12 px yarıçap, 20 px simge.
class FactRow extends StatelessWidget {
  final AppIconData icon;
  final String text;

  const FactRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          AppIcon(icon, color: p.fg2),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTypography.body(14, color: p.fg2)),
          ),
        ],
      ),
    );
  }
}
