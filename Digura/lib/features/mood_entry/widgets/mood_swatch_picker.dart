import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/pressable.dart';

/// Beşli duygu seçici (`swatches`): 50 px daire, seçili = `bg` + `fg` çift
/// halka (3 + 5 px) ve onay simgesi. Basılıyken daire 0.94 ölçeklenir.
class MoodSwatchPicker extends StatelessWidget {
  final Mood? selected;
  final ValueChanged<Mood> onSelect;
  final double dotSize;
  final Color? ringGapColor;

  const MoodSwatchPicker({
    super.key,
    required this.selected,
    required this.onSelect,
    this.dotSize = 50,
    this.ringGapColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.moodPickerLabel,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < Mood.values.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: MoodSwatch(
                  mood: Mood.values[i],
                  selected: selected == Mood.values[i],
                  onTap: () => onSelect(Mood.values[i]),
                  dotSize: dotSize,
                  ringGapColor: ringGapColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MoodSwatch extends StatelessWidget {
  final Mood mood;
  final bool selected;
  final VoidCallback onTap;
  final double dotSize;
  final Color? ringGapColor;

  const MoodSwatch({
    super.key,
    required this.mood,
    required this.selected,
    required this.onTap,
    this.dotSize = 50,
    this.ringGapColor,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reduce = context.reduceMotion;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Pressable(
        onTap: onTap,
        scale: 1,
        semanticLabel: mood.label,
        button: false,
        builder: (context, pressed) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              AnimatedScale(
                scale: pressed && !reduce ? AppMotion.pressSwatch : 1,
                duration: AppMotion.press,
                curve: AppMotion.easeOut,
                child: AnimatedContainer(
                  duration: AppMotion.press,
                  curve: AppMotion.easeOut,
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.mood(mood),
                    boxShadow: [
                      BoxShadow(color: p.fg, spreadRadius: selected ? 5 : 0),
                      BoxShadow(color: ringGapColor ?? p.bg, spreadRadius: selected ? 3 : 0),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    opacity: selected ? 1 : 0,
                    duration: AppMotion.press,
                    child: AppIcon(AppIcons.check, size: 22, strokeWidth: 2.6, color: p.onMood(mood)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 29),
                child: Text(
                  mood.stackedLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    12,
                    height: 1.2,
                    weight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? p.fg : p.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
