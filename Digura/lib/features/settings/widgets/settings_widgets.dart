import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/pressable.dart';
import '../models/settings_model.dart';

/// Grup etiketi (`.group-label`): 14 / 500, soluk.
class SettingsGroupLabel extends StatelessWidget {
  final String text;

  const SettingsGroupLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: AppTypography.body(14, weight: FontWeight.w500, tracking: 0.02, color: context.palette.muted),
        ),
      ),
    );
  }
}

/// Ayar satırı (`.set-row`): min 72, 24 px simge, başlık + alt yazı ve
/// sağda ok ya da anahtar. Dokunulabilir satır basılıyken 0.985 ölçeklenir.
class SettingsRow extends StatelessWidget {
  final AppIconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitch;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.switchValue,
    this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget content(bool pressed) => AnimatedContainer(
      duration: AppMotion.press,
      curve: AppMotion.easeOut,
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: pressed ? p.borderSoft : Colors.transparent,
      child: Row(
        children: [
          AppIcon(icon, size: 24, color: p.fg2),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body(16, height: 1.35, color: p.fg)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.body(14, height: 1.35, color: p.muted)),
              ],
            ),
          ),
          if (switchValue != null) ...[
            const SizedBox(width: 16),
            Switch(value: switchValue!, onChanged: onSwitch),
          ] else if (onTap != null) ...[
            const SizedBox(width: 16),
            AppIcon(AppIcons.chevron, color: p.muted),
          ],
        ],
      ),
    );
    if (switchValue != null) return MergeSemantics(child: content(false));
    if (onTap == null) return Semantics(container: true, child: content(false));
    return Pressable(
      onTap: onTap,
      scale: AppMotion.pressRow,
      semanticLabel: '$title, $subtitle',
      builder: (context, pressed) => ExcludeSemantics(child: content(pressed)),
    );
  }
}

/// Satır ayırıcı (`.divider`): 1 px `borderSoft`, yatay 24 boşluk.
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 24), color: context.palette.borderSoft);
}

/// Bilgi notu (`.note`): `bg` zemin, kalkan simgesi.
class SettingsNote extends StatelessWidget {
  final String text;

  const SettingsNote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: AppIcon(AppIcons.shield, color: p.fg2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTypography.body(14, color: p.fg2)),
          ),
        ],
      ),
    );
  }
}

/// Tema seçimi (radyo diyaloğu): Sistem varsayılanı / Açık / Koyu.
class ThemeDialog extends StatefulWidget {
  final ThemeOption initial;

  const ThemeDialog({super.key, required this.initial});

  static Future<ThemeOption?> show(BuildContext context, ThemeOption initial) => showAppDialog<ThemeOption>(
    context: context,
    builder: (_) => ThemeDialog(initial: initial),
  );

  @override
  State<ThemeDialog> createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<ThemeDialog> {
  late ThemeOption _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return AppDialog.lock(
      title: AppStrings.theme,
      // `.radios { margin: 0 -12px }`: satırlar diyalog iç boşluğuna 12 px taşar.
      bodyBleed: 12,
      body: Semantics(
        label: AppStrings.theme,
        container: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in ThemeOption.values) ...[
              if (option != ThemeOption.values.first) const SizedBox(height: 2),
              _ThemeRadioRow(
                option: option,
                selected: option == _selected,
                onTap: () => setState(() => _selected = option),
              ),
            ],
          ],
        ),
      ),
      actions: [
        AppTextButton(label: AppStrings.cancel, onPressed: () => Navigator.of(context).pop()),
        AppTextButton(label: AppStrings.ok, onPressed: () => Navigator.of(context).pop(_selected)),
      ],
    );
  }
}

class _ThemeRadioRow extends StatelessWidget {
  final ThemeOption option;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeRadioRow({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Pressable(
        onTap: onTap,
        scale: AppMotion.pressRow,
        button: false,
        semanticLabel: '${option.label}, ${option.description}',
        builder: (context, pressed) => ExcludeSemantics(
          child: AnimatedContainer(
            duration: AppMotion.press,
            curve: AppMotion.easeOut,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: pressed ? p.borderSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppMotion.press,
                  curve: AppMotion.easeOut,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? p.surface : Colors.transparent,
                    border: Border.all(color: selected ? p.accent : p.muted, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: AppMotion.press,
                    curve: AppMotion.easeOut,
                    width: selected ? 10 : 0,
                    height: selected ? 10 : 0,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: p.accent),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.label, style: AppTypography.body(16, height: 1.35, color: p.fg)),
                      Text(option.description, style: AppTypography.body(14, height: 1.35, color: p.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Örnek veriye dön" onayı.
class ResetSampleDialog extends StatelessWidget {
  const ResetSampleDialog({super.key});

  static Future<bool> show(BuildContext context) async =>
      await showAppDialog<bool>(context: context, builder: (_) => const ResetSampleDialog()) ?? false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppDialog.lock(
      title: AppStrings.resetSampleTitle,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(AppStrings.resetSampleBody, style: AppTypography.body(14, color: p.fg2)),
      ),
      actions: [
        AppTextButton(label: AppStrings.cancel, onPressed: () => Navigator.of(context).pop(false)),
        AppTextButton(label: AppStrings.resetSample, onPressed: () => Navigator.of(context).pop(true)),
      ],
    );
  }
}
