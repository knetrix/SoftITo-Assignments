import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/pin_validator.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/pressable.dart';

enum PinTone { normal, error, success }

/// Üst çubuk: mono adım etiketi (`ADIM 1 / 2`) ve isteğe bağlı sağ eylem.
class StepTopBar extends StatelessWidget {
  final String? step;
  final Widget? leading;
  final Widget? trailing;

  const StepTopBar({super.key, this.step, this.leading, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: leading ?? (step == null ? null : Text(trUpper(step!), style: AppTypography.eyebrow(12, p.muted))),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Başlık + açıklama (`.intro`): 28 px başlık, en çok 30ch açıklama.
class PinIntro extends StatelessWidget {
  final String title;
  final String subtitle;

  /// `max-width: 30ch` (15 px Roboto'da ≈ 253 px).
  static const double _maxSubtitleWidth = 253;

  const PinIntro({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.display(28, height: 1.15, tracking: -0.01, color: p.fg),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxSubtitleWidth),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body(15, color: p.fg2),
            ),
          ),
        ],
      ),
    );
  }
}

/// 4 PIN noktası (16 px). Yeni dolan nokta 0.6 → 1 (`micro`); hata = kırmızı
/// noktalar + ±8 dp sallanma (`shake`, hareket azaltmada yok).
class PinDots extends StatefulWidget {
  final int filled;
  final PinTone tone;
  final int shakeTick;

  const PinDots({super.key, required this.filled, this.tone = PinTone.normal, this.shakeTick = 0});

  @override
  State<PinDots> createState() => _PinDotsState();
}

class _PinDotsState extends State<PinDots> with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(vsync: this, duration: AppMotion.shake);
  late final Animation<double> _offset = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -AppMotion.shakeOffset), weight: 20),
    TweenSequenceItem(
      tween: Tween(begin: -AppMotion.shakeOffset, end: AppMotion.shakeOffset),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(begin: AppMotion.shakeOffset, end: -AppMotion.shakeOffset),
      weight: 20,
    ),
    TweenSequenceItem(tween: Tween(begin: -AppMotion.shakeOffset, end: 0), weight: 20),
  ]).animate(CurvedAnimation(parent: _shake, curve: AppMotion.easeOut));

  @override
  void didUpdateWidget(PinDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeTick != oldWidget.shakeTick && !context.reduceMotion) _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final row = ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < PinValidator.length; i++) ...[
            if (i > 0) const SizedBox(width: 20),
            _PinDot(filled: i < widget.filled, tone: widget.tone),
          ],
        ],
      ),
    );
    return AnimatedBuilder(
      animation: _shake,
      child: row,
      builder: (context, child) =>
          _shake.isAnimating ? Transform.translate(offset: Offset(_offset.value, 0), child: child) : child!,
    );
  }
}

class _PinDot extends StatelessWidget {
  final bool filled;
  final PinTone tone;

  const _PinDot({required this.filled, required this.tone});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (Color fill, Color border) = switch (tone) {
      PinTone.success => (p.success, p.success),
      PinTone.error => (filled ? p.danger : Colors.transparent, p.danger),
      PinTone.normal => (filled ? p.fg : Colors.transparent, filled ? p.fg : p.fg2),
    };
    final reduce = context.reduceMotion;
    return TweenAnimationBuilder<double>(
      key: ValueKey(filled),
      tween: Tween(begin: filled ? 0 : 1, end: 1),
      duration: AppMotion.micro,
      curve: AppMotion.easeOut,
      builder: (context, t, child) => t == 1
          ? child!
          : reduce
          ? Opacity(opacity: AppMotion.dotOpacityFrom + (1 - AppMotion.dotOpacityFrom) * t, child: child)
          : Transform.scale(scale: AppMotion.dotFrom + (1 - AppMotion.dotFrom) * t, child: child),
      child: AnimatedContainer(
        duration: AppMotion.micro,
        curve: AppMotion.easeOut,
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: border, width: 2),
        ),
      ),
    );
  }
}

/// Durum satırı (`.msg`): min 42 px, hata = kırmızı + uyarı simgesi.
class PinMessage extends StatelessWidget {
  final String text;
  final PinTone tone;
  final AppIconData? icon;

  const PinMessage({super.key, required this.text, this.tone = PinTone.normal, this.icon});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = switch (tone) {
      PinTone.error => p.danger,
      PinTone.success => p.success,
      PinTone.normal => p.muted,
    };
    return Semantics(
      liveRegion: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 42),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: AppIcon(icon!, size: 18, strokeWidth: 2, color: color),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTypography.body(14, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PIN tuş takımı: 3 × 76 px, satır aralığı 12, sütun aralığı 24.
/// Sol alt köşe parmak izi tuşu ya da boşluk; sağ alt silme tuşu.
class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final bool enabled;
  final Widget? leading;

  const PinKeypad({super.key, required this.onDigit, required this.onDelete, this.enabled = true, this.leading});

  @override
  Widget build(BuildContext context) {
    Widget digit(String d) => PinKey(label: d, enabled: enabled, onTap: () => onDigit(d));
    Widget row(List<Widget> keys) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < keys.length; i++) ...[if (i > 0) const SizedBox(width: 24), keys[i]],
      ],
    );
    return Semantics(
      label: AppStrings.keypadLabel,
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row([digit('1'), digit('2'), digit('3')]),
          const SizedBox(height: 12),
          row([digit('4'), digit('5'), digit('6')]),
          const SizedBox(height: 12),
          row([digit('7'), digit('8'), digit('9')]),
          const SizedBox(height: 12),
          row([
            leading ?? const SizedBox.square(dimension: PinKey.size),
            digit('0'),
            PinKey(
              icon: AppIcons.backspace,
              ghost: true,
              enabled: enabled,
              onTap: onDelete,
              label: AppStrings.deleteKey,
            ),
          ]),
        ],
      ),
    );
  }
}

class PinKey extends StatelessWidget {
  static const double size = 76;

  final String label;
  final AppIconData? icon;
  final bool ghost;
  final bool enabled;
  final VoidCallback onTap;

  const PinKey({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.ghost = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      onTap: enabled ? onTap : null,
      scale: AppMotion.pressKey,
      semanticLabel: label,
      builder: (context, pressed) {
        final background = ghost ? (pressed ? p.borderSoft : Colors.transparent) : (pressed ? p.keyActive : p.key);
        final color = enabled ? (icon == null ? p.fg : p.fg2) : p.keyDisabled;
        return AnimatedContainer(
          duration: AppMotion.press,
          curve: AppMotion.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: background),
          alignment: Alignment.center,
          child: icon != null
              ? AppIcon(icon!, size: 28, strokeWidth: 1.7, color: color)
              : AnimatedDefaultTextStyle(
                  duration: AppMotion.ui,
                  style: AppTypography.display(28, weight: FontWeight.w400, height: 1.2, color: color),
                  child: Text(label),
                ),
        );
      },
    );
  }
}
