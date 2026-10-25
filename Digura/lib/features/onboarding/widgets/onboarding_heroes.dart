import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/layout_parts.dart';
import '../../../core/widgets/pressable.dart';

/// Adım 1: beş duygu rengi çemberi (300 px) ve merkezde seçili duygu.
class MoodPaletteHero extends StatelessWidget {
  final Mood selected;
  final ValueChanged<Mood> onSelect;

  static const double _size = 300;
  static const double _orbit = 122;
  static const double _button = 56;
  static const double _coreInset = 82;

  const MoodPaletteHero({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reduce = context.reduceMotion;
    return Semantics(
      label: AppStrings.onboardingPalette,
      container: true,
      child: SizedBox.square(
        dimension: _size,
        child: Stack(
          children: [
            Positioned.fill(
              left: _coreInset,
              top: _coreInset,
              right: _coreInset,
              bottom: _coreInset,
              child: _PaletteCore(mood: selected),
            ),
            for (var i = 0; i < Mood.values.length; i++)
              () {
                final mood = Mood.values[i];
                final angle = (-90 + i * 72) * math.pi / 180;
                final isOn = mood == selected;
                return Positioned(
                  left: _size / 2 + math.cos(angle) * _orbit - _button / 2,
                  top: _size / 2 + math.sin(angle) * _orbit - _button / 2,
                  child: Semantics(
                    selected: isOn,
                    child: Pressable(
                      onTap: () => onSelect(mood),
                      scale: 1,
                      semanticLabel: mood.label,
                      builder: (context, pressed) => AnimatedScale(
                        scale: pressed && !reduce ? AppMotion.pressPalette : 1,
                        duration: AppMotion.press,
                        curve: AppMotion.easeOut,
                        child: AnimatedContainer(
                          duration: AppMotion.press,
                          curve: AppMotion.easeOut,
                          width: _button,
                          height: _button,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.mood(mood),
                            boxShadow: [
                              BoxShadow(color: p.fg, spreadRadius: isOn ? 5 : 0),
                              BoxShadow(color: p.surface, spreadRadius: isOn ? 3 : 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }(),
          ],
        ),
      ),
    );
  }
}

class _PaletteCore extends StatefulWidget {
  final Mood mood;

  const _PaletteCore({required this.mood});

  @override
  State<_PaletteCore> createState() => _PaletteCoreState();
}

class _PaletteCoreState extends State<_PaletteCore> with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(vsync: this, duration: AppMotion.settle, value: 1);

  @override
  void didUpdateWidget(_PaletteCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = p.mood(widget.mood);
    final reduce = context.reduceMotion;
    final core = AnimatedContainer(
      duration: AppMotion.settle,
      curve: AppMotion.easeOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [cssShadow(color: color, y: 24, blur: 50, spread: -20)],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Semantics(
        liveRegion: true,
        child: AnimatedSwitcher(
          duration: AppMotion.ui,
          child: Text(
            widget.mood.label,
            key: ValueKey(widget.mood),
            textAlign: TextAlign.center,
            style: AppTypography.display(18, height: 1.3, color: p.onMood(widget.mood)),
          ),
        ),
      ),
    );
    return AnimatedBuilder(
      animation: _pop,
      child: core,
      builder: (context, child) {
        final t = AppMotion.easeOut.transform(_pop.value);
        if (reduce) {
          return Opacity(opacity: 0.6 + 0.4 * t, child: child);
        }
        return Transform.scale(scale: AppMotion.orbFrom + (1 - AppMotion.orbFrom) * t, child: child);
      },
    );
  }
}

/// Adım 2: kilitli kapsül kartı önizlemesi. Sayfa görününce ilerleme
/// çubuğu %60'a dolar (`intro`, 180 ms gecikme).
class CapsulePreviewHero extends StatefulWidget {
  final bool active;

  const CapsulePreviewHero({super.key, required this.active});

  @override
  State<CapsulePreviewHero> createState() => _CapsulePreviewHeroState();
}

class _CapsulePreviewHeroState extends State<CapsulePreviewHero> with SingleTickerProviderStateMixin {
  static const double _fill = 0.6;

  late final AnimationController _bar = AnimationController(
    vsync: this,
    duration: AppMotion.capsuleBarDelay + AppMotion.intro,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _bar,
    curve: Interval(
      AppMotion.capsuleBarDelay.inMicroseconds / (AppMotion.capsuleBarDelay + AppMotion.intro).inMicroseconds,
      1,
      curve: AppMotion.easeOut,
    ),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _bar.forward();
  }

  @override
  void didUpdateWidget(CapsulePreviewHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _bar.forward(from: 0);
    if (!widget.active && oldWidget.active) _bar.value = 0;
  }

  @override
  void dispose() {
    _curve.dispose();
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reduce = context.reduceMotion;
    final mono11 = AppTypography.mono(11, color: p.muted);
    final front = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(24),
        boxShadow: p.raised,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: p.mood(Mood.calmSad), borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Mood.calmSad.label, style: AppTypography.display(18, color: p.fg)),
                    Text(AppStrings.capsuleSampleDate, style: AppTypography.mono(12, color: p.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const RedactedLines(widths: [0.94, 0.58]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                AppIcon(AppIcons.lock, color: p.fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.capsuleRemaining(12),
                        style: AppTypography.body(14, weight: FontWeight.w500, color: p.fg),
                      ),
                      Text(AppStrings.capsuleSampleSub, style: AppTypography.body(12, color: p.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 6,
              color: p.empty,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _fill,
                heightFactor: 1,
                child: AnimatedBuilder(
                  animation: _curve,
                  builder: (context, child) =>
                      Transform.scale(alignment: Alignment.centerLeft, scaleX: reduce ? 1 : _curve.value, child: child),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: p.fg, borderRadius: BorderRadius.circular(999)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.timelineStart, style: mono11),
              Text(AppStrings.timelineMid, style: mono11),
              Text(AppStrings.timelineEnd, style: mono11),
            ],
          ),
        ],
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 16,
          right: 16,
          top: 0,
          height: 80,
          child: ExcludeSemantics(
            child: Opacity(
              opacity: 0.55,
              child: Transform.translate(
                offset: const Offset(0, 10),
                child: Transform.rotate(
                  angle: -3 * math.pi / 180,
                  child: Container(
                    decoration: BoxDecoration(
                      color: p.borderSoft,
                      border: Border.all(color: p.border),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // `.cap-card.back { margin-bottom: -60px }` + 12 px ızgara boşluğu.
        Padding(
          padding: const EdgeInsets.only(top: 80 + 12 - 60),
          child: front,
        ),
      ],
    );
  }
}

/// Adım 3: örnek ay ısı haritası kartı.
class HeatmapPreviewHero extends StatelessWidget {
  /// Prototipteki örnek ay deseni (35 hücre; ilk 2 ve son 3 boş).
  static const String _pattern = 'x x j s c j s t s j a x s j j c t s s j x s t a j s c j s j x x x x x';
  static const Map<String, Mood> _key = {
    'j': Mood.joyful,
    'c': Mood.calmSad,
    'a': Mood.angryStressed,
    's': Mood.serene,
    't': Mood.tired,
  };

  const HeatmapPreviewHero({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cells = _pattern.split(' ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(AppStrings.mapPreviewTitle, style: AppTypography.display(16, color: p.fg)),
              ),
              Text(AppStrings.mapPreviewSub, style: AppTypography.mono(11, color: p.muted)),
            ],
          ),
          const SizedBox(height: 12),
          ExcludeSemantics(
            child: Column(
              children: [
                for (var row = 0; row < 5; row++) ...[
                  if (row > 0) const SizedBox(height: 5),
                  Row(
                    children: [
                      for (var col = 0; col < 7; col++) ...[
                        if (col > 0) const SizedBox(width: 5),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: () {
                              final i = row * 7 + col;
                              final blank = i < 2 || i > 31;
                              final mood = _key[cells[i]];
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: blank ? Colors.transparent : (mood == null ? p.empty : p.mood(mood)),
                                  borderRadius: BorderRadius.circular(7),
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
            ),
          ),
        ],
      ),
    );
  }
}

/// Gizlilik kartı: "Hesap yok, internet yok" + 21:00 hatırlatıcı anahtarı.
class PrivacyCard extends StatelessWidget {
  final bool reminder;
  final ValueChanged<bool> onReminderChanged;

  const PrivacyCard({super.key, required this.reminder, required this.onReminderChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget row(AppIconData icon, String title, String sub, {Widget? trailing}) => Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          AppIcon(icon, color: p.fg2),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body(14, height: 1.35, color: p.fg)),
                Text(sub, style: AppTypography.body(12, height: 1.35, color: p.muted)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing],
        ],
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          row(AppIcons.shield, AppStrings.privacyTitle, AppStrings.privacySub),
          Container(height: 1, color: p.borderSoft),
          MergeSemantics(
            child: row(
              AppIcons.bell,
              AppStrings.reminderOnboarding,
              reminder ? AppStrings.reminderPermission : AppStrings.reminderOptional,
              trailing: Switch(value: reminder, onChanged: onReminderChanged),
            ),
          ),
        ],
      ),
    );
  }
}
