import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/pressable.dart';
import '../models/mood_calendar_model.dart';

/// Ay / Yıl segment seçici: min 44, hap; seçili `borderSoft` zemin + 600 + onay.
class ViewSegment extends StatelessWidget {
  final CalendarMode mode;
  final ValueChanged<CalendarMode> onChanged;

  const ViewSegment({super.key, required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: AppStrings.viewLabel,
      container: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.all(3),
        decoration: ShapeDecoration(
          color: p.surface,
          shape: StadiumBorder(side: BorderSide(color: p.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SegmentButton(
                label: AppStrings.viewMonth,
                selected: mode == CalendarMode.month,
                onTap: () => onChanged(CalendarMode.month),
              ),
            ),
            Expanded(
              child: _SegmentButton(
                label: AppStrings.viewYear,
                selected: mode == CalendarMode.year,
                onTap: () => onChanged(CalendarMode.year),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = selected ? p.fg : p.muted;
    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: AppMotion.press,
        curve: AppMotion.easeOut,
        constraints: const BoxConstraints(minHeight: 44),
        decoration: ShapeDecoration(shape: const StadiumBorder(), color: selected ? p.borderSoft : Colors.transparent),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[AppIcon(AppIcons.check, size: 16, color: color), const SizedBox(width: 6)],
            Text(
              label,
              style: AppTypography.body(
                14,
                height: 1.4,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
