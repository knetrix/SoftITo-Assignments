import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../constants/app_colors.dart'; // palette Erişimi İçin AppColors'ı import Eder.
import '../constants/app_motion.dart'; // Diyalog Animasyon Süre Ve Curve'leri İçin AppMotion'ı import Eder.
import '../theme/app_theme.dart'; // Yazı Stilleri İçin AppTypography'yi import Eder.

/// Diyalog açılışı (ANIMATION.md 4.3): saydamlık 0 → 1 ve ölçek 0.96 → 1,
/// `ui` (200 ms) `easeOut`. Hareket azaltma açıkken yalnızca solma.
Future<T?> showAppDialog<T>({ // Uygulama Animasyonuyla Diyalog Açan Yardımcı Fonksiyondur.
  required BuildContext context, // Diyaloğun Açılacağı context'tir.
  required WidgetBuilder builder, // Diyalog İçeriğini Oluşturan builder'dır.
  bool barrierDismissible = true, // Arka Plana Dokununca Kapanıp Kapanmayacağını Belirtir.
}) {
  final reduce = context.reduceMotion; // Hareket Azaltma Tercihini Okur.
  return showGeneralDialog<T>( // Özel Geçişli Genel Diyaloğu Gösterir.
    context: context, // Diyalog context'ini Verir.
    barrierDismissible: barrierDismissible, // Arka Plana Dokunarak Kapatmayı Ayarlar.
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel, // Arka Plan İçin Erişilebilirlik Etiketini Verir.
    barrierColor: context.palette.scrim, // Arka Plan Örtü Rengini Paletten Alır.
    transitionDuration: AppMotion.ui, // Geçiş Süresini ui Yapar.
    pageBuilder: (context, _, _) => builder(context), // Diyalog İçeriğini Verilen builder İle Oluşturur.
    transitionBuilder: (context, animation, _, child) { // Açılış Animasyonunu Kuran Callback'tir.
      final curved = CurvedAnimation(parent: animation, curve: AppMotion.easeOut); // easeOut Curve'lü Animasyon Oluşturur.
      final faded = FadeTransition(opacity: curved, child: child); // İçeriği Soldurarak Gösterir.
      if (reduce) return faded; // Hareket Azaltma Açıksa Yalnızca Solmayı Döndürür.
      return ScaleTransition( // Solmaya Ek Olarak Ölçek Animasyonu Uygular.
        scale: Tween<double>(begin: AppMotion.dialogFrom, end: 1).animate(curved), // Ölçeği dialogFrom'dan 1'e Büyütür.
        child: faded, // Solan İçeriği Ölçeklendirir.
      );
    },
  );
}

/// 28 px yarıçaplı diyalog yüzeyi: başlık, gövde ve sağa yaslı eylemler.
class AppDialog extends StatelessWidget { // Başlık, Gövde Ve Eylemlerden Oluşan Diyalog StatelessWidget'ıdır.
  final String title; // Diyalog Başlığıdır.
  final Widget body; // Diyalog Gövde İçeriğidir.
  final List<Widget> actions; // Sağa Yaslı Eylem Düğmeleridir.
  final double titleSize; // Başlık Font Boyutudur.
  final double titleGap; // Başlık İle Gövde Arasındaki Boşluktur.
  final EdgeInsets padding; // Diyalog Yüzeyinin İç Boşluğudur.
  final double actionsGap; // Gövde İle Eylemler Arasındaki Boşluktur.
  final bool raised; // Yüzeye Gölge Uygulanıp Uygulanmayacağını Belirtir.

  /// Gövdenin yatay iç boşluğa taşma miktarı (`.radios { margin: 0 -12px }`).
  final double bodyBleed; // Gövdenin Yatay İç Boşluğa Taşma Miktarıdır.

