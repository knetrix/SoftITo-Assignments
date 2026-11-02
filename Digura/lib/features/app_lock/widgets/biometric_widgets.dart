import 'dart:async'; // Timer Class'ını Sağlayan dart:async Kütüphanesini import Eder.
import 'dart:math' as math; // pi Sabiti İçin dart:math Kütüphanesini math Önekiyle import Eder.

import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // AppPalette ve context.palette Extension'ını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons ve AppIconData Class'larını import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre ve Curve Sabitlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.

/// "Taranıyor" halkası: doğrusal 900 ms/tur, en çok 60 sn döner sonra durur.
class ScanRing extends StatefulWidget { // Dönen Tarama Halkasını Çizen StatefulWidget'tır.
  final double size; // Halkanın Piksel Cinsinden Boyutudur.
  final Color color; // Dönen Yayın Rengidir.
  final Color trackColor; // Arka Plandaki Tam Halkanın Rengidir.
  final double strokeWidth; // Çizgi Kalınlığıdır.

  const ScanRing({ // ScanRing'in const Constructor'ıdır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.size, // size Field'ını required Yapar.
    required this.color, // color Field'ını required Yapar.
    this.trackColor = Colors.transparent, // trackColor Varsayılanını Şeffaf Yapar.
    this.strokeWidth = 3, // strokeWidth Varsayılanını 3 Yapar.
  });

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<ScanRing> createState() => _ScanRingState(); // ScanRing'in State Nesnesini Oluşturur.
}

class _ScanRingState extends State<ScanRing> with SingleTickerProviderStateMixin { // Dönüş Animasyonunu Yöneten State Class'ıdır.
  late final AnimationController _spin = AnimationController(vsync: this, duration: AppMotion.scanTurn)..repeat(); // Tur Süresiyle Sürekli Tekrarlanan Dönüş Controller'ıdır.
  Timer? _limit; // Dönüşü Azami Süre Sonunda Durduran Timer'dır.

  @override // Superclass'taki initState Metodunun Override Edildiğini Belirtir.
  void initState() { // State İlk Oluşturulduğunda Çalışır.
    super.initState(); // Superclass'ın initState Metodunu Çağırır.
    _limit = Timer(AppMotion.scanMax, _spin.stop); // scanMax Süresi Dolunca Dönüşü Durduran Timer'ı Başlatır.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _limit?.cancel(); // Bekleyen Timer'ı İptal Eder.
    _spin.dispose(); // Dönüş Controller'ını dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Halkanın Widget Tree'sini Oluşturur.
    return RotationTransition( // İçeriği Controller Değerine Göre Döndürür.
      turns: _spin, // Dönüş Miktarını _spin Controller'ından Alır.
      child: CustomPaint( // Halkayı Özel Painter İle Çizer.
        size: Size.square(widget.size), // Çizim Alanını Kare size Boyutunda Yapar.
        painter: _RingPainter(widget.color, widget.trackColor, widget.strokeWidth), // Renk ve Kalınlıkla _RingPainter Oluşturur.
      ),
    );
  }
}

class _RingPainter extends CustomPainter { // Halka ve Üst Çeyrek Yayı Çizen CustomPainter'dır.
  final Color color; // Yayın Rengidir.
  final Color track; // Arka Halkanın Rengidir.
  final double stroke; // Çizgi Kalınlığıdır.

  _RingPainter(this.color, this.track, this.stroke); // Renk, Track ve Kalınlığı Alan Constructor'dır.

  @override // Superclass'taki paint Metodunun Override Edildiğini Belirtir.
  void paint(Canvas canvas, Size size) { // Halkayı Canvas Üzerine Çizer.
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke); // Çizginin Taşmaması İçin İçeri Alınmış Dikdörtgeni Hesaplar.
    final paint = Paint() // Çizim İçin Paint Nesnesi Oluşturur.
      ..style = PaintingStyle.stroke // Yalnızca Kontur Çizilmesini Sağlar.
      ..strokeWidth = stroke; // Kontur Kalınlığını Ayarlar.
    if (track.a > 0) canvas.drawOval(rect, paint..color = track); // Track Rengi Görünürse Tam Halkayı Çizer.
    // CSS `border-top-color`: üst çeyrek yay.
    canvas.drawArc(rect, -3 * math.pi / 4, math.pi / 2, false, paint..color = color); // Üst Çeyrek Yayı color İle Çizer.
  }

  @override // Superclass'taki shouldRepaint Metodunun Override Edildiğini Belirtir.
  bool shouldRepaint(_RingPainter old) => old.color != color || old.track != track || old.stroke != stroke; // Herhangi Bir Değer Değiştiyse Yeniden Çizer.
}

