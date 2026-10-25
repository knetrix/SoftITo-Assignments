import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_page_route.dart';
import '../../mood_calendar/views/mood_calendar_view.dart';
import '../../mood_entry/views/mood_entry_view.dart';
import '../../mood_stats/views/mood_stats_view.dart';
import '../../settings/views/settings_view.dart';
import '../controllers/home_controller.dart';
import '../models/home_model.dart';
import '../widgets/digura_navigation_bar.dart';

/// 3 sekmeli ana kabuk: Bugün, Harita, İstatistik. Sekme durumları
/// (`IndexedStack`) korunur; sekme değişince içerik kademeli girer.
class HomeShellView extends StatefulWidget {
  const HomeShellView({super.key});

  @override
  State<HomeShellView> createState() => _HomeShellViewState();
}

class _HomeShellViewState extends State<HomeShellView> {
  final HomeController _controller = HomeController();
  final Map<HomeTab, ScrollController> _scrolls = {for (final tab in HomeTab.values) tab: ScrollController()};

  @override
  void dispose() {
    _controller.dispose();
    for (final s in _scrolls.values) {
      s.dispose();
    }
    super.dispose();
  }

  void _select(HomeTab tab) {
    if (tab == _controller.state.value.tab) return;
    FocusScope.of(context).unfocus();
    final scroll = _scrolls[tab]!;
    if (scroll.hasClients) scroll.jumpTo(0);
    _controller.select(tab);
  }

  void _openSettings() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(AppPageRoute.of<void>(context, (_) => const SettingsView()));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeShellState>(
      valueListenable: _controller.state,
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: context.palette.bg,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: state.tab.index,
              children: [
                MoodEntryView(
                  entranceTrigger: _controller.entranceTriggerFor(HomeTab.today),
                  scrollController: _scrolls[HomeTab.today],
                  onOpenSettings: _openSettings,
                  onShowMap: () => _select(HomeTab.map),
                ),
                MoodCalendarView(
                  entranceTrigger: _controller.entranceTriggerFor(HomeTab.map),
                  scrollController: _scrolls[HomeTab.map],
                ),
                MoodStatsView(
                  entranceTrigger: _controller.entranceTriggerFor(HomeTab.stats),
                  scrollController: _scrolls[HomeTab.stats],
                ),
              ],
            ),
          ),
          bottomNavigationBar: DiguraNavigationBar(selected: state.tab, onSelect: _select),
        );
      },
    );
  }
}
