import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/data/mood_repository.dart';
import '../models/mood_entry_draft_model.dart';
import '../models/mood_entry_model.dart';

enum SaveOutcome { saved, alreadySaved, noMood }

/// Bugün sekmesinin iş mantığı: seçim, tek cümle kuralı ve günde bir kayıt.
class MoodEntryController {
  final MoodRepository _repository;
  final ValueListenable<DateTime> _today;

  final ValueNotifier<MoodEntryDraftModel> draft = ValueNotifier(const MoodEntryDraftModel());

  /// Kayıttan hemen sonra dairenin bir kez "yerleşme" animasyonu için.
  final ValueNotifier<bool> savedNow = ValueNotifier(false);

  Timer? _savedNowTimer;

  MoodEntryController(this._repository, this._today);

  /// Bugün değiştiğinde ya da kayıt eklendiğinde yeniden çizim tetikleyicisi.
  Listenable get changes => Listenable.merge([_repository.entries, _today]);

  DateTime get today => _today.value;

  MoodEntry? get savedToday => _repository.entryFor(_today.value);

  void selectMood(Mood mood) => draft.value = draft.value.copyWith(selectedMood: mood);

  /// Satır sonları boşluğa döner, 140 karakteri aşan kısım kesilir.
  void updateNote(String raw) {
    final single = raw.replaceAll(RegExp(r'[\r\n]+'), ' ');
    final chars = single.characters;
    final clipped = chars.length > MoodEntryDraftModel.maxNoteLength
        ? chars.take(MoodEntryDraftModel.maxNoteLength).toString()
        : single;
    draft.value = draft.value.copyWith(note: clipped);
  }

  Future<SaveOutcome> save() async {
    final mood = draft.value.selectedMood;
    if (mood == null) return SaveOutcome.noMood;
    final ok = await _repository.saveToday(mood, draft.value.note.trim());
    if (!ok) return SaveOutcome.alreadySaved;
    draft.value = const MoodEntryDraftModel();
    savedNow.value = true;
    _savedNowTimer?.cancel();
    _savedNowTimer = Timer(AppMotion.savedNowWindow, () => savedNow.value = false);
    return SaveOutcome.saved;
  }

  void dispose() {
    _savedNowTimer?.cancel();
    draft.dispose();
    savedNow.dispose();
  }
}
