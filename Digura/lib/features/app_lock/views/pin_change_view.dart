import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/layout_parts.dart';
import '../controllers/pin_change_controller.dart';
import '../models/pin_flow_model.dart';
import '../widgets/pin_widgets.dart';

/// Ayarlar › Güvenlik › PIN'i değiştir. Başarıyla biterse `true` ile kapanır.
class PinChangeView extends StatefulWidget {
  const PinChangeView({super.key});

  @override
  State<PinChangeView> createState() => _PinChangeViewState();
}

class _PinChangeViewState extends State<PinChangeView> {
  PinChangeController? _controller;

  PinChangeController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= PinChangeController(AppScope.of(context).lock)..state.addListener(_onState);
  }

  void _onState() {
    if (controller.state.value.completed && mounted) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  static (String, String) _copy(PinChangeStep step) => switch (step) {
    PinChangeStep.current => (AppStrings.changeCurrentTitle, AppStrings.changeCurrentSub),
    PinChangeStep.next => (AppStrings.changeNextTitle, AppStrings.changeNextSub),
    PinChangeStep.confirm => (AppStrings.changeConfirmTitle, AppStrings.changeConfirmSub),
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBarRow(title: AppStrings.changePinTitle, onBack: () => Navigator.of(context).pop(false)),
            Expanded(
              child: ValueListenableBuilder<PinChangeState>(
                valueListenable: controller.state,
                builder: (context, state, _) {
                  final (title, sub) = _copy(state.step);
                  return FillScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          PinIntro(title: title, subtitle: sub),
                          const SizedBox(height: 32),
                          PinDots(
                            filled: state.entered.length,
                            tone: state.error != null ? PinTone.error : PinTone.normal,
                            shakeTick: state.shakeTick,
                          ),
                          const SizedBox(height: 12),
                          state.error != null
                              ? PinMessage(text: state.error!, tone: PinTone.error, icon: AppIcons.alert)
                              : PinMessage(text: AppStrings.stepOf(state.step.number, 3)),
                          const Spacer(),
                          PinKeypad(onDigit: controller.inputDigit, onDelete: controller.deleteDigit),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
