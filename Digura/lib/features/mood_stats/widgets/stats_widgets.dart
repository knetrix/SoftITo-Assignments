import 'dart:math' as math; // pi Sabiti İçin dart:math Kütüphanesini math Adıyla import Eder.

import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // Renk Token'larını import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Görünen Metinleri (AppStrings) import Eder.
import '../../../core/theme/app_theme.dart'; // palette ve AppTypography'yi import Eder.
import '../../../core/widgets/layout_parts.dart'; // AppCard Widget'ını import Eder.
import '../models/mood_stats_model.dart'; // MoodStatsModel ve MoodShare Class'larını import Eder.

/// Aylık özet kartı: toplam, en sık duygu, yığılmış şerit ve dağılım listesi.
class StatsCard extends StatelessWidget { // Aylık İstatistik Özetini Gösteren StatelessWidget'tır.
  final MoodStatsModel stats; // Gösterilecek İstatistik Modelidir.

  const StatsCard({super.key, required this.stats}); // key'i Superclass'a İleten ve stats'ı required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Özet Kartının Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final top = stats.top!; // En Sık Duyguyu Alır (Kart Yalnızca Kayıt Varken Gösterilir).
    return AppCard( // Ortak Kart Kabını Oluşturur.
      child: Column( // Kart İçeriğini Dikey Dizer.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
        children: [ // Sütun Çocuklarıdır.
          Row( // Toplam ve En Sık Duyguyu Yatay Dizer.
            crossAxisAlignment: CrossAxisAlignment.end, // Çocukları Alta Hizalar.
            children: [ // Satır Çocuklarıdır.
              Expanded( // Toplam Bölümünü Kalan Genişliğe Yayar.
                child: Column( // Toplam Sayı ve Etiketini Dikey Dizer.
                  crossAxisAlignment: CrossAxisAlignment.start, // Sola Hizalar.
                  children: [ // Sütun Çocuklarıdır.
                    Text( // Toplam Kayıt Sayısını Gösterir.
                      '${stats.total}', // Toplamı Metne Çevirir.
                      style: AppTypography.display( // Büyük Başlık Stilini Tanımlar.
                        40, // Font Boyutudur.
                        height: 1, // Satır Yüksekliğidir.
                        tracking: -0.02, // Harf Aralığıdır.
                        color: p.fg, // Metin Rengidir.
                      ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]), // Rakamları Eşit Genişlikli Yapar.
                    ),
                    const SizedBox(height: 4), // Dikey Boşluk Bırakır.
                    Text(AppStrings.statsEntriesThisMonth, style: AppTypography.mono(12, color: p.muted)), // Bu Ayki Kayıt Etiketini Gösterir.
                  ],
                ),
              ),
              const SizedBox(width: 12), // Yatay Boşluk Bırakır.
              Column( // En Sık Duygu Bölümünü Dikey Dizer.
                crossAxisAlignment: CrossAxisAlignment.end, // Sağa Hizalar.
                children: [ // Sütun Çocuklarıdır.
                  Text(AppStrings.statsMostFrequent, style: AppTypography.mono(12, color: p.muted)), // En Sık Etiketini Gösterir.
                  const SizedBox(height: 2), // Dikey Boşluk Bırakır.
                  Text( // En Sık Duyguyu Yüzdesiyle Gösterir.
                    AppStrings.topMood(top.percent, top.mood.label), // Yüzde ve Duygu Adından Metin Üretir.
                    style: AppTypography.body(15, weight: FontWeight.w600, height: 1.4, color: p.fg), // Kalın Gövde Metni Stili Verir.
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12 + 4), // Dikey Boşluk Bırakır.
          StackBar(shares: stats.shares), // Yığılmış Dağılım Çubuğunu Gösterir.
          const SizedBox(height: 2 + 14), // Dikey Boşluk Bırakır.
          for (var i = 0; i < stats.shares.length; i++) DistributionRow(share: stats.shares[i], showDivider: i > 0), // Her Duygu İçin Dağılım Satırı Ekler, İlki Dışında Ayraç Çizer.
        ],
      ),
    );
  }
}

/// Yığılmış dağılım çubuğu (`stack-bar`): 18 px hap, dilimler arası 2 px.
class StackBar extends StatelessWidget { // Duygu Paylarını Tek Yığılmış Çubukta Gösteren StatelessWidget'tır.
  final List<MoodShare> shares; // Duygu Payları Listesidir.

  const StackBar({super.key, required this.shares}); // key'i Superclass'a İleten ve shares'i required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Yığılmış Çubuğun Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final visible = shares.where((s) => s.count > 0).toList(); // Yalnızca Sayısı Sıfırdan Büyük Payları Alır.
    return Semantics( // Çubuğu Etiketli Bir Görsel Olarak İşaretler.
      label: AppStrings.statsDistribution, // Erişilebilirlik Etiketini Verir.
      image: true, // Semantik Olarak Görsel Olduğunu Belirtir.
      child: ClipRRect( // Çubuğu Hap Şeklinde Kırpar.
        borderRadius: BorderRadius.circular(999), // Tam Yuvarlak Köşe Verir.
        child: SizedBox( // Çubuğa Sabit Yükseklik Verir.
          height: 18, // Çubuk Yüksekliğidir.
          child: Row( // Dilimleri Yatay Dizer.
            crossAxisAlignment: CrossAxisAlignment.stretch, // Dilimleri Dikeyde Genişletir.
            children: [ // Satır Çocuklarıdır.
              for (var i = 0; i < visible.length; i++) ...[ // Her Görünür Pay İçin Döner.
                if (i > 0) const SizedBox(width: 2), // İlk Dilim Dışında 2 px Boşluk Koyar.
                Expanded( // Dilimi Payına Göre Genişletir.
                  flex: visible[i].count, // Genişliği Gün Sayısıyla Orantılar.
                  child: ColoredBox(color: p.mood(visible[i].mood)), // Dilimi Duygu Rengiyle Boyar.
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dağılım satırı: renk kutusu, ad + oran şeridi, yüzde ve gün sayısı.
class DistributionRow extends StatelessWidget { // Tek Bir Duygunun Dağılım Satırını Gösteren StatelessWidget'tır.
  final MoodShare share; // Gösterilecek Duygu Payıdır.
  final bool showDivider; // Üstte Ayraç Çizilip Çizilmeyeceğidir.

  const DistributionRow({super.key, required this.share, required this.showDivider}); // key'i Superclass'a İleten ve Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Dağılım Satırının Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final color = p.mood(share.mood); // Duygunun Rengini Alır.
    return Opacity( // Kaydı Olmayan Duyguyu Soluk Gösterir.
      opacity: share.count == 0 ? 0.55 : 1, // Sayı Sıfırsa Opaklığı Düşürür.
      child: Container( // Satır Kabını Oluşturur.
        padding: const EdgeInsets.symmetric(vertical: 10), // Dikey İç Boşluk Verir.
        decoration: BoxDecoration( // Satır Dekorasyonunu Tanımlar.
          border: showDivider ? Border(top: BorderSide(color: p.border)) : null, // Gerekiyorsa Üst Ayraç Çizer.
        ),
        child: Row( // Satır Parçalarını Yatay Dizer.
          children: [ // Satır Çocuklarıdır.
            Container( // Duygu Renk Kutusunu Oluşturur.
              width: 14, // Kutu Genişliğidir.
              height: 14, // Kutu Yüksekliğidir.
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)), // Duygu Renginde Yuvarlak Köşeli Kutu Çizer.
            ),
            const SizedBox(width: 12), // Yatay Boşluk Bırakır.
            Expanded( // Ad ve Oran Şeridini Kalan Genişliğe Yayar.
              child: Column( // Ad ve Şeridi Dikey Dizer.
                crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
                children: [ // Sütun Çocuklarıdır.
                  Text(share.mood.label, style: AppTypography.body(15, height: 1.4, color: p.fg)), // Duygu Adını Gösterir.
                  const SizedBox(height: 5), // Dikey Boşluk Bırakır.
                  ClipRRect( // Oran Şeridini Hap Şeklinde Kırpar.
                    borderRadius: BorderRadius.circular(999), // Tam Yuvarlak Köşe Verir.
                    child: Container( // Şeridin Boş Zeminini Oluşturur.
                      height: 5, // Şerit Yüksekliğidir.
                      color: p.empty, // Boş Zemin Rengini Verir.
                      alignment: Alignment.centerLeft, // Dolu Kısmı Sola Hizalar.
                      child: FractionallySizedBox( // Dolu Kısmı Yüzdeye Göre Boyutlandırır.
                        widthFactor: share.percent / 100, // Genişliği Yüzde Payına Göre Ayarlar.
                        heightFactor: 1, // Tam Yüksekliği Kullanır.
                        child: DecoratedBox( // Dolu Kısmı Çizer.
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)), // Duygu Renginde Hap Çizer.
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12), // Yatay Boşluk Bırakır.
            ConstrainedBox( // Sayı Sütununa En Az Genişlik Verir.
              constraints: const BoxConstraints(minWidth: 48), // En Az 48 px Genişlik Sağlar.
              child: Column( // Yüzde ve Gün Sayısını Dikey Dizer.
                crossAxisAlignment: CrossAxisAlignment.end, // Sağa Hizalar.
                children: [ // Sütun Çocuklarıdır.
                  Text( // Yüzdeyi Gösterir.
                    AppStrings.percent(share.percent), // Yüzde Metnini Üretir.
                    style: AppTypography.mono(15, weight: FontWeight.w600, color: p.fg), // Kalın Mono Stil Verir.
                  ),
                  Text(AppStrings.dayCount(share.count), style: AppTypography.mono(11, color: p.muted)), // Gün Sayısını Gösterir.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Boş ay durumu: kesik çizgili halka + "Bu ay henüz kayıt yok".
class StatsEmptyState extends StatelessWidget { // Kayıtsız Ay İçin Boş Durum Kartını Gösteren StatelessWidget'tır.
  const StatsEmptyState({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Boş Durumun Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    return AppCard( // Ortak Kart Kabını Oluşturur.
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 30), // Kart İç Boşluğunu Verir.
      child: Column( // İçeriği Dikey Dizer.
        children: [ // Sütun Çocuklarıdır.
          CustomPaint(size: const Size.square(72), painter: _DashedRingPainter(p.border)), // 72 px Kesik Çizgili Halka Çizer.
          const SizedBox(height: 16), // Dikey Boşluk Bırakır.
          Text( // Boş Durum Başlığını Gösterir.
            AppStrings.statsEmptyTitle, // Başlık Metnidir.
            textAlign: TextAlign.center, // Metni Ortalar.
            style: AppTypography.display(22, height: 1.2, tracking: -0.015, color: p.fg), // Başlık Stilini Verir.
          ),
          const SizedBox(height: 6), // Dikey Boşluk Bırakır.
          Text( // Boş Durum Açıklamasını Gösterir.
            AppStrings.statsEmptyBody, // Açıklama Metnidir.
            textAlign: TextAlign.center, // Metni Ortalar.
            style: AppTypography.body(14, height: 1.4, color: p.muted), // Soluk Gövde Metni Stili Verir.
          ),
        ],
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter { // Kesik Çizgili Halka Çizen CustomPainter'dır.
  final Color color; // Halka Rengidir.

  _DashedRingPainter(this.color); // Halka Rengini Alan Constructor'dır.

  @override // Superclass'taki paint Metodunun Override Edildiğini Belirtir.
  void paint(Canvas canvas, Size size) { // Halkayı Canvas'a Çizer.
    const stroke = 2.0; // Çizgi Kalınlığıdır.
    final radius = size.width / 2 - stroke / 2; // Çizgi Kalınlığını Hesaba Katarak Yarıçapı Hesaplar.
    final paint = Paint() // Çizim Ayarlarını Oluşturur.
      ..color = color // Çizgi Rengini Verir.
      ..style = PaintingStyle.stroke // Yalnızca Kontur Çizer.
      ..strokeWidth = stroke; // Çizgi Kalınlığını Verir.
    // CSS `border: 2px dashed`: tire ≈ 3 × kalınlık, boşluk ≈ kalınlık kadar.
    const dash = 6.0; // Tire Uzunluğudur.
    const gap = 4.0; // Tireler Arası Boşluktur.
    final circumference = 2 * math.pi * radius; // Halkanın Çevresini Hesaplar.
    final count = (circumference / (dash + gap)).floor(); // Sığacak Tire Sayısını Hesaplar.
    final sweep = (dash / circumference) * 2 * math.pi; // Bir Tirenin Açısal Uzunluğunu Hesaplar.
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: radius); // Halkanın Sınır Dikdörtgenini Oluşturur.
    for (var i = 0; i < count; i++) { // Her Tire İçin Döner.
      canvas.drawArc(rect, -math.pi / 2 + i * 2 * math.pi / count, sweep, false, paint); // Tepeden Başlayarak Eşit Aralıklı Tire Yayı Çizer.
    }
  }

  @override // Superclass'taki shouldRepaint Metodunun Override Edildiğini Belirtir.
  bool shouldRepaint(_DashedRingPainter old) => old.color != color; // Renk Değiştiyse Yeniden Çizer.
}
