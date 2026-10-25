import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_icon.dart';
import '../models/app_lock_model.dart';
import 'biometric_widgets.dart';

/// Biyometrik doğrulama alt paneli (`FingerprintSheet`): kenarlardan 8 px
/// içeride yüzen panel; açılış `sheet` + `drawer`, kapanış `ui` + `easeOut`.
class FingerprintSheetLayer extends StatefulWidget {
  final FingerprintSheetStatus? status;
  final int attemptsLeft;
  final VoidCallback onUsePin;
  final VoidCallback onRetry;

  const FingerprintSheetLayer({
    super.key,
    required this.status,
    required this.attemptsLeft,
    required this.onUsePin,
    required this.onRetry,
  });

  @override
  State<FingerprintSheetLayer> createState() => _FingerprintSheetLayerState();
}

class _FingerprintSheetLayerState extends State<FingerprintSheetLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: AppMotion.sheet,
    reverseDuration: AppMotion.ui,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _open,
    curve: AppMotion.drawer,
    reverseCurve: AppMotion.easeOut,
  );
  FingerprintSheetStatus? _shown;

  @override
  void initState() {
    super.initState();
    _shown = widget.status;
    if (_shown != null) _open.forward();
    _open.addStatusListener((s) {
      if (s == AnimationStatus.dismissed && mounted) setState(() => _shown = null);
    });
  }

  @override
  void didUpdateWidget(FingerprintSheetLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != null) {
      _shown = widget.status;
      _open.forward();
    } else if (oldWidget.status != null) {
      _open.reverse();
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _shown;
    if (status == null) return const SizedBox.shrink();
    final p = context.palette;
    final reduce = context.reduceMotion;
    final dismissible = status == FingerprintSheetStatus.failed || status == FingerprintSheetStatus.lockout;
    final bottom = math.max(8.0, MediaQuery.viewPaddingOf(context).bottom);
    final panel = _FingerprintPanel(
      status: status,
      attemptsLeft: widget.attemptsLeft,
      onUsePin: widget.onUsePin,
      onRetry: widget.onRetry,
    );
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: dismissible ? widget.onUsePin : null,
            child: FadeTransition(
              opacity: _open,
              child: ColoredBox(color: p.scrim),
            ),
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: bottom,
          child: reduce
              ? FadeTransition(opacity: _open, child: panel)
              : SlideTransition(
                  position: Tween(begin: const Offset(0, 1.1), end: Offset.zero).animate(_curve),
                  child: panel,
                ),
        ),
      ],
    );
  }
}

class _FingerprintPanel extends StatelessWidget {
  final FingerprintSheetStatus status;
  final int attemptsLeft;
  final VoidCallback onUsePin;
  final VoidCallback onRetry;

