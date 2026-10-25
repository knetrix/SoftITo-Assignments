/// Derleme zamanı geliştirici bayrakları (`--dart-define`).
abstract final class AppConfig {
  /// İlk açılışta `MockMoodData` örnek kayıtlarını yükler (varsayılan: açık).
  /// Kapatmak için: `--dart-define=DIGURA_MOCK=false`.
  static const bool seedMockData = bool.fromEnvironment('DIGURA_MOCK', defaultValue: true);

  /// Karşılama ve kurulumu atlar, demo PIN `2580` ile doğrudan kilit
  /// ekranından başlar: `--dart-define=DIGURA_DEMO=true`.
  static const bool demoMode = bool.fromEnvironment('DIGURA_DEMO');
}