/// Parmak izi kurulum görseli (168 px `surfaceWarm` daire, 76 px simge).
class BiometricHero extends StatelessWidget { // Parmak İzi Kurulum Görselini Gösteren StatelessWidget'tır.
  final bool scanning; // Tarama Halkasının Gösterilip Gösterilmeyeceğidir.
  final bool enabled; // Biyometrinin Etkinleştirilip Etkinleştirilmediğidir.
  final String semanticLabel; // Ekran Okuyucu İçin Erişilebilirlik Etiketidir.

  const BiometricHero({super.key, required this.scanning, required this.enabled, required this.semanticLabel}); // Tüm Field'ları required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Görselin Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    return Semantics( // Görsele Erişilebilirlik Bilgisi Ekler.
      label: semanticLabel, // Ekran Okuyucu Etiketini Ayarlar.
      image: true, // Öğeyi Görsel Olarak İşaretler.
      child: SizedBox.square( // Kare Bir Alan Ayırır.
        dimension: 180, // Alanın Kenar Uzunluğunu 180 Yapar.
        child: Stack( // Daire ve Halkayı Üst Üste Yerleştirir.
          alignment: Alignment.center, // Çocukları Ortalar.
          children: [ // Stack'in Çocuk Listesidir.
            AnimatedContainer( // Renk Değişimini Animasyonlu Yapan Dairedir.
              duration: AppMotion.ui, // Animasyon Süresini ui Yapar.
              curve: AppMotion.easeOut, // Animasyon Curve'ünü easeOut Yapar.
              width: 168, // Dairenin Genişliğini 168 Yapar.
              height: 168, // Dairenin Yüksekliğini 168 Yapar.
              decoration: BoxDecoration(shape: BoxShape.circle, color: enabled ? p.successSoft : p.surfaceWarm), // Etkinse Yeşil, Değilse Sıcak Zeminli Daire Çizer.
              alignment: Alignment.center, // Simgeyi Ortalar.
              child: AppIcon( // Ortadaki Simgeyi Gösterir.
                enabled ? AppIcons.check : AppIcons.fingerprint, // Etkinse Onay, Değilse Parmak İzi Simgesini Seçer.
                size: 76, // Simge Boyutunu 76 Yapar.
                strokeWidth: 1.6, // Simge Çizgi Kalınlığını Ayarlar.
                color: enabled ? p.success : p.fg, // Duruma Göre Simge Rengini Seçer.
              ),
            ),
            if (scanning) ScanRing(size: 180, color: p.fg, trackColor: p.borderSoft), // Tarama Sürüyorsa Dönen Halkayı Gösterir.
          ],
        ),
      ),
    );
  }
}

/// Bilgi satırı (`.fact`): `bg` zemin, 12 px yarıçap, 20 px simge.
class FactRow extends StatelessWidget { // Simge ve Metinden Oluşan Bilgi Satırı StatelessWidget'ıdır.
  final AppIconData icon; // Satırda Gösterilecek Simgedir.
  final String text; // Satırda Gösterilecek Metindir.

  const FactRow({super.key, required this.icon, required this.text}); // icon ve text Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Bilgi Satırının Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    return Container( // Satırın Zeminli Kutusunu Oluşturur.
      padding: const EdgeInsets.all(12), // Her Yönden 12 Boşluk Verir.
      decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(12)), // bg Zemin ve 12 Yarıçaplı Köşe Uygular.
      child: Row( // Simge ve Metni Yan Yana Dizer.
        children: [ // Row'un Çocuk Listesidir.
          AppIcon(icon, color: p.fg2), // Bilgi Simgesini İkincil Renkle Çizer.
          const SizedBox(width: 12), // Simge İle Metin Arasına 12 Boşluk Koyar.
          Expanded( // Metnin Kalan Genişliği Kaplamasını Sağlar.
            child: Text(text, style: AppTypography.body(14, color: p.fg2)), // Bilgi Metnini 14 Punto Gövde Stiliyle Yazar.
          ),
        ],
      ),
    );
  }
}
