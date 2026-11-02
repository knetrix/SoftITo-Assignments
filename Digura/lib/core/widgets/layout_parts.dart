import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../constants/app_colors.dart'; // palette Erişimi İçin AppColors'ı import Eder.
import '../constants/app_icons.dart'; // AppIcons Simge Sabitlerini Ve AppIconData Tipini import Eder.
import '../constants/app_strings.dart'; // Kullanıcıya Görünen Metinler İçin AppStrings'i import Eder.
import '../theme/app_theme.dart'; // Yazı Stilleri İçin AppTypography'yi import Eder.
import '../utils/clock.dart'; // trUpper Ve DateHelpers Yardımcılarını import Eder.
import 'app_buttons.dart'; // AppIconButton Widget'ını import Eder.
import 'app_icon.dart'; // Simge Çizen AppIcon Widget'ını import Eder.

/// Sekme başlığı: mono üstbilgi (BÜYÜK HARF) + 28 px başlık, isteğe bağlı
/// sağ üst eylem (Bugün'deki dişli). `padding: 8 20 16`.
class ScreenHeader extends StatelessWidget { // Üstbilgi Ve Başlıktan Oluşan Sekme Başlığı StatelessWidget'ıdır.
  final String eyebrow; // Başlığın Üstündeki Küçük Üstbilgi Metnidir.
  final String title; // Ana Başlık Metnidir.
  final Widget? trailing; // Sağ Üstteki İsteğe Bağlı Eylem Widget'ıdır.

  const ScreenHeader({super.key, required this.eyebrow, required this.title, this.trailing}); // eyebrow Ve title'ı required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Sekme Başlığını Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    return Padding( // Başlığa Dış Boşluk Ekler.
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16), // Sol 20, Üst 8, Sağ 20, Alt 16 Boşluk Verir.
      child: Stack( // Başlık Ve Sağ Üst Eylemi Üst Üste Yerleştirir.
        clipBehavior: Clip.none, // Taşan Eylemin Kırpılmasını Engeller.
        children: [ // Stack'in Çocuklarını Tanımlar.
          Padding( // Eylem Varsa Metnin Altına Girmemesi İçin Sağ Boşluk Ekler.
            padding: EdgeInsets.only(right: trailing == null ? 0 : 44), // Eylem Varsa Sağda 44 Boşluk Bırakır.
            child: Column( // Üstbilgi Ve Başlığı Dikey Dizer.
              crossAxisAlignment: CrossAxisAlignment.start, // Metinleri Sola Yaslar.
              children: [ // Column'un Çocuklarını Tanımlar.
                Text(trUpper(eyebrow), style: AppTypography.eyebrow(11, p.muted)), // Üstbilgiyi Türkçe Büyük Harfle Yazar.
                const SizedBox(height: 6), // Üstbilgi İle Başlık Arasına 6 Boşluk Koyar.
                Semantics( // Başlığı Erişilebilirlik İçin İşaretler.
                  header: true, // Bu Metni Başlık Olarak Bildirir.
                  child: Text(title, style: AppTypography.display(28, height: 1.1, tracking: -0.02, color: p.fg)), // Başlığı 28 Boyutlu Display Stiliyle Yazar.
                ),
              ],
            ),
          ),
          if (trailing != null) Positioned(top: -8, right: -10, child: trailing!), // Eylem Varsa Sağ Üst Köşeye Yerleştirir.
        ],
      ),
    );
  }
}

/// Ay başlığı + "X / N gün renklendi" alt yazısı ve önceki/sonraki okları.
class MonthNav extends StatelessWidget { // Ay Başlığı Ve Gezinme Oklarını Gösteren StatelessWidget'tır.
  final String title; // Ay Başlığıdır.
  final String subtitle; // Başlığın Altındaki Alt Yazıdır.
  final bool monoTitle; // Başlığın Mono Fontla Yazılıp Yazılmayacağını Belirtir.
  final VoidCallback? onPrevious; // Önceki Aya Geçiş Callback'idir.
  final VoidCallback? onNext; // Sonraki Aya Geçiş Callback'idir.
  final bool showArrows; // Gezinme Oklarının Gösterilip Gösterilmeyeceğini Belirtir.

