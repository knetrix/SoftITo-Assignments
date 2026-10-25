import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_motion.dart';
import '../theme/app_theme.dart';

/// Diyalog açılışı (ANIMATION.md 4.3): saydamlık 0 → 1 ve ölçek 0.96 → 1,
/// `ui` (200 ms) `easeOut`. Hareket azaltma açıkken yalnızca solma.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final reduce = context.reduceMotion;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: context.palette.scrim,
    transitionDuration: AppMotion.ui,
    pageBuilder: (context, _, _) => builder(context),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: AppMotion.easeOut);
      final faded = FadeTransition(opacity: curved, child: child);
      if (reduce) return faded;
      return ScaleTransition(
        scale: Tween<double>(begin: AppMotion.dialogFrom, end: 1).animate(curved),
        child: faded,
      );
    },
  );
}

/// 28 px yarıçaplı diyalog yüzeyi: başlık, gövde ve sağa yaslı eylemler.
class AppDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final double titleSize;
  final double titleGap;
  final EdgeInsets padding;
  final double actionsGap;
  final bool raised;

  /// Gövdenin yatay iç boşluğa taşma miktarı (`.radios { margin: 0 -12px }`).
  final double bodyBleed;

  const AppDialog({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
    this.titleSize = 22,
    this.titleGap = 10,
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 16),
    this.actionsGap = 18,
    this.raised = false,
    this.bodyBleed = 0,
  });

  /// `digura-kilit.html` diyalogu: başlık 24, alt boşluk 12, gölgeli.
  const AppDialog.lock({super.key, required this.title, required this.body, required this.actions, this.bodyBleed = 0})
    : titleSize = 24,
      titleGap = 12,
      padding = const EdgeInsets.fromLTRB(24, 24, 24, 12),
      actionsGap = 16,
      raised = true;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: double.infinity,
            padding: padding.copyWith(left: padding.left - bodyBleed, right: padding.right - bodyBleed),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: raised ? p.raised : null,
            ),
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: title,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: bodyBleed),
                    child: Text(
                      title,
                      style: AppTypography.display(titleSize, height: 1.25, tracking: -0.01, color: p.fg),
                    ),
                  ),
                  SizedBox(height: titleGap),
                  body,
                  SizedBox(height: actionsGap),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: bodyBleed),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 4),
                          Flexible(child: actions[i]),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
