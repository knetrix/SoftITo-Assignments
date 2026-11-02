import 'package:flutter/widgets.dart'; // InheritedWidget İçin Flutter'ın Temel Widget'larını import Eder.

import '../data/app_lock_repository.dart'; // PIN Kilidini Yöneten AppLockRepository Class'ını import Eder.
import '../data/mood_repository.dart'; // Duygu Kayıtlarını Yöneten MoodRepository Class'ını import Eder.
import '../data/preferences_service.dart'; // Kalıcı Ayarları Yöneten PreferencesService Class'ını import Eder.
import '../services/biometric_service.dart'; // BiometricAuthenticator Interface'ini import Eder.
import '../services/reminder_service.dart'; // ReminderService Interface'ini import Eder.
import '../utils/clock.dart'; // Clock Ve TodayNotifier Class'larını import Eder.

/// Uygulama genelindeki tekil servisler. Durum yönetimi paketi yerine
/// çekirdek `InheritedWidget` ile ağaca verilir; testlerde sahteleri geçilir.
class AppServices { // Uygulama Servislerini Bir Arada Tutan Paket Class'tır.
  final Clock clock; // Test Edilebilir Zaman Kaynağıdır.
  final TodayNotifier today; // Bugünün Tarihini Yayınlayan ValueNotifier'dır.
  final PreferencesService prefs; // Kalıcı Ayar Servisidir.
  final MoodRepository moods; // Duygu Kayıtları Repository'sidir.
  final AppLockRepository lock; // PIN Kilidi Repository'sidir.
  final BiometricAuthenticator biometrics; // Biyometrik Doğrulayıcıdır.
  final ReminderService reminders; // Günlük Hatırlatıcı Servisidir.

  AppServices({ // Tüm Servisleri required Olarak Alan Constructor'dır.
    required this.clock, // clock Field'ını required Yapar.
    required this.today, // today Field'ını required Yapar.
    required this.prefs, // prefs Field'ını required Yapar.
    required this.moods, // moods Field'ını required Yapar.
    required this.lock, // lock Field'ını required Yapar.
    required this.biometrics, // biometrics Field'ını required Yapar.
    required this.reminders, // reminders Field'ını required Yapar.
  });

  void dispose() { // Kaynak Tutan Servisleri Serbest Bırakır.
    today.dispose(); // TodayNotifier'ı dispose Eder.
    moods.dispose(); // MoodRepository'yi dispose Eder.
    lock.dispose(); // AppLockRepository'yi dispose Eder.
    prefs.dispose(); // PreferencesService'i dispose Eder.
  }
}

class AppScope extends InheritedWidget { // AppServices'i Widget Tree'ye Sağlayan InheritedWidget'tır.
  final AppServices services; // Ağaca Sağlanan Servis Paketidir.

  const AppScope({super.key, required this.services, required super.child}); // key Ve child'ı Superclass'a İleten const Constructor'dır.

  static AppServices of(BuildContext context) { // Context'ten AppServices'e Erişim Sağlayan Statik Metottur.
    final scope = context.getInheritedWidgetOfExactType<AppScope>(); // Üst Ağaçtaki AppScope'u Bağımlılık Kurmadan Bulur.
    assert(scope != null, 'AppScope bulunamadı'); // AppScope Yoksa Debug Modda Hata Verir.
    return scope!.services; // Bulunan Servis Paketini Döndürür.
  }

  @override // Superclass'taki updateShouldNotify Metodunun Override Edildiğini Belirtir.
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services; // Servis Paketi Değiştiyse Bağımlıları Bilgilendirir.
}
