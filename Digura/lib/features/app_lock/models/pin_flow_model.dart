import 'package:flutter/foundation.dart'; // @immutable Annotation'ı İçin Flutter'ın foundation Kütüphanesini import Eder.

enum PinSetupStage { create, confirm, done } // PIN Kurulumunun Aşamalarını Tanımlayan enum'dur.

/// 2 adımlı kurulumun 1. adımı: PIN oluştur → tekrar gir → oluşturuldu.
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class PinSetupState { // PIN Kurulum Ekranının Durumunu Tutan Class'tır.
  final PinSetupStage stage; // Kurulumun Mevcut Aşamasıdır.
  final String entered; // Şu Ana Kadar Girilen PIN Haneleridir.
  final String? error; // Gösterilecek Hata Metnidir, Yoksa null'dır.
  final int shakeTick; // Sallama Animasyonunu Tetikleyen Sayaçtır.

  const PinSetupState({this.stage = PinSetupStage.create, this.entered = '', this.error, this.shakeTick = 0}); // Varsayılan Değerli Named Parametreler Alan const Constructor'dır.

  PinSetupState copyWith({PinSetupStage? stage, String? entered, String? Function()? error, int? shakeTick}) => // Seçilen Field'ları Değiştirilmiş Yeni Bir Kopya Üretir.
      PinSetupState( // Güncellenmiş Değerlerle Yeni PinSetupState Döndürür.
        stage: stage ?? this.stage, // Verilmediyse Mevcut Aşamayı Korur.
        entered: entered ?? this.entered, // Verilmediyse Mevcut Haneleri Korur.
        error: error != null ? error() : this.error, // Fonksiyon Verildiyse Sonucunu, Yoksa Mevcut Hatayı Kullanır.
        shakeTick: shakeTick ?? this.shakeTick, // Verilmediyse Mevcut Sayacı Korur.
      );

  factory PinSetupState.fromJson(Map<String, dynamic> json) => PinSetupState( // JSON'dan PinSetupState Üreten factory Constructor'dır.
    stage: PinSetupStage.values.firstWhere((s) => s.name == json['stage'], orElse: () => PinSetupStage.create), // Aşamayı Adından Bulur, Yoksa create Kullanır.
  );

  /// Girilen haneler bilinçli olarak dışarıda bırakılır.
  Map<String, dynamic> toJson() => {'stage': stage.name}; // Yalnızca Aşama Adını JSON Map'ine Yazar.

  @override // Object'teki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => // İki PinSetupState'i Değer Olarak Karşılaştırır.
      other is PinSetupState && // Karşılaştırılan Nesnenin PinSetupState Olduğunu Kontrol Eder.
      other.stage == stage && // Aşamaları Karşılaştırır.
      other.entered == entered && // Girilen Haneleri Karşılaştırır.
      other.error == error && // Hata Metinlerini Karşılaştırır.
      other.shakeTick == shakeTick; // Sallama Sayaçlarını Karşılaştırır.

  @override // Object'teki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash(stage, entered, error, shakeTick); // Tüm Field'lardan hashCode Üretir.
}

enum PinChangeStep { // PIN Değiştirme Adımlarını Numaralarıyla Tanımlayan enum'dur.
  current(1), // Mevcut PIN'i Girme Adımıdır.
  next(2), // Yeni PIN'i Girme Adımıdır.
  confirm(3); // Yeni PIN'i Tekrar Girme Adımıdır.

  final int number; // Adımın Ekranda Gösterilen Sıra Numarasıdır.

  const PinChangeStep(this.number); // Adım Numarasını Alan const Constructor'dır.
}

/// Ayarlar › Güvenlik › PIN'i değiştir (1/3 → 2/3 → 3/3).
@immutable // Class'ın Değiştirilemez Olduğunu Belirtir.
class PinChangeState { // PIN Değiştirme Ekranının Durumunu Tutan Class'tır.
  final PinChangeStep step; // Akışın Mevcut Adımıdır.
  final String entered; // Şu Ana Kadar Girilen PIN Haneleridir.
  final String? error; // Gösterilecek Hata Metnidir, Yoksa null'dır.
  final int shakeTick; // Sallama Animasyonunu Tetikleyen Sayaçtır.
  final bool completed; // PIN Değişikliğinin Tamamlanıp Tamamlanmadığını Tutar.

  const PinChangeState({ // Varsayılan Değerli Named Parametreler Alan const Constructor'dır.
    this.step = PinChangeStep.current, // Akış Varsayılan Olarak Mevcut PIN Adımından Başlar.
    this.entered = '', // Girilen Haneler Varsayılan Olarak Boştur.
    this.error, // error Field'ını İsteğe Bağlı Alır.
    this.shakeTick = 0, // Sallama Sayacı Sıfırdan Başlar.
    this.completed = false, // Akış Varsayılan Olarak Tamamlanmamıştır.
  });

  PinChangeState copyWith({ // Seçilen Field'ları Değiştirilmiş Yeni Bir Kopya Üretir.
    PinChangeStep? step, // Yeni Adımdır.
    String? entered, // Yeni Girilen Hanelerdir.
    String? Function()? error, // null Atanabilmesi İçin Fonksiyon Olarak Alınan Hata Metnidir.
    int? shakeTick, // Yeni Sallama Sayacıdır.
    bool? completed, // Yeni Tamamlanma Durumudur.
  }) => PinChangeState( // Güncellenmiş Değerlerle Yeni PinChangeState Döndürür.
    step: step ?? this.step, // Verilmediyse Mevcut Adımı Korur.
    entered: entered ?? this.entered, // Verilmediyse Mevcut Haneleri Korur.
    error: error != null ? error() : this.error, // Fonksiyon Verildiyse Sonucunu, Yoksa Mevcut Hatayı Kullanır.
    shakeTick: shakeTick ?? this.shakeTick, // Verilmediyse Mevcut Sayacı Korur.
    completed: completed ?? this.completed, // Verilmediyse Mevcut Tamamlanma Durumunu Korur.
  );

  factory PinChangeState.fromJson(Map<String, dynamic> json) => PinChangeState( // JSON'dan PinChangeState Üreten factory Constructor'dır.
    step: PinChangeStep.values.firstWhere((s) => s.name == json['step'], orElse: () => PinChangeStep.current), // Adımı Adından Bulur, Yoksa current Kullanır.
  );

  Map<String, dynamic> toJson() => {'step': step.name}; // Yalnızca Adım Adını JSON Map'ine Yazar.

  @override // Object'teki == Operatörünün Override Edildiğini Belirtir.
  bool operator ==(Object other) => // İki PinChangeState'i Değer Olarak Karşılaştırır.
      other is PinChangeState && // Karşılaştırılan Nesnenin PinChangeState Olduğunu Kontrol Eder.
      other.step == step && // Adımları Karşılaştırır.
      other.entered == entered && // Girilen Haneleri Karşılaştırır.
      other.error == error && // Hata Metinlerini Karşılaştırır.
      other.shakeTick == shakeTick && // Sallama Sayaçlarını Karşılaştırır.
      other.completed == completed; // Tamamlanma Durumlarını Karşılaştırır.

  @override // Object'teki hashCode Getter'ının Override Edildiğini Belirtir.
  int get hashCode => Object.hash(step, entered, error, shakeTick, completed); // Tüm Field'lardan hashCode Üretir.
}

enum BiometricSetupStatus { idle, scanning, enabled, failed, unavailable } // Parmak İzi Kurulumunun Olası Durumlarını Tanımlayan enum'dur.
