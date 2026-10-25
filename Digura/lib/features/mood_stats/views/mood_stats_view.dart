import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/clock.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/layout_parts.dart';
import '../controllers/mood_stats_controller.dart';
import '../widgets/stats_widgets.dart';

/// İstatistik sekmesi: aylık dağılım şeritleri, yüzdeler ve boş durum.
class MoodStatsView extends StatefulWidget {
  final Object? entranceTrigger;
  final ScrollController? scrollController;

  const MoodStatsView({super.key, this.entranceTrigger, this.scrollController});

  @override
  State<MoodStatsView> createState() => _MoodStatsViewState();
}

class _MoodStatsViewState extends State<MoodStatsView> {
  MoodStatsController? _controller;

  MoodStatsController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final services = AppScope.of(context);
      _controller = MoodStatsController(services.moods, services.today);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EntranceScope(
      trigger: widget.entranceTrigger,
      child: ListenableBuilder(
        listenable: controller.changes,
        builder: (context, _) {
          final stats = controller.stats;
          final blocks = <Widget>[
            const ScreenHeader(eyebrow: AppStrings.statsEyebrow, title: AppStrings.statsTitle),
            MonthNav(
              title: DateHelpers.formatMonth(stats.month),
              subtitle: AppStrings.statsSub,
              onPrevious: controller.canGoPrevious ? controller.previousMonth : null,
              onNext: controller.canGoNext ? controller.nextMonth : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: stats.isEmpty ? const StatsEmptyState() : StatsCard(stats: stats),
            ),
            const InfoHint(icon: AppIcons.shield, text: AppStrings.statsPrivacy),
          ];
          return SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (var i = 0; i < blocks.length; i++) EntranceItem(index: i, child: blocks[i])],
            ),
          );
        },
      ),
    );
  }
}
