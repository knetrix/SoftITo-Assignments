import 'package:flutter/foundation.dart'; // defaultTargetPlatform Ve debugPrint İçin Flutter Foundation Kütüphanesini import Eder.
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Yerel Bildirim Planlama API'lerini import Eder.
import 'package:timezone/data/latest.dart' as tz_data; // Saat Dilimi Veritabanını tz_data Önekiyle import Eder.
import 'package:timezone/timezone.dart' as tz; // TZDateTime Ve UTC Konumu İçin timezone Kütüphanesini tz Önekiyle import Eder.

import '../constants/app_strings.dart'; // Bildirim Ve Kanal Metinleri İçin AppStrings'i import Eder.
import '../utils/clock.dart'; // Test Edilebilir Zaman Kaynağı Clock Class'ını import Eder.

/// Her akşam 21:00 yerel hatırlatıcı. Bildirim metni hiçbir zaman not
/// içermez (kilitli not gizliliği).
abstract interface class ReminderService { // Günlük Hatırlatıcı Servislerinin Interface'idir.
  /// İzni ister ve hatırlatıcıyı kurar; izin verilmezse `false`.
  Future<bool> enableDaily(); // Günlük Hatırlatıcıyı Açar Ve Başarı Durumunu Döndürür.

  Future<void> disable(); // Günlük Hatırlatıcıyı Kapatır.
}

class NoopReminderService implements ReminderService { // Testlerde Kullanılan Hiçbir Şey Yapmayan Hatırlatıcı Servisidir.
  @override // Superclass'taki enableDaily Metodunun Override Edildiğini Belirtir.
  Future<bool> enableDaily() async => true; // Bildirim Kurmadan Her Zaman true Döndürür.

  @override // Superclass'taki disable Metodunun Override Edildiğini Belirtir.
  Future<void> disable() async {} // Hiçbir İşlem Yapmaz.
}

class LocalReminderService implements ReminderService { // flutter_local_notifications İle Gerçek Hatırlatıcı Kuran Servistir.
  static const int _notificationId = 2100; // Hatırlatıcı Bildiriminin Sabit id'sidir.
  static const int hour = 21; // Hatırlatıcının Gönderileceği Saattir.

  final Clock _clock; // Şimdiki Zamanı Sağlayan Clock Nesnesidir.
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin(); // Yerel Bildirim Plugin Örneğidir.
  bool _initialized = false; // Plugin'in Başlatılıp Başlatılmadığını Tutar.

  LocalReminderService(this._clock); // Clock Nesnesini Alan Constructor'dır.

  Future<void> _ensureInitialized() async { // Plugin'i Ve Saat Dilimi Verisini Yalnızca Bir Kez Başlatır.
    if (_initialized) return; // Zaten Başlatıldıysa Çıkar.
    tz_data.initializeTimeZones(); // Saat Dilimi Veritabanını Yükler.
    await _plugin.initialize( // Bildirim Plugin'ini Platform Ayarlarıyla Başlatır.
      settings: const InitializationSettings( // Platformlara Göre Başlatma Ayarlarını Tanımlar.
        android: AndroidInitializationSettings('@mipmap/launcher_icon'), // Android Bildirim Simgesini Belirler.
        iOS: DarwinInitializationSettings( // iOS Başlatma Ayarlarını Tanımlar.
          requestAlertPermission: false, // Başlatırken Uyarı İzni İstemez.
          requestBadgePermission: false, // Başlatırken Rozet İzni İstemez.
          requestSoundPermission: false, // Başlatırken Ses İzni İstemez.
        ),
      ),
    );
    _initialized = true; // Plugin'i Başlatılmış Olarak İşaretler.
  }

  Future<bool> _requestPermission() async { // Platforma Göre Bildirim İzni İster.
    if (defaultTargetPlatform == TargetPlatform.iOS) { // Platform iOS İse.
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>(); // iOS'a Özgü Plugin Uygulamasını Alır.
      return await ios?.requestPermissions(alert: true, sound: true) ?? false; // Uyarı Ve Ses İzni İster, Sonuç Yoksa false Döndürür.
    }
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>(); // Android'e Özgü Plugin Uygulamasını Alır.
    return await android?.requestNotificationsPermission() ?? true; // Bildirim İzni İster, Sonuç Yoksa true Döndürür.
  }

