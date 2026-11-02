import 'dart:async'; // Timer Class'ını Sağlayan Async Kütüphanesini import Eder.

import 'package:flutter/foundation.dart'; // ValueNotifier Class'ını Sağlayan Foundation Kütüphanesini import Eder.

import '../constants/app_strings.dart'; // Ay ve Gün Adları İçin AppStrings'i import Eder.

/// Test edilebilir zaman soyutlaması. Uygulamada `DateTime.now()` doğrudan
/// çağrılmaz; 30 günlük kapsül kilidi ve PIN bekleme süresi buradan hesaplanır.
class Clock { // Test Edilebilir Zaman Kaynağı Class'ıdır.
  final DateTime Function() _now; // Şimdiki Zamanı Döndüren Fonksiyondur.

  const Clock([DateTime Function() now = DateTime.now]) : _now = now; // Varsayılan Olarak DateTime.now Kullanan const Constructor'dır.

  /// Sabit bir ana kilitlenmiş saat (testler için).
  factory Clock.fixed(DateTime instant) => Clock(() => instant); // Hep Aynı Anı Döndüren Clock Üreten factory Constructor'dır.

  DateTime now() => _now(); // Şimdiki Zamanı Döndürür.

  /// Kullanıcının yerel takvim günü, UTC gece yarısı olarak (`dateOnly`).
  DateTime today() => DateHelpers.dateOnly(_now()); // Bugünü UTC Gece Yarısına Normalize Ederek Döndürür.
}

/// Ayarlanabilir saat: birim testlerinde zamanı ileri sarmak için.
class MutableClock extends Clock { // Zamanı Elle İlerletilebilen Clock Alt Class'ıdır.
  DateTime current; // Saatin Güncel Zamanıdır.

  MutableClock(this.current) : super(); // current Field'ını Alan Constructor'dır.

  @override // Superclass'taki now Metodunun Override Edildiğini Belirtir.
  DateTime now() => current; // Güncel Zamanı Döndürür.

  @override // Superclass'taki today Metodunun Override Edildiğini Belirtir.
  DateTime today() => DateHelpers.dateOnly(current); // Güncel Zamanın Gününü Döndürür.

  void advance(Duration by) => current = current.add(by); // Zamanı Verilen Süre Kadar İleri Sarar.
}

/// Bugünün tarihini yayınlar; gece yarısında ve uygulama öne geldiğinde
/// yenilenir ki "Bugün" sekmesi gün değişince kendini güncellesin.
class TodayNotifier extends ValueNotifier<DateTime> { // Bugünün Tarihini Yayınlayan ValueNotifier'dır.
  final Clock clock; // Tarihin Okunduğu Zaman Kaynağıdır.
  final bool autoRefresh; // Gece Yarısı Otomatik Yenilemenin Açık Olup Olmadığını Belirtir.
  Timer? _midnight; // Gece Yarısında Tetiklenen Timer'dır.

  TodayNotifier(this.clock, {this.autoRefresh = true}) : super(clock.today()) { // Bugünün Tarihiyle Başlayan Constructor'dır.
    _scheduleMidnight(); // İlk Gece Yarısı Yenilemesini Planlar.
  }

  void refresh() { // Bugünün Tarihini Yeniden Okur.
    final today = clock.today(); // Güncel Günü Alır.
    if (today != value) value = today; // Gün Değiştiyse value'yu Günceller.
    _scheduleMidnight(); // Sonraki Gece Yarısı Yenilemesini Planlar.
  }

  void _scheduleMidnight() { // Bir Sonraki Gece Yarısı İçin Timer Kurar.
    _midnight?.cancel(); // Önceki Timer'ı İptal Eder.
    if (!autoRefresh) return; // Otomatik Yenileme Kapalıysa Çıkar.
    final now = clock.now(); // Şimdiki Zamanı Alır.
    final next = DateTime(now.year, now.month, now.day + 1); // Yarının Gece Yarısını Hesaplar.
    _midnight = Timer(next.difference(now), refresh); // Gece Yarısında refresh'i Çağıracak Timer'ı Kurar.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // Notifier Kaldırılırken Kaynakları Serbest Bırakır.
    _midnight?.cancel(); // Bekleyen Timer'ı İptal Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }
}

/// UTC gün (y/a/g) yardımcıları ve Türkçe biçimlendirme.
abstract final class DateHelpers { // Tarih Hesaplama ve Biçimlendirme Yardımcılarını Tutan Class'tır.
  /// Yerel takvim bileşenlerini UTC gece yarısına sabitler.
  static DateTime dateOnly(DateTime date) => DateTime.utc(date.year, date.month, date.day); // Saati Atıp UTC Gece Yarısı Döndürür.

  /// `YYYY-MM-DD` gün anahtarı.
  static String dayKey(DateTime date) { // Tarihten Gün Anahtarı Üretir.
    final m = date.month.toString().padLeft(2, '0'); // Ayı İki Haneli Metne Çevirir.
    final d = date.day.toString().padLeft(2, '0'); // Günü İki Haneli Metne Çevirir.
    return '${date.year}-$m-$d'; // YYYY-MM-DD Biçiminde Anahtarı Döndürür.
  }

  static DateTime fromDayKey(String key) { // Gün Anahtarını Tarihe Çevirir.
    final parts = key.split('-').map(int.parse).toList(); // Anahtarı Yıl, Ay ve Gün Sayılarına Ayırır.
    return DateTime.utc(parts[0], parts[1], parts[2]); // Parçalardan UTC Tarih Oluşturur.
  }

  static DateTime addDays(DateTime date, int days) => DateTime.utc(date.year, date.month, date.day + days); // Tarihe Gün Ekleyip UTC Gün Döndürür.

  static int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day; // Aydaki Gün Sayısını Döndürür.

  /// Pazartesi ile başlayan haftada ayın ilk gününden önceki boş hücre sayısı.
  static int leadingBlanks(int year, int month) => DateTime.utc(year, month, 1).weekday - 1; // Ayın Başındaki Boş Hücre Sayısını Hesaplar.

  static DateTime monthStart(DateTime date) => DateTime.utc(date.year, date.month, 1); // Ayın İlk Gününü Döndürür.

  static DateTime shiftMonth(DateTime month, int delta) => DateTime.utc(month.year, month.month + delta, 1); // Ayı delta Kadar Kaydırır.

  /// "25 Ekim 2026"
  static String formatLong(DateTime date) => '${date.day} ${AppStrings.months[date.month - 1]} ${date.year}'; // Tarihi Uzun Türkçe Biçimde Döndürür.

  /// "Pazar"
  static String weekday(DateTime date) => AppStrings.weekdays[date.weekday - 1]; // Haftanın Gününün Türkçe Adını Döndürür.

  /// "25 Ekim 2026 · Pazar"
  static String formatWithWeekday(DateTime date) => '${formatLong(date)} · ${weekday(date)}'; // Tarihi Gün Adıyla Birlikte Döndürür.

  /// "Ekim 2026"
  static String formatMonth(DateTime month) => '${AppStrings.months[month.month - 1]} ${month.year}'; // Ay ve Yılı Türkçe Biçimde Döndürür.
}

/// Türkçe büyük harf dönüşümü (CSS `text-transform: uppercase` + `lang="tr"`).
String trUpper(String text) => text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase(); // Metni Türkçe Kurallarına Göre Büyük Harfe Çevirir.
