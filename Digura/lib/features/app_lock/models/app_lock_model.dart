import 'package:flutter/foundation.dart'; // @immutable Annotation'ı İçin Flutter'ın foundation Kütüphanesini import Eder.

/// Parmak izi panelinin durumu (`FingerprintSheet`).
enum FingerprintSheetStatus { scanning, failed, lockout, verified } // Parmak İzi Panelinin Olası Durumlarını Tanımlayan enum'dur.

/// Açılış kilidi durumu (PROJECT_NEW.md 6.3).
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class AppLockState { // Açılış Kilidi Ekranının Tüm Durumunu Tutan Class'tır.
  static const int maxPinAttempts = 5; // İzin Verilen En Fazla Yanlış PIN Sayısıdır.
  static const int lockoutSeconds = 30; // Kilitlenme Süresinin Saniye Cinsinden Değeridir.
  static const int maxBiometricFailures = 3; // Biyometri Askıya Alınmadan Önceki En Fazla Hata Sayısıdır.

  final bool hasPin; // Kullanıcının PIN Tanımlayıp Tanımlamadığını Tutar.
  final bool biometricEnabled; // Parmak İzinin Açık Olup Olmadığını Tutar.
  final int remainingPinAttempts; // Kalan PIN Deneme Hakkıdır.

  /// 0 ya da 30'dan geri sayım.
  final int lockoutRemainingSeconds; // Kilitlenmenin Bitmesine Kalan Saniyedir.
  final int biometricFailCount; // Art Arda Başarısız Biyometrik Deneme Sayısıdır.
  final bool biometricTemporarilyDisabled; // Biyometrinin Geçici Olarak Kapalı Olup Olmadığını Tutar.

  /// Girilen haneler (en çok 4).
  final String entered; // Şu Ana Kadar Girilen PIN Haneleridir.
  final String? error; // Gösterilecek Hata Metnidir, Yoksa null'dır.

  /// Her hatada artar; görünüm sallanmayı bununla tetikler.
  final int shakeTick; // Sallama Animasyonunu Tetikleyen Sayaçtır.
  final FingerprintSheetStatus? sheet; // Parmak İzi Panelinin Durumudur, Kapalıysa null'dır.
  final bool unlocked; // Kilidin Açılıp Açılmadığını Tutar.

  const AppLockState({ // Varsayılan Değerli Named Parametreler Alan const Constructor'dır.
    this.hasPin = true, // hasPin Varsayılan Olarak true'dur.
    this.biometricEnabled = false, // biometricEnabled Varsayılan Olarak false'tur.
    this.remainingPinAttempts = maxPinAttempts, // Deneme Hakkı Varsayılan Olarak Maksimumdur.
    this.lockoutRemainingSeconds = 0, // Varsayılan Olarak Kilitlenme Yoktur.
    this.biometricFailCount = 0, // Hata Sayısı Varsayılan Olarak Sıfırdır.
    this.biometricTemporarilyDisabled = false, // Biyometri Varsayılan Olarak Askıda Değildir.
    this.entered = '', // Girilen Haneler Varsayılan Olarak Boştur.
    this.error, // error Field'ını İsteğe Bağlı Alır.
    this.shakeTick = 0, // Sallama Sayacı Sıfırdan Başlar.
    this.sheet, // sheet Field'ını İsteğe Bağlı Alır.
    this.unlocked = false, // Kilit Varsayılan Olarak Kapalıdır.
  });

  bool get isLockedOut => lockoutRemainingSeconds > 0; // Kilitlenme Sürüyorsa true Döndüren Getter'dır.

  bool get keypadEnabled => !isLockedOut && sheet == null && !unlocked; // Tuş Takımının Kullanılabilir Olup Olmadığını Döndürür.

  bool get canUseBiometric => biometricEnabled && !biometricTemporarilyDisabled && !isLockedOut; // Parmak İzinin Şu An Kullanılabilir Olup Olmadığını Döndürür.

  int get biometricAttemptsLeft => maxBiometricFailures - biometricFailCount; // Kalan Biyometrik Deneme Hakkını Döndürür.

  AppLockState copyWith({ // Seçilen Field'ları Değiştirilmiş Yeni Bir Kopya Üretir.
    bool? hasPin, // Yeni hasPin Değeridir.
    bool? biometricEnabled, // Yeni biometricEnabled Değeridir.
    int? remainingPinAttempts, // Yeni Kalan Deneme Sayısıdır.
    int? lockoutRemainingSeconds, // Yeni Kalan Kilitlenme Saniyesidir.
    int? biometricFailCount, // Yeni Biyometrik Hata Sayısıdır.
    bool? biometricTemporarilyDisabled, // Yeni Biyometri Askı Durumudur.
    String? entered, // Yeni Girilen Hanelerdir.
    String? Function()? error, // null Atanabilmesi İçin Fonksiyon Olarak Alınan Hata Metnidir.
    int? shakeTick, // Yeni Sallama Sayacıdır.
    FingerprintSheetStatus? Function()? sheet, // null Atanabilmesi İçin Fonksiyon Olarak Alınan Panel Durumudur.
    bool? unlocked, // Yeni Kilit Açık Durumudur.
  }) {
    return AppLockState( // Güncellenmiş Değerlerle Yeni AppLockState Döndürür.
      hasPin: hasPin ?? this.hasPin, // Verilmediyse Mevcut hasPin'i Korur.
      biometricEnabled: biometricEnabled ?? this.biometricEnabled, // Verilmediyse Mevcut biometricEnabled'ı Korur.
      remainingPinAttempts: remainingPinAttempts ?? this.remainingPinAttempts, // Verilmediyse Mevcut Deneme Sayısını Korur.
      lockoutRemainingSeconds: lockoutRemainingSeconds ?? this.lockoutRemainingSeconds, // Verilmediyse Mevcut Geri Sayımı Korur.
      biometricFailCount: biometricFailCount ?? this.biometricFailCount, // Verilmediyse Mevcut Hata Sayısını Korur.
      biometricTemporarilyDisabled: biometricTemporarilyDisabled ?? this.biometricTemporarilyDisabled, // Verilmediyse Mevcut Askı Durumunu Korur.
      entered: entered ?? this.entered, // Verilmediyse Mevcut Haneleri Korur.
      error: error != null ? error() : this.error, // Fonksiyon Verildiyse Sonucunu, Yoksa Mevcut Hatayı Kullanır.
      shakeTick: shakeTick ?? this.shakeTick, // Verilmediyse Mevcut Sayacı Korur.
      sheet: sheet != null ? sheet() : this.sheet, // Fonksiyon Verildiyse Sonucunu, Yoksa Mevcut Paneli Kullanır.
      unlocked: unlocked ?? this.unlocked, // Verilmediyse Mevcut Kilit Durumunu Korur.
    );
  }

  /// PIN haneleri ve hata metni kalıcı hale getirilmez.
  factory AppLockState.fromJson(Map<String, dynamic> json) => AppLockState( // JSON'dan AppLockState Üreten factory Constructor'dır.
    hasPin: json['hasPin'] as bool? ?? true, // hasPin'i Okur, Yoksa true Kullanır.
    biometricEnabled: json['biometricEnabled'] as bool? ?? false, // biometricEnabled'ı Okur, Yoksa false Kullanır.
    remainingPinAttempts: json['remainingPinAttempts'] as int? ?? maxPinAttempts, // Kalan Denemeyi Okur, Yoksa Maksimumu Kullanır.
    lockoutRemainingSeconds: json['lockoutRemainingSeconds'] as int? ?? 0, // Kalan Kilitlenme Saniyesini Okur, Yoksa 0 Kullanır.
    biometricFailCount: json['biometricFailCount'] as int? ?? 0, // Biyometrik Hata Sayısını Okur, Yoksa 0 Kullanır.
    biometricTemporarilyDisabled: json['biometricTemporarilyDisabled'] as bool? ?? false, // Askı Durumunu Okur, Yoksa false Kullanır.
  );

  Map<String, dynamic> toJson() => { // Durumu JSON Map'ine Dönüştürür.
    'hasPin': hasPin, // hasPin Değerini Yazar.
    'biometricEnabled': biometricEnabled, // biometricEnabled Değerini Yazar.
    'remainingPinAttempts': remainingPinAttempts, // Kalan Deneme Sayısını Yazar.
    'lockoutRemainingSeconds': lockoutRemainingSeconds, // Kalan Kilitlenme Saniyesini Yazar.
    'biometricFailCount': biometricFailCount, // Biyometrik Hata Sayısını Yazar.
    'biometricTemporarilyDisabled': biometricTemporarilyDisabled, // Biyometri Askı Durumunu Yazar.
  };

  @override // Object'teki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => // İki AppLockState'i Değer Olarak Karşılaştırır.
      other is AppLockState && // Karşılaştırılan Nesnenin AppLockState Olduğunu Kontrol Eder.
      other.hasPin == hasPin && // hasPin Değerlerini Karşılaştırır.
      other.biometricEnabled == biometricEnabled && // biometricEnabled Değerlerini Karşılaştırır.
      other.remainingPinAttempts == remainingPinAttempts && // Kalan Deneme Sayılarını Karşılaştırır.
      other.lockoutRemainingSeconds == lockoutRemainingSeconds && // Kalan Kilitlenme Saniyelerini Karşılaştırır.
      other.biometricFailCount == biometricFailCount && // Biyometrik Hata Sayılarını Karşılaştırır.
      other.biometricTemporarilyDisabled == biometricTemporarilyDisabled && // Askı Durumlarını Karşılaştırır.
      other.entered == entered && // Girilen Haneleri Karşılaştırır.
      other.error == error && // Hata Metinlerini Karşılaştırır.
      other.shakeTick == shakeTick && // Sallama Sayaçlarını Karşılaştırır.
      other.sheet == sheet && // Panel Durumlarını Karşılaştırır.
      other.unlocked == unlocked; // Kilit Açık Durumlarını Karşılaştırır.

  @override // Object'teki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash( // Tüm Field'lardan hashCode Üretir.
    hasPin, // hasPin'i Hash'e Katar.
    biometricEnabled, // biometricEnabled'ı Hash'e Katar.
    remainingPinAttempts, // Kalan Deneme Sayısını Hash'e Katar.
    lockoutRemainingSeconds, // Kalan Kilitlenme Saniyesini Hash'e Katar.
    biometricFailCount, // Biyometrik Hata Sayısını Hash'e Katar.
    biometricTemporarilyDisabled, // Askı Durumunu Hash'e Katar.
    entered, // Girilen Haneleri Hash'e Katar.
    error, // Hata Metnini Hash'e Katar.
    shakeTick, // Sallama Sayacını Hash'e Katar.
    sheet, // Panel Durumunu Hash'e Katar.
    unlocked, // Kilit Açık Durumunu Hash'e Katar.
  );
}
