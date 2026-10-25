import 'package:flutter/foundation.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// 3 adımlı karşılama durumu.
@immutable
class OnboardingState {
  static const int pageCount = 3;
  static const List<String> ctaLabels = [AppStrings.next, AppStrings.next, AppStrings.startToday];

  final int page;

  /// 1. adımdaki "denemek için bir renge dokun" seçimi (varsayılan Dingin).
  final Mood previewMood;

  /// 3. adımdaki "Her akşam 21:00'de hatırlat" anahtarı.
  final bool reminder;

  const OnboardingState({this.page = 0, this.previewMood = Mood.serene, this.reminder = false});

  bool get isLast => page == pageCount - 1;

  String get ctaLabel => ctaLabels[page];

  OnboardingState copyWith({int? page, Mood? previewMood, bool? reminder}) => OnboardingState(
    page: page ?? this.page,
    previewMood: previewMood ?? this.previewMood,
    reminder: reminder ?? this.reminder,
  );

  factory OnboardingState.fromJson(Map<String, dynamic> json) => OnboardingState(
    page: (json['page'] as int? ?? 0).clamp(0, pageCount - 1),
    previewMood: Mood.fromId(json['mood'] as String?) ?? Mood.serene,
    reminder: json['reminder'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {'page': page, 'mood': previewMood.id, 'reminder': reminder};

  @override
  bool operator ==(Object other) =>
      other is OnboardingState && other.page == page && other.previewMood == previewMood && other.reminder == reminder;

  @override
  int get hashCode => Object.hash(page, previewMood, reminder);
}