  const MonthNav({ // MonthNav'ın const Constructor'ıdır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.title, // title Field'ını required Yapar.
    required this.subtitle, // subtitle Field'ını required Yapar.
    this.monoTitle = false, // Varsayılan Olarak Display Fontu Kullanır.
    this.onPrevious, // İsteğe Bağlı Önceki Ay Callback'ini Alır.
    this.onNext, // İsteğe Bağlı Sonraki Ay Callback'ini Alır.
    this.showArrows = true, // Varsayılan Olarak Okları Gösterir.
  });

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Ay Gezinme Satırını Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    final titleStyle = monoTitle // monoTitle'a Göre Başlık Stilini Seçer.
        ? AppTypography.mono(20, height: 1.4, color: p.fg) // Mono Font Stilini Kullanır.
        : AppTypography.display(20, height: 1.4, tracking: -0.01, color: p.fg); // Display Font Stilini Kullanır.
    return Padding( // Satıra Dış Boşluk Ekler.
      padding: const EdgeInsets.fromLTRB(20, 0, 10, 8), // Sol 20, Sağ 10, Alt 8 Boşluk Verir.
      child: Row( // Başlık Ve Okları Yan Yana Dizer.
        children: [ // Row'un Çocuklarını Tanımlar.
          Expanded( // Başlık Bloğunun Kalan Genişliği Kaplamasını Sağlar.
            child: Column( // Başlık Ve Alt Yazıyı Dikey Dizer.
              crossAxisAlignment: CrossAxisAlignment.start, // Metinleri Sola Yaslar.
              children: [ // Column'un Çocuklarını Tanımlar.
                Text(title, style: titleStyle), // Ay Başlığını Yazar.
                const SizedBox(height: 2), // Başlık İle Alt Yazı Arasına 2 Boşluk Koyar.
                Text(subtitle, style: AppTypography.mono(12, color: p.muted)), // Alt Yazıyı Soluk Mono Stille Yazar.
              ],
            ),
          ),
          if (showArrows) ...[ // Oklar Gösterilecekse.
            AppIconButton(icon: AppIcons.left, onPressed: onPrevious, tooltip: AppStrings.previousMonth), // Önceki Ay Düğmesini Ekler.
            AppIconButton(icon: AppIcons.right, onPressed: onNext, tooltip: AppStrings.nextMonth), // Sonraki Ay Düğmesini Ekler.
          ],
        ],
      ),
    );
  }
}

/// Bilgi satırı: 16 px simge + 13 px soluk metin (`.hint`).
class InfoHint extends StatelessWidget { // Simge Ve Soluk Metinden Oluşan Bilgi Satırı StatelessWidget'ıdır.
  final AppIconData icon; // Satırın Başındaki Simgedir.
  final String text; // Bilgi Metnidir.
  final bool centered; // Simgesiz Ve Ortalanmış Gösterilip Gösterilmeyeceğini Belirtir.
  final EdgeInsets margin; // Satırın Dış Boşluğudur.

  const InfoHint({ // Simgeli Bilgi Satırı İçin const Constructor'dır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.icon, // icon Field'ını required Yapar.
    required this.text, // text Field'ını required Yapar.
    this.centered = false, // Varsayılan Olarak Simgeli Ve Sola Yaslı Gösterir.
    this.margin = const EdgeInsets.fromLTRB(20, 14, 20, 0), // Varsayılan Dış Boşluğu Belirler.
  });

