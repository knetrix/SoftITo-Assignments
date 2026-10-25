import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/layout_parts.dart';
import '../controllers/app_lock_controller.dart';
import '../models/app_lock_model.dart';
import '../widgets/lock_overlays.dart';
import '../widgets/pin_widgets.dart';

/// Açılış kilidi: her açılışta PIN tuş takımı ya da parmak izi.
class LockView extends StatefulWidget {
  final VoidCallback onUnlocked;

  /// "PIN'imi unuttum → Her şeyi sil ve sıfırla" onaylandı.
  final VoidCallback onWipeRequested;

  const LockView({super.key, required this.onUnlocked, required this.onWipeRequested});

  @override
  State<LockView> createState() => _LockViewState();
}

class _LockViewState extends State<LockView> {
  AppLockController? _controller;
  Timer? _holdTimer;

  AppLockController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final s = AppScope.of(context);
      _controller = AppLockController(s.lock, s.prefs, s.biometrics, s.clock)..state.addListener(_onState);
    }
  }

  void _onState() {
    if (controller.state.value.unlocked && _holdTimer == null) {
      _holdTimer = Timer(AppMotion.unlockHold, widget.onUnlocked);
    }
  }

  Future<void> _forgot() async {
    final wipe = await ForgotPinDialog.show(context);
    if (wipe && mounted) widget.onWipeRequested();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: p.surface,
        body: ValueListenableBuilder<AppLockState>(
          valueListenable: controller.state,
          builder: (context, state, _) {
            return Stack(
              children: [
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _LockBody(state: state, controller: controller),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        child: Center(
                          child: AppTextButton(
                            label: AppStrings.forgotPin,
                            onPressed: state.unlocked || state.sheet != null ? null : _forgot,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: FingerprintSheetLayer(
                    status: state.sheet,
                    attemptsLeft: state.biometricAttemptsLeft,
                    onUsePin: controller.closeSheet,
                    onRetry: controller.startBiometric,
                  ),
                ),
                if (state.unlocked)
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: AppMotion.ui,
                      curve: AppMotion.easeOut,
                      builder: (context, t, child) => Opacity(opacity: t, child: child),
                      child: const UnlockedOverlay(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LockBody extends StatelessWidget {
  final AppLockState state;
  final AppLockController controller;

  const _LockBody({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bioReady = state.biometricEnabled && !state.biometricTemporarilyDisabled;
    final wrongPin = state.error != null && !state.isLockedOut;
    final Widget message;
    if (state.error != null) {
      message = PinMessage(text: state.error!, tone: PinTone.error, icon: AppIcons.alert);
    } else if (state.biometricEnabled && state.biometricTemporarilyDisabled) {
      message = const PinMessage(text: AppStrings.bioTemporarilyOff, icon: AppIcons.alert);
    } else {
      message = const PinMessage(text: '');
    }
    return FillScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Wordmark(fontSize: 24),
            const SizedBox(height: 8),
            Text(
              bioReady ? AppStrings.lockPromptBio : AppStrings.lockPromptPin,
              textAlign: TextAlign.center,
              style: AppTypography.body(15, color: p.fg2),
            ),
            const SizedBox(height: 32),
            PinDots(
              filled: state.entered.length,
              tone: wrongPin ? PinTone.error : PinTone.normal,
              shakeTick: state.shakeTick,
            ),
            const SizedBox(height: 12),
            message,
            const Spacer(),
            AnimatedOpacity(
              duration: AppMotion.ui,
              curve: AppMotion.easeOut,
              opacity: state.isLockedOut ? 0.6 : 1,
              child: PinKeypad(
                enabled: state.keypadEnabled,
                onDigit: controller.inputDigit,
                onDelete: controller.deleteDigit,
                leading: state.biometricEnabled
                    ? PinKey(
                        label: state.biometricTemporarilyDisabled ? AppStrings.bioKeyOffLabel : AppStrings.bioKeyLabel,
                        icon: AppIcons.fingerprint,
                        ghost: true,
                        enabled: state.canUseBiometric && state.keypadEnabled,
                        onTap: controller.startBiometric,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
