/// Derleme zamanı geliştirici bayrakları (`--dart-define`).
abstract final class AppConfig { // Derleme Zamanı Bayraklarını Tutan Örneklenemez Class'tır.
  /// İlk açılışta `MockMoodData` örnek kayıtlarını yükler (varsayılan: açık).
  /// Kapatmak için: `--dart-define=DIGURA_MOCK=false`.
  static const bool seedMockData = bool.fromEnvironment('DIGURA_MOCK', defaultValue: true); // DIGURA_MOCK Bayrağını Varsayılan true Olarak Okur.

  /// Karşılama ve kurulumu atlar, demo PIN `2580` ile doğrudan kilit
  /// ekranından başlar: `--dart-define=DIGURA_DEMO=true`.
  static const bool demoMode = bool.fromEnvironment('DIGURA_DEMO'); // DIGURA_DEMO Bayrağını Varsayılan false Olarak Okur.
}
