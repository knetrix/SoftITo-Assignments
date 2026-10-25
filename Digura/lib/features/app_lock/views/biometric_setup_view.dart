import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/layout_parts.dart';
import '../controllers/pin_setup_controller.dart';
import '../models/pin_flow_model.dart';
import '../widgets/biometric_widgets.dart';
import '../widgets/pin_widgets.dart';

/// Kurulum 2/2 (isteğe bağlı): tek dokunuşla açılış için parmak izi.
class BiometricSetupView extends StatefulWidget {
  /// `skipped == true` ise "Şimdi değil" ile geçildi.
  final ValueChanged<bool> onCompleted;

  const BiometricSetupView({super.key, required this.onCompleted});

  @override
  State<BiometricSetupView> createState() => _BiometricSetupViewState();
}

class _BiometricSetupViewState extends State<BiometricSetupView> {
  BiometricSetupController? _controller;

  BiometricSetupController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final services = AppScope.of(context);
    _controller ??= BiometricSetupController(services.lock, services.biometrics);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    await controller.skip();
    widget.onCompleted(true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: ValueListenableBuilder<BiometricSetupStatus>(
          valueListenable: controller.status,
          builder: (context, status, _) {
            final on = status == BiometricSetupStatus.enabled;
            final scanning = status == BiometricSetupStatus.scanning;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StepTopBar(
                  step: AppStrings.stepOf(2, 2),
                  trailing: on ? null : AppTextButton(label: AppStrings.notNow, onPressed: scanning ? null : _skip),
                ),
                Expanded(
                  child: FillScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PinIntro(
                            title: on ? AppStrings.bioOnTitle : AppStrings.bioSetupTitle,
                            subtitle: on ? AppStrings.bioOnSub : AppStrings.bioSetupSub,
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: BiometricHero(
                                  scanning: scanning,
                                  enabled: on,
                                  semanticLabel: on ? AppStrings.bioIconOnLabel : AppStrings.bioIconLabel,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const FactRow(icon: AppIcons.chip, text: AppStrings.bioFactDevice),
                          const SizedBox(height: 8),
                          const FactRow(icon: AppIcons.alert, text: AppStrings.bioFactFallback),
                          const SizedBox(height: 8),
                          switch (status) {
                            BiometricSetupStatus.scanning => const PinMessage(text: AppStrings.bioPlaceFinger),
                            BiometricSetupStatus.failed => const PinMessage(
                              text: AppStrings.bioSetupFailed,
                              tone: PinTone.error,
                              icon: AppIcons.alert,
                            ),
                            BiometricSetupStatus.unavailable => const PinMessage(
                              text: AppStrings.bioUnavailable,
                              tone: PinTone.error,
                              icon: AppIcons.alert,
                            ),
                            _ => const PinMessage(text: ''),
                          },
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    children: [
                      const PageDots(count: 2, index: 1),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: on ? AppStrings.startToday : (scanning ? AppStrings.bioScanning : AppStrings.bioUse),
                        onPressed: scanning
                            ? null
                            : on
                            ? () => widget.onCompleted(false)
                            : (status == BiometricSetupStatus.unavailable ? null : controller.enable),
                      ),
                    ],
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
