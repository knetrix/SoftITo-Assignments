import 'dart:math' as math; // Trigonometri İçin dart:math Kütüphanesini math Önekiyle import Eder.

import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood Enum'unu, palette Extension'ını Ve cssShadow'u import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons Ve AppIconData Simge Tanımlarını import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre/Eğri Sabitlerini Ve reduceMotion'ı import Eder.
import '../../../core/constants/app_strings.dart'; // AppStrings Metin Sabitlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_icon.dart'; // AppIcon Widget'ını import Eder.
import '../../../core/widgets/layout_parts.dart'; // RedactedLines Widget'ını import Eder.
import '../../../core/widgets/pressable.dart'; // Pressable Basılabilir Widget'ını import Eder.

/// Adım 1: beş duygu rengi çemberi (300 px) ve merkezde seçili duygu.
class MoodPaletteHero extends StatelessWidget { // Duygu Renk Çemberini Çizen StatelessWidget'tır.
  final Mood selected; // Seçili Duygudur.
  final ValueChanged<Mood> onSelect; // Bir Duygu Seçildiğinde Çağrılan Callback'tir.

  static const double _size = 300; // Çemberin Toplam Boyutudur.
  static const double _orbit = 122; // Düğmelerin Merkeze Uzaklığıdır.
  static const double _button = 56; // Renk Düğmesinin Çapıdır.
  static const double _coreInset = 82; // Merkez Dairenin Kenarlardan İç Boşluğudur.

