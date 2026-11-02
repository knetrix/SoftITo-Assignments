import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_icons.dart'; // Uygulama İkon Tanımlarını (AppIcons) import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Görünen Metinleri (AppStrings) import Eder.
import '../../../core/utils/clock.dart'; // Ay Biçimleme İçin DateHelpers'ı import Eder.
import '../../../core/widgets/app_scope.dart'; // Servislere Erişim Sağlayan AppScope'u import Eder.
import '../../../core/widgets/entrance.dart'; // Giriş Animasyonu İçin EntranceScope ve EntranceItem'ı import Eder.
import '../../../core/widgets/layout_parts.dart'; // ScreenHeader, MonthNav ve InfoHint Gibi Ortak Parçaları import Eder.
import '../controllers/mood_stats_controller.dart'; // MoodStatsController Class'ını import Eder.
import '../widgets/stats_widgets.dart'; // StatsCard ve StatsEmptyState Widget'larını import Eder.

/// İstatistik sekmesi: aylık dağılım şeritleri, yüzdeler ve boş durum.
class MoodStatsView extends StatefulWidget { // İstatistik Sekmesini Gösteren StatefulWidget'tır.
  final Object? entranceTrigger; // Değiştiğinde Giriş Animasyonunu Yeniden Tetikleyen Değerdir.
  final ScrollController? scrollController; // Dışarıdan Verilen Opsiyonel ScrollController'dır.

  const MoodStatsView({super.key, this.entranceTrigger, this.scrollController}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<MoodStatsView> createState() => _MoodStatsViewState(); // Widget'ın State Nesnesini Oluşturur.
}

class _MoodStatsViewState extends State<MoodStatsView> { // MoodStatsView'in State Class'ıdır.
  MoodStatsController? _controller; // Lazy Oluşturulan Controller Field'ıdır.

  MoodStatsController get controller => _controller!; // Controller'ı null Olmayan Olarak Döndüren Getter'dır.

  @override // Superclass'taki didChangeDependencies Metodunun Override Edildiğini Belirtir.
  void didChangeDependencies() { // Bağımlılıklar Hazır Olduğunda Çağrılan Metottur.
    super.didChangeDependencies(); // Superclass'ın didChangeDependencies Metodunu Çağırır.
    if (_controller == null) { // Controller Henüz Oluşturulmadıysa Çalışır.
      final services = AppScope.of(context); // AppScope'tan Uygulama Servislerini Alır.
      _controller = MoodStatsController(services.moods, services.today); // Repository ve Bugün Bilgisiyle Controller'ı Oluşturur.
    }
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // Widget Kaldırılırken Kaynakları Serbest Bırakır.
    _controller?.dispose(); // Controller'ı dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // İstatistik Sekmesinin Widget Tree'sini Oluşturur.
    return EntranceScope( // Blokların Giriş Animasyonunu Yöneten Kapsamı Oluşturur.
      trigger: widget.entranceTrigger, // Animasyonu Tetikleyen Değeri Verir.
      child: ListenableBuilder( // Controller Değişimlerinde Yeniden Çizer.
        listenable: controller.changes, // Birleşik Değişim Listenable'ını Dinler.
        builder: (context, _) { // Her Değişimde İçeriği Oluşturan Builder'dır.
          final stats = controller.stats; // Görünen Ayın İstatistiklerini Alır.
          final blocks = <Widget>[ // Sayfadaki Blokların Listesini Oluşturur.
            const ScreenHeader(eyebrow: AppStrings.statsEyebrow, title: AppStrings.statsTitle), // Sayfa Başlığını Gösterir.
            MonthNav( // Ay Başlığı ve Ok Butonlarını Gösterir.
              title: DateHelpers.formatMonth(stats.month), // Ay Adını ve Yılı Başlık Yapar.
              subtitle: AppStrings.statsSub, // Alt Başlık Metnini Verir.
              onPrevious: controller.canGoPrevious ? controller.previousMonth : null, // Mümkünse Önceki Ay Callback'ini Verir.
              onNext: controller.canGoNext ? controller.nextMonth : null, // Mümkünse Sonraki Ay Callback'ini Verir.
            ),
            Padding( // Karta Yatay Kenar Boşluğu Verir.
              padding: const EdgeInsets.symmetric(horizontal: 20), // Yatayda 20 px Boşluk Bırakır.
              child: stats.isEmpty ? const StatsEmptyState() : StatsCard(stats: stats), // Kayıt Yoksa Boş Durumu, Varsa İstatistik Kartını Gösterir.
            ),
            const InfoHint(icon: AppIcons.shield, text: AppStrings.statsPrivacy), // Gizlilik Bilgi İpucunu Gösterir.
          ];
          return SingleChildScrollView( // İçeriği Kaydırılabilir Yapar.
            controller: widget.scrollController, // Dışarıdan Gelen ScrollController'ı Bağlar.
            padding: const EdgeInsets.only(top: 4, bottom: 24), // Üst ve Alt Boşluk Verir.
            child: Column( // Blokları Dikey Dizer.
              crossAxisAlignment: CrossAxisAlignment.stretch, // Blokları Yatayda Genişletir.
              children: [for (var i = 0; i < blocks.length; i++) EntranceItem(index: i, child: blocks[i])], // Her Bloğu Sıralı Giriş Animasyonuyla Sarar.
            ),
          );
        },
      ),
    );
  }
}
