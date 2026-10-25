import 'package:flutter/material.dart';

import '../constants/app_motion.dart';

typedef PressedWidgetBuilder = Widget Function(BuildContext context, bool pressed);

/// Basma geri bildirimi (ANIMATION.md 4.1): basılıyken ölçek küçülür,
/// bırakılınca geri döner. Düğme 0.97 · tuş 0.94 · swatch 0.92–0.94 ·
/// hücre 0.96. Hareket azaltma açıkken ölçek değişmez.
///
/// Yerel UI durumu olduğu için `StatefulWidget` kabul edilen tek istisnadır.
class Pressable extends StatefulWidget {
  final Widget? child;
  final PressedWidgetBuilder? builder;
  final VoidCallback? onTap;
  final double scale;
  final String? semanticLabel;
  final bool button;
  final bool? selected;
  final bool? checked;

  const Pressable({
    super.key,
    this.child,
    this.builder,
    required this.onTap,
    this.scale = AppMotion.pressButton,
    this.semanticLabel,
    this.button = true,
    this.selected,
    this.checked,
  }) : assert(child != null || builder != null);

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  bool get _enabled => widget.onTap != null;

  void _setDown(bool value) {
    if (!_enabled || _down == value) return;
    setState(() => _down = value);
  }

  @override
  void didUpdateWidget(Pressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) _down = false;
  }

  @override
  Widget build(BuildContext context) {
    final target = (_down && !context.reduceMotion) ? widget.scale : 1.0;
    final content = widget.builder?.call(context, _down) ?? widget.child!;
    return Semantics(
      button: widget.button,
      enabled: _enabled,
      selected: widget.selected,
      checked: widget.checked,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setDown(true),
        onTapUp: (_) => _setDown(false),
        onTapCancel: () => _setDown(false),
        onTap: widget.onTap,
        excludeFromSemantics: true,
        child: AnimatedScale(scale: target, duration: AppMotion.press, curve: AppMotion.easeOut, child: content),
      ),
    );
  }
}
