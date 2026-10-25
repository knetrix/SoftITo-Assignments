import 'package:flutter/material.dart';

import '../constants/app_motion.dart';

/// Kademeli blok girişi (ANIMATION.md 5.2): saydamlık + 8 dp yukarı.
///
/// [EntranceScope] tek bir `AnimationController` tutar; [EntranceItem]'lar
/// kendi gecikmesini `Interval` ile okur. Hareket azaltma açıkken yalnızca
/// solma kalır. [trigger] değiştiğinde giriş baştan oynar.
class EntranceScope extends StatefulWidget {
  final Widget child;
  final Object? trigger;
  final bool playOnMount;
  final Duration duration;
  final Duration step;
  final Duration maxDelay;

  const EntranceScope({
    super.key,
    required this.child,
    this.trigger,
    this.playOnMount = false,
    this.duration = AppMotion.settle,
    this.step = AppMotion.stagger,
    this.maxDelay = AppMotion.staggerMax,
  });

  /// İlk açılış girişi: 420 ms, bloklar 0 / 60 / 120 ms.
  const EntranceScope.intro({super.key, required this.child, this.playOnMount = true})
    : trigger = null,
      duration = AppMotion.intro,
      step = AppMotion.introStep,
      maxDelay = AppMotion.staggerMax;

  @override
  State<EntranceScope> createState() => _EntranceScopeState();
}

class _EntranceScopeState extends State<EntranceScope> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration + widget.maxDelay,
    value: widget.playOnMount ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.playOnMount) _controller.forward();
  }

  @override
  void didUpdateWidget(EntranceScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _EntranceData(
    animation: _controller,
    duration: widget.duration,
    step: widget.step,
    maxDelay: widget.maxDelay,
    child: widget.child,
  );
}

class _EntranceData extends InheritedWidget {
  final Animation<double> animation;
  final Duration duration;
  final Duration step;
  final Duration maxDelay;

  const _EntranceData({
    required this.animation,
    required this.duration,
    required this.step,
    required this.maxDelay,
    required super.child,
  });

  @override
  bool updateShouldNotify(_EntranceData old) => animation != old.animation;
}

class EntranceItem extends StatelessWidget {
  final int index;
  final Widget child;

  const EntranceItem({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<_EntranceData>();
    if (data == null) return child;
    final total = (data.duration + data.maxDelay).inMicroseconds;
    var delay = data.step * index;
    if (delay > data.maxDelay) delay = data.maxDelay;
    final start = delay.inMicroseconds / total;
    final end = (delay + data.duration).inMicroseconds / total;
    final interval = Interval(start, end.clamp(0.0, 1.0), curve: AppMotion.easeOut);
    final reduce = context.reduceMotion;
    return AnimatedBuilder(
      animation: data.animation,
      child: child,
      builder: (context, child) {
        final t = interval.transform(data.animation.value);
        final faded = Opacity(opacity: t, child: child);
        if (reduce || t == 1) return faded;
        return Transform.translate(offset: Offset(0, AppMotion.enterOffset * (1 - t)), child: faded);
      },
    );
  }
}
