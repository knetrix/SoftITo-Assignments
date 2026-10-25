import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Güvenli anahtar–değer deposu soyutlaması (testte bellek içi sürüm).
abstract interface class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

/// iOS Keychain / Android Keystore destekli depo.
class FlutterSecureStore implements SecureStore {
  final FlutterSecureStorage _storage;

  const FlutterSecureStore([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

class InMemorySecureStore implements SecureStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();
}

/// Cihaz içi PIN ve biyometrik kilit ayarları.
///
/// PIN düz metin saklanmaz: rastgele tuz + SHA-256 özeti güvenli depoda
/// tutulur. Kurtarma yoktur; unutulursa tek seçenek [wipe].
class AppLockRepository {
  static const String _kSalt = 'digura.pin.salt';
  static const String _kHash = 'digura.pin.hash';
  static const String _kBiometric = 'digura.biometric';

  final SecureStore _store;

  final ValueNotifier<bool> hasPin = ValueNotifier(false);
  final ValueNotifier<bool> biometricEnabled = ValueNotifier(false);

  AppLockRepository(this._store);

  Future<void> load() async {
    hasPin.value = await _store.read(_kHash) != null;
    biometricEnabled.value = await _store.read(_kBiometric) == 'true';
  }

  Future<void> setPin(String pin) async {
    final salt = _newSalt();
    await _store.write(_kSalt, salt);
    await _store.write(_kHash, _hash(salt, pin));
    hasPin.value = true;
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _store.read(_kSalt);
    final hash = await _store.read(_kHash);
    if (salt == null || hash == null) return false;
    return _hash(salt, pin) == hash;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _store.write(_kBiometric, enabled.toString());
    biometricEnabled.value = enabled;
  }

  Future<void> wipe() async {
    await _store.deleteAll();
    hasPin.value = false;
    biometricEnabled.value = false;
  }

  static String _hash(String salt, String pin) => sha256.convert(utf8.encode('$salt:$pin')).toString();

  static String _newSalt() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  void dispose() {
    hasPin.dispose();
    biometricEnabled.dispose();
  }
}
