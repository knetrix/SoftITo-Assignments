import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/layout_parts.dart';
import '../../../core/widgets/pressable.dart';
import '../models/mood_calendar_model.dart';

/// 7 sütunlu ay ısı haritası (`Pt–Pz`), harici takvim paketi olmadan.
class MonthHeatmap extends StatelessWidget {
  final DateTime month;
  final List<DayCellModel?> cells;
  final ValueChanged<String> onDayTap;

  const MonthHeatmap({super.key, required this.month, required this.cells, required this.onDayTap});

  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = (constraints.maxWidth - _gap * 6) / 7;
          return Column(
            children: [
              ExcludeSemantics(
                child: Row(
                  children: [
                    for (var i = 0; i < 7; i++) ...[
                      if (i > 0) const SizedBox(width: _gap),
                      SizedBox(
                        width: size,
                        child: Text(
                          AppStrings.weekdaysShort[i],
                          textAlign: TextAlign.center,
                          style: AppTypography.mono(11, tracking: 0.04, color: p.muted),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: _gap,
                runSpacing: _gap,
                children: [
                  for (final cell in cells)
                    SizedBox.square(
                      dimension: size,
                      child: cell == null
                          ? null
                          : HeatmapCell(
                              cell: cell,
                              monthName: AppStrings.months[month.month - 1],
                              onTap: cell.entryId == null ? null : () => onDayTap(cell.entryId!),
                            ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Isı haritası hücresi (~45 px, yarıçap 11). Kilitli gün = sağ altta 11 px
/// kilit; bugün = çift halka; yeni açılan = sağ altta 7 px nokta.
/// Hücre başına animasyon yoktur; yalnızca dokunulabilir hücrede basma ölçeği.
class HeatmapCell extends StatelessWidget {
  final DayCellModel cell;
  final String monthName;
  final VoidCallback? onTap;

  const HeatmapCell({super.key, required this.cell, required this.monthName, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mood = cell.mood;
    final textColor = mood == null ? p.muted : p.onMood(mood);
    final box = Container(
      padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
      decoration: BoxDecoration(
        color: mood != null ? p.mood(mood) : (cell.isFuture ? Colors.transparent : p.empty),
        borderRadius: BorderRadius.circular(11),
        border: cell.isFuture ? Border.all(color: p.border) : null,
        boxShadow: cell.isToday
            ? [BoxShadow(color: p.fg, spreadRadius: 4), BoxShadow(color: p.bg, spreadRadius: 2)]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Text('${cell.day}', style: AppTypography.mono(11, color: textColor)),
          if (cell.isLocked)
            Positioned(
              right: -1,
              bottom: 0,
              child: Opacity(
                opacity: 0.75,
                child: AppIcon(AppIcons.lock, size: 11, strokeWidth: 2.2, color: textColor),
              ),
            ),
          if (cell.isFresh)
            Positioned(
              right: -1,
              bottom: 0,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
    if (onTap == null || mood == null) {
      return Semantics(
        label: '${cell.day} $monthName',
        child: ExcludeSemantics(child: box),
      );
    }
    final state = cell.isLocked ? AppStrings.lockedCapsule : (cell.isFresh ? AppStrings.freshCapsule : null);
    return Pressable(
      onTap: onTap,
      scale: AppMotion.pressCell,
      semanticLabel: AppStrings.dayCellLabel(cell.day, monthName, mood.label, state),
      child: ExcludeSemantics(child: box),
    );
  }
}

/// Yıl görünümü: 12 ayın 3 × 4 mini ısı haritası kartı.
class YearHeatmap extends StatelessWidget {
  final List<MiniMonthModel> months;
  final ValueChanged<int> onMonthTap;

  const YearHeatmap({super.key, required this.months, required this.onMonthTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      // CSS ızgarası gibi: aynı satırdaki kartlar en uzun kart kadar uzar.
      child: Column(
        children: [
          for (var row = 0; row < months.length / 3; row++) ...[
            if (row > 0) const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var col = 0; col < 3; col++) ...[
                    if (col > 0) const SizedBox(width: 10),
                    Expanded(
                      child: () {
                        final m = months[row * 3 + col];
                        return MiniMonthCard(month: m, onTap: m.isFuture ? null : () => onMonthTap(m.month.month));
                      }(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MiniMonthCard extends StatelessWidget {
  final MiniMonthModel month;
  final VoidCallback? onTap;

  const MiniMonthCard({super.key, required this.month, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final name = AppStrings.months[month.month.month - 1];
    final card = Opacity(
      opacity: month.isFuture ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
        decoration: BoxDecoration(
          color: p.surface,
          border: Border.all(color: p.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.monthShort(month.month.month),
                    style: AppTypography.body(12, weight: FontWeight.w600, height: 1.4, color: p.fg),
                  ),
                ),
                Text(month.count == 0 ? '' : '${month.count}', style: AppTypography.mono(11, color: p.muted)),
              ],
            ),
            const SizedBox(height: 6),
            _MiniGrid(leadingBlanks: month.leadingBlanks, days: month.days),
          ],
        ),
      ),
    );
    return Pressable(
      onTap: onTap,
      semanticLabel: AppStrings.miniMonthLabel(name, month.month.year, month.count),
      child: ExcludeSemantics(child: card),
    );
  }
}

/// Mini ay ızgarası: 7 sütun, 2 px aralık, 3 px yarıçaplı hücreler.
class _MiniGrid extends StatelessWidget {
  final int leadingBlanks;
  final List<Mood?> days;

  const _MiniGrid({required this.leadingBlanks, required this.days});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final total = leadingBlanks + days.length;
    final rows = (total / 7).ceil();
    return Column(
      children: [
        for (var r = 0; r < rows; r++) ...[
          if (r > 0) const SizedBox(height: 2),
          Row(
            children: [
              for (var c = 0; c < 7; c++) ...[
                if (c > 0) const SizedBox(width: 2),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: () {
                      final i = r * 7 + c - leadingBlanks;
                      if (i < 0 || i >= days.length) return const SizedBox.shrink();
                      final mood = days[i];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: mood == null ? p.empty : p.mood(mood),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }(),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Renk açıklaması: beş duygu + "Kayıt yok".
class MoodLegend extends StatelessWidget {
  const MoodLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: [
          for (final mood in Mood.values) LegendSwatch(color: p.mood(mood), label: mood.label),
          LegendSwatch(color: p.empty, label: AppStrings.noEntry, outlined: true),
        ],
      ),
    );
  }
}
