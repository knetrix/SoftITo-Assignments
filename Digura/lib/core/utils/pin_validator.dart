/// 4 haneli PIN kuralları (PROJECT_NEW.md 4.4).
abstract final class PinValidator { // PIN Doğrulama Kurallarını Tutan Class'tır.
  static const int length = 4; // PIN'in Hane Sayısıdır.
  static const String _ascending = '0123456789'; // Artan Sıralı Dizileri Bulmak İçin Referans Metindir.
  static const String _descending = '9876543210'; // Azalan Sıralı Dizileri Bulmak İçin Referans Metindir.
  static final RegExp _digits = RegExp(r'^\d{4}$'); // Tam 4 Rakamı Eşleyen RegExp'tir.
  static final RegExp _repeated = RegExp(r'^(\d)\1{3}$'); // Aynı Rakamın 4 Kez Tekrarını Eşleyen RegExp'tir.

  static bool isWellFormed(String pin) => _digits.hasMatch(pin); // PIN'in 4 Rakamdan Oluşup Oluşmadığını Kontrol Eder.

  /// Aynı rakamın tekrarı (`0000`–`9999`) ya da artan/azalan sıralı dizi
  /// (`1234`, `6789`, `9876` …) zayıf kabul edilir.
  static bool isWeak(String pin) => _repeated.hasMatch(pin) || _ascending.contains(pin) || _descending.contains(pin); // Tekrarlı ya da Sıralı PIN'leri Zayıf Kabul Eder.
}