  @override // Superclass'taki enableDaily Metodunun Override Edildiğini Belirtir.
  Future<bool> enableDaily() async { // Her Akşam 21:00 İçin Tekrarlayan Bildirimi Planlar.
    try { // Planlama Hatalarını Yakalamak İçin try Bloğu Başlatır.
      await _ensureInitialized(); // Plugin'in Başlatıldığından Emin Olur.
      if (!await _requestPermission()) return false; // İzin Verilmezse false Döndürür.
      await _plugin.cancel(id: _notificationId); // Önceki Hatırlatıcıyı İptal Eder.
      await _plugin.zonedSchedule( // Saat Dilimine Bağlı Bildirimi Planlar.
        id: _notificationId, // Bildirimin Sabit id'sini Verir.
        title: AppStrings.reminderNotificationTitle, // Bildirim Başlığını Belirler.
        body: AppStrings.reminderNotificationBody, // Not İçermeyen Bildirim Gövdesini Belirler.
        scheduledDate: _nextNinePm(), // İlk Tetiklenme Zamanını Bir Sonraki 21:00 Yapar.
        notificationDetails: const NotificationDetails( // Platforma Özgü Bildirim Ayrıntılarını Tanımlar.
          android: AndroidNotificationDetails( // Android Bildirim Kanalı Ayarlarını Tanımlar.
            AppStrings.reminderChannelId, // Bildirim Kanalının id'sidir.
            AppStrings.reminderChannelName, // Bildirim Kanalının Adıdır.
            channelDescription: AppStrings.reminderChannelDescription, // Bildirim Kanalının Açıklamasıdır.
          ),
          iOS: DarwinNotificationDetails(), // Varsayılan iOS Bildirim Ayrıntılarını Kullanır.
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // Android'de Boşta Modda Da Yaklaşık Zamanlamaya İzin Verir.
        matchDateTimeComponents: DateTimeComponents.time, // Bildirimi Her Gün Aynı Saatte Tekrarlar.
      );
      return true; // Planlama Başarılıysa true Döndürür.
    } on Exception catch (e) { // Planlama Sırasında Oluşan Exception'ı Yakalar.
      debugPrint('Digura: hatırlatıcı kurulamadı ($e)'); // Hatayı Debug Konsoluna Yazar.
      return false; // Hata Durumunda false Döndürür.
    }
  }

  @override // Superclass'taki disable Metodunun Override Edildiğini Belirtir.
  Future<void> disable() async { // Planlanmış Hatırlatıcıyı İptal Eder.
    try { // İptal Hatalarını Yakalamak İçin try Bloğu Başlatır.
      await _ensureInitialized(); // Plugin'in Başlatıldığından Emin Olur.
      await _plugin.cancel(id: _notificationId); // Hatırlatıcı Bildirimini İptal Eder.
    } on Exception catch (e) { // İptal Sırasında Oluşan Exception'ı Yakalar.
      debugPrint('Digura: hatırlatıcı kapatılamadı ($e)'); // Hatayı Debug Konsoluna Yazar.
    }
  }

  /// Yerel 21:00'in UTC karşılığı. `timezone` veritabanında cihaz bölgesi
  /// bilinmediği için zaman UTC ile ifade edilir; günlük tekrar aynı ana denk
  /// gelir (yaz saati uygulamayan bölgelerde birebir 21:00).
  tz.TZDateTime _nextNinePm() { // Bir Sonraki Yerel 21:00'i UTC TZDateTime Olarak Hesaplar.
    final now = _clock.now(); // Clock'tan Şimdiki Zamanı Alır.
    var target = DateTime(now.year, now.month, now.day, hour); // Bugünün 21:00'ini Hedef Olarak Ayarlar.
    if (!target.isAfter(now)) target = DateTime(now.year, now.month, now.day + 1, hour); // 21:00 Geçtiyse Hedefi Yarına Kaydırır.
    return tz.TZDateTime.from(target.toUtc(), tz.UTC); // Hedefi UTC TZDateTime'a Çevirip Döndürür.
  }
}
