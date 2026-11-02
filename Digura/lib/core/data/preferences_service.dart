import 'dart:convert'; // jsonEncode ve jsonDecode Fonksiyonlarını import Eder.

import 'package:flutter/material.dart'; // ThemeMode ve ValueNotifier Tiplerini Sağlayan Material Kütüphanesini import Eder.
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences Class'ını import Eder.

/// Cihaz içi tercihler: tema, karşılama durumu, hatırlatıcı, açılış anı
/// oynatılmış kapsüller, PIN bekleme süresi ve günlük kayıtların ham JSON'u.
///
/// Anahtarlar DESIGN.md Bölüm 10'daki prototip sözleşmesini izler.
class PreferencesService { // SharedPreferences Üzerinden Cihaz İçi Tercihleri Yöneten Servistir.
  static const String _kTheme = 'digura.theme'; // Tema Tercihinin Anahtarıdır.
  static const String _kOnboardingDone = 'digura.onboarding.done'; // Karşılamanın Tamamlanma Durumunun Anahtarıdır.
  static const String _kOnboardingStep = 'digura.onboarding.step'; // Karşılamadaki Mevcut Adımın Anahtarıdır.
  static const String _kEntries = 'digura.entries.v1'; // Günlük Kayıtların JSON Anahtarıdır.
  static const String _kOpened = 'digura.opened'; // Açılmış Kapsüllerin Anahtarıdır.
  static const String _kReminder = 'digura.reminder'; // Hatırlatıcı Durumunun Anahtarıdır.
  static const String _kLockoutUntil = 'digura.lock.lockoutUntil'; // PIN Bekleme Bitiş Zamanının Anahtarıdır.
  static const String _kInstalled = 'digura.installed'; // Kurulum İşaretinin Anahtarıdır.
  static const String _kBiometricSuspended = 'digura.lock.biometricSuspended'; // Biyometrik Askıya Alma Durumunun Anahtarıdır.

  final SharedPreferences _prefs; // Alttaki SharedPreferences Nesnesidir.

  final ValueNotifier<ThemeMode> themeMode; // Seçili Tema Modunu Yayınlayan Notifier'dır.
  final ValueNotifier<bool> reminderEnabled; // Hatırlatıcının Açık Olup Olmadığını Yayınlayan Notifier'dır.

  PreferencesService._(this._prefs) // SharedPreferences'ı Alan Private Constructor'dır.
    : themeMode = ValueNotifier(_parseTheme(_prefs.getString(_kTheme))), // Kayıtlı Temayı Okuyarak themeMode'u Başlatır.
      reminderEnabled = ValueNotifier(_prefs.getBool(_kReminder) ?? false); // Kayıtlı Hatırlatıcı Durumuyla reminderEnabled'ı Başlatır.

  static Future<PreferencesService> init() async { // Servisi async Olarak Oluşturan Fabrika Metodudur.
    final prefs = await SharedPreferences.getInstance(); // SharedPreferences Örneğini Alır.
    return PreferencesService._(prefs); // Yeni PreferencesService Döndürür.
  }

  // ─── İlk kurulum ───

  /// Uygulama bu kurulumda ilk kez mi açılıyor? (iOS anahtar zinciri yeniden
  /// kurulumda silinmediği için güvenli depo bu bilgiye göre temizlenir.)
  bool get isFirstLaunch => !(_prefs.getBool(_kInstalled) ?? false); // Kurulum İşareti Yoksa true Döndürür.

  Future<void> markInstalled() => _prefs.setBool(_kInstalled, true); // Kurulum İşaretini true Olarak Yazar.

  // ─── Tema ───

  Future<void> setThemeMode(ThemeMode mode) async { // Tema Modunu Değiştirip Kaydeder.
    themeMode.value = mode; // Yeni Tema Modunu Yayınlar.
    await _prefs.setString(_kTheme, mode.name); // Tema Modunun Adını Depoya Yazar.
  }

  static ThemeMode _parseTheme(String? raw) => switch (raw) { // Kayıtlı Metni ThemeMode'a Çevirir.
    'light' => ThemeMode.light, // light Değerini Açık Temaya Çevirir.
    'dark' => ThemeMode.dark, // dark Değerini Koyu Temaya Çevirir.
    _ => ThemeMode.system, // Diğer Durumlarda Sistem Temasını Döndürür.
  };

  // ─── Karşılama ───

  bool get onboardingDone => _prefs.getBool(_kOnboardingDone) ?? false; // Karşılamanın Tamamlanıp Tamamlanmadığını Döndürür.