  const InfoHint.textOnly({super.key, required this.text, this.margin = const EdgeInsets.fromLTRB(20, 14, 20, 0)}) // Yalnızca Ortalanmış Metin İçin Named const Constructor'dır.
    : icon = AppIcons.info, // Kullanılmayan Simge İçin info'yu Atar.
      centered = true; // Metni Ortalanmış Gösterir.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Bilgi Satırını Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    final style = AppTypography.body(13, height: 1.4, color: p.muted); // 13 Boyutlu Soluk Gövde Stilini Hazırlar.
    if (centered) { // Ortalanmış Mod İse.
      return Padding( // Dış Boşluklu Ortalanmış Metni Döndürür.
        padding: margin, // Dış Boşluğu Uygular.
        child: Text(text, textAlign: TextAlign.center, style: style), // Metni Ortalayarak Yazar.
      );
    }
    return Padding( // Dış Boşluklu Simgeli Satırı Döndürür.
      padding: margin, // Dış Boşluğu Uygular.
      child: Row( // Simge Ve Metni Yan Yana Dizer.
        crossAxisAlignment: CrossAxisAlignment.start, // Öğeleri Üstten Hizalar.
        children: [ // Row'un Çocuklarını Tanımlar.
          Padding( // Simgeyi Metinle Hizalamak İçin Boşluk Ekler.
            padding: const EdgeInsets.only(top: 1), // Simgeyi 1 Birim Aşağı İter.
            child: AppIcon(icon, size: 16, color: p.muted), // 16 Boyutlu Soluk Simgeyi Çizer.
          ),
          const SizedBox(width: 8), // Simge İle Metin Arasına 8 Boşluk Koyar.
          Expanded(child: Text(text, style: style)), // Metnin Kalan Genişliği Kaplamasını Sağlar.
        ],
      ),
    );
  }
}

/// Düz kart: `surface` + 1 px `border`, 20 px yarıçap, 16 iç boşluk.
class AppCard extends StatelessWidget { // Kenarlıklı Düz Kart StatelessWidget'ıdır.
  final Widget child; // Kartın İçeriğidir.
  final EdgeInsets padding; // Kartın İç Boşluğudur.

  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)}); // child'ı required Alan, Varsayılan İç Boşluğu 16 Olan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Kartı Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    return Container( // Kart Yüzeyini Çizer.
      padding: padding, // İç Boşluğu Uygular.
      decoration: BoxDecoration( // Kart Dekorasyonunu Tanımlar.
        color: p.surface, // Yüzey Rengini Verir.
        border: Border.all(color: p.border), // 1 Birimlik Kenarlık Çizer.
        borderRadius: BorderRadius.circular(20), // Köşeleri 20 Yarıçapla Yuvarlar.
      ),
      child: child, // Kart İçeriğini Yerleştirir.
    );
  }
}

/// Kapsül kilit rozeti + başlık + "Açılış: tarih" satırı (`.capsule-line`).
class CapsuleLine extends StatelessWidget { // Kilit Rozeti, Başlık Ve Açılış Tarihini Gösteren StatelessWidget'tır.
  final String title; // Kapsül Başlığıdır.
  final DateTime unlockDate; // Notun Açılacağı Tarihtir.