  const _FingerprintPanel({
    required this.status,
    required this.attemptsLeft,
    required this.onUsePin,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final lockout = status == FingerprintSheetStatus.lockout;
    final failed = status == FingerprintSheetStatus.failed || lockout;
    final ok = status == FingerprintSheetStatus.verified;
    final scanning = status == FingerprintSheetStatus.scanning;
    final text = switch (status) {
      FingerprintSheetStatus.lockout => AppStrings.bioSheetLockout,
      FingerprintSheetStatus.failed => AppStrings.bioFail(attemptsLeft),
      FingerprintSheetStatus.verified => AppStrings.bioSheetOk,
      FingerprintSheetStatus.scanning => AppStrings.bioSheetPlace,
    };
    final tone = failed ? p.danger : (ok ? p.success : p.muted);
    final circle = failed ? p.dangerSoft : (ok ? p.successSoft : p.surfaceWarm);
    final icon = failed ? AppIcons.alert : (ok ? AppIcons.check : AppIcons.fingerprint);
    final iconColor = failed ? p.danger : (ok ? p.success : p.fg);
    final reduce = context.reduceMotion;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: AppStrings.bioSheetTitle,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          decoration: BoxDecoration(color: p.raisedSheet, borderRadius: BorderRadius.circular(28), boxShadow: p.raised),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.bioSheetTitle, style: AppTypography.display(18, height: 1.5, color: p.fg)),
              const SizedBox(height: 4),
              Text(AppStrings.bioSheetSub, style: AppTypography.body(14, color: p.fg2)),
              const SizedBox(height: 20),
              SizedBox.square(
                dimension: 86,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: AppMotion.ui,
                      switchInCurve: AppMotion.easeOut,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: reduce
                            ? child
                            : ScaleTransition(
                                scale: Tween<double>(begin: AppMotion.dialogFrom, end: 1).animate(animation),
                                child: child,
                              ),
                      ),
                      child: Container(
                        key: ValueKey(icon),
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: circle),
                        alignment: Alignment.center,
                        child: AppIcon(icon, size: 40, strokeWidth: 1.6, color: iconColor),
                      ),
                    ),
                    if (scanning) ScanRing(size: 86, color: p.fg),
                  ],
                ),
              ),
              const SizedBox(height: 12 - 5),
              Semantics(
                liveRegion: true,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 42),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(14, color: tone),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: lockout
                    ? [
                        const SizedBox.shrink(),
                        Flexible(
                          child: AppTextButton(label: AppStrings.continueWithPin, onPressed: onUsePin),
                        ),
                      ]
                    : [
                        Flexible(
                          child: AppTextButton(label: AppStrings.usePin, onPressed: ok || scanning ? null : onUsePin),
                        ),
                        if (failed)
                          Flexible(
                            child: AppTextButton(label: AppStrings.retry, onPressed: onRetry),
                          ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Kilit açıldı" katmanı: içerik 0.96 → 1 ölçek + saydamlıkla, 40 ms arayla.
class UnlockedOverlay extends StatefulWidget {
  const UnlockedOverlay({super.key});

  @override
  State<UnlockedOverlay> createState() => _UnlockedOverlayState();
}

class _UnlockedOverlayState extends State<UnlockedOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.unlockPop + AppMotion.stagger * 2,
  )..forward();

  Widget _pop(int index, Widget child) {
    final total = _c.duration!.inMicroseconds;
    final start = (AppMotion.stagger * index).inMicroseconds / total;
    final end = (AppMotion.stagger * index + AppMotion.unlockPop).inMicroseconds / total;
    final interval = Interval(start, end, curve: AppMotion.easeOut);
    final reduce = context.reduceMotion;
    return AnimatedBuilder(
      animation: _c,
      child: child,
      builder: (context, child) {
        final t = interval.transform(_c.value);
        final faded = Opacity(opacity: t, child: child);
        if (reduce) return faded;
        return Transform.scale(scale: AppMotion.dialogFrom + (1 - AppMotion.dialogFrom) * t, child: faded);
      },
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      liveRegion: true,
      child: ColoredBox(
        color: p.surface,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _pop(
                0,
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < Mood.values.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: p.mood(Mood.values[i])),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _pop(1, Text(AppStrings.unlockedTitle, style: AppTypography.display(24, height: 1.3, color: p.fg))),
              const SizedBox(height: 12),
              _pop(2, Text(AppStrings.unlockedSub, style: AppTypography.body(14, color: p.muted))),
            ],
          ),
        ),
      ),
    );
  }
}

/// "PIN kurtarılamaz" onayı: tek seçenek her şeyi silmek.
class ForgotPinDialog extends StatelessWidget {
  const ForgotPinDialog({super.key});

  static Future<bool> show(BuildContext context) async =>
      await showAppDialog<bool>(context: context, builder: (_) => const ForgotPinDialog()) ?? false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = AppTypography.body(14, color: p.fg2);
    return AppDialog.lock(
      title: AppStrings.forgotTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.forgotBody1, style: style),
          const SizedBox(height: 12),
          Text.rich(
            const TextSpan(
              children: [
                TextSpan(text: AppStrings.forgotBody2Lead),
                TextSpan(
                  text: AppStrings.forgotBody2Strong,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: AppStrings.forgotBody2Tail),
              ],
            ),
            style: style,
          ),
          const SizedBox(height: 12),
        ],
      ),
      actions: [
        AppTextButton(label: AppStrings.cancel, onPressed: () => Navigator.of(context).pop(false)),
        AppTextButton(label: AppStrings.wipeAll, color: p.danger, onPressed: () => Navigator.of(context).pop(true)),
      ],
    );
  }
}
