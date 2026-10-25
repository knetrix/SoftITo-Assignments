import 'package:flutter/material.dart';

import '../constants/app_motion.dart';

/// Sayfa geçişleri (ANIMATION.md 5.1). Gelen sayfa sağdan kayar (`slide`,
/// 300 ms, `easeOut`); giden sayfa %22 sola kayıp solar (parallax).
/// Hareket azaltma açıkken yalnızca çapraz solma (`ui`).
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final bool fadeOnly;

  AppPageRoute({required WidgetBuilder builder, required bool reduceMotion, this.fadeOnly = false, super.settings})
    : super(
        transitionDuration: reduceMotion || fadeOnly ? AppMotion.ui : AppMotion.slide,
        reverseTransitionDuration: reduceMotion || fadeOnly ? AppMotion.ui : AppMotion.slide,
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, animation, secondary, child) {
          final inCurve = CurvedAnimation(parent: animation, curve: AppMotion.easeOut);
          final outCurve = CurvedAnimation(parent: secondary, curve: AppMotion.easeOut);
          if (reduceMotion || fadeOnly) {
            return FadeTransition(
              opacity: inCurve,
              child: FadeTransition(opacity: ReverseAnimation(outCurve), child: child),
            );
          }
          return SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(inCurve),
            child: SlideTransition(
              position: Tween(begin: Offset.zero, end: const Offset(-AppMotion.parallax, 0)).animate(outCurve),
              child: FadeTransition(opacity: ReverseAnimation(outCurve), child: child),
            ),
          );
        },
      );

  /// Bağlamdan hareket tercihini okuyarak rota üretir.
  static AppPageRoute<T> of<T>(BuildContext context, WidgetBuilder builder, {bool fadeOnly = false}) =>
      AppPageRoute<T>(builder: builder, reduceMotion: context.reduceMotion, fadeOnly: fadeOnly);
}
