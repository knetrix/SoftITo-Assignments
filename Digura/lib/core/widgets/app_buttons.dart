import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_motion.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Ana düğme: tam genişlik, min 52, hap. Basılıyken vurgu %14 koyulaşır ve
/// 0.97 ölçeklenir; pasifken `borderSoft` zemin + `muted` yazı.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  /// Metin değişimini çapraz soldurmak için (onboarding "Devam" → "Günün rengini seç").
  final bool animateLabel;

  const PrimaryButton({super.key, required this.label, required this.onPressed, this.animateLabel = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onPressed != null;
    final text = Text(
      label,
      key: ValueKey(label),
      textAlign: TextAlign.center,
      style: AppTypography.body(
        16,
        weight: FontWeight.w500,
        height: 1.5,
        tracking: 0.02,
        color: enabled ? p.accentOn : p.muted,
      ),
    );
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      builder: (context, pressed) => AnimatedContainer(
        duration: AppMotion.press,
        curve: AppMotion.easeOut,
        constraints: const BoxConstraints(minHeight: 52),
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: !enabled ? p.borderSoft : (pressed ? p.accentActive : p.accent),
        ),
        child: ExcludeSemantics(
          child: animateLabel
              ? AnimatedSwitcher(
                  duration: AppMotion.ctaSwap,
                  switchInCurve: AppMotion.easeOut,
                  switchOutCurve: AppMotion.easeOut,
                  child: text,
                )
              : text,
        ),
      ),
    );
  }
}

/// Metin düğmesi: min 44, hap. İsteğe bağlı baş/son simge.
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppIconData? leadingIcon;
  final AppIconData? trailingIcon;
  final double fontSize;
  final FontWeight weight;
  final double tracking;
  final Color? color;
  final Color? background;
  final EdgeInsets padding;
  final double iconSize;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.fontSize = 14,
    this.weight = FontWeight.w500,
    this.tracking = 0.02,
    this.color,
    this.background,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.iconSize = 18,
  });

  /// `digura-prototip.html` metin düğmesi: 15 / 600, yatay 14.
  const AppTextButton.strong({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.color,
    this.background,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  }) : fontSize = 15,
       weight = FontWeight.w600,
       tracking = 0,
       iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = color ?? p.fg2;
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: padding,
        decoration: ShapeDecoration(shape: const StadiumBorder(), color: background ?? Colors.transparent),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[AppIcon(leadingIcon!, size: iconSize, color: fg), const SizedBox(width: 6)],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(fontSize, weight: weight, height: 1.4, tracking: tracking, color: fg),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 6),
                AppIcon(trailingIcon!, size: iconSize, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Yuvarlak simge düğmesi (44 veya 48). Pasifken saydamlık 0.35.
class AppIconButton extends StatelessWidget {
  final AppIconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final double iconSize;
  final Color? color;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 44,
    this.iconSize = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      semanticLabel: tooltip,
      child: AnimatedOpacity(
        duration: AppMotion.press,
        opacity: onPressed == null ? 0.35 : 1,
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: AppIcon(icon, size: iconSize, color: color ?? context.palette.fg),
          ),
        ),
      ),
    );
  }
}
