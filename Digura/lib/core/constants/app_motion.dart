import 'package:flutter/widgets.dart';

/// Hareket jetonları (ANIMATION.md Bölüm 2). Widget içinde `Duration(...)`
/// ya da `Cubic(...)` yazılmaz; tüm süre, eğri ve ölçekler buradan okunur.
abstract final class AppMotion {
  // ─── Süreler ───
  static const Duration micro = Duration(milliseconds: 140); // PIN noktası
  static const Duration press = Duration(milliseconds: 160); // basma geri bildirimi
  static const Duration ui = Duration(milliseconds: 200); // diyalog, scrim, snackbar, anahtar
  static const Duration settle = Duration(milliseconds: 240); // renk dairesi, içerik girişi
  static const Duration slide = Duration(milliseconds: 300); // onboarding sayfa geçişi
  static const Duration sheet = Duration(milliseconds: 300); // alt panel (açılış)
  static const Duration intro = Duration(milliseconds: 420); // yalnızca ilk açılış, tek sefer
  static const Duration shake = Duration(milliseconds: 360); // hatalı PIN
  static const Duration stagger = Duration(milliseconds: 40); // art arda giren bloklar
  static const Duration staggerMax = Duration(milliseconds: 120); // 4. ve sonraki bloklar
  static const Duration introStep = Duration(milliseconds: 60); // ilk açılış blok aralığı

  // Ekrana özgü süreler (prototiplerde denenmiş değerler)
  static const Duration savedPop = Duration(milliseconds: 320); // kayıttan sonra daire
  static const Duration unlockPop = Duration(milliseconds: 260); // kilit açıldı içeriği
  static const Duration unsealRing = Duration(milliseconds: 640); // kapsül halkası
  static const Duration unsealReveal = Duration(milliseconds: 560); // dairesel açılış
  static const Duration unsealTextDelay = Duration(milliseconds: 320);
  static const Duration unsealText = Duration(milliseconds: 300);
  static const Duration scanTurn = Duration(milliseconds: 900); // taranıyor halkası turu
  static const Duration scanMax = Duration(seconds: 60); // sürekli dönme üst sınırı
  static const Duration ctaSwap = Duration(milliseconds: 120); // düğme metni çapraz solma
  static const Duration capsuleBarDelay = Duration(milliseconds: 180); // kapsül çubuğu dolumu
  static const Duration pinEvaluate = Duration(milliseconds: 180); // 4. haneden sonra kontrol
  static const Duration biometricOkHold = Duration(milliseconds: 650); // "Doğrulandı" bekleme
  static const Duration unlockHold = Duration(milliseconds: 1200); // "Kilit açıldı" bekleme
  static const Duration simulatedScan = Duration(milliseconds: 1100); // demo sensör (kilit)
  static const Duration simulatedEnroll = Duration(milliseconds: 1300); // demo sensör (kurulum)
  static const Duration snackShort = Duration(milliseconds: 2400);
  static const Duration snackLong = Duration(milliseconds: 2600);
  static const Duration savedNowWindow = Duration(milliseconds: 400);

  // ─── Eğriler ───
  static const Curve easeOut = Cubic(0.23, 1, 0.32, 1); // varsayılan: giren/çıkan her şey
  static const Curve drawer = Cubic(0.32, 0.72, 0, 1); // alttan açılan paneller
  static const Curve linear = Curves.linear; // taranıyor halkası

  // ─── Ölçekler ───
  static const double pressButton = 0.97;
  static const double pressKey = 0.94;
  static const double pressSwatch = 0.94;
  static const double pressPalette = 0.92;
  static const double pressCell = 0.96;
  static const double pressRow = 0.985;
  static const double enterOffset = 8; // dp, aşağıdan yukarı
  static const double dialogFrom = 0.96;
  static const double orbFrom = 0.94;
  static const double orbOpacityFrom = 0.7;
  static const double dotFrom = 0.6;
  static const double dotOpacityFrom = 0.4;
  static const double shakeOffset = 8;
  static const double parallax = 0.22; // onboarding → Bugün geçişinde giden sayfa
  static const double ringTo = 1.9;
  static const double ringOpacityFrom = 0.7;
}

extension MotionContext on BuildContext {
  /// Sistem "Hareketi azalt" ayarı (iOS) / "Animasyonları kaldır" (Android).
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;
}
