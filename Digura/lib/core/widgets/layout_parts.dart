import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../utils/clock.dart';
import 'app_buttons.dart';
import 'app_icon.dart';

/// Sekme başlığı: mono üstbilgi (BÜYÜK HARF) + 28 px başlık, isteğe bağlı
/// sağ üst eylem (Bugün'deki dişli). `padding: 8 20 16`.
class ScreenHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget? trailing;

  const ScreenHeader({super.key, required this.eyebrow, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(right: trailing == null ? 0 : 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trUpper(eyebrow), style: AppTypography.eyebrow(11, p.muted)),
                const SizedBox(height: 6),
                Semantics(
                  header: true,
                  child: Text(title, style: AppTypography.display(28, height: 1.1, tracking: -0.02, color: p.fg)),
                ),
              ],
            ),
          ),
          if (trailing != null) Positioned(top: -8, right: -10, child: trailing!),
        ],
      ),
    );
  }
}

/// Ay başlığı + "X / N gün renklendi" alt yazısı ve önceki/sonraki okları.
class MonthNav extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool monoTitle;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool showArrows;

  const MonthNav({
    super.key,
    required this.title,
    required this.subtitle,
    this.monoTitle = false,
    this.onPrevious,
    this.onNext,
    this.showArrows = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final titleStyle = monoTitle
        ? AppTypography.mono(20, height: 1.4, color: p.fg)
        : AppTypography.display(20, height: 1.4, tracking: -0.01, color: p.fg);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 10, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.mono(12, color: p.muted)),
              ],
            ),
          ),
          if (showArrows) ...[
            AppIconButton(icon: AppIcons.left, onPressed: onPrevious, tooltip: AppStrings.previousMonth),
            AppIconButton(icon: AppIcons.right, onPressed: onNext, tooltip: AppStrings.nextMonth),
          ],
        ],
      ),
    );
  }
}

/// Bilgi satırı: 16 px simge + 13 px soluk metin (`.hint`).
class InfoHint extends StatelessWidget {
  final AppIconData icon;
  final String text;
  final bool centered;
  final EdgeInsets margin;

  const InfoHint({
    super.key,
    required this.icon,
    required this.text,
    this.centered = false,
    this.margin = const EdgeInsets.fromLTRB(20, 14, 20, 0),
  });

  const InfoHint.textOnly({super.key, required this.text, this.margin = const EdgeInsets.fromLTRB(20, 14, 20, 0)})
    : icon = AppIcons.info,
      centered = true;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = AppTypography.body(13, height: 1.4, color: p.muted);
    if (centered) {
      return Padding(
        padding: margin,
        child: Text(text, textAlign: TextAlign.center, style: style),
      );
    }
    return Padding(
      padding: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: AppIcon(icon, size: 16, color: p.muted),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

/// Düz kart: `surface` + 1 px `border`, 20 px yarıçap, 16 iç boşluk.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

/// Kapsül kilit rozeti + başlık + "Açılış: tarih" satırı (`.capsule-line`).
class CapsuleLine extends StatelessWidget {
  final String title;
  final DateTime unlockDate;

  const CapsuleLine({super.key, required this.title, required this.unlockDate});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final muted = AppTypography.body(14, height: 1.4, color: p.muted);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: p.borderSoft, borderRadius: BorderRadius.circular(14)),
          alignment: Alignment.center,
          child: AppIcon(AppIcons.lock, color: p.fg),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.body(15, weight: FontWeight.w600, height: 1.4, color: p.fg),
              ),
              Text.rich(
                TextSpan(
                  text: AppStrings.unlockOn(''),
                  children: [
                    TextSpan(
                      text: DateHelpers.formatLong(unlockDate),
                      style: AppTypography.mono(14, color: p.muted),
                    ),
                  ],
                ),
                style: muted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 6 px ilerleme çubuğu (`.bar`): `empty` zemin, `fg` dolgu.
class CapsuleProgressBar extends StatelessWidget {
  final double value;
  final double height;

  const CapsuleProgressBar({super.key, required this.value, this.height = 6});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: p.empty,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(color: p.fg, borderRadius: BorderRadius.circular(999)),
          ),
        ),
      ),
    );
  }
}

/// Kilitli notun temsili sansür çubukları. Metin ağaçta hiç yer almaz.
class RedactedLines extends StatelessWidget {
  final List<double> widths;

  const RedactedLines({super.key, required this.widths});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < widths.length; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            FractionallySizedBox(
              widthFactor: widths[i],
              child: Container(
                height: 12,
                decoration: BoxDecoration(color: p.empty, borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Duygu rengi + etiket (renk açıklaması öğesi).
class LegendSwatch extends StatelessWidget {
  final Color color;
  final String label;
  final bool outlined;

  const LegendSwatch({super.key, required this.color, required this.label, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: outlined ? Border.all(color: p.border) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.body(12, height: 1.4, color: p.muted)),
      ],
    );
  }
}

/// Ekranı dolduran, gerektiğinde kaydırılan gövde. Küçük ekranlarda tuş
/// takımı taşmaz; büyük ekranlarda `Spacer` tuş takımını alta iter.
class FillScrollView extends StatelessWidget {
  final Widget child;

  const FillScrollView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}

/// Ayarlar üst çubuğu (`.appbar`): 48 px geri düğmesi + 22 px başlık.
class AppBarRow extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final String backLabel;

  const AppBarRow({super.key, required this.title, required this.onBack, this.backLabel = AppStrings.back});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
      child: Row(
        children: [
          AppIconButton(icon: AppIcons.arrowBack, size: 48, iconSize: 24, tooltip: backLabel, onPressed: onBack),
          const SizedBox(width: 4),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: AppTypography.display(22, height: 1.3, color: p.fg)),
            ),
          ),
        ],
      ),
    );
  }
}
