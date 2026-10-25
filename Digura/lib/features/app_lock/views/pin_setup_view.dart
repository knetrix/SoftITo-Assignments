import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/layout_parts.dart';
import '../controllers/pin_setup_controller.dart';
import '../models/pin_flow_model.dart';
import '../widgets/pin_widgets.dart';

/// Kurulum 1/2: 4 haneli PIN oluştur ve tekrar girerek doğrula.
class PinSetupView extends StatefulWidget {
  final VoidCallback onCompleted;

  const PinSetupView({super.key, required this.onCompleted});

  @override
  State<PinSetupView> createState() => _PinSetupViewState();
}

class _PinSetupViewState extends State<PinSetupView> {
  PinSetupController? _controller;

  PinSetupController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= PinSetupController(AppScope.of(context).lock);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: ValueListenableBuilder<PinSetupState>(
          valueListenable: controller.state,
          builder: (context, state, _) {
            final confirm = state.stage == PinSetupStage.confirm;
            final done = state.stage == PinSetupStage.done;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StepTopBar(
                  step: AppStrings.stepOf(1, 2),
                  trailing: confirm
                      ? AppTextButton(
                          label: AppStrings.restart,
                          leadingIcon: AppIcons.back,
                          onPressed: controller.restart,
                        )
                      : null,
                ),
                Expanded(
                  child: done ? const _PinCreated() : _PinEntry(state: state, controller: controller),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    children: [
                      const PageDots(count: 2, index: 0),
                      if (done) ...[
                        const SizedBox(height: 12),
                        PrimaryButton(label: AppStrings.next, onPressed: widget.onCompleted),
                      ],
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

class _PinEntry extends StatelessWidget {
  final PinSetupState state;
  final PinSetupController controller;

  const _PinEntry({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    final confirm = state.stage == PinSetupStage.confirm;
    return FillScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            PinIntro(
              title: confirm ? AppStrings.pinConfirmTitle : AppStrings.pinCreateTitle,
              subtitle: confirm ? AppStrings.pinConfirmSub : AppStrings.pinCreateSub,
            ),
            const SizedBox(height: 32),
            PinDots(
              filled: state.entered.length,
              tone: state.error != null ? PinTone.error : PinTone.normal,
              shakeTick: state.shakeTick,
            ),
            const SizedBox(height: 12),
            state.error != null
                ? PinMessage(text: state.error!, tone: PinTone.error, icon: AppIcons.alert)
                : PinMessage(text: confirm ? AppStrings.pinHintConfirm : AppStrings.pinHintCreate),
            const Spacer(),
            PinKeypad(onDigit: controller.inputDigit, onDelete: controller.deleteDigit),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PinCreated extends StatelessWidget {
  const _PinCreated();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.successSoft),
                alignment: Alignment.center,
                child: AppIcon(AppIcons.check, size: 40, strokeWidth: 2.2, color: p.success),
              ),
              const SizedBox(height: 12),
              Text(AppStrings.pinCreated, style: AppTypography.display(24, height: 1.3, color: p.fg)),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 236),
                child: Text(
                  AppStrings.pinCreatedSub,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(15, color: p.fg2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
