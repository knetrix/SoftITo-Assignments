import 'package:flutter/material.dart';

import 'core/constants/app_motion.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_page_route.dart';
import 'core/widgets/app_scope.dart';
import 'core/widgets/app_snack.dart';
import 'features/app_lock/views/biometric_setup_view.dart';
import 'features/app_lock/views/lock_view.dart';
import 'features/app_lock/views/pin_setup_view.dart';
import 'features/home/views/home_shell_view.dart';
import 'features/onboarding/views/onboarding_view.dart';

/// Digura kök widget'ı: tema tercihi, ekran akışı ve arka plandan dönüşte
/// yeniden kilitleme.
///
/// Akış: Karşılama (3 adım) → PIN (1/2) → Parmak izi (2/2) → Bugün;
/// sonraki açılışlarda Açılış Kilidi → Bugün.
class DiguraApp extends StatefulWidget {
  final AppServices services;

  const DiguraApp({super.key, required this.services});

  @override
  State<DiguraApp> createState() => _DiguraAppState();
}

class _DiguraAppState extends State<DiguraApp> {
  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();
  late final AppLifecycleListener _lifecycle;

  /// Kilit açılmış bir oturum var mı (Bugün'e ulaşıldı mı)?
  bool _sessionUnlocked = false;
  bool _relockShown = false;
  bool _wentToBackground = false;

  AppServices get _s => widget.services;

  /// İlk ekran bir kez seçilir; tema değişiminde yeniden hesaplanmaz.
  late final Widget _home = _initialScreen();

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onPause: _onPause, onResume: _onResume);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _onPause() => _wentToBackground = true;

  void _onResume() {
    _s.today.refresh();
    if (!_wentToBackground) return;
    _wentToBackground = false;
    if (_sessionUnlocked && !_relockShown && _s.lock.hasPin.value) _relock();
  }

  BuildContext? get _navContext => _navigator.currentContext;

  bool get _reduceMotion => _navContext?.reduceMotion ?? false;

  void _replace(WidgetBuilder builder, {bool fade = false}) {
    _navigator.currentState?.pushReplacement(
      AppPageRoute<void>(builder: builder, reduceMotion: _reduceMotion, fadeOnly: fade),
    );
  }

  Widget _initialScreen() {
    if (!_s.prefs.onboardingDone) return OnboardingView(onFinished: _toPinSetup);
    if (!_s.lock.hasPin.value) return PinSetupView(onCompleted: _toBiometricSetup);
    return LockView(onUnlocked: _toHomeAfterUnlock, onWipeRequested: _wipe);
  }

  void _toPinSetup() => _replace((_) => PinSetupView(onCompleted: _toBiometricSetup));

  void _toBiometricSetup() => _replace((_) => BiometricSetupView(onCompleted: _toHomeAfterSetup));

  void _toHomeAfterSetup(bool skipped) {
    _sessionUnlocked = true;
    _replace((_) => const HomeShellView());
    final context = _navContext;
    if (skipped && context != null) {
      showAppSnack(context, AppStrings.bioSkippedSnack, duration: AppMotion.snackLong);
    }
  }

  void _toHomeAfterUnlock() {
    _sessionUnlocked = true;
    _replace((_) => const HomeShellView(), fade: true);
  }

  /// Uygulama öne geldiğinde açık oturumun üstüne kilit ekranı açılır.
  void _relock() {
    final nav = _navigator.currentState;
    if (nav == null) return;
    _relockShown = true;
    nav.push(
      AppPageRoute<void>(
        reduceMotion: true,
        fadeOnly: true,
        builder: (context) => LockView(
          onUnlocked: () {
            _relockShown = false;
            Navigator.of(context).pop();
          },
          onWipeRequested: _wipe,
        ),
      ),
    );
  }

  /// "Her şeyi sil ve sıfırla": PIN, ayarlar ve tüm kayıtlar kalıcı olarak silinir.
  Future<void> _wipe() async {
    await _s.reminders.disable();
    await _s.lock.wipe();
    await _s.prefs.wipe();
    _s.moods.clearInMemory();
    _sessionUnlocked = false;
    _relockShown = false;
    _navigator.currentState?.pushAndRemoveUntil(
      AppPageRoute<void>(
        reduceMotion: _reduceMotion,
        fadeOnly: true,
        builder: (_) => OnboardingView(onFinished: _toPinSetup),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: _s,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _s.prefs.themeMode,
        builder: (context, mode, _) => MaterialApp(
          navigatorKey: _navigator,
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          themeAnimationDuration: AppTheme.themeAnimation,
          themeAnimationCurve: AppMotion.easeOut,
          home: _home,
        ),
      ),
    );
  }
}