  const CapsuleLine({super.key, required this.title, required this.unlockDate}); // title Ve unlockDate'i required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Kapsül Satırını Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    final muted = AppTypography.body(14, height: 1.4, color: p.muted); // 14 Boyutlu Soluk Gövde Stilini Hazırlar.
    return Row( // Rozet Ve Metinleri Yan Yana Dizer.
      children: [ // Row'un Çocuklarını Tanımlar.
        Container( // Kilit Rozeti Kutusunu Çizer.
          width: 44, // Rozet Genişliğini 44 Yapar.
          height: 44, // Rozet Yüksekliğini 44 Yapar.
          decoration: BoxDecoration(color: p.borderSoft, borderRadius: BorderRadius.circular(14)), // Yumuşak Zemin Ve 14 Yarıçap Verir.
          alignment: Alignment.center, // Simgeyi Ortalar.
          child: AppIcon(AppIcons.lock, color: p.fg), // Kilit Simgesini Çizer.
        ),
        const SizedBox(width: 12), // Rozet İle Metinler Arasına 12 Boşluk Koyar.
        Expanded( // Metin Bloğunun Kalan Genişliği Kaplamasını Sağlar.
          child: Column( // Başlık Ve Tarih Satırını Dikey Dizer.
            crossAxisAlignment: CrossAxisAlignment.start, // Metinleri Sola Yaslar.
            children: [ // Column'un Çocuklarını Tanımlar.
              Text( // Kapsül Başlığını Yazar.
                title, // Başlık Metnini Verir.
                style: AppTypography.body(15, weight: FontWeight.w600, height: 1.4, color: p.fg), // Başlığa Kalın Gövde Stilini Uygular.
              ),
              Text.rich( // Karışık Stilli Açılış Tarihi Satırını Yazar.
                TextSpan( // Ana Metin Parçasını Tanımlar.
                  text: AppStrings.unlockOn(''), // Tarihsiz "Açılış:" Önekini Yazar.
                  children: [ // Alt Metin Parçalarını Tanımlar.
                    TextSpan( // Tarih Parçasını Tanımlar.
                      text: DateHelpers.formatLong(unlockDate), // Açılış Tarihini Uzun Biçimde Yazar.
                      style: AppTypography.mono(14, color: p.muted), // Tarihe Soluk Mono Stil Uygular.
                    ),
                  ],
                ),
                style: muted, // Satırın Varsayılan Stilini Soluk Yapar.
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 6 px ilerleme çubuğu (`.bar`): `empty` zemin, `fg` dolgu.
class CapsuleProgressBar extends StatelessWidget { // Kapsül İlerlemesini Gösteren Çubuk StatelessWidget'ıdır.
  final double value; // 0 İle 1 Arasındaki İlerleme Değeridir.
  final double height; // Çubuğun Yüksekliğidir.

  const CapsuleProgressBar({super.key, required this.value, this.height = 6}); // value'yu required Alan, Varsayılan Yüksekliği 6 Olan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // İlerleme Çubuğunu Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    return ClipRRect( // Çubuğu Yuvarlak Köşelerle Kırpar.
      borderRadius: BorderRadius.circular(999), // Tam Hap Şekli İçin Büyük Yarıçap Verir.
      child: Container( // Çubuk Zeminini Çizer.
        height: height, // Çubuk Yüksekliğini Belirler.
        color: p.empty, // Zemini empty Rengiyle Boyar.
        alignment: Alignment.centerLeft, // Dolguyu Soldan Başlatır.
        child: FractionallySizedBox( // Dolguyu İlerleme Oranında Genişletir.
          widthFactor: value.clamp(0.0, 1.0), // Genişlik Oranını 0-1 Aralığına Sınırlar.
          heightFactor: 1, // Tam Yükseklik Kaplar.
          child: DecoratedBox( // Dolgu Kutusunu Çizer.
            decoration: BoxDecoration(color: p.fg, borderRadius: BorderRadius.circular(999)), // Dolguyu fg Rengiyle Hap Şeklinde Boyar.
          ),
        ),
      ),
    );
  }
}

/// Kilitli notun temsili sansür çubukları. Metin ağaçta hiç yer almaz.
class RedactedLines extends StatelessWidget { // Kilitli Not Yerine Sansür Çubukları Gösteren StatelessWidget'tır.
  final List<double> widths; // Her Çubuğun Genişlik Oranlarıdır.

  const RedactedLines({super.key, required this.widths}); // widths'i required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Sansür Çubuklarını Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    return ExcludeSemantics( // Dekoratif Çubukları Ekran Okuyucudan Gizler.
      child: Column( // Çubukları Dikey Dizer.
        crossAxisAlignment: CrossAxisAlignment.start, // Çubukları Sola Yaslar.
        children: [ // Column'un Çocuklarını Tanımlar.
          for (var i = 0; i < widths.length; i++) ...[ // Her Genişlik İçin Çubuk Üretir.
            if (i > 0) const SizedBox(height: 7), // İlk Çubuk Hariç Araya 7 Boşluk Koyar.
            FractionallySizedBox( // Çubuğu Verilen Oranda Genişletir.
              widthFactor: widths[i], // Genişlik Oranını Verir.
              child: Container( // Sansür Çubuğunu Çizer.
                height: 12, // Çubuk Yüksekliğini 12 Yapar.
                decoration: BoxDecoration(color: p.empty, borderRadius: BorderRadius.circular(6)), // empty Rengi Ve 6 Yarıçap Verir.
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Duygu rengi + etiket (renk açıklaması öğesi).
class LegendSwatch extends StatelessWidget { // Renk Kutusu Ve Etiketten Oluşan Açıklama Öğesi StatelessWidget'ıdır.
  final Color color; // Kutunun Rengidir.
  final String label; // Renk Etiketidir.
  final bool outlined; // Kutuya Kenarlık Çizilip Çizilmeyeceğini Belirtir.

  const LegendSwatch({super.key, required this.color, required this.label, this.outlined = false}); // color Ve label'ı required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Açıklama Öğesini Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    return Row( // Kutu Ve Etiketi Yan Yana Dizer.
      mainAxisSize: MainAxisSize.min, // Row'u İçeriği Kadar Genişletir.
      children: [ // Row'un Çocuklarını Tanımlar.
        Container( // Renk Kutusunu Çizer.
          width: 12, // Kutu Genişliğini 12 Yapar.
          height: 12, // Kutu Yüksekliğini 12 Yapar.
          decoration: BoxDecoration( // Kutu Dekorasyonunu Tanımlar.
            color: color, // Kutu Rengini Verir.
            borderRadius: BorderRadius.circular(4), // Köşeleri 4 Yarıçapla Yuvarlar.
            border: outlined ? Border.all(color: p.border) : null, // outlined İse Kenarlık Çizer.
          ),
        ),
        const SizedBox(width: 6), // Kutu İle Etiket Arasına 6 Boşluk Koyar.
        Text(label, style: AppTypography.body(12, height: 1.4, color: p.muted)), // Etiketi 12 Boyutlu Soluk Stille Yazar.
      ],
    );
  }
}

/// Ekranı dolduran, gerektiğinde kaydırılan gövde. Küçük ekranlarda tuş
/// takımı taşmaz; büyük ekranlarda `Spacer` tuş takımını alta iter.
class FillScrollView extends StatelessWidget { // Ekranı Dolduran Ve Gerektiğinde Kayan Gövde StatelessWidget'ıdır.
  final Widget child; // Kaydırılabilir İçeriktir.

  const FillScrollView({super.key, required this.child}); // child'ı required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Doldurup Kayan Gövdeyi Oluşturur.
    return LayoutBuilder( // Üstten Gelen Kısıtları Okur.
      builder: (context, constraints) => SingleChildScrollView( // İçeriği Kaydırılabilir Yapar.
        physics: const ClampingScrollPhysics(), // Kenarlarda Sekmeyen Kaydırma Fiziği Kullanır.
        child: ConstrainedBox( // İçeriğe En Az Ekran Yüksekliği Verir.
          constraints: BoxConstraints(minHeight: constraints.maxHeight), // En Az Yüksekliği Kullanılabilir Yüksekliğe Eşitler.
          child: IntrinsicHeight(child: child), // Spacer'ın Çalışması İçin İçeriği Doğal Yüksekliğe Oturtur.
        ),
      ),
    );
  }
}

/// Ayarlar üst çubuğu (`.appbar`): 48 px geri düğmesi + 22 px başlık.
class AppBarRow extends StatelessWidget { // Geri Düğmesi Ve Başlıktan Oluşan Üst Çubuk StatelessWidget'ıdır.
  final String title; // Üst Çubuk Başlığıdır.
  final VoidCallback onBack; // Geri Düğmesine Basıldığında Çağrılan Callback'tir.
  final String backLabel; // Geri Düğmesinin Erişilebilirlik Etiketidir.

  const AppBarRow({super.key, required this.title, required this.onBack, this.backLabel = AppStrings.back}); // title Ve onBack'i required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Üst Çubuğu Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    return Container( // Üst Çubuk Kutusunu Çizer.
      constraints: const BoxConstraints(minHeight: 56), // En Az 56 Yükseklik Verir.
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 8), // Üst Çubuğun İç Boşluğunu Belirler.
      child: Row( // Geri Düğmesi Ve Başlığı Yan Yana Dizer.
        children: [ // Row'un Çocuklarını Tanımlar.
          AppIconButton(icon: AppIcons.arrowBack, size: 48, iconSize: 24, tooltip: backLabel, onPressed: onBack), // 48 Boyutlu Geri Düğmesini Ekler.
          const SizedBox(width: 4), // Düğme İle Başlık Arasına 4 Boşluk Koyar.
          Expanded( // Başlığın Kalan Genişliği Kaplamasını Sağlar.
            child: Semantics( // Başlığı Erişilebilirlik İçin İşaretler.
              header: true, // Bu Metni Başlık Olarak Bildirir.
              child: Text(title, style: AppTypography.display(22, height: 1.3, color: p.fg)), // Başlığı 22 Boyutlu Display Stiliyle Yazar.
            ),
          ),
        ],
      ),
    );
  }
}
