import 'dart:async';

import 'package:flutter/foundation.dart';

import '../constants/app_strings.dart';

/// Test edilebilir zaman soyutlaması. Uygulamada `DateTime.now()` doğrudan
/// çağrılmaz; 30 günlük kapsül kilidi ve PIN bekleme süresi buradan hesaplanır.
class Clock {
  final DateTime Function() _now;

  const Clock([DateTime Function() now = DateTime.now]) : _now = now;

  /// Sabit bir ana kilitlenmiş saat (testler için).
  factory Clock.fixed(DateTime instant) => Clock(() => instant);

  DateTime now() => _now();

  /// Kullanıcının yerel takvim günü, UTC gece yarısı olarak (`dateOnly`).
  DateTime today() => DateHelpers.dateOnly(_now());
}

/// Ayarlanabilir saat: birim testlerinde zamanı ileri sarmak için.
class MutableClock extends Clock {
  DateTime current;

  MutableClock(this.current) : super();

  @override
  DateTime now() => current;

  @override
  DateTime today() => DateHelpers.dateOnly(current);

  void advance(Duration by) => current = current.add(by);
}

/// Bugünün tarihini yayınlar; gece yarısında ve uygulama öne geldiğinde
/// yenilenir ki "Bugün" sekmesi gün değişince kendini güncellesin.
class TodayNotifier extends ValueNotifier<DateTime> {
  final Clock clock;
  final bool autoRefresh;
  Timer? _midnight;

  TodayNotifier(this.clock, {this.autoRefresh = true}) : super(clock.today()) {
    _scheduleMidnight();
  }

  void refresh() {
    final today = clock.today();
    if (today != value) value = today;
    _scheduleMidnight();
  }

  void _scheduleMidnight() {
    _midnight?.cancel();
    if (!autoRefresh) return;
    final now = clock.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(next.difference(now), refresh);
  }

  @override
  void dispose() {
    _midnight?.cancel();
    super.dispose();
  }
}

/// UTC gün (y/a/g) yardımcıları ve Türkçe biçimlendirme.
abstract final class DateHelpers {
  /// Yerel takvim bileşenlerini UTC gece yarısına sabitler.
  static DateTime dateOnly(DateTime date) => DateTime.utc(date.year, date.month, date.day);

  /// `YYYY-MM-DD` gün anahtarı.
  static String dayKey(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  static DateTime fromDayKey(String key) {
    final parts = key.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], parts[2]);
  }

  static DateTime addDays(DateTime date, int days) => DateTime.utc(date.year, date.month, date.day + days);

  static int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

  /// Pazartesi ile başlayan haftada ayın ilk gününden önceki boş hücre sayısı.
  static int leadingBlanks(int year, int month) => DateTime.utc(year, month, 1).weekday - 1;

  static DateTime monthStart(DateTime date) => DateTime.utc(date.year, date.month, 1);

  static DateTime shiftMonth(DateTime month, int delta) => DateTime.utc(month.year, month.month + delta, 1);

  /// "25 Ekim 2026"
  static String formatLong(DateTime date) => '${date.day} ${AppStrings.months[date.month - 1]} ${date.year}';

  /// "Pazar"
  static String weekday(DateTime date) => AppStrings.weekdays[date.weekday - 1];

  /// "25 Ekim 2026 · Pazar"
  static String formatWithWeekday(DateTime date) => '${formatLong(date)} · ${weekday(date)}';

  /// "Ekim 2026"
  static String formatMonth(DateTime month) => '${AppStrings.months[month.month - 1]} ${month.year}';
}

/// Türkçe büyük harf dönüşümü (CSS `text-transform: uppercase` + `lang="tr"`).
String trUpper(String text) => text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
