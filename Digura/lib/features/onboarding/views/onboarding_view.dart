import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/layout_parts.dart';
import '../controllers/onboarding_controller.dart';
import '../models/onboarding_model.dart';
import '../widgets/onboarding_heroes.dart';

/// 3 adımlı karşılama (`PageView`): Devam / Geri / kaydırma. Üst çubuk,
/// sayfa noktaları ve ana düğme sabit kalır; düğme metni çapraz solar.
class OnboardingView extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingView({super.key, required this.onFinished});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  OnboardingController? _controller;
  PageController? _pages;
  bool _finishing = false;

  OnboardingController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final s = AppScope.of(context);
      _controller = OnboardingController(s.prefs, s.reminders);
      _pages = PageController(initialPage: controller.state.value.page);
    }
  }

  @override
  void dispose() {
    _pages?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    final target = page.clamp(0, OnboardingState.pageCount - 1);
    _pages!.animateToPage(
      target,
      duration: context.reduceMotion ? AppMotion.ui : AppMotion.slide,
      curve: AppMotion.easeOut,
    );
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    await controller.finish();
    if (mounted) widget.onFinished();
  }

  void _next() {
    final state = controller.state.value;
    if (state.isLast) {
      _finish();
    } else {
      _goTo(state.page + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: EntranceScope.intro(
          playOnMount: controller.playIntro,
          child: ValueListenableBuilder<OnboardingState>(
            valueListenable: controller.state,
            builder: (context, state, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(page: state.page, onBack: () => _goTo(state.page - 1), onSkip: _finish),
                  Expanded(
                    child: PageView(
                      controller: _pages,
                      onPageChanged: controller.setPage,
                      children: [
                        _Pane(
                          index: 0,
                          pages: _pages!,
                          currentPage: state.page,
                          intro: true,
                          hero: Center(
                            child: MoodPaletteHero(selected: state.previewMood, onSelect: controller.selectMood),
                          ),
                          title: AppStrings.welcomeTitle,
                          body: AppStrings.welcomeBody,
                        ),
                        _Pane(
                          index: 1,
                          pages: _pages!,
                          currentPage: state.page,
                          hero: Center(child: CapsulePreviewHero(active: state.page == 1)),
                          title: AppStrings.capsuleTitle,
                          body: AppStrings.capsuleBody,
                        ),
                        _Pane(
                          index: 2,
                          pages: _pages!,
                          currentPage: state.page,
                          hero: const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(padding: EdgeInsets.only(top: 8), child: HeatmapPreviewHero()),
                          ),
                          title: AppStrings.startTitle,
                          body: AppStrings.startBody,
                          copyBottom: 0,
                          footer: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: PrivacyCard(reminder: state.reminder, onReminderChanged: controller.setReminder),
                          ),
                        ),
                      ],
                    ),
                  ),
                  EntranceItem(
                    index: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Column(
                        children: [
                          PageDots(count: OnboardingState.pageCount, index: state.page),
                          const SizedBox(height: 16),
                          PrimaryButton(label: state.ctaLabel, animateLabel: true, onPressed: _next),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Sabit üst çubuk: 1. adımda marka, sonrasında "Geri"; son adımda "Atla" gizlenir.
class _TopBar extends StatelessWidget {
  final int page;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _TopBar({required this.page, required this.onBack, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    Widget fade(bool visible, Widget child) => IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: AppMotion.ui,
          curve: AppMotion.easeOut,
          child: child,
        ),
      ),
    );
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
      child: Row(
        children: [
          // `.lead { min-width: 96px; height: 44px }`: marka ve "Geri" aynı yerde çapraz solar.
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96, minHeight: 44),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                fade(page == 0, const Wordmark()),
                Transform.translate(
                  offset: const Offset(-8, 0),
                  child: fade(
                    page > 0,
                    AppTextButton(label: AppStrings.back, leadingIcon: AppIcons.back, onPressed: onBack),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          fade(page < OnboardingState.pageCount - 1, AppTextButton(label: AppStrings.skip, onPressed: onSkip)),
        ],
      ),
    );
  }
}

/// Tek karşılama sayfası: görsel + başlık/açıklama. Kayarken ayrılan sayfa
/// solar, gelen sayfa belirir.
class _Pane extends StatelessWidget {
  final int index;
  final PageController pages;

  /// Kontrolcü henüz ölçülmediğinde opaklık için kullanılan etkin sayfa.
  final int currentPage;
  final Widget hero;
  final String title;
  final String body;
  final bool intro;
  final double copyBottom;
  final Widget? footer;

  const _Pane({
    required this.index,
    required this.pages,
    required this.currentPage,
    required this.hero,
    required this.title,
    required this.body,
    this.intro = false,
    this.copyBottom = 20,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget wrap(int i, Widget child) => intro ? EntranceItem(index: i, child: child) : child;
    final content = FillScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: wrap(0, hero)),
            wrap(
              1,
              Padding(
                padding: EdgeInsets.only(bottom: copyBottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(title, style: AppTypography.display(30, height: 1.15, tracking: -0.01, color: p.fg)),
                    ),
                    const SizedBox(height: 12),
                    Text(body, style: AppTypography.body(15, color: p.fg2)),
                  ],
                ),
              ),
            ),
            ?footer,
          ],
        ),
      ),
    );
    return Semantics(
      label: AppStrings.stepOf(index + 1, OnboardingState.pageCount),
      container: true,
      child: AnimatedBuilder(
        animation: pages,
        child: content,
        builder: (context, child) {
          final page = pages.hasClients && pages.position.haveDimensions
              ? pages.page ?? index.toDouble()
              : currentPage.toDouble();
          final opacity = (1 - (page - index).abs()).clamp(0.0, 1.0);
          return Opacity(opacity: opacity, child: child);
        },
      ),
    );
  }
}
