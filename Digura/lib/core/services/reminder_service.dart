import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_strings.dart';
import '../utils/clock.dart';

/// Her akşam 21:00 yerel hatırlatıcı. Bildirim metni hiçbir zaman not
/// içermez (kilitli not gizliliği).
abstract interface class ReminderService {
  /// İzni ister ve hatırlatıcıyı kurar; izin verilmezse `false`.
  Future<bool> enableDaily();

  Future<void> disable();
}

class NoopReminderService implements ReminderService {
  @override
  Future<bool> enableDaily() async => true;

  @override
  Future<void> disable() async {}
}

class LocalReminderService implements ReminderService {
  static const int _notificationId = 2100;
  static const int hour = 21;

  final Clock _clock;
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  LocalReminderService(this._clock);

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  Future<bool> _requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<bool> enableDaily() async {
    try {
      await _ensureInitialized();
      if (!await _requestPermission()) return false;
      await _plugin.cancel(id: _notificationId);
      await _plugin.zonedSchedule(
        id: _notificationId,
        title: AppStrings.reminderNotificationTitle,
        body: AppStrings.reminderNotificationBody,
        scheduledDate: _nextNinePm(),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            AppStrings.reminderChannelId,
            AppStrings.reminderChannelName,
            channelDescription: AppStrings.reminderChannelDescription,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return true;
    } on Exception catch (e) {
      debugPrint('Digura: hatırlatıcı kurulamadı ($e)');
      return false;
    }
  }

  @override
  Future<void> disable() async {
    try {
      await _ensureInitialized();
      await _plugin.cancel(id: _notificationId);
    } on Exception catch (e) {
      debugPrint('Digura: hatırlatıcı kapatılamadı ($e)');
    }
  }

  /// Yerel 21:00'in UTC karşılığı. `timezone` veritabanında cihaz bölgesi
  /// bilinmediği için zaman UTC ile ifade edilir; günlük tekrar aynı ana denk
  /// gelir (yaz saati uygulamayan bölgelerde birebir 21:00).
  tz.TZDateTime _nextNinePm() {
    final now = _clock.now();
    var target = DateTime(now.year, now.month, now.day, hour);
    if (!target.isAfter(now)) target = DateTime(now.year, now.month, now.day + 1, hour);
    return tz.TZDateTime.from(target.toUtc(), tz.UTC);
  }
}
