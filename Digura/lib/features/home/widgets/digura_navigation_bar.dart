import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/pressable.dart';
import '../models/home_model.dart';

/// Material 3 alt gezinme çubuğu (DESIGN.md 5): 3 sekme, min 60 px, gösterge
/// 64 × 32 hap, seçili `surfaceWarm`. Basılıyken gösterge 0.94 ölçeklenir.
class DiguraNavigationBar extends StatelessWidget {
  final HomeTab selected;
  final ValueChanged<HomeTab> onSelect;

  const DiguraNavigationBar({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottom = math.max(22.0, MediaQuery.viewPaddingOf(context).bottom);
    return Semantics(
      container: true,
      label: AppStrings.navLabel,
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          border: Border(top: BorderSide(color: p.border)),
        ),
        padding: EdgeInsets.fromLTRB(8, 10, 8, 4 + bottom),
        child: Row(
          children: [
            for (final tab in HomeTab.values)
              Expanded(
                child: _NavItem(tab: tab, selected: tab == selected, onTap: () => onSelect(tab)),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final HomeTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.tab, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = selected ? p.fg : p.muted;
    final reduce = context.reduceMotion;
    return Pressable(
      onTap: onTap,
      scale: 1,
      selected: selected,
      semanticLabel: tab.label,
      builder: (context, pressed) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: pressed && !reduce ? AppMotion.pressKey : 1,
              duration: AppMotion.press,
              curve: AppMotion.easeOut,
              child: AnimatedContainer(
                duration: AppMotion.ui,
                curve: AppMotion.easeOut,
                width: 64,
                height: 32,
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: selected ? p.surfaceWarm : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: AppIcon(tab.icon, size: 22, color: color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: AppTypography.body(
                12,
                height: 1.4,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
