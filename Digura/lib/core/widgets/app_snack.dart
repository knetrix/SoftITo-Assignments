import 'package:flutter/material.dart';

import '../constants/app_motion.dart';

/// Bildirim (DESIGN.md 5): `fg` zemin, `surface` yazı, 12 px yarıçap,
/// `role="status"`. Yeni bildirim öncekinin yerini alır.
void showAppSnack(BuildContext context, String message, {Duration duration = AppMotion.snackShort}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Semantics(liveRegion: true, child: Text(message)),
        duration: duration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
}
