import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/layout_parts.dart';
import '../models/mood_stats_model.dart';

/// Aylık özet kartı: toplam, en sık duygu, yığılmış şerit ve dağılım listesi.
class StatsCard extends StatelessWidget {
  final MoodStatsModel stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final top = stats.top!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.total}',
                      style: AppTypography.display(
                        40,
                        height: 1,
                        tracking: -0.02,
                        color: p.fg,
                      ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                    const SizedBox(height: 4),
                    Text(AppStrings.statsEntriesThisMonth, style: AppTypography.mono(12, color: p.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppStrings.statsMostFrequent, style: AppTypography.mono(12, color: p.muted)),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.topMood(top.percent, top.mood.label),
                    style: AppTypography.body(15, weight: FontWeight.w600, height: 1.4, color: p.fg),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12 + 4),
          StackBar(shares: stats.shares),
          const SizedBox(height: 2 + 14),
          for (var i = 0; i < stats.shares.length; i++) DistributionRow(share: stats.shares[i], showDivider: i > 0),
        ],
      ),
    );
  }
}

/// Yığılmış dağılım çubuğu (`stack-bar`): 18 px hap, dilimler arası 2 px.
class StackBar extends StatelessWidget {
  final List<MoodShare> shares;

  const StackBar({super.key, required this.shares});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final visible = shares.where((s) => s.count > 0).toList();
    return Semantics(
      label: AppStrings.statsDistribution,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 18,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                Expanded(
                  flex: visible[i].count,
                  child: ColoredBox(color: p.mood(visible[i].mood)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dağılım satırı: renk kutusu, ad + oran şeridi, yüzde ve gün sayısı.
class DistributionRow extends StatelessWidget {
  final MoodShare share;
  final bool showDivider;

  const DistributionRow({super.key, required this.share, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = p.mood(share.mood);
    return Opacity(
      opacity: share.count == 0 ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: showDivider ? Border(top: BorderSide(color: p.border)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(share.mood.label, style: AppTypography.body(15, height: 1.4, color: p.fg)),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 5,
                      color: p.empty,
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: share.percent / 100,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppStrings.percent(share.percent),
                    style: AppTypography.mono(15, weight: FontWeight.w600, color: p.fg),
                  ),
                  Text(AppStrings.dayCount(share.count), style: AppTypography.mono(11, color: p.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Boş ay durumu: kesik çizgili halka + "Bu ay henüz kayıt yok".
class StatsEmptyState extends StatelessWidget {
  const StatsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 30),
      child: Column(
        children: [
          CustomPaint(size: const Size.square(72), painter: _DashedRingPainter(p.border)),
          const SizedBox(height: 16),
          Text(
            AppStrings.statsEmptyTitle,
            textAlign: TextAlign.center,
            style: AppTypography.display(22, height: 1.2, tracking: -0.015, color: p.fg),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.statsEmptyBody,
            textAlign: TextAlign.center,
            style: AppTypography.body(14, height: 1.4, color: p.muted),
          ),
        ],
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  final Color color;

  _DashedRingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.0;
    final radius = size.width / 2 - stroke / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    // CSS `border: 2px dashed`: tire ≈ 3 × kalınlık, boşluk ≈ kalınlık kadar.
    const dash = 6.0;
    const gap = 4.0;
    final circumference = 2 * math.pi * radius;
    final count = (circumference / (dash + gap)).floor();
    final sweep = (dash / circumference) * 2 * math.pi;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: radius);
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, -math.pi / 2 + i * 2 * math.pi / count, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.color != color;
}
