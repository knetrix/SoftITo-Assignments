import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/widgets/app_icon.dart';

/// Büyük renk dairesi (`orb`, 152 px). Boşken `empty` + iç çizgi; doluyken
/// duygu rengi + renk gölgesi. Renk değişince 0.94 → 1 ölçek ve 0.7 → 1
/// saydamlıkla yerleşir (`settle`); [popKey] değişince bir kez `savedPop`.
class MoodOrb extends StatefulWidget {
  final Mood? mood;
  final bool showCheck;
  final double size;
  final Object? popKey;

  /// Kayıttan hemen sonra yeni oluşturulan dairenin bir kez yerleşmesi.
  final bool popOnMount;

  const MoodOrb({
    super.key,
    required this.mood,
    this.showCheck = false,
    this.size = 152,
    this.popKey,
    this.popOnMount = false,
  });

  @override
  State<MoodOrb> createState() => _MoodOrbState();
}

class _MoodOrbState extends State<MoodOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(vsync: this, value: 1);

  @override
  void initState() {
    super.initState();
    if (widget.popOnMount) _play(AppMotion.savedPop);
  }

  @override
  void didUpdateWidget(MoodOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.popKey != oldWidget.popKey && widget.popKey != null) {
      _play(AppMotion.savedPop);
    } else if (widget.mood != oldWidget.mood && widget.mood != null) {
      _play(AppMotion.settle);
    }
  }

  void _play(Duration duration) {
    _pop.duration = duration;
    _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mood = widget.mood;
    final fill = mood == null ? p.empty : p.mood(mood);
    final reduce = context.reduceMotion;
    final orb = AnimatedContainer(
      duration: AppMotion.ui,
      curve: AppMotion.easeOut,
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: mood == null ? Border.all(color: p.border) : null,
        boxShadow: [if (mood != null) cssShadow(color: fill, y: 18, blur: 40, spread: -16)],
      ),
      alignment: Alignment.center,
      child: mood == null
          ? AppIcon(AppIcons.dot, size: 30, color: p.muted)
          : (widget.showCheck ? AppIcon(AppIcons.check, size: 30, color: p.onMood(mood)) : null),
    );
    return AnimatedBuilder(
      animation: _pop,
      child: orb,
      builder: (context, child) {
        final t = AppMotion.easeOut.transform(_pop.value);
        final opacity = AppMotion.orbOpacityFrom + (1 - AppMotion.orbOpacityFrom) * t;
        if (reduce) return Opacity(opacity: opacity, child: child);
        final scale = AppMotion.orbFrom + (1 - AppMotion.orbFrom) * t;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}
