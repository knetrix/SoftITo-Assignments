import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_icons.dart'; // Uygulama İkon Tanımlarını (AppIcons) import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Görünen Metinleri (AppStrings) import Eder.
import '../../../core/utils/clock.dart'; // Tarih Biçimleme ve Hesapları İçin DateHelpers'ı import Eder.
import '../../../core/widgets/app_scope.dart'; // Servislere Erişim Sağlayan AppScope'u import Eder.
import '../../../core/widgets/entrance.dart'; // Giriş Animasyonu İçin EntranceScope ve EntranceItem'ı import Eder.
import '../../../core/widgets/layout_parts.dart'; // ScreenHeader, MonthNav ve InfoHint Gibi Ortak Parçaları import Eder.
import '../controllers/mood_calendar_controller.dart'; // MoodCalendarController Class'ını import Eder.
import '../models/mood_calendar_model.dart'; // CalendarMode ve Takvim Modellerini import Eder.
import '../widgets/capsule_detail_sheet.dart'; // showCapsuleDetailSheet Fonksiyonunu import Eder.
import '../widgets/heatmap.dart'; // MonthHeatmap, YearHeatmap ve MoodLegend Widget'larını import Eder.
import '../widgets/view_segment.dart'; // Ay / Yıl Seçici ViewSegment Widget'ını import Eder.

/// Harita sekmesi: Ay (7 sütun) ve Yıl (12 mini ay) ısı haritası.
/// Ay ↔ Yıl ve ay değişimi animasyonsuzdur (yüksek hücre sayısı).
class MoodCalendarView extends StatefulWidget { // Harita Sekmesini Gösteren StatefulWidget'tır.
  final Object? entranceTrigger; // Değiştiğinde Giriş Animasyonunu Yeniden Tetikleyen Değerdir.
  final ScrollController? scrollController; // Dışarıdan Verilen Opsiyonel ScrollController'dır.

  const MoodCalendarView({super.key, this.entranceTrigger, this.scrollController}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<MoodCalendarView> createState() => _MoodCalendarViewState(); // Widget'ın State Nesnesini Oluşturur.
}

class _MoodCalendarViewState extends State<MoodCalendarView> { // MoodCalendarView'in State Class'ıdır.
  MoodCalendarController? _controller; // Lazy Oluşturulan Controller Field'ıdır.

  MoodCalendarController get controller => _controller!; // Controller'ı null Olmayan Olarak Döndüren Getter'dır.

  @override // Superclass'taki didChangeDependencies Metodunun Override Edildiğini Belirtir.
  void didChangeDependencies() { // Bağımlılıklar Hazır Olduğunda Çağrılan Metottur.
    super.didChangeDependencies(); // Superclass'ın didChangeDependencies Metodunu Çağırır.
    if (_controller == null) { // Controller Henüz Oluşturulmadıysa Çalışır.
      final services = AppScope.of(context); // AppScope'tan Uygulama Servislerini Alır.
      _controller = MoodCalendarController(services.moods, services.today); // Repository ve Bugün Bilgisiyle Controller'ı Oluşturur.
    }
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // Widget Kaldırılırken Kaynakları Serbest Bırakır.
    _controller?.dispose(); // Controller'ı dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  Future<void> _openDay(String id) async { // Dokunulan Günün Kapsül Detayını Açan async Metottur.
    final detail = await controller.openDay(id); // Controller'dan Kapsül Detayını Alır.
    if (detail == null || !mounted) return; // Detay Yoksa veya Widget Kaldırıldıysa Çıkar.
    await showCapsuleDetailSheet(context, detail); // Kapsül Detay Modalını Gösterir.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Harita Sekmesinin Widget Tree'sini Oluşturur.
    return EntranceScope( // Blokların Giriş Animasyonunu Yöneten Kapsamı Oluşturur.
      trigger: widget.entranceTrigger, // Animasyonu Tetikleyen Değeri Verir.
      child: ListenableBuilder( // Controller Değişimlerinde Yeniden Çizer.
        listenable: controller.changes, // Birleşik Değişim Listenable'ını Dinler.
        builder: (context, _) { // Her Değişimde İçeriği Oluşturan Builder'dır.
          final state = controller.state.value; // Güncel Takvim State'ini Alır.
          final isYear = state.mode == CalendarMode.year; // Yıl Görünümünde Olup Olmadığını Hesaplar.
          final blocks = <Widget>[ // Sayfadaki Blokların Listesini Oluşturur.
            const ScreenHeader(eyebrow: AppStrings.mapEyebrow, title: AppStrings.mapTitle), // Sayfa Başlığını Gösterir.
            ViewSegment(mode: state.mode, onChanged: controller.setMode), // Ay / Yıl Seçicisini Gösterir.
            if (isYear) ..._yearBlocks() else ..._monthBlocks(state.visibleMonth), // Moda Göre Yıl veya Ay Bloklarını Ekler.
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

  List<Widget> _monthBlocks(DateTime month) { // Ay Görünümünün Bloklarını Üretir.
    final days = DateHelpers.daysInMonth(month.year, month.month); // Aydaki Gün Sayısını Hesaplar.
    return [ // Ay Görünümü Blok Listesini Döndürür.
      MonthNav( // Ay Başlığı ve Ok Butonlarını Gösterir.
        title: DateHelpers.formatMonth(month), // Ay Adını ve Yılı Başlık Yapar.
        subtitle: AppStrings.monthColored(controller.countForMonth(month), days), // Renklendirilen Gün Sayısını Alt Başlık Yapar.
        onPrevious: controller.canGoPrevious ? controller.previousMonth : null, // Mümkünse Önceki Ay Callback'ini Verir.
        onNext: controller.canGoNext ? controller.nextMonth : null, // Mümkünse Sonraki Ay Callback'ini Verir.
      ),
      MonthHeatmap(month: month, cells: controller.monthCells(month), onDayTap: _openDay), // Ay Isı Haritasını Gösterir.
      const MoodLegend(), // Renk Açıklamasını Gösterir.
      const InfoHint(icon: AppIcons.lock, text: AppStrings.mapHint), // Kilit Hakkında Bilgi İpucunu Gösterir.
    ];
  }

  List<Widget> _yearBlocks() { // Yıl Görünümünün Bloklarını Üretir.
    final year = controller.today.year; // İçinde Bulunulan Yılı Alır.
    return [ // Yıl Görünümü Blok Listesini Döndürür.
      MonthNav( // Yıl Başlığını Oksuz Gösterir.
        title: '$year', // Yılı Başlık Metni Yapar.
        monoTitle: true, // Başlığı Mono Fontla Gösterir.
        subtitle: AppStrings.yearColored(controller.countForYear(year)), // Yıldaki Kayıt Sayısını Alt Başlık Yapar.
        showArrows: false, // Gezinme Oklarını Gizler.
      ),
      YearHeatmap(months: controller.yearMonths(year), onMonthTap: controller.openMonth), // 12 Mini Aylık Yıl Haritasını Gösterir.
      const MoodLegend(), // Renk Açıklamasını Gösterir.
    ];
  }
}
