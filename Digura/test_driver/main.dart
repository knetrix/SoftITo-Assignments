import 'package:digura/main.dart' as app;
import 'package:flutter_driver/driver_extension.dart';

/// Simülatörde ekran ekran doğrulama için Flutter Driver uzantılı giriş noktası.
/// `flutter run -t test_driver/main.dart -d <cihaz>`
void main() {
  enableFlutterDriverExtension();
  app.main();
}
