import 'package:flutter/foundation.dart'; // immutable Annotation'ını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'ını import Eder.

/// Bir duygunun aylık payı.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class MoodShare { // Bir Duygunun Aylık Sayısını ve Yüzdesini Tutan Class'tır.
  final Mood mood; // Payı Tutulan Duygudur.
  final int count; // Duygunun Aydaki Gün Sayısıdır.
  final int percent; // Duygunun Yuvarlanmış Yüzde Payıdır.

  const MoodShare({required this.mood, required this.count, required this.percent}); // Field'ları required Yapan const Constructor'dır.

  factory MoodShare.fromJson(Map<String, dynamic> json) => MoodShare( // JSON'dan MoodShare Oluşturan factory Constructor'dır.
    mood: Mood.fromId(json['mood'] as String?) ?? Mood.serene, // Duyguyu id'den Çözer, Bulunamazsa serene Kullanır.
    count: json['count'] as int? ?? 0, // Sayıyı Okur, Yoksa 0 Kullanır.
    percent: json['percent'] as int? ?? 0, // Yüzdeyi Okur, Yoksa 0 Kullanır.
  );

  Map<String, dynamic> toJson() => {'mood': mood.id, 'count': count, 'percent': percent}; // Payı JSON Map'ine Dönüştürür.

  @override // Superclass'taki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => // İki Payın Eşitliğini Karşılaştırır.
      other is MoodShare && other.mood == mood && other.count == count && other.percent == percent; // Tip ve Tüm Field'lar Aynıysa true Döndürür.

  @override // Superclass'taki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash(mood, count, percent); // Field'lardan hashCode Üretir.
}

/// Aylık duygu dağılımı. Yalnızca renkler kullanılır; notlara erişilmez.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class MoodStatsModel { // Bir Ayın Duygu Dağılımını Tutan Class'tır.
  final DateTime month; // İstatistiğin Ait Olduğu Aydır.
  final int total; // Aydaki Toplam Kayıt Sayısıdır.

  /// Gün sayısına göre azalan sıralı (eşitlikte duygu sırası korunur).
  final List<MoodShare> shares; // Sıralı Duygu Payları Listesidir.

  const MoodStatsModel({required this.month, required this.total, required this.shares}); // Field'ları required Yapan const Constructor'dır.

  bool get isEmpty => total == 0; // Ayda Hiç Kayıt Yoksa true Döndürür.

  MoodShare? get top => isEmpty ? null : shares.first; // En Sık Duyguyu, Kayıt Yoksa null Döndürür.

  factory MoodStatsModel.fromCounts(DateTime month, Map<Mood, int> counts) { // Duygu Sayaçlarından Model Üreten factory Constructor'dır.
    final total = counts.values.fold<int>(0, (a, b) => a + b); // Tüm Sayaçları Toplar.
    final shares = [ // Her Duygu İçin Pay Listesi Oluşturur.
      for (final mood in Mood.values) // Tüm Duygular İçin Döner.
        MoodShare( // Duygunun Payını Oluşturur.
          mood: mood, // Duyguyu Verir.
          count: counts[mood] ?? 0, // Sayıyı Verir, Yoksa 0 Kullanır.
          percent: total == 0 ? 0 : ((counts[mood] ?? 0) * 100 / total).round(), // Yüzdeyi Hesaplayıp Yuvarlar.
        ),
    ];
    // List.sort kararlı değildir; eşitlikte duygu sırası korunur (prototipteki Array.sort gibi).
    shares.sort((a, b) { // Payları Sayıya Göre Azalan Sıralar.
      final byCount = b.count.compareTo(a.count); // Sayıları Büyükten Küçüğe Karşılaştırır.
      return byCount != 0 ? byCount : a.mood.index.compareTo(b.mood.index); // Eşitlikte Duygu Sırasını Kullanır.
    });
    return MoodStatsModel(month: month, total: total, shares: List.unmodifiable(shares)); // Değiştirilemez Pay Listesiyle Modeli Döndürür.
  }
}
