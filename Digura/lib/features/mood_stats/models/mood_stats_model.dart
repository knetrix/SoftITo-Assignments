import 'package:flutter/foundation.dart';

import '../../../core/constants/app_colors.dart';

/// Bir duygunun aylık payı.
@immutable
class MoodShare {
  final Mood mood;
  final int count;
  final int percent;

  const MoodShare({required this.mood, required this.count, required this.percent});

  factory MoodShare.fromJson(Map<String, dynamic> json) => MoodShare(
    mood: Mood.fromId(json['mood'] as String?) ?? Mood.serene,
    count: json['count'] as int? ?? 0,
    percent: json['percent'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {'mood': mood.id, 'count': count, 'percent': percent};

  @override
  bool operator ==(Object other) =>
      other is MoodShare && other.mood == mood && other.count == count && other.percent == percent;

  @override
  int get hashCode => Object.hash(mood, count, percent);
}

/// Aylık duygu dağılımı. Yalnızca renkler kullanılır; notlara erişilmez.
@immutable
class MoodStatsModel {
  final DateTime month;
  final int total;

  /// Gün sayısına göre azalan sıralı (eşitlikte duygu sırası korunur).
  final List<MoodShare> shares;

  const MoodStatsModel({required this.month, required this.total, required this.shares});

  bool get isEmpty => total == 0;

  MoodShare? get top => isEmpty ? null : shares.first;

  factory MoodStatsModel.fromCounts(DateTime month, Map<Mood, int> counts) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final shares = [
      for (final mood in Mood.values)
        MoodShare(
          mood: mood,
          count: counts[mood] ?? 0,
          percent: total == 0 ? 0 : ((counts[mood] ?? 0) * 100 / total).round(),
        ),
    ];
    // List.sort kararlı değildir; eşitlikte duygu sırası korunur (prototipteki Array.sort gibi).
    shares.sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.mood.index.compareTo(b.mood.index);
    });
    return MoodStatsModel(month: month, total: total, shares: List.unmodifiable(shares));
  }
}
