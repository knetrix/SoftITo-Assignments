import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/layout_parts.dart';
import '../models/mood_calendar_model.dart';
import 'circle_reveal.dart';

/// Kapsül Detay Modalı (ANIMATION.md 4.2): aşağıdan yukarı `sheet` (300 ms,
/// `drawer`), kapanış `ui` (200 ms, `easeOut`). Hareket azaltma açıkken
/// kayma yerine solma.
Future<void> showCapsuleDetailSheet(BuildContext context, CapsuleDetail detail) {
  final reduce = context.reduceMotion;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: context.palette.scrim,
    barrierLabel: AppStrings.close,
    sheetAnimationStyle: reduce
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: AppMotion.sheet,
            reverseDuration: AppMotion.ui,
            curve: AppMotion.drawer,
            reverseCurve: AppMotion.easeOut,
          ),
    builder: (_) => CapsuleDetailSheet(detail: detail),
  );
}

class CapsuleDetailSheet extends StatefulWidget {
  final CapsuleDetail detail;

  const CapsuleDetailSheet({super.key, required this.detail});

  @override
  State<CapsuleDetailSheet> createState() => _CapsuleDetailSheetState();
}

class _CapsuleDetailSheetState extends State<CapsuleDetailSheet> with SingleTickerProviderStateMixin {
  /// Açılış anı zaman çizelgesi: halka 640 ms, açılış 0–560 ms, not 320–620 ms.
  late final AnimationController _unseal = AnimationController(vsync: this, duration: AppMotion.unsealRing);
  late final CurvedAnimation _reveal = CurvedAnimation(
    parent: _unseal,
    curve: Interval(0, _ratio(AppMotion.unsealReveal), curve: AppMotion.easeOut),
  );
  late final CurvedAnimation _text = CurvedAnimation(
    parent: _unseal,
    curve: Interval(
      _ratio(AppMotion.unsealTextDelay),
      _ratio(AppMotion.unsealTextDelay + AppMotion.unsealText),
      curve: AppMotion.easeOut,
    ),
  );
  late final CurvedAnimation _ring = CurvedAnimation(parent: _unseal, curve: AppMotion.easeOut);
  bool _hapticDone = false;

  static double _ratio(Duration d) => d.inMicroseconds / AppMotion.unsealRing.inMicroseconds;

  bool get _firstUnseal => switch (widget.detail) {
    OpenedCapsule(:final firstUnseal) => firstUnseal,
    LockedCapsule() => false,
  };

  @override
  void initState() {
    super.initState();
    if (_firstUnseal) {
      _reveal.addListener(_maybeHaptic);
      _unseal.forward();
    } else {
      _unseal.value = 1;
    }
  }

  /// `HapticFeedback.mediumImpact()` tam açılış anında bir kez.
  void _maybeHaptic() {
    if (_hapticDone || _reveal.value < 1) return;
    _hapticDone = true;
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _reveal.dispose();
    _text.dispose();
    _ring.dispose();
    _unseal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final detail = widget.detail;
    final reduce = context.reduceMotion;
    final double bottom = 12 + math.max<double>(22, MediaQuery.viewPaddingOf(context).bottom);
    final sheet = Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(top: 4, bottom: 14),
                    decoration: ShapeDecoration(shape: const StadiumBorder(), color: p.muted.withValues(alpha: 0.5)),
                  ),
                ),
                _SheetHead(detail: detail, ring: _firstUnseal && !reduce ? _ring : null),
                const SizedBox(height: 20),
                switch (detail) {
                  LockedCapsule() => _LockedBody(detail: detail),
                  OpenedCapsule() => _OpenedBody(
                    detail: detail,
                    reveal: detail.firstUnseal ? _reveal : null,
                    text: detail.firstUnseal ? _text : null,
                  ),
                },
              ],
            ),
          ),
          Positioned(
            top: 14,
            right: 12,
            child: AppIconButton(
              icon: AppIcons.close,
              tooltip: AppStrings.close,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
    final content = Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: AppStrings.capsuleDetail,
      child: sheet,
    );
    if (!reduce) return content;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.ui,
      curve: AppMotion.easeOut,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: content,
    );
  }
}

class _SheetHead extends StatelessWidget {
  final CapsuleDetail detail;
  final Animation<double>? ring;

  const _SheetHead({required this.detail, required this.ring});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = p.mood(detail.mood);
    return Row(
      children: [
        SizedBox.square(
          dimension: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                ),
              ),
              if (ring != null)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: ring!,
                    builder: (context, _) {
                      final t = ring!.value;
                      return Opacity(
                        opacity: (AppMotion.ringOpacityFrom * (1 - t)).clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 1 + (AppMotion.ringTo - 1) * t,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color, width: 3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateHelpers.formatWithWeekday(detail.entryDate), style: AppTypography.mono(12, color: p.muted)),
              const SizedBox(height: 4),
              Text(detail.mood.label, style: AppTypography.display(22, height: 1.2, tracking: -0.015, color: p.fg)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kilitli kapsül: yalnızca sansür çubukları, kalan gün ve ilerleme.
/// Bu widget'a not metni hiçbir koşulda verilmez ([LockedCapsule] not taşımaz).
class _LockedBody extends StatelessWidget {
  final LockedCapsule detail;

  const _LockedBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RedactedLines(widths: [0.92, 0.64]),
        const SizedBox(height: 14),
        CapsuleLine(title: AppStrings.capsuleRemaining(detail.remainingDays), unlockDate: detail.unlockDate),
        const SizedBox(height: 10),
        CapsuleProgressBar(value: detail.progress),
      ],
    );
  }
}

class _OpenedBody extends StatelessWidget {
  final OpenedCapsule detail;
  final Animation<double>? reveal;
  final Animation<double>? text;

  const _OpenedBody({required this.detail, required this.reveal, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final unsealing = reveal != null && text != null;
    final quoteColor = unsealing ? p.onMood(detail.mood) : null;
    final quote = Semantics(
      liveRegion: unsealing,
      child: detail.note.isEmpty
          ? Text(AppStrings.emptyCapsuleNote, style: AppTypography.body(15, height: 1.4, color: quoteColor ?? p.muted))
          : Text(
              AppStrings.quoted(detail.note),
              style: AppTypography.display(
                21,
                weight: FontWeight.w400,
                height: 1.35,
                tracking: -0.01,
                color: quoteColor ?? p.fg,
              ),
            ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AppIcon(AppIcons.unlock, color: p.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                AppStrings.capsuleOpened(DateHelpers.formatLong(detail.unlockDate)),
                style: AppTypography.mono(12, color: p.muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (!unsealing) quote else _RevealPanel(mood: detail.mood, reveal: reveal!, text: text!, child: quote),
      ],
    );
  }
}

/// Duygu renginde, renk kutusundan dairesel açılan not paneli.
class _RevealPanel extends StatelessWidget {
  final Mood mood;
  final Animation<double> reveal;
  final Animation<double> text;
  final Widget child;

  /// Panel köşesine göre renk kutusunun merkezi (`circle(… at 32px -56px)`).
  static const Offset _origin = Offset(32, -56);

  const _RevealPanel({required this.mood, required this.reveal, required this.text, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final panel = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: p.mood(mood), borderRadius: BorderRadius.circular(20)),
      child: FadeTransition(opacity: text, child: child),
    );
    if (context.reduceMotion) return FadeTransition(opacity: reveal, child: panel);
    return ClipPath(clipper: CircleReveal(reveal, _origin), child: panel);
  }
}
