import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'ını ve Renk Token'larını import Eder.
import '../../../core/constants/app_icons.dart'; // Uygulama İkon Tanımlarını (AppIcons) import Eder.
import '../../../core/constants/app_motion.dart'; // Basma Ölçeği Gibi Hareket Token'larını (AppMotion) import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Görünen Metinleri (AppStrings) import Eder.
import '../../../core/theme/app_theme.dart'; // palette ve AppTypography'yi import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.
import '../../../core/widgets/layout_parts.dart'; // LegendSwatch Widget'ını import Eder.
import '../../../core/widgets/pressable.dart'; // Basma Ölçekli Dokunma Widget'ı Pressable'ı import Eder.
import '../models/mood_calendar_model.dart'; // DayCellModel ve MiniMonthModel Modellerini import Eder.

/// 7 sütunlu ay ısı haritası (`Pt–Pz`), harici takvim paketi olmadan.
class MonthHeatmap extends StatelessWidget { // Ayın Günlerini 7 Sütunlu Isı Haritası Olarak Gösteren StatelessWidget'tır.
  final DateTime month; // Gösterilen Aydır.
  final List<DayCellModel?> cells; // Boşluklar Dahil Gün Hücreleri Listesidir.
  final ValueChanged<String> onDayTap; // Bir Güne Dokunulunca entryId İle Çağrılan Callback'tir.

  const MonthHeatmap({super.key, required this.month, required this.cells, required this.onDayTap}); // key'i Superclass'a İleten ve Field'ları required Yapan const Constructor'dır.

