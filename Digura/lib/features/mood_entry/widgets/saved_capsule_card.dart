import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/layout_parts.dart';
import '../models/mood_entry_model.dart';

/// Kayıttan sonra Bugün'deki kilitli kapsül kartı. Not metni burada da
/// gösterilmez; yalnızca notlu/notsuz bilgisi, açılış tarihi ve ilerleme.
class SavedCapsuleCard extends StatelessWidget {
  final MoodEntry entry;
  final DateTime today;

  const SavedCapsuleCard({super.key, required this.entry, required this.today});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final remaining = entry.remainingDays(today);
    final meta = AppTypography.mono(12, color: p.muted);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CapsuleLine(
            title: entry.hasNote ? AppStrings.noteSealed : AppStrings.noNoteToday,
            unlockDate: entry.unlockDate,
          ),
          const SizedBox(height: 12),
          CapsuleProgressBar(value: entry.lockProgress(today)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(AppStrings.capsuleRemaining(remaining), style: meta)),
              Text(AppStrings.lockProgress(MoodEntry.lockDays - remaining, MoodEntry.lockDays), style: meta),
            ],
          ),
        ],
      ),
    );
  }
}
