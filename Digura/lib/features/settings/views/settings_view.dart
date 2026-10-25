import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_page_route.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/layout_parts.dart';
import '../../app_lock/views/pin_change_view.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_widgets.dart';

/// Ayarlar: Gizlilik ve güvenlik, Bildirimler, Görünüm, Örnek veri, Hakkında.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  SettingsController? _controller;

  SettingsController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= SettingsController(AppScope.of(context));
  }

  Future<void> _run(Future<String> Function() action, {Duration duration = AppMotion.snackLong}) async {
    final message = await action();
    if (mounted) showAppSnack(context, message, duration: duration);
  }

  Future<void> _pickTheme() async {
    final picked = await ThemeDialog.show(context, controller.model.theme);
    if (picked != null) await _run(() => controller.setTheme(picked));
  }

  Future<void> _resetSample() async {
    if (await ResetSampleDialog.show(context)) await _run(controller.resetToSampleData);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller.changes,
          builder: (context, _) {
            final model = controller.model;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBarRow(title: AppStrings.settingsTitle, onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      const SettingsGroupLabel(AppStrings.groupPrivacy),
                      SettingsRow(
                        icon: AppIcons.shield,
                        title: AppStrings.security,
                        subtitle: AppStrings.securitySub(model.biometricEnabled),
                        onTap: () =>
                            Navigator.of(context).push(AppPageRoute.of<void>(context, (_) => const SecurityView())),
                      ),
                      const SettingsGroupLabel(AppStrings.groupNotifications),
                      SettingsRow(
                        icon: AppIcons.bell,
                        title: AppStrings.reminder,
                        subtitle: model.reminderEnabled ? AppStrings.reminderOn : AppStrings.reminderOff,
                        switchValue: model.reminderEnabled,
                        onSwitch: (on) => _run(() => controller.setReminder(on)),
                      ),
                      const SettingsGroupLabel(AppStrings.groupAppearance),
                      SettingsRow(
                        icon: AppIcons.theme,
                        title: AppStrings.theme,
                        subtitle: model.theme.summary,
                        onTap: _pickTheme,
                      ),
                      const SettingsGroupLabel(AppStrings.groupSampleData),
                      SettingsRow(
                        icon: AppIcons.restore,
                        title: AppStrings.resetSample,
                        subtitle: AppStrings.resetSampleSub,
                        onTap: _resetSample,
                      ),
                      const SettingsGroupLabel(AppStrings.groupAbout),
                      const SettingsRow(
                        icon: AppIcons.info,
                        title: AppStrings.appName,
                        subtitle: AppStrings.appVersion,
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

/// Ayarlar › Güvenlik: PIN değiştirme ve parmak izi anahtarı.
class SecurityView extends StatefulWidget {
  const SecurityView({super.key});

  @override
  State<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  SettingsController? _controller;

  SettingsController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= SettingsController(AppScope.of(context));
  }

  Future<void> _changePin() async {
    final changed = await Navigator.of(context)
        .push<bool>(AppPageRoute.of<bool>(context, (_) => const PinChangeView()));
    if (changed == true && mounted) {
      showAppSnack(context, AppStrings.pinChangedSnack, duration: AppMotion.snackLong);
    }
  }

  Future<void> _toggleBiometric(bool on) async {
    final message = await controller.setBiometric(on);
    if (mounted) showAppSnack(context, message, duration: AppMotion.snackLong);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller.changes,
          builder: (context, _) {
            final bio = controller.model.biometricEnabled;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBarRow(
                  title: AppStrings.security,
                  backLabel: AppStrings.backToSettings,
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      const SettingsGroupLabel(AppStrings.groupAppLock),
                      SettingsRow(
                        icon: AppIcons.key,
                        title: AppStrings.changePinTitle,
                        subtitle: AppStrings.changePinSub,
                        onTap: _changePin,
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: AppIcons.fingerprint,
                        title: AppStrings.bioRow,
                        subtitle: bio ? AppStrings.bioRowOn : AppStrings.bioRowOff,
                        switchValue: bio,
                        onSwitch: _toggleBiometric,
                      ),
                      const SettingsNote(AppStrings.securityNote),
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