  static const double _gap = 4; // Hücreler Arası Boşluktur.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Ay Isı Haritasının Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    return Padding( // Haritaya Yatay Kenar Boşluğu Verir.
      padding: const EdgeInsets.symmetric(horizontal: 12), // Yatayda 12 px Boşluk Bırakır.
      child: LayoutBuilder( // Mevcut Genişliğe Göre Hücre Boyutunu Hesaplamak İçin Kullanılır.
        builder: (context, constraints) { // Constraint'lere Göre İçeriği Oluşturan Builder'dır.
          final size = (constraints.maxWidth - _gap * 6) / 7; // 7 Sütuna Sığacak Hücre Boyutunu Hesaplar.
          return Column( // Gün Başlıkları ve Hücreleri Dikey Dizer.
            children: [ // Sütun Çocuklarıdır.
              ExcludeSemantics( // Gün Kısaltmalarını Ekran Okuyucudan Gizler.
                child: Row( // Haftanın Gün Kısaltmalarını Yatay Dizer.
                  children: [ // Satır Çocuklarıdır.
                    for (var i = 0; i < 7; i++) ...[ // Haftanın 7 Günü İçin Döner.
                      if (i > 0) const SizedBox(width: _gap), // İlk Gün Dışında Araya Boşluk Koyar.
                      SizedBox( // Gün Kısaltmasına Hücre Genişliği Verir.
                        width: size, // Hücre Genişliğini Kullanır.
                        child: Text( // Gün Kısaltmasını Gösterir.
                          AppStrings.weekdaysShort[i], // Pazartesi Başlangıçlı Kısa Gün Adını Alır.
                          textAlign: TextAlign.center, // Metni Ortalar.
                          style: AppTypography.mono(11, tracking: 0.04, color: p.muted), // Küçük Mono Soluk Stil Verir.
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 6), // Başlık ile Hücreler Arasında Boşluk Bırakır.
              Wrap( // Hücreleri Satırlara Sararak Dizer.
                spacing: _gap, // Yatay Hücre Aralığıdır.
                runSpacing: _gap, // Dikey Satır Aralığıdır.
                children: [ // Wrap Çocuklarıdır.
                  for (final cell in cells) // Her Hücre İçin Döner.
                    SizedBox.square( // Hücreye Kare Alan Ayırır.
                      dimension: size, // Hesaplanan Hücre Boyutunu Kullanır.
                      child: cell == null // Hücrenin Boşluk Olup Olmadığını Kontrol Eder.
                          ? null // Boşluk Hücresinde İçerik Göstermez.
                          : HeatmapCell( // Gün Hücresini Oluşturur.
                              cell: cell, // Hücre Modelini Verir.
                              monthName: AppStrings.months[month.month - 1], // Erişilebilirlik İçin Ay Adını Verir.
                              onTap: cell.entryId == null ? null : () => onDayTap(cell.entryId!), // Kayıt Varsa Dokunma Callback'ini Bağlar.
                            ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Isı haritası hücresi (~45 px, yarıçap 11). Kilitli gün = sağ altta 11 px
/// kilit; bugün = çift halka; yeni açılan = sağ altta 7 px nokta.
/// Hücre başına animasyon yoktur; yalnızca dokunulabilir hücrede basma ölçeği.
class HeatmapCell extends StatelessWidget { // Tek Bir Gün Hücresini Çizen StatelessWidget'tır.
  final DayCellModel cell; // Hücre Modelidir.
  final String monthName; // Erişilebilirlik Etiketi İçin Ay Adıdır.
  final VoidCallback? onTap; // Opsiyonel Dokunma Callback'idir.

  const HeatmapCell({super.key, required this.cell, required this.monthName, this.onTap}); // key'i Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Hücrenin Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final mood = cell.mood; // Hücrenin Duygusunu Alır.
    final textColor = mood == null ? p.muted : p.onMood(mood); // Duyguya Göre Okunabilir Metin Rengini Seçer.
    final box = Container( // Hücre Kutusunu Oluşturur.
      padding: const EdgeInsets.fromLTRB(6, 5, 6, 5), // Hücre İç Boşluğunu Verir.
      decoration: BoxDecoration( // Hücre Dekorasyonunu Tanımlar.
        color: mood != null ? p.mood(mood) : (cell.isFuture ? Colors.transparent : p.empty), // Duygu Rengi, Gelecek İçin Şeffaf veya Boş Rengi Seçer.
        borderRadius: BorderRadius.circular(11), // Köşeleri 11 px Yuvarlatır.
        border: cell.isFuture ? Border.all(color: p.border) : null, // Gelecek Günlere Kenarlık Çizer.
        boxShadow: cell.isToday // Bugünse Çift Halka Gölgesi Uygular.
            ? [BoxShadow(color: p.fg, spreadRadius: 4), BoxShadow(color: p.bg, spreadRadius: 2)] // Dışta Ön Plan, İçte Zemin Renginde Halka Çizer.
            : null, // Bugün Değilse Gölge Uygulamaz.
      ),
      child: Stack( // Gün Numarası ve Rozetleri Üst Üste Dizer.
        clipBehavior: Clip.none, // Rozetlerin Taşmasına İzin Verir.
        children: [ // Stack Katmanlarıdır.
          Text('${cell.day}', style: AppTypography.mono(11, color: textColor)), // Gün Numarasını Gösterir.
          if (cell.isLocked) // Kapsül Kilitliyse Çalışır.
            Positioned( // Kilit İkonunu Sağ Alta Konumlandırır.
              right: -1, // Sağdan Konumdur.
              bottom: 0, // Alttan Konumdur.
              child: Opacity( // Kilit İkonunu Hafif Saydam Yapar.
                opacity: 0.75, // Opaklık Değeridir.
                child: AppIcon(AppIcons.lock, size: 11, strokeWidth: 2.2, color: textColor), // 11 px Kilit İkonunu Çizer.
              ),
            ),
          if (cell.isFresh) // Kapsül Yeni Açıldıysa Çalışır.
            Positioned( // Yeni Rozetini Sağ Alta Konumlandırır.
              right: -1, // Sağdan Konumdur.
              bottom: 0, // Alttan Konumdur.
              child: Container( // 7 px Nokta Rozetini Oluşturur.
                width: 7, // Nokta Genişliğidir.
                height: 7, // Nokta Yüksekliğidir.
                decoration: BoxDecoration(color: textColor, shape: BoxShape.circle), // Metin Renginde Daire Çizer.
              ),
            ),
        ],
      ),
    );
    if (onTap == null || mood == null) { // Dokunulamayan veya Kayıtsız Hücreyse Çalışır.
      return Semantics( // Hücreye Yalnızca Gün ve Ay Etiketi Verir.
        label: '${cell.day} $monthName', // Gün ve Ay Adından Etiket Oluşturur.
        child: ExcludeSemantics(child: box), // İç Semantikleri Gizleyerek Kutuyu Gösterir.
      );
    }
    final state = cell.isLocked ? AppStrings.lockedCapsule : (cell.isFresh ? AppStrings.freshCapsule : null); // Etiket İçin Kilitli / Yeni Durum Metnini Seçer.
    return Pressable( // Basma Ölçekli Dokunulabilir Hücre Oluşturur.
      onTap: onTap, // Dokunma Callback'ini Verir.
      scale: AppMotion.pressCell, // Hücre Basma Ölçeğini Verir.
      semanticLabel: AppStrings.dayCellLabel(cell.day, monthName, mood.label, state), // Gün, Ay, Duygu ve Durumdan Erişilebilirlik Etiketi Üretir.
      child: ExcludeSemantics(child: box), // İç Semantikleri Gizleyerek Kutuyu Gösterir.
    );
  }
}

/// Yıl görünümü: 12 ayın 3 × 4 mini ısı haritası kartı.
class YearHeatmap extends StatelessWidget { // 12 Mini Ay Kartını 3 Sütunlu Izgarada Gösteren StatelessWidget'tır.
  final List<MiniMonthModel> months; // Mini Ay Modelleri Listesidir.
  final ValueChanged<int> onMonthTap; // Bir Aya Dokunulunca Ay Numarasıyla Çağrılan Callback'tir.

  const YearHeatmap({super.key, required this.months, required this.onMonthTap}); // key'i Superclass'a İleten ve Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Yıl Izgarasının Widget Tree'sini Oluşturur.
    return Padding( // Izgaraya Yatay Kenar Boşluğu Verir.
      padding: const EdgeInsets.symmetric(horizontal: 20), // Yatayda 20 px Boşluk Bırakır.
      // CSS ızgarası gibi: aynı satırdaki kartlar en uzun kart kadar uzar.
      child: Column( // Satırları Dikey Dizer.
        children: [ // Sütun Çocuklarıdır.
          for (var row = 0; row < months.length / 3; row++) ...[ // Her Üçlü Satır İçin Döner.
            if (row > 0) const SizedBox(height: 10), // İlk Satır Dışında Araya Boşluk Koyar.
            IntrinsicHeight( // Satırdaki Kartları En Uzun Kart Kadar Uzatır.
              child: Row( // Üç Kartı Yatay Dizer.
                crossAxisAlignment: CrossAxisAlignment.stretch, // Kartları Dikeyde Genişletir.
                children: [ // Satır Çocuklarıdır.
                  for (var col = 0; col < 3; col++) ...[ // Satırdaki 3 Sütun İçin Döner.
                    if (col > 0) const SizedBox(width: 10), // İlk Sütun Dışında Araya Boşluk Koyar.
                    Expanded( // Kartı Eşit Genişliğe Yayar.
                      child: () { // Kartı Oluşturan Hemen Çağrılan Anonim Fonksiyondur.
                        final m = months[row * 3 + col]; // Satır ve Sütundan İlgili Ayı Seçer.
                        return MiniMonthCard(month: m, onTap: m.isFuture ? null : () => onMonthTap(m.month.month)); // Gelecek Değilse Dokunulabilir Mini Ay Kartı Döndürür.
                      }(), // Anonim Fonksiyonu Hemen Çağırır.
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MiniMonthCard extends StatelessWidget { // Yıl Görünümündeki Tek Mini Ay Kartını Gösteren StatelessWidget'tır.
  final MiniMonthModel month; // Mini Ay Modelidir.
  final VoidCallback? onTap; // Opsiyonel Dokunma Callback'idir.

  const MiniMonthCard({super.key, required this.month, this.onTap}); // key'i Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Mini Ay Kartının Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final name = AppStrings.months[month.month.month - 1]; // Ayın Tam Adını Alır.
    final card = Opacity( // Gelecek Ayları Soluk Gösterir.
      opacity: month.isFuture ? 0.55 : 1, // Gelecek Aysa Opaklığı Düşürür.
      child: Container( // Kart Kabını Oluşturur.
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 9), // Kart İç Boşluğunu Verir.
        decoration: BoxDecoration( // Kart Dekorasyonunu Tanımlar.
          color: p.surface, // Kart Yüzey Rengini Verir.
          border: Border.all(color: p.border), // Kart Kenarlığını Çizer.
          borderRadius: BorderRadius.circular(14), // Köşeleri 14 px Yuvarlatır.
        ),
        child: Column( // Başlık ve Mini Izgarayı Dikey Dizer.
          crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
          children: [ // Sütun Çocuklarıdır.
            Row( // Ay Adı ve Kayıt Sayısını Yatay Dizer.
              children: [ // Satır Çocuklarıdır.
                Expanded( // Ay Adını Kalan Genişliğe Yayar.
                  child: Text( // Kısa Ay Adını Gösterir.
                    AppStrings.monthShort(month.month.month), // Ayın Kısa Adını Alır.
                    style: AppTypography.body(12, weight: FontWeight.w600, height: 1.4, color: p.fg), // Kalın Küçük Metin Stili Verir.
                  ),
                ),
                Text(month.count == 0 ? '' : '${month.count}', style: AppTypography.mono(11, color: p.muted)), // Kayıt Varsa Sayısını Gösterir.
              ],
            ),
            const SizedBox(height: 6), // Başlık ile Izgara Arasında Boşluk Bırakır.
            _MiniGrid(leadingBlanks: month.leadingBlanks, days: month.days), // Ayın Mini Renk Izgarasını Gösterir.
          ],
        ),
      ),
    );
    return Pressable( // Kartı Dokunulabilir Yapar.
      onTap: onTap, // Dokunma Callback'ini Verir.
      semanticLabel: AppStrings.miniMonthLabel(name, month.month.year, month.count), // Ay, Yıl ve Kayıt Sayısından Erişilebilirlik Etiketi Üretir.
      child: ExcludeSemantics(child: card), // İç Semantikleri Gizleyerek Kartı Gösterir.
    );
  }
}

/// Mini ay ızgarası: 7 sütun, 2 px aralık, 3 px yarıçaplı hücreler.
class _MiniGrid extends StatelessWidget { // Mini Ayın Renk Hücrelerini Çizen StatelessWidget'tır.
  final int leadingBlanks; // Ay Başındaki Boş Hücre Sayısıdır.
  final List<Mood?> days; // Günlük Duygu Listesidir.

  const _MiniGrid({required this.leadingBlanks, required this.days}); // Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Mini Izgaranın Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final total = leadingBlanks + days.length; // Boşluklar Dahil Toplam Hücre Sayısını Hesaplar.
    final rows = (total / 7).ceil(); // Gereken Satır Sayısını Hesaplar.
    return Column( // Satırları Dikey Dizer.
      children: [ // Sütun Çocuklarıdır.
        for (var r = 0; r < rows; r++) ...[ // Her Satır İçin Döner.
          if (r > 0) const SizedBox(height: 2), // İlk Satır Dışında 2 px Boşluk Koyar.
          Row( // Satırdaki Hücreleri Yatay Dizer.
            children: [ // Satır Çocuklarıdır.
              for (var c = 0; c < 7; c++) ...[ // Satırdaki 7 Sütun İçin Döner.
                if (c > 0) const SizedBox(width: 2), // İlk Sütun Dışında 2 px Boşluk Koyar.
                Expanded( // Hücreyi Eşit Genişliğe Yayar.
                  child: AspectRatio( // Hücreyi Kare Tutar.
                    aspectRatio: 1, // En Boy Oranı 1'dir.
                    child: () { // Hücreyi Oluşturan Hemen Çağrılan Anonim Fonksiyondur.
                      final i = r * 7 + c - leadingBlanks; // Hücrenin Gün İndeksini Hesaplar.
                      if (i < 0 || i >= days.length) return const SizedBox.shrink(); // Ay Dışındaki Hücreleri Boş Bırakır.
                      final mood = days[i]; // O Günün Duygusunu Alır.
                      return DecoratedBox( // Gün Hücresini Çizer.
                        decoration: BoxDecoration( // Hücre Dekorasyonunu Tanımlar.
                          color: mood == null ? p.empty : p.mood(mood), // Kayıt Yoksa Boş, Varsa Duygu Rengini Kullanır.
                          borderRadius: BorderRadius.circular(3), // Köşeleri 3 px Yuvarlatır.
                        ),
                      );
                    }(), // Anonim Fonksiyonu Hemen Çağırır.
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Renk açıklaması: beş duygu + "Kayıt yok".
class MoodLegend extends StatelessWidget { // Duygu Renklerinin Açıklamasını Gösteren StatelessWidget'tır.
  const MoodLegend({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Renk Açıklamasının Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    return Padding( // Açıklamaya Kenar Boşluğu Verir.
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0), // Yan ve Üst Boşluğu Verir.
      child: Wrap( // Renk Örneklerini Satırlara Sararak Dizer.
        spacing: 14, // Yatay Aralıktır.
        runSpacing: 8, // Dikey Satır Aralığıdır.
        children: [ // Wrap Çocuklarıdır.
          for (final mood in Mood.values) LegendSwatch(color: p.mood(mood), label: mood.label), // Her Duygu İçin Renk Örneği ve Adını Gösterir.
          LegendSwatch(color: p.empty, label: AppStrings.noEntry, outlined: true), // Kayıt Yok Durumu İçin Çerçeveli Örnek Gösterir.
        ],
      ),
    );
  }
}
