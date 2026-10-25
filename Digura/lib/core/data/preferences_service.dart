import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cihaz içi tercihler: tema, karşılama durumu, hatırlatıcı, açılış anı
/// oynatılmış kapsüller, PIN bekleme süresi ve günlük kayıtların ham JSON'u.
///
/// Anahtarlar DESIGN.md Bölüm 10'daki prototip sözleşmesini izler.
class PreferencesService {
  static const String _kTheme = 'digura.theme';
  static const String _kOnboardingDone = 'digura.onboarding.done';
  static const String _kOnboardingStep = 'digura.onboarding.step';
  static const String _kEntries = 'digura.entries.v1';
  static const String _kOpened = 'digura.opened';
  static const String _kReminder = 'digura.reminder';
  static const String _kLockoutUntil = 'digura.lock.lockoutUntil';
  static const String _kInstalled = 'digura.installed';
  static const String _kBiometricSuspended = 'digura.lock.biometricSuspended';

  final SharedPreferences _prefs;

  final ValueNotifier<ThemeMode> themeMode;
  final ValueNotifier<bool> reminderEnabled;

  PreferencesService._(this._prefs)
    : themeMode = ValueNotifier(_parseTheme(_prefs.getString(_kTheme))),
      reminderEnabled = ValueNotifier(_prefs.getBool(_kReminder) ?? false);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService._(prefs);
  }

  // ─── İlk kurulum ───

  /// Uygulama bu kurulumda ilk kez mi açılıyor? (iOS anahtar zinciri yeniden
  /// kurulumda silinmediği için güvenli depo bu bilgiye göre temizlenir.)
  bool get isFirstLaunch => !(_prefs.getBool(_kInstalled) ?? false);

  Future<void> markInstalled() => _prefs.setBool(_kInstalled, true);

  // ─── Tema ───

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs.setString(_kTheme, mode.name);
  }

  static ThemeMode _parseTheme(String? raw) => switch (raw) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  // ─── Karşılama ───

  bool get onboardingDone => _prefs.getBool(_kOnboardingDone) ?? false;

  Future<void> setOnboardingDone(bool value) async {
    await _prefs.setBool(_kOnboardingDone, value);
    await _prefs.remove(_kOnboardingStep);
  }

  int get onboardingStep => _prefs.getInt(_kOnboardingStep) ?? 0;

  Future<void> setOnboardingStep(int step) => _prefs.setInt(_kOnboardingStep, step);

  // ─── Hatırlatıcı ───

  Future<void> setReminderEnabled(bool value) async {
    reminderEnabled.value = value;
    await _prefs.setBool(_kReminder, value);
  }

  // ─── Kapsül açılış anı ───

  Set<String> get openedCapsules => (_prefs.getStringList(_kOpened) ?? const []).toSet();

  Future<void> setOpenedCapsules(Set<String> ids) => _prefs.setStringList(_kOpened, ids.toList()..sort());

  // ─── PIN bekleme süresi (uygulama kapatılsa da korunur) ───

  DateTime? get lockoutUntil {
    final ms = _prefs.getInt(_kLockoutUntil);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLockoutUntil(DateTime? until) =>
      until == null ? _prefs.remove(_kLockoutUntil) : _prefs.setInt(_kLockoutUntil, until.millisecondsSinceEpoch);

  /// 3 hatalı parmak izinden sonra sensör, PIN ile giriş yapılana dek kapalı kalır.
  bool get biometricSuspended => _prefs.getBool(_kBiometricSuspended) ?? false;

  Future<void> setBiometricSuspended(bool value) =>
      value ? _prefs.setBool(_kBiometricSuspended, true) : _prefs.remove(_kBiometricSuspended);

  // ─── Günlük kayıtlar (yalnızca MoodRepository kullanır) ───

  bool get hasStoredEntries => _prefs.containsKey(_kEntries);

  List<Map<String, dynamic>> readEntries() {
    final raw = _prefs.getString(_kEntries);
    if (raw == null) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> writeEntries(List<Map<String, dynamic>> entries) => _prefs.setString(_kEntries, jsonEncode(entries));

  /// "Her şeyi sil ve sıfırla": tüm tercihler silinir, kayıtlar boş bırakılır
  /// (örnek veri yeniden yüklenmez).
  Future<void> wipe() async {
    await _prefs.clear();
    await _prefs.setBool(_kInstalled, true);
    await writeEntries(const []);
    themeMode.value = ThemeMode.system;
    reminderEnabled.value = false;
  }

  void dispose() {
    themeMode.dispose();
    reminderEnabled.dispose();
  }
}
