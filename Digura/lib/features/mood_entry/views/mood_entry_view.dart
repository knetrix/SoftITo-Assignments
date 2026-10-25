import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/layout_parts.dart';
import '../controllers/mood_entry_controller.dart';
import '../models/mood_entry_draft_model.dart';
import '../models/mood_entry_model.dart';
import '../widgets/mood_orb.dart';
import '../widgets/mood_swatch_picker.dart';
import '../widgets/note_field.dart';
import '../widgets/save_confirm_dialog.dart';
import '../widgets/saved_capsule_card.dart';

/// Bugün sekmesi: renk dairesi, 5 duygu seçici, 140 karakterlik not ve
/// onaylı kayıt; kayıttan sonra kilitli kapsül kartı.
class MoodEntryView extends StatefulWidget {
  final Object? entranceTrigger;
  final VoidCallback onOpenSettings;
  final VoidCallback onShowMap;
  final ScrollController? scrollController;

  const MoodEntryView({
    super.key,
    required this.onOpenSettings,
    required this.onShowMap,
    this.entranceTrigger,
    this.scrollController,
  });

  @override
  State<MoodEntryView> createState() => _MoodEntryViewState();
}

class _MoodEntryViewState extends State<MoodEntryView> {
  MoodEntryController? _controller;

  MoodEntryController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final services = AppScope.of(context);
      _controller = MoodEntryController(services.moods, services.today);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _askSave() async {
    final draft = controller.draft.value;
    final mood = draft.selectedMood;
    if (mood == null) return;
    FocusScope.of(context).unfocus();
    final confirmed = await SaveConfirmDialog.show(context, mood: mood, hasNote: draft.hasNote);
    if (!confirmed || !mounted) return;
    final outcome = await controller.save();
    if (!mounted) return;
    showAppSnack(context, outcome == SaveOutcome.saved ? AppStrings.savedSnack : AppStrings.alreadySavedSnack);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: EntranceScope(
        trigger: widget.entranceTrigger,
        child: ListenableBuilder(
          listenable: controller.changes,
          builder: (context, _) {
            final saved = controller.savedToday;
            return SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.only(top: 4, bottom: 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: saved == null ? _buildDraft() : _buildSaved(saved),
            );
          },
        ),
      ),
    );
  }

  Widget _header(String title) => ScreenHeader(
    eyebrow: DateHelpers.formatWithWeekday(controller.today),
    title: title,
    trailing: AppIconButton(
      icon: AppIcons.gear,
      iconSize: 22,
      tooltip: AppStrings.settingsTooltip,
      onPressed: widget.onOpenSettings,
    ),
  );

  Widget _buildDraft() {
    return ValueListenableBuilder<MoodEntryDraftModel>(
      valueListenable: controller.draft,
      builder: (context, draft, _) {
        final mood = draft.selectedMood;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EntranceItem(index: 0, child: _header(AppStrings.todayTitle)),
            EntranceItem(
              index: 1,
              child: _OrbBlock(
                orb: MoodOrb(mood: mood),
                title: mood?.label ?? AppStrings.pickColor,
                titleMuted: mood == null,
                meta: mood == null ? AppStrings.pickColorHint : AppStrings.selectedMood,
              ),
            ),
            EntranceItem(
              index: 2,
              child: MoodSwatchPicker(selected: mood, onSelect: controller.selectMood),
            ),
            EntranceItem(
              index: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: NoteField(value: draft.note, onChanged: controller.updateNote),
              ),
            ),
            EntranceItem(
              index: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: PrimaryButton(label: AppStrings.saveColor, onPressed: draft.canSave ? _askSave : null),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaved(MoodEntry saved) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntranceItem(index: 0, child: _header(AppStrings.todaySavedTitle)),
        EntranceItem(
          index: 1,
          child: _OrbBlock(
            orb: MoodOrb(mood: saved.mood, showCheck: true, popOnMount: controller.savedNow.value),
            title: saved.mood.label,
            meta: AppStrings.savedPermanent,
          ),
        ),
        EntranceItem(
          index: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: SavedCapsuleCard(entry: saved, today: controller.today),
          ),
        ),
        EntranceItem(
          index: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Center(
              child: AppTextButton.strong(
                label: AppStrings.seeOnMap,
                trailingIcon: AppIcons.right,
                color: p.fg,
                onPressed: widget.onShowMap,
              ),
            ),
          ),
        ),
        const EntranceItem(index: 4, child: InfoHint.textOnly(text: AppStrings.tomorrowHint)),
      ],
    );
  }
}

/// Daire + başlık + mono alt bilgi (`orb-wrap`).
class _OrbBlock extends StatelessWidget {
  final Widget orb;
  final String title;
  final bool titleMuted;
  final String meta;

  const _OrbBlock({required this.orb, required this.title, required this.meta, this.titleMuted = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 18),
      child: Column(
        children: [
          orb,
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Semantics(
              liveRegion: true,
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 27),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.display(
                        22,
                        height: 1.2,
                        tracking: -0.015,
                        color: titleMuted ? p.muted : p.fg,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meta,
                    textAlign: TextAlign.center,
                    style: AppTypography.mono(12, color: p.muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
