import 'dart:convert'; // utf8 ve base64Url Kodlayıcılarını import Eder.
import 'dart:math'; // Random.secure İçin Math Kütüphanesini import Eder.

import 'package:crypto/crypto.dart'; // sha256 Özet Fonksiyonunu import Eder.
import 'package:flutter/foundation.dart'; // ValueNotifier Class'ını import Eder.
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // FlutterSecureStorage Class'ını import Eder.

/// Güvenli anahtar–değer deposu soyutlaması (testte bellek içi sürüm).
abstract interface class SecureStore { // Güvenli Depo İşlemlerini Tanımlayan Interface'tir.
  Future<String?> read(String key); // Anahtara Karşılık Gelen Değeri Okur.
  Future<void> write(String key, String value); // Anahtara Değer Yazar.
  Future<void> delete(String key); // Anahtarı Siler.
  Future<void> deleteAll(); // Tüm Anahtarları Siler.
}

/// iOS Keychain / Android Keystore destekli depo.
class FlutterSecureStore implements SecureStore { // FlutterSecureStorage Kullanan SecureStore Uygulamasıdır.
  final FlutterSecureStorage _storage; // Platform Güvenli Depolama Nesnesidir.

  const FlutterSecureStore([this._storage = const FlutterSecureStorage()]); // Varsayılan FlutterSecureStorage İle const Constructor'dır.

  @override // Interface'teki read Metodunun Override Edildiğini Belirtir.
  Future<String?> read(String key) => _storage.read(key: key); // Güvenli Depodan Değeri Okur.

  @override // Interface'teki write Metodunun Override Edildiğini Belirtir.
  Future<void> write(String key, String value) => _storage.write(key: key, value: value); // Güvenli Depoya Değeri Yazar.

  @override // Interface'teki delete Metodunun Override Edildiğini Belirtir.
  Future<void> delete(String key) => _storage.delete(key: key); // Güvenli Depodan Anahtarı Siler.

  @override // Interface'teki deleteAll Metodunun Override Edildiğini Belirtir.
  Future<void> deleteAll() => _storage.deleteAll(); // Güvenli Depodaki Tüm Kayıtları Siler.
}

class InMemorySecureStore implements SecureStore { // Testler İçin Bellek İçi SecureStore Uygulamasıdır.
  final Map<String, String> values = {}; // Değerleri Bellekte Tutan Map'tir.

  @override // Interface'teki read Metodunun Override Edildiğini Belirtir.
  Future<String?> read(String key) async => values[key]; // Map'ten Değeri Okur.

  @override // Interface'teki write Metodunun Override Edildiğini Belirtir.
  Future<void> write(String key, String value) async => values[key] = value; // Map'e Değeri Yazar.

  @override // Interface'teki delete Metodunun Override Edildiğini Belirtir.
  Future<void> delete(String key) async => values.remove(key); // Map'ten Anahtarı Siler.

  @override // Interface'teki deleteAll Metodunun Override Edildiğini Belirtir.
  Future<void> deleteAll() async => values.clear(); // Map'i Tamamen Temizler.
}

/// Cihaz içi PIN ve biyometrik kilit ayarları.
///
/// PIN düz metin saklanmaz: rastgele tuz + SHA-256 özeti güvenli depoda
/// tutulur. Kurtarma yoktur; unutulursa tek seçenek [wipe].
class AppLockRepository { // PIN ve Biyometrik Kilit Ayarlarını Yöneten Repository'dir.
  static const String _kSalt = 'digura.pin.salt'; // PIN Tuzunun Depo Anahtarıdır.
  static const String _kHash = 'digura.pin.hash'; // PIN Özetinin Depo Anahtarıdır.
  static const String _kBiometric = 'digura.biometric'; // Biyometrik Ayarın Depo Anahtarıdır.

  final SecureStore _store; // Verilerin Yazıldığı Güvenli Depodur.

  final ValueNotifier<bool> hasPin = ValueNotifier(false); // PIN Tanımlı Olup Olmadığını Yayınlar.
  final ValueNotifier<bool> biometricEnabled = ValueNotifier(false); // Biyometrik Kilidin Açık Olup Olmadığını Yayınlar.

  AppLockRepository(this._store); // Güvenli Depoyu Alan Constructor'dır.

  Future<void> load() async { // Kilit Durumunu Depodan Yükler.
    hasPin.value = await _store.read(_kHash) != null; // Özet Varsa hasPin'i true Yapar.
    biometricEnabled.value = await _store.read(_kBiometric) == 'true'; // Biyometrik Ayarını Depodan Okur.
  }

  Future<void> setPin(String pin) async { // Yeni PIN'i Tuzlayıp Özetini Kaydeder.
    final salt = _newSalt(); // Rastgele Yeni Bir Tuz Üretir.
    await _store.write(_kSalt, salt); // Tuzu Depoya Yazar.
    await _store.write(_kHash, _hash(salt, pin)); // PIN Özetini Depoya Yazar.
    hasPin.value = true; // PIN'in Tanımlandığını Yayınlar.
  }

  Future<bool> verifyPin(String pin) async { // Girilen PIN'in Doğru Olup Olmadığını Kontrol Eder.
    final salt = await _store.read(_kSalt); // Kayıtlı Tuzu Okur.
    final hash = await _store.read(_kHash); // Kayıtlı Özeti Okur.
    if (salt == null || hash == null) return false; // Kayıt Yoksa false Döndürür.
    return _hash(salt, pin) == hash; // Hesaplanan Özet Kayıtlıyla Eşleşirse true Döndürür.
  }

  Future<void> setBiometricEnabled(bool enabled) async { // Biyometrik Kilit Ayarını Değiştirir.
    await _store.write(_kBiometric, enabled.toString()); // Ayarı Depoya Metin Olarak Yazar.
    biometricEnabled.value = enabled; // Yeni Değeri Yayınlar.
  }

  Future<void> wipe() async { // Tüm Kilit Verilerini Siler.
    await _store.deleteAll(); // Güvenli Depoyu Tamamen Temizler.
    hasPin.value = false; // PIN Olmadığını Yayınlar.
    biometricEnabled.value = false; // Biyometrik Kilidin Kapalı Olduğunu Yayınlar.
  }

  static String _hash(String salt, String pin) => sha256.convert(utf8.encode('$salt:$pin')).toString(); // Tuz ve PIN'in SHA-256 Özetini Hesaplar.

  static String _newSalt() { // 16 Baytlık Rastgele Tuz Üretir.
    final random = Random.secure(); // Kriptografik Güvenli Rastgele Üreteci Oluşturur.
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256))); // 16 Rastgele Baytı base64Url Olarak Döndürür.
  }

  void dispose() { // Notifier'ları Serbest Bırakır.
    hasPin.dispose(); // hasPin Notifier'ını Kapatır.
    biometricEnabled.dispose(); // biometricEnabled Notifier'ını Kapatır.
  }
}
