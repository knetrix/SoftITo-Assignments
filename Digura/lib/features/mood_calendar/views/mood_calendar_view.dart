import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/clock.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/layout_parts.dart';
import '../controllers/mood_calendar_controller.dart';
import '../models/mood_calendar_model.dart';
import '../widgets/capsule_detail_sheet.dart';
import '../widgets/heatmap.dart';
import '../widgets/view_segment.dart';

/// Harita sekmesi: Ay (7 sütun) ve Yıl (12 mini ay) ısı haritası.
/// Ay ↔ Yıl ve ay değişimi animasyonsuzdur (yüksek hücre sayısı).
class MoodCalendarView extends StatefulWidget {
  final Object? entranceTrigger;
  final ScrollController? scrollController;

  const MoodCalendarView({super.key, this.entranceTrigger, this.scrollController});

  @override
  State<MoodCalendarView> createState() => _MoodCalendarViewState();
}

class _MoodCalendarViewState extends State<MoodCalendarView> {
  MoodCalendarController? _controller;

  MoodCalendarController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final services = AppScope.of(context);
      _controller = MoodCalendarController(services.moods, services.today);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _openDay(String id) async {
    final detail = await controller.openDay(id);
    if (detail == null || !mounted) return;
    await showCapsuleDetailSheet(context, detail);
  }

  @override
  Widget build(BuildContext context) {
    return EntranceScope(
      trigger: widget.entranceTrigger,
      child: ListenableBuilder(
        listenable: controller.changes,
        builder: (context, _) {
          final state = controller.state.value;
          final isYear = state.mode == CalendarMode.year;
          final blocks = <Widget>[
            const ScreenHeader(eyebrow: AppStrings.mapEyebrow, title: AppStrings.mapTitle),
            ViewSegment(mode: state.mode, onChanged: controller.setMode),
            if (isYear) ..._yearBlocks() else ..._monthBlocks(state.visibleMonth),
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

  List<Widget> _monthBlocks(DateTime month) {
    final days = DateHelpers.daysInMonth(month.year, month.month);
    return [
      MonthNav(
        title: DateHelpers.formatMonth(month),
        subtitle: AppStrings.monthColored(controller.countForMonth(month), days),
        onPrevious: controller.canGoPrevious ? controller.previousMonth : null,
        onNext: controller.canGoNext ? controller.nextMonth : null,
      ),
      MonthHeatmap(month: month, cells: controller.monthCells(month), onDayTap: _openDay),
      const MoodLegend(),
      const InfoHint(icon: AppIcons.lock, text: AppStrings.mapHint),
    ];
  }

  List<Widget> _yearBlocks() {
    final year = controller.today.year;
    return [
      MonthNav(
        title: '$year',
        monoTitle: true,
        subtitle: AppStrings.yearColored(controller.countForYear(year)),
        showArrows: false,
      ),
      YearHeatmap(months: controller.yearMonths(year), onMonthTap: controller.openMonth),
      const MoodLegend(),
    ];
  }
}