  Future<void> setOnboardingDone(bool value) async { // Karşılama Tamamlanma Durumunu Kaydeder.
    await _prefs.setBool(_kOnboardingDone, value); // Tamamlanma Durumunu Depoya Yazar.
    await _prefs.remove(_kOnboardingStep); // Kayıtlı Karşılama Adımını Siler.
  }

  int get onboardingStep => _prefs.getInt(_kOnboardingStep) ?? 0; // Kayıtlı Karşılama Adımını Döndürür.

  Future<void> setOnboardingStep(int step) => _prefs.setInt(_kOnboardingStep, step); // Karşılama Adımını Depoya Yazar.

  // ─── Hatırlatıcı ───

  Future<void> setReminderEnabled(bool value) async { // Hatırlatıcı Durumunu Değiştirip Kaydeder.
    reminderEnabled.value = value; // Yeni Hatırlatıcı Durumunu Yayınlar.
    await _prefs.setBool(_kReminder, value); // Hatırlatıcı Durumunu Depoya Yazar.
  }

  // ─── Kapsül açılış anı ───

  Set<String> get openedCapsules => (_prefs.getStringList(_kOpened) ?? const []).toSet(); // Açılmış Kapsül id'lerini Set Olarak Döndürür.

  Future<void> setOpenedCapsules(Set<String> ids) => _prefs.setStringList(_kOpened, ids.toList()..sort()); // Açılmış Kapsül id'lerini Sıralı Liste Olarak Yazar.

  // ─── PIN bekleme süresi (uygulama kapatılsa da korunur) ───

  DateTime? get lockoutUntil { // PIN Bekleme Süresinin Bitiş Zamanını Döndüren Getter'dır.
    final ms = _prefs.getInt(_kLockoutUntil); // Kayıtlı Milisaniye Değerini Okur.
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms); // Değer Varsa DateTime'a Çevirir, Yoksa null Döndürür.
  }

  Future<void> setLockoutUntil(DateTime? until) => // PIN Bekleme Bitiş Zamanını Kaydeder ya da Siler.
      until == null ? _prefs.remove(_kLockoutUntil) : _prefs.setInt(_kLockoutUntil, until.millisecondsSinceEpoch); // null İse Anahtarı Siler, Değilse Milisaniye Olarak Yazar.

  /// 3 hatalı parmak izinden sonra sensör, PIN ile giriş yapılana dek kapalı kalır.
  bool get biometricSuspended => _prefs.getBool(_kBiometricSuspended) ?? false; // Biyometriğin Askıda Olup Olmadığını Döndürür.

  Future<void> setBiometricSuspended(bool value) => // Biyometrik Askıya Alma Durumunu Kaydeder.
      value ? _prefs.setBool(_kBiometricSuspended, true) : _prefs.remove(_kBiometricSuspended); // true İse Yazar, false İse Anahtarı Siler.

  // ─── Günlük kayıtlar (yalnızca MoodRepository kullanır) ───

  bool get hasStoredEntries => _prefs.containsKey(_kEntries); // Depoda Kayıt Anahtarı Olup Olmadığını Döndürür.

  List<Map<String, dynamic>> readEntries() { // Kayıtlı JSON Kayıtlarını Okur.
    final raw = _prefs.getString(_kEntries); // Ham JSON Metnini Okur.
    if (raw == null) return const []; // Kayıt Yoksa Boş Liste Döndürür.
    final decoded = jsonDecode(raw) as List<dynamic>; // JSON Metnini Listeye Çözer.
    return decoded.cast<Map<String, dynamic>>(); // Liste Öğelerini Map Tipine Dönüştürür.
  }

  Future<void> writeEntries(List<Map<String, dynamic>> entries) => _prefs.setString(_kEntries, jsonEncode(entries)); // Kayıtları JSON Metni Olarak Yazar.

  /// "Her şeyi sil ve sıfırla": tüm tercihler silinir, kayıtlar boş bırakılır
  /// (örnek veri yeniden yüklenmez).
  Future<void> wipe() async { // Tüm Tercihleri ve Kayıtları Siler.
    await _prefs.clear(); // Tüm SharedPreferences Verisini Temizler.
    await _prefs.setBool(_kInstalled, true); // Kurulum İşaretini Yeniden Yazar.
    await writeEntries(const []); // Boş Kayıt Listesi Yazar.
    themeMode.value = ThemeMode.system; // Tema Modunu Sistem Varsayılanına Döndürür.
    reminderEnabled.value = false; // Hatırlatıcıyı Kapalı Olarak Yayınlar.
  }

  void dispose() { // Notifier'ları Serbest Bırakır.
    themeMode.dispose(); // themeMode Notifier'ını Kapatır.
    reminderEnabled.dispose(); // reminderEnabled Notifier'ını Kapatır.
  }
}
