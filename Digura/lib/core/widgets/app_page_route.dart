import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../constants/app_motion.dart'; // Geçiş Süreleri, Curve'ler Ve reduceMotion İçin AppMotion'ı import Eder.

/// Sayfa geçişleri (ANIMATION.md 5.1). Gelen sayfa sağdan kayar (`slide`,
/// 300 ms, `easeOut`); giden sayfa %22 sola kayıp solar (parallax).
/// Hareket azaltma açıkken yalnızca çapraz solma (`ui`).
class AppPageRoute<T> extends PageRouteBuilder<T> { // Uygulamaya Özel Geçiş Animasyonlu Route'tur.
  final bool fadeOnly; // Kaydırma Yerine Yalnızca Solma Kullanılıp Kullanılmayacağını Belirtir.

  AppPageRoute({required WidgetBuilder builder, required bool reduceMotion, this.fadeOnly = false, super.settings}) // builder, reduceMotion Ve İsteğe Bağlı settings Alan Constructor'dır.
    : super( // Geçiş Ayarlarını Superclass'a İletir.
        transitionDuration: reduceMotion || fadeOnly ? AppMotion.ui : AppMotion.slide, // Giriş Geçiş Süresini Belirler.
        reverseTransitionDuration: reduceMotion || fadeOnly ? AppMotion.ui : AppMotion.slide, // Çıkış Geçiş Süresini Belirler.
        pageBuilder: (context, _, _) => builder(context), // Sayfa İçeriğini Verilen builder İle Oluşturur.
        transitionsBuilder: (context, animation, secondary, child) { // Giriş Ve Çıkış Animasyonlarını Kuran Callback'tir.
          final inCurve = CurvedAnimation(parent: animation, curve: AppMotion.easeOut); // Gelen Sayfa İçin easeOut Animasyonu Oluşturur.
          final outCurve = CurvedAnimation(parent: secondary, curve: AppMotion.easeOut); // Giden Sayfa İçin easeOut Animasyonu Oluşturur.
          if (reduceMotion || fadeOnly) { // Hareket Azaltma Ya Da Yalnızca Solma İsteniyorsa.
            return FadeTransition( // Gelen Sayfayı Soldurarak Gösterir.
              opacity: inCurve, // Saydamlığı Giriş Animasyonuna Bağlar.
              child: FadeTransition(opacity: ReverseAnimation(outCurve), child: child), // Üstüne Sayfa Gelince Bu Sayfayı Soldurur.
            );
          }
          return SlideTransition( // Gelen Sayfayı Sağdan Kaydırır.
            position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(inCurve), // Sağ Kenardan Yerine Kayma Konumunu Hesaplar.
            child: SlideTransition( // Giden Sayfa İçin Parallax Kaydırması Uygular.
              position: Tween(begin: Offset.zero, end: const Offset(-AppMotion.parallax, 0)).animate(outCurve), // Sayfayı Parallax Oranında Sola Kaydırır.
              child: FadeTransition(opacity: ReverseAnimation(outCurve), child: child), // Giden Sayfayı Soldurur.
            ),
          );
        },
      );

  /// Bağlamdan hareket tercihini okuyarak rota üretir.
  static AppPageRoute<T> of<T>(BuildContext context, WidgetBuilder builder, {bool fadeOnly = false}) => // Context'ten reduceMotion Okuyarak Route Üreten Factory Metodudur.
      AppPageRoute<T>(builder: builder, reduceMotion: context.reduceMotion, fadeOnly: fadeOnly); // reduceMotion Tercihiyle Yeni AppPageRoute Oluşturur.
}
