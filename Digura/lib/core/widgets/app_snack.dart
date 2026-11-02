import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../constants/app_motion.dart'; // Bildirim Süreleri İçin AppMotion Sabitlerini import Eder.

/// Bildirim (DESIGN.md 5): `fg` zemin, `surface` yazı, 12 px yarıçap,
/// `role="status"`. Yeni bildirim öncekinin yerini alır.
void showAppSnack(BuildContext context, String message, {Duration duration = AppMotion.snackShort}) { // Uygulama Stilinde SnackBar Gösteren Yardımcı Fonksiyondur.
  final messenger = ScaffoldMessenger.maybeOf(context); // Context'teki ScaffoldMessenger'ı Varsa Alır.
  if (messenger == null) return; // ScaffoldMessenger Yoksa Hiçbir Şey Yapmaz.
  messenger // ScaffoldMessenger Üzerinde Zincirleme Çağrı Başlatır.
    ..hideCurrentSnackBar() // Mevcut SnackBar'ı Gizler.
    ..showSnackBar( // Yeni SnackBar'ı Gösterir.
      SnackBar( // Bildirim Widget'ını Oluşturur.
        content: Semantics(liveRegion: true, child: Text(message)), // Mesajı Ekran Okuyucuya Duyurulan Canlı Bölge Olarak Gösterir.
        duration: duration, // Bildirimin Ekranda Kalma Süresini Belirler.
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), // Bildirimin İç Boşluğunu Belirler.
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Bildirimin Kenarlardan Dış Boşluğunu Belirler.
      ),
    );
}
