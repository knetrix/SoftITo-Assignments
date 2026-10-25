import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_dialog.dart';

/// Geri alınamaz eylem onayı: kayıt düzenlenemez ve silinemez.
class SaveConfirmDialog extends StatelessWidget {
  final Mood mood;
  final bool hasNote;

  const SaveConfirmDialog({super.key, required this.mood, required this.hasNote});

  static Future<bool> show(BuildContext context, {required Mood mood, required bool hasNote}) async {
    final result = await showAppDialog<bool>(
      context: context,
      builder: (_) => SaveConfirmDialog(mood: mood, hasNote: hasNote),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppDialog(
      title: AppStrings.confirmTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.confirmBody, style: AppTypography.body(15, height: 1.4, color: p.muted)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: p.borderSoft, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(color: p.mood(mood), borderRadius: BorderRadius.circular(6)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: mood.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: ' · ${hasNote ? AppStrings.withNote : AppStrings.withoutNote}'),
                      ],
                    ),
                    style: AppTypography.body(14, height: 1.4, color: p.fg),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
      actions: [
        AppTextButton.strong(label: AppStrings.cancel, color: p.fg, onPressed: () => Navigator.of(context).pop(false)),
        AppTextButton.strong(
          label: AppStrings.save,
          color: p.accentOn,
          background: p.accent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
