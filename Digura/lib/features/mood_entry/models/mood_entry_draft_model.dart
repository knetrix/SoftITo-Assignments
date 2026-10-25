import 'package:flutter/widgets.dart';

import '../../../core/constants/app_colors.dart';
import 'mood_entry_model.dart';

/// Bugün sekmesindeki kaydedilmemiş seçim: renk zorunlu, not isteğe bağlı.
@immutable
class MoodEntryDraftModel {
  static const int maxNoteLength = MoodEntry.maxNoteLength;

  final Mood? selectedMood;
  final String note;

  const MoodEntryDraftModel({this.selectedMood, this.note = ''});

  bool get canSave => selectedMood != null;

  int get noteLength => note.characters.length;

  bool get atLimit => noteLength >= maxNoteLength;

  bool get hasNote => note.trim().isNotEmpty;

  MoodEntryDraftModel copyWith({Mood? selectedMood, String? note}) {
    return MoodEntryDraftModel(selectedMood: selectedMood ?? this.selectedMood, note: note ?? this.note);
  }

  factory MoodEntryDraftModel.fromJson(Map<String, dynamic> json) {
    return MoodEntryDraftModel(selectedMood: Mood.fromId(json['mood'] as String?), note: json['note'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'mood': selectedMood?.id, 'note': note};

  @override
  bool operator ==(Object other) =>
      other is MoodEntryDraftModel && other.selectedMood == selectedMood && other.note == note;

  @override
  int get hashCode => Object.hash(selectedMood, note);
}
