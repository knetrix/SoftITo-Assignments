/// 4 haneli PIN kuralları (PROJECT_NEW.md 4.4).
abstract final class PinValidator {
  static const int length = 4;
  static const String _ascending = '0123456789';
  static const String _descending = '9876543210';
  static final RegExp _digits = RegExp(r'^\d{4}$');
  static final RegExp _repeated = RegExp(r'^(\d)\1{3}$');

  static bool isWellFormed(String pin) => _digits.hasMatch(pin);

  /// Aynı rakamın tekrarı (`0000`–`9999`) ya da artan/azalan sıralı dizi
  /// (`1234`, `6789`, `9876` …) zayıf kabul edilir.
  static bool isWeak(String pin) => _repeated.hasMatch(pin) || _ascending.contains(pin) || _descending.contains(pin);
}