  const AppDialog({ // Varsayılan Diyalog Ölçüleriyle const Constructor'dır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.title, // title Field'ını required Yapar.
    required this.body, // body Field'ını required Yapar.
    required this.actions, // actions Field'ını required Yapar.
    this.titleSize = 22, // Varsayılan Başlık Boyutunu 22 Yapar.
    this.titleGap = 10, // Varsayılan Başlık Boşluğunu 10 Yapar.
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 16), // Varsayılan İç Boşluğu Belirler.
    this.actionsGap = 18, // Varsayılan Eylem Boşluğunu 18 Yapar.
    this.raised = false, // Varsayılan Olarak Gölge Kullanmaz.
    this.bodyBleed = 0, // Varsayılan Olarak Taşma Uygulamaz.
  });

  /// `digura-kilit.html` diyalogu: başlık 24, alt boşluk 12, gölgeli.
  const AppDialog.lock({super.key, required this.title, required this.body, required this.actions, this.bodyBleed = 0}) // Kilit Ekranı Diyaloğu İçin Named const Constructor'dır.
    : titleSize = 24, // Başlık Boyutunu 24 Yapar.
      titleGap = 12, // Başlık Boşluğunu 12 Yapar.
      padding = const EdgeInsets.fromLTRB(24, 24, 24, 12), // Kilit Diyaloğu İç Boşluğunu Belirler.
      actionsGap = 16, // Eylem Boşluğunu 16 Yapar.
      raised = true; // Yüzeye Gölge Uygular.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Diyalog Yüzeyini Oluşturur.
    final p = context.palette; // Temadaki Renk Paletini Alır.
    return Center( // Diyaloğu Ekranda Ortalar.
      child: Padding( // Yatay Kenar Boşluğu Ekler.
        padding: const EdgeInsets.symmetric(horizontal: 24), // Ekran Kenarlarından 24 Boşluk Bırakır.
        child: Material( // Metin Stilleri İçin Saydam Material Sağlar.
          type: MaterialType.transparency, // Material'ı Saydam Yapar.
          child: Container( // Diyalog Yüzeyini Çizer.
            width: double.infinity, // Kullanılabilir Genişliğin Tamamını Kaplar.
            padding: padding.copyWith(left: padding.left - bodyBleed, right: padding.right - bodyBleed), // Taşma Miktarı Kadar Yatay İç Boşluğu Azaltır.
            decoration: BoxDecoration( // Yüzey Dekorasyonunu Tanımlar.
              color: p.surface, // Yüzey Rengini Verir.
              borderRadius: BorderRadius.circular(28), // Köşeleri 28 Yarıçapla Yuvarlar.
              boxShadow: raised ? p.raised : null, // raised İse Gölge Uygular.
            ),
            child: Semantics( // Diyaloğu Ayrı Bir Route Olarak Erişilebilir Yapar.
              scopesRoute: true, // Semantics'te Yeni Route Kapsamı Açar.
              namesRoute: true, // Route Adını Bu Düğümden Alır.
              explicitChildNodes: true, // Çocukları Ayrı Semantics Düğümleri Olarak Tutar.
              label: title, // Route Adı Olarak Başlığı Verir.
              child: Column( // Başlık, Gövde Ve Eylemleri Dikey Dizer.
                mainAxisSize: MainAxisSize.min, // Column'u İçeriği Kadar Yükseltir.
                crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Gerer.
                children: [ // Column'un Çocuklarını Tanımlar.
                  Padding( // Başlığa Taşma Telafisi İç Boşluğu Ekler.
                    padding: EdgeInsets.symmetric(horizontal: bodyBleed), // Taşma Kadar Yatay Boşluk Verir.
                    child: Text( // Diyalog Başlığını Yazar.
                      title, // Başlık Metnini Verir.
                      style: AppTypography.display(titleSize, height: 1.25, tracking: -0.01, color: p.fg), // Başlığa Display Stilini Uygular.
                    ),
                  ),
                  SizedBox(height: titleGap), // Başlık İle Gövde Arasına Boşluk Koyar.
                  body, // Diyalog Gövdesini Yerleştirir.
                  SizedBox(height: actionsGap), // Gövde İle Eylemler Arasına Boşluk Koyar.
                  Padding( // Eylemlere Taşma Telafisi İç Boşluğu Ekler.
                    padding: EdgeInsets.symmetric(horizontal: bodyBleed), // Taşma Kadar Yatay Boşluk Verir.
                    child: Row( // Eylem Düğmelerini Yan Yana Dizer.
                      mainAxisAlignment: MainAxisAlignment.end, // Eylemleri Sağa Yaslar.
                      children: [ // Row'un Çocuklarını Tanımlar.
                        for (var i = 0; i < actions.length; i++) ...[ // Her Eylem İçin Öğe Üretir.
                          if (i > 0) const SizedBox(width: 4), // İlk Eylem Hariç Araya 4 Boşluk Koyar.
                          Flexible(child: actions[i]), // Eylemi Esnek Genişlikte Yerleştirir.
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