  const MoodPaletteHero({super.key, required this.selected, required this.onSelect}); // key'i Superclass'a İleten Ve Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Renk Çemberinin Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final reduce = context.reduceMotion; // Azaltılmış Hareket Tercihini Alır.
    return Semantics( // Çembere Erişilebilirlik Etiketi Ekler.
      label: AppStrings.onboardingPalette, // Çemberin Erişilebilirlik Etiketidir.
      container: true, // Çemberi Ayrı Bir Semantics Düğümü Yapar.
      child: SizedBox.square( // Kare Bir Alan Ayırır.
        dimension: _size, // Kare Alanın Kenar Uzunluğudur.
        child: Stack( // Merkez Ve Düğmeleri Üst Üste Konumlar.
          children: [ // Stack'in Çocuk Widget'larıdır.
            Positioned.fill( // Merkez Daireyi İç Boşluklarla Yerleştirir.
              left: _coreInset, // Soldan İç Boşluktur.
              top: _coreInset, // Üstten İç Boşluktur.
              right: _coreInset, // Sağdan İç Boşluktur.
              bottom: _coreInset, // Alttan İç Boşluktur.
              child: _PaletteCore(mood: selected), // Seçili Duyguyu Gösteren Merkez Daireyi Çizer.
            ),
            for (var i = 0; i < Mood.values.length; i++) // Her Duygu İçin Bir Düğme Üretir.
              () { // Düğmeyi Oluşturan Anında Çağrılan Fonksiyondur.
                final mood = Mood.values[i]; // Sıradaki Duyguyu Alır.
                final angle = (-90 + i * 72) * math.pi / 180; // Üstten Başlayarak 72 Derece Aralıklı Açıyı Radyana Çevirir.
                final isOn = mood == selected; // Bu Duygunun Seçili Olup Olmadığını Belirler.
                return Positioned( // Düğmeyi Çember Üzerinde Konumlar.
                  left: _size / 2 + math.cos(angle) * _orbit - _button / 2, // Açıya Göre Yatay Konumu Hesaplar.
                  top: _size / 2 + math.sin(angle) * _orbit - _button / 2, // Açıya Göre Dikey Konumu Hesaplar.
                  child: Semantics( // Düğmeye Seçili Durumu Bildirir.
                    selected: isOn, // Seçili İse Semantics'e Bildirir.
                    child: Pressable( // Dokunulabilir Düğme Oluşturur.
                      onTap: () => onSelect(mood), // Dokununca Duyguyu Seçer.
                      scale: 1, // Pressable'ın Kendi Ölçeklemesini Kapatır.
                      semanticLabel: mood.label, // Düğmenin Erişilebilirlik Etiketidir.
                      builder: (context, pressed) => AnimatedScale( // Basılıyken Düğmeyi Ölçekler.
                        scale: pressed && !reduce ? AppMotion.pressPalette : 1, // Basılıysa Ve Hareket Azaltılmadıysa Küçültür.
                        duration: AppMotion.press, // Ölçekleme Süresidir.
                        curve: AppMotion.easeOut, // Ölçekleme Eğrisidir.
                        child: AnimatedContainer( // Seçim Halkasını Animasyonla Değiştirir.
                          duration: AppMotion.press, // Geçiş Süresidir.
                          curve: AppMotion.easeOut, // Geçiş Eğrisidir.
                          width: _button, // Düğme Genişliğidir.
                          height: _button, // Düğme Yüksekliğidir.
                          decoration: BoxDecoration( // Düğmenin Görünümünü Tanımlar.
                            shape: BoxShape.circle, // Düğmeyi Daire Yapar.
                            color: p.mood(mood), // Duygunun Rengini Uygular.
                            boxShadow: [ // Seçim Halkasını Gölgelerle Çizer.
                              BoxShadow(color: p.fg, spreadRadius: isOn ? 5 : 0), // Seçiliyse Dış Koyu Halkayı Çizer.
                              BoxShadow(color: p.surface, spreadRadius: isOn ? 3 : 0), // Seçiliyse İç Boşluk Halkasını Çizer.
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }(), // Fonksiyonu Hemen Çağırıp Widget'ı Listeye Ekler.
          ],
        ),
      ),
    );
  }
}

class _PaletteCore extends StatefulWidget { // Seçili Duyguyu Gösteren Merkez Daire StatefulWidget'ıdır.
  final Mood mood; // Gösterilecek Duygudur.

  const _PaletteCore({required this.mood}); // mood Field'ını required Yapan const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<_PaletteCore> createState() => _PaletteCoreState(); // Widget'ın State Nesnesini Oluşturur.
}

class _PaletteCoreState extends State<_PaletteCore> with SingleTickerProviderStateMixin { // Merkez Dairenin Pop Animasyonunu Yöneten State'tir.
  late final AnimationController _pop = AnimationController(vsync: this, duration: AppMotion.settle, value: 1); // Tamamlanmış Halde Başlayan Pop Animasyonu Controller'ıdır.

  @override // Superclass'taki didUpdateWidget Metodunun Override Edildiğini Belirtir.
  void didUpdateWidget(_PaletteCore oldWidget) { // Widget Güncellendiğinde Çağrılır.
    super.didUpdateWidget(oldWidget); // Superclass'ın didUpdateWidget Metodunu Çağırır.
    if (oldWidget.mood != widget.mood) _pop.forward(from: 0); // Duygu Değiştiyse Pop Animasyonunu Baştan Oynatır.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _pop.dispose(); // AnimationController'ı Serbest Bırakır.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Merkez Dairenin Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final color = p.mood(widget.mood); // Seçili Duygunun Rengini Alır.
    final reduce = context.reduceMotion; // Azaltılmış Hareket Tercihini Alır.
    final core = AnimatedContainer( // Renk Değişimini Animasyonla Yapan Daireyi Oluşturur.
      duration: AppMotion.settle, // Renk Geçiş Süresidir.
      curve: AppMotion.easeOut, // Renk Geçiş Eğrisidir.
      decoration: BoxDecoration( // Dairenin Görünümünü Tanımlar.
        shape: BoxShape.circle, // Şekli Daire Yapar.
        color: color, // Duygu Rengini Uygular.
        boxShadow: [cssShadow(color: color, y: 24, blur: 50, spread: -20)], // Duygu Renginde Yumuşak Gölge Ekler.
      ),
      alignment: Alignment.center, // İçeriği Ortalar.
      padding: const EdgeInsets.symmetric(horizontal: 8), // Yatay İç Boşluk Verir.
      child: Semantics( // Duygu Etiketini Erişilebilirliğe Bildirir.
        liveRegion: true, // Değişiklikleri Ekran Okuyucuya Duyurur.
        child: AnimatedSwitcher( // Etiket Değişiminde Çapraz Geçiş Yapar.
          duration: AppMotion.ui, // Geçiş Süresidir.
          child: Text( // Duygu Adını Gösterir.
            widget.mood.label, // Seçili Duygunun Etiketidir.
            key: ValueKey(widget.mood), // AnimatedSwitcher'ın Değişimi Algılaması İçin key Verir.
            textAlign: TextAlign.center, // Metni Ortalar.
            style: AppTypography.display(18, height: 1.3, color: p.onMood(widget.mood)), // Duygu Rengi Üzerinde Okunur Display Stilini Uygular.
          ),
        ),
      ),
    );
    return AnimatedBuilder( // Pop Animasyonuna Göre Yeniden Çizer.
      animation: _pop, // Pop AnimationController'ını Dinler.
      child: core, // Yeniden Oluşturulmayan Merkez Dairedir.
      builder: (context, child) { // Animasyon Değerine Göre Dönüşüm Uygulayan Builder'dır.
        final t = AppMotion.easeOut.transform(_pop.value); // Animasyon Değerine easeOut Eğrisi Uygular.
        if (reduce) { // Hareket Azaltıldıysa Bloğu Çalıştırır.
          return Opacity(opacity: 0.6 + 0.4 * t, child: child); // Ölçek Yerine Opaklıkla Geçiş Yapar.
        }
        return Transform.scale(scale: AppMotion.orbFrom + (1 - AppMotion.orbFrom) * t, child: child); // Daireyi orbFrom'dan 1'e Ölçekler.
      },
    );
  }
}

/// Adım 2: kilitli kapsül kartı önizlemesi. Sayfa görününce ilerleme
/// çubuğu %60'a dolar (`intro`, 180 ms gecikme).
class CapsulePreviewHero extends StatefulWidget { // Kilitli Kapsül Kartı Önizlemesini Gösteren StatefulWidget'tır.
  final bool active; // Sayfanın Etkin Olup Olmadığını Belirtir.

  const CapsulePreviewHero({super.key, required this.active}); // key'i Superclass'a İleten Ve active'i required Yapan const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<CapsulePreviewHero> createState() => _CapsulePreviewHeroState(); // Widget'ın State Nesnesini Oluşturur.
}

class _CapsulePreviewHeroState extends State<CapsulePreviewHero> with SingleTickerProviderStateMixin { // İlerleme Çubuğu Animasyonunu Yöneten State'tir.
  static const double _fill = 0.6; // İlerleme Çubuğunun Doluluk Oranıdır.

  late final AnimationController _bar = AnimationController( // İlerleme Çubuğu AnimationController'ını Oluşturur.
    vsync: this, // Ticker Sağlayıcı Olarak Bu State'i Kullanır.
    duration: AppMotion.capsuleBarDelay + AppMotion.intro, // Gecikme Dahil Toplam Süreyi Belirler.
  );
  late final CurvedAnimation _curve = CurvedAnimation( // Gecikmeli Ve Eğrili Animasyonu Oluşturur.
    parent: _bar, // Temel AnimationController'dır.
    curve: Interval( // Animasyonu Gecikmeden Sonra Başlatan Aralıktır.
      AppMotion.capsuleBarDelay.inMicroseconds / (AppMotion.capsuleBarDelay + AppMotion.intro).inMicroseconds, // Gecikmenin Toplam Süreye Oranını Başlangıç Yapar.
      1, // Aralığın Bitişidir.
      curve: AppMotion.easeOut, // Aralık İçindeki Eğridir.
    ),
  );

  @override // Superclass'taki initState Metodunun Override Edildiğini Belirtir.
  void initState() { // State İlk Oluşturulduğunda Çağrılır.
    super.initState(); // Superclass'ın initState Metodunu Çağırır.
    if (widget.active) _bar.forward(); // Sayfa Etkinse Çubuk Animasyonunu Başlatır.
  }

  @override // Superclass'taki didUpdateWidget Metodunun Override Edildiğini Belirtir.
  void didUpdateWidget(CapsulePreviewHero oldWidget) { // Widget Güncellendiğinde Çağrılır.
    super.didUpdateWidget(oldWidget); // Superclass'ın didUpdateWidget Metodunu Çağırır.
    if (widget.active && !oldWidget.active) _bar.forward(from: 0); // Sayfa Etkinleştiyse Animasyonu Baştan Oynatır.
    if (!widget.active && oldWidget.active) _bar.value = 0; // Sayfa Pasifleştiyse Çubuğu Sıfırlar.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _curve.dispose(); // CurvedAnimation'ı Serbest Bırakır.
    _bar.dispose(); // AnimationController'ı Serbest Bırakır.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Kapsül Önizlemesinin Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final reduce = context.reduceMotion; // Azaltılmış Hareket Tercihini Alır.
    final mono11 = AppTypography.mono(11, color: p.muted); // Zaman Çizelgesi Etiketleri İçin Mono Stilini Hazırlar.
    final front = Container( // Öndeki Kapsül Kartını Oluşturur.
      padding: const EdgeInsets.all(16), // Kartın İç Boşluğudur.
      decoration: BoxDecoration( // Kartın Görünümünü Tanımlar.
        color: p.surface, // Kart Arka Plan Rengidir.
        border: Border.all(color: p.border), // Kart Kenarlığını Çizer.
        borderRadius: BorderRadius.circular(24), // Köşeleri Yuvarlar.
        boxShadow: p.raised, // Kabarık Gölgeyi Uygular.
      ),
      child: Column( // Kart İçeriğini Dikey Dizer.
        mainAxisSize: MainAxisSize.min, // Yüksekliği İçerik Kadar Tutar.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
        children: [ // Column'un Çocuk Widget'larıdır.
          Row( // Renk Kutusu Ve Başlıkları Yatay Dizer.
            children: [ // Row'un Çocuk Widget'larıdır.
              Container( // Duygu Rengi Kutusunu Oluşturur.
                width: 44, // Kutu Genişliğidir.
                height: 44, // Kutu Yüksekliğidir.
                decoration: BoxDecoration(color: p.mood(Mood.calmSad), borderRadius: BorderRadius.circular(12)), // calmSad Rengiyle Yuvarlak Köşeli Kutu Çizer.
              ),
              const SizedBox(width: 12), // Kutu İle Metin Arasına Boşluk Koyar.
              Expanded( // Metinlerin Kalan Genişliği Doldurmasını Sağlar.
                child: Column( // Duygu Adı Ve Tarihi Dikey Dizer.
                  crossAxisAlignment: CrossAxisAlignment.start, // Metinleri Sola Hizalar.
                  children: [ // Column'un Çocuk Widget'larıdır.
                    Text(Mood.calmSad.label, style: AppTypography.display(18, color: p.fg)), // Örnek Duygu Adını Gösterir.
                    Text(AppStrings.capsuleSampleDate, style: AppTypography.mono(12, color: p.muted)), // Örnek Tarihi Gösterir.
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Dikey Boşluk Koyar.
          const RedactedLines(widths: [0.94, 0.58]), // Kilitli Notu Temsil Eden Gizli Çizgileri Çizer.
          const SizedBox(height: 16), // Dikey Boşluk Koyar.
          Container( // Kilit Bilgisi Kutusunu Oluşturur.
            padding: const EdgeInsets.all(12), // Kutunun İç Boşluğudur.
            decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(12)), // Arka Plan Rengi Ve Yuvarlak Köşe Verir.
            child: Row( // Kilit Simgesi Ve Metinleri Yatay Dizer.
              children: [ // Row'un Çocuk Widget'larıdır.
                AppIcon(AppIcons.lock, color: p.fg), // Kilit Simgesini Çizer.
                const SizedBox(width: 12), // Simge İle Metin Arasına Boşluk Koyar.
                Expanded( // Metinlerin Kalan Genişliği Doldurmasını Sağlar.
                  child: Column( // Kalan Süre Ve Alt Metni Dikey Dizer.
                    crossAxisAlignment: CrossAxisAlignment.start, // Metinleri Sola Hizalar.
                    children: [ // Column'un Çocuk Widget'larıdır.
                      Text( // Kalan Gün Metnini Gösterir.
                        AppStrings.capsuleRemaining(12), // 12 Gün Kaldı Metnini Üretir.
                        style: AppTypography.body(14, weight: FontWeight.w500, color: p.fg), // Orta Kalınlıkta Gövde Stilini Uygular.
                      ),
                      Text(AppStrings.capsuleSampleSub, style: AppTypography.body(12, color: p.muted)), // Örnek Alt Açıklamayı Gösterir.
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12), // Dikey Boşluk Koyar.
          ClipRRect( // İlerleme Çubuğunu Yuvarlak Kırpar.
            borderRadius: BorderRadius.circular(999), // Hap Şeklinde Köşe Yuvarlatır.
            child: Container( // Çubuğun Boş Arka Planını Oluşturur.
              height: 6, // Çubuk Yüksekliğidir.
              color: p.empty, // Boş Çubuk Rengidir.
              alignment: Alignment.centerLeft, // Dolu Kısmı Sola Hizalar.
              child: FractionallySizedBox( // Dolu Kısmı Oransal Genişlikte Yapar.
                widthFactor: _fill, // Genişliği %60 Yapar.
                heightFactor: 1, // Yüksekliği Tam Yapar.
                child: AnimatedBuilder( // Çubuk Animasyonuna Göre Yeniden Çizer.
                  animation: _curve, // Eğrili Animasyonu Dinler.
                  builder: (context, child) => // Yatay Ölçeklemeyi Uygulayan Builder'dır.
                      Transform.scale(alignment: Alignment.centerLeft, scaleX: reduce ? 1 : _curve.value, child: child), // Soldan Başlayarak Çubuğu Doldurur.
                  child: DecoratedBox( // Dolu Çubuk Parçasını Çizer.
                    decoration: BoxDecoration(color: p.fg, borderRadius: BorderRadius.circular(999)), // Koyu Renk Ve Hap Köşe Verir.
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6), // Dikey Boşluk Koyar.
          Row( // Zaman Çizelgesi Etiketlerini Yatay Dizer.
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Etiketleri Eşit Aralıkla Yayar.
            children: [ // Row'un Çocuk Widget'larıdır.
              Text(AppStrings.timelineStart, style: mono11), // Başlangıç Etiketini Gösterir.
              Text(AppStrings.timelineMid, style: mono11), // Orta Etiketini Gösterir.
              Text(AppStrings.timelineEnd, style: mono11), // Bitiş Etiketini Gösterir.
            ],
          ),
        ],
      ),
    );
    return Stack( // Arka Kart Ve Ön Kartı Üst Üste Koyar.
      clipBehavior: Clip.none, // Taşan İçeriği Kırpmaz.
      children: [ // Stack'in Çocuk Widget'larıdır.
        Positioned( // Arka Kartı Konumlar.
          left: 16, // Soldan 16 Birim İçeride Başlar.
          right: 16, // Sağdan 16 Birim İçeride Biter.
          top: 0, // En Üste Yerleşir.
          height: 80, // Arka Kartın Yüksekliğidir.
          child: ExcludeSemantics( // Dekoratif Kartı Erişilebilirlikten Çıkarır.
            child: Opacity( // Arka Kartı Yarı Saydam Yapar.
              opacity: 0.55, // Opaklık Değeridir.
              child: Transform.translate( // Arka Kartı Aşağı Öteler.
                offset: const Offset(0, 10), // 10 Birim Aşağı Kaydırır.
                child: Transform.rotate( // Arka Kartı Hafifçe Döndürür.
                  angle: -3 * math.pi / 180, // -3 Dereceyi Radyana Çevirir.
                  child: Container( // Arka Kart Kutusunu Çizer.
                    decoration: BoxDecoration( // Arka Kartın Görünümünü Tanımlar.
                      color: p.borderSoft, // Arka Kart Rengidir.
                      border: Border.all(color: p.border), // Kenarlık Çizer.
                      borderRadius: BorderRadius.circular(24), // Köşeleri Yuvarlar.
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // `.cap-card.back { margin-bottom: -60px }` + 12 px ızgara boşluğu.
        Padding( // Ön Kartı Arka Kartın Altına Kaydırır.
          padding: const EdgeInsets.only(top: 80 + 12 - 60), // Arka Kartla Örtüşecek Üst Boşluğu Verir.
          child: front, // Öndeki Kapsül Kartıdır.
        ),
      ],
    );
  }
}

/// Adım 3: örnek ay ısı haritası kartı.
class HeatmapPreviewHero extends StatelessWidget { // Örnek Ay Isı Haritasını Çizen StatelessWidget'tır.
  /// Prototipteki örnek ay deseni (35 hücre; ilk 2 ve son 3 boş).
  static const String _pattern = 'x x j s c j s t s j a x s j j c t s s j x s t a j s c j s j x x x x x'; // Hücre Harflerinden Oluşan Örnek Desendir.
  static const Map<String, Mood> _key = { // Desen Harflerini Duygulara Eşleyen Map'tir.
    'j': Mood.joyful, // j Harfini joyful Duygusuna Eşler.
    'c': Mood.calmSad, // c Harfini calmSad Duygusuna Eşler.
    'a': Mood.angryStressed, // a Harfini angryStressed Duygusuna Eşler.
    's': Mood.serene, // s Harfini serene Duygusuna Eşler.
    't': Mood.tired, // t Harfini tired Duygusuna Eşler.
  };

  const HeatmapPreviewHero({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Isı Haritası Kartının Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final cells = _pattern.split(' '); // Deseni Hücre Listesine Böler.
    return Container( // Kart Kapsayıcısını Oluşturur.
      padding: const EdgeInsets.all(16), // Kartın İç Boşluğudur.
      decoration: BoxDecoration( // Kartın Görünümünü Tanımlar.
        color: p.surface, // Kart Arka Plan Rengidir.
        border: Border.all(color: p.border), // Kenarlık Çizer.
        borderRadius: BorderRadius.circular(24), // Köşeleri Yuvarlar.
      ),
      child: Column( // Başlık Ve Izgarayı Dikey Dizer.
        mainAxisSize: MainAxisSize.min, // Yüksekliği İçerik Kadar Tutar.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
        children: [ // Column'un Çocuk Widget'larıdır.
          Row( // Başlık Ve Alt Başlığı Yatay Dizer.
            crossAxisAlignment: CrossAxisAlignment.baseline, // Metinleri Taban Çizgisine Hizalar.
            textBaseline: TextBaseline.alphabetic, // Alfabetik Taban Çizgisini Kullanır.
            children: [ // Row'un Çocuk Widget'larıdır.
              Expanded( // Başlığın Kalan Genişliği Doldurmasını Sağlar.
                child: Text(AppStrings.mapPreviewTitle, style: AppTypography.display(16, color: p.fg)), // Harita Başlığını Gösterir.
              ),
              Text(AppStrings.mapPreviewSub, style: AppTypography.mono(11, color: p.muted)), // Harita Alt Başlığını Gösterir.
            ],
          ),
          const SizedBox(height: 12), // Dikey Boşluk Koyar.
          ExcludeSemantics( // Dekoratif Izgarayı Erişilebilirlikten Çıkarır.
            child: Column( // Izgara Satırlarını Dikey Dizer.
              children: [ // Column'un Çocuk Widget'larıdır.
                for (var row = 0; row < 5; row++) ...[ // 5 Satır Üretir.
                  if (row > 0) const SizedBox(height: 5), // İlk Satır Dışında Üste Boşluk Koyar.
                  Row( // Bir Haftalık Hücreleri Yatay Dizer.
                    children: [ // Row'un Çocuk Widget'larıdır.
                      for (var col = 0; col < 7; col++) ...[ // 7 Sütun Üretir.
                        if (col > 0) const SizedBox(width: 5), // İlk Sütun Dışında Sola Boşluk Koyar.
                        Expanded( // Hücrelerin Genişliği Eşit Paylaşmasını Sağlar.
                          child: AspectRatio( // Hücreyi Kare Tutar.
                            aspectRatio: 1, // En-Boy Oranını 1 Yapar.
                            child: () { // Hücreyi Oluşturan Anında Çağrılan Fonksiyondur.
                              final i = row * 7 + col; // Hücrenin Düz İndeksini Hesaplar.
                              final blank = i < 2 || i > 31; // Ay Dışı Boş Hücreleri Belirler.
                              final mood = _key[cells[i]]; // Hücre Harfinden Duyguyu Bulur.
                              return DecoratedBox( // Hücre Kutusunu Çizer.
                                decoration: BoxDecoration( // Hücrenin Görünümünü Tanımlar.
                                  color: blank ? Colors.transparent : (mood == null ? p.empty : p.mood(mood)), // Boşsa Saydam, Duygu Yoksa Boş Renk, Varsa Duygu Rengi Verir.
                                  borderRadius: BorderRadius.circular(7), // Hücre Köşelerini Yuvarlar.
                                ),
                              );
                            }(), // Fonksiyonu Hemen Çağırıp Hücreyi Üretir.
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gizlilik kartı: "Hesap yok, internet yok" + 21:00 hatırlatıcı anahtarı.
class PrivacyCard extends StatelessWidget { // Gizlilik Ve Hatırlatıcı Kartını Çizen StatelessWidget'tır.
  final bool reminder; // Hatırlatıcının Açık Olup Olmadığını Belirtir.
  final ValueChanged<bool> onReminderChanged; // Hatırlatıcı Anahtarı Değişince Çağrılan Callback'tir.

  const PrivacyCard({super.key, required this.reminder, required this.onReminderChanged}); // key'i Superclass'a İleten Ve Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Gizlilik Kartının Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    Widget row(AppIconData icon, String title, String sub, {Widget? trailing}) => Container( // Simge, Başlık, Alt Metin Ve İsteğe Bağlı Sağ Öğeli Satır Üreten Yardımcı Fonksiyondur.
      constraints: const BoxConstraints(minHeight: 56), // En Az 56 Birim Yükseklik Verir.
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Yatay Ve Dikey İç Boşluk Verir.
      child: Row( // Satır Öğelerini Yatay Dizer.
        children: [ // Row'un Çocuk Widget'larıdır.
          AppIcon(icon, color: p.fg2), // Satır Simgesini Çizer.
          const SizedBox(width: 12), // Simge İle Metin Arasına Boşluk Koyar.
          Expanded( // Metinlerin Kalan Genişliği Doldurmasını Sağlar.
            child: Column( // Başlık Ve Alt Metni Dikey Dizer.
              crossAxisAlignment: CrossAxisAlignment.start, // Metinleri Sola Hizalar.
              children: [ // Column'un Çocuk Widget'larıdır.
                Text(title, style: AppTypography.body(14, height: 1.35, color: p.fg)), // Satır Başlığını Gösterir.
                Text(sub, style: AppTypography.body(12, height: 1.35, color: p.muted)), // Satır Alt Metnini Gösterir.
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing], // trailing Varsa Boşlukla Birlikte Sağa Ekler.
        ],
      ),
    );
    return Container( // Kart Kapsayıcısını Oluşturur.
      decoration: BoxDecoration( // Kartın Görünümünü Tanımlar.
        color: p.surface, // Kart Arka Plan Rengidir.
        border: Border.all(color: p.border), // Kenarlık Çizer.
        borderRadius: BorderRadius.circular(24), // Köşeleri Yuvarlar.
      ),
      clipBehavior: Clip.antiAlias, // İçeriği Yuvarlak Köşelere Göre Kırpar.
      child: Column( // Satırları Dikey Dizer.
        children: [ // Column'un Çocuk Widget'larıdır.
          row(AppIcons.shield, AppStrings.privacyTitle, AppStrings.privacySub), // Kalkan Simgeli Gizlilik Satırını Gösterir.
          Container(height: 1, color: p.borderSoft), // Satırlar Arasına İnce Ayırıcı Çizer.
          MergeSemantics( // Hatırlatıcı Satırını Tek Semantics Düğümünde Birleştirir.
            child: row( // Hatırlatıcı Satırını Oluşturur.
              AppIcons.bell, // Zil Simgesidir.
              AppStrings.reminderOnboarding, // Hatırlatıcı Başlığıdır.
              reminder ? AppStrings.reminderPermission : AppStrings.reminderOptional, // Duruma Göre İzin Ya Da İsteğe Bağlı Metnini Seçer.
              trailing: Switch(value: reminder, onChanged: onReminderChanged), // Hatırlatıcıyı Açıp Kapatan Switch'i Ekler.
            ),
          ),
        ],
      ),
    );
  }
}
