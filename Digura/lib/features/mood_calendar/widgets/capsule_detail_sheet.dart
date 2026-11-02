import 'dart:math' as math; // max Fonksiyonu İçin dart:math Kütüphanesini math Adıyla import Eder.

import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.
import 'package:flutter/services.dart'; // HapticFeedback İçin Flutter Services'i import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'ını ve Renk Token'larını import Eder.
import '../../../core/constants/app_icons.dart'; // Uygulama İkon Tanımlarını (AppIcons) import Eder.
import '../../../core/constants/app_motion.dart'; // Süre ve Curve Token'larını (AppMotion) import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Görünen Metinleri (AppStrings) import Eder.
import '../../../core/theme/app_theme.dart'; // palette, reduceMotion ve AppTypography'yi import Eder.
import '../../../core/utils/clock.dart'; // Tarih Biçimleme İçin DateHelpers'ı import Eder.
import '../../../core/widgets/app_buttons.dart'; // AppIconButton Widget'ını import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.
import '../../../core/widgets/layout_parts.dart'; // RedactedLines, CapsuleLine ve CapsuleProgressBar'ı import Eder.
import '../models/mood_calendar_model.dart'; // CapsuleDetail, LockedCapsule ve OpenedCapsule Modellerini import Eder.
import 'circle_reveal.dart'; // Dairesel Açılış Clipper'ı CircleReveal'ı import Eder.

/// Kapsül Detay Modalı (ANIMATION.md 4.2): aşağıdan yukarı `sheet` (300 ms,
/// `drawer`), kapanış `ui` (200 ms, `easeOut`). Hareket azaltma açıkken
/// kayma yerine solma.
Future<void> showCapsuleDetailSheet(BuildContext context, CapsuleDetail detail) { // Kapsül Detayını Bottom Sheet Olarak Açan Fonksiyondur.
  final reduce = context.reduceMotion; // Hareket Azaltma Ayarını Okur.
  return showModalBottomSheet<void>( // Modal Bottom Sheet'i Gösterir.
    context: context, // Sheet'in Açılacağı context'i Verir.
    isScrollControlled: true, // Sheet Yüksekliğini İçeriğe Göre Serbest Bırakır.
    useSafeArea: false, // Safe Area'yı Sheet İçinde Elle Yönetir.
    backgroundColor: Colors.transparent, // Sheet Arka Planını Şeffaf Yapar.
    barrierColor: context.palette.scrim, // Arka Örtü Rengini Palette'ten Alır.
    barrierLabel: AppStrings.close, // Örtünün Erişilebilirlik Etiketini Verir.
    sheetAnimationStyle: reduce // Hareket Azaltmaya Göre Animasyon Stilini Seçer.
        ? AnimationStyle.noAnimation // Hareket Azaltma Açıksa Kayma Animasyonunu Kapatır.
        : const AnimationStyle( // Aksi Halde Özel Açılış / Kapanış Animasyonunu Tanımlar.
            duration: AppMotion.sheet, // Açılış Süresini Verir.
            reverseDuration: AppMotion.ui, // Kapanış Süresini Verir.
            curve: AppMotion.drawer, // Açılış Curve'ünü Verir.
            reverseCurve: AppMotion.easeOut, // Kapanış Curve'ünü Verir.
          ),
    builder: (_) => CapsuleDetailSheet(detail: detail), // Sheet İçeriği Olarak CapsuleDetailSheet'i Oluşturur.
  );
}

class CapsuleDetailSheet extends StatefulWidget { // Kapsül Detay Modalının İçeriğini Gösteren StatefulWidget'tır.
  final CapsuleDetail detail; // Gösterilecek Kapsül Detayıdır.

  const CapsuleDetailSheet({super.key, required this.detail}); // key'i Superclass'a İleten ve detail'i required Yapan const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<CapsuleDetailSheet> createState() => _CapsuleDetailSheetState(); // Widget'ın State Nesnesini Oluşturur.
}

class _CapsuleDetailSheetState extends State<CapsuleDetailSheet> with SingleTickerProviderStateMixin { // Açılış Animasyonu İçin Ticker Sağlayan State Class'ıdır.
  /// Açılış anı zaman çizelgesi: halka 640 ms, açılış 0–560 ms, not 320–620 ms.
  late final AnimationController _unseal = AnimationController(vsync: this, duration: AppMotion.unsealRing); // Tüm Açılış Animasyonunu Süren Ana AnimationController'dır.
  late final CurvedAnimation _reveal = CurvedAnimation( // Dairesel Panel Açılışının Animasyonudur.
    parent: _unseal, // Ana Controller'a Bağlanır.
    curve: Interval(0, _ratio(AppMotion.unsealReveal), curve: AppMotion.easeOut), // Zaman Çizelgesinin Başındaki Açılış Aralığını Kullanır.
  );
  late final CurvedAnimation _text = CurvedAnimation( // Not Metninin Belirme Animasyonudur.
    parent: _unseal, // Ana Controller'a Bağlanır.
    curve: Interval( // Metnin Gecikmeli Belirdiği Aralığı Tanımlar.
      _ratio(AppMotion.unsealTextDelay), // Aralığın Başlangıç Oranıdır.
      _ratio(AppMotion.unsealTextDelay + AppMotion.unsealText), // Aralığın Bitiş Oranıdır.
      curve: AppMotion.easeOut, // Aralık İçindeki Curve'ü Verir.
    ),
  );
  late final CurvedAnimation _ring = CurvedAnimation(parent: _unseal, curve: AppMotion.easeOut); // Renk Kutusu Etrafındaki Halka Animasyonudur.
  bool _hapticDone = false; // Titreşimin Daha Önce Verilip Verilmediğini Tutar.

  static double _ratio(Duration d) => d.inMicroseconds / AppMotion.unsealRing.inMicroseconds; // Bir Süreyi Toplam Animasyon Süresine Oranlar.

  bool get _firstUnseal => switch (widget.detail) { // İlk Açılış Animasyonunun Oynatılıp Oynatılmayacağını Döndürür.
    OpenedCapsule(:final firstUnseal) => firstUnseal, // Açılmış Kapsülde firstUnseal Değerini Kullanır.
    LockedCapsule() => false, // Kilitli Kapsülde Animasyon Oynatılmaz.
  };

  @override // Superclass'taki initState Metodunun Override Edildiğini Belirtir.
  void initState() { // State İlk Oluşturulduğunda Çağrılan Metottur.
    super.initState(); // Superclass'ın initState Metodunu Çağırır.
    if (_firstUnseal) { // İlk Açılışsa Çalışır.
      _reveal.addListener(_maybeHaptic); // Açılış Tamamlanınca Titreşim Vermek İçin Listener Ekler.
      _unseal.forward(); // Açılış Animasyonunu Başlatır.
    } else { // İlk Açılış Değilse Çalışır.
      _unseal.value = 1; // Animasyonu Doğrudan Bitmiş Duruma Getirir.
    }
  }

  /// `HapticFeedback.mediumImpact()` tam açılış anında bir kez.
  void _maybeHaptic() { // Açılış Tamamlandığında Bir Kez Titreşim Veren Metottur.
    if (_hapticDone || _reveal.value < 1) return; // Zaten Verildiyse veya Açılış Bitmediyse Çıkar.
    _hapticDone = true; // Titreşimin Verildiğini İşaretler.
    HapticFeedback.mediumImpact(); // Orta Şiddetli Haptic Titreşim Verir.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // Animasyon Kaynaklarını Serbest Bırakır.
    _reveal.dispose(); // _reveal CurvedAnimation'ını dispose Eder.
    _text.dispose(); // _text CurvedAnimation'ını dispose Eder.
    _ring.dispose(); // _ring CurvedAnimation'ını dispose Eder.
    _unseal.dispose(); // Ana AnimationController'ı dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Sheet'in Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final detail = widget.detail; // Gösterilecek Kapsül Detayını Alır.
    final reduce = context.reduceMotion; // Hareket Azaltma Ayarını Okur.
    final double bottom = 12 + math.max<double>(22, MediaQuery.viewPaddingOf(context).bottom); // Alt Boşluğu Cihazın Alt Padding'ine Göre Hesaplar.
    final sheet = Container( // Sheet'in Yüzey Kabını Oluşturur.
      decoration: BoxDecoration( // Yüzey Dekorasyonunu Tanımlar.
        color: p.surface, // Yüzey Rengini Verir.
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), // Üst Köşeleri Yuvarlatır.
      ),
      child: Stack( // İçerik ile Kapat Butonunu Üst Üste Dizer.
        children: [ // Stack Katmanlarıdır.
          Padding( // İçeriğe Kenar Boşluğu Verir.
            padding: EdgeInsets.fromLTRB(20, 10, 20, bottom), // Yan, Üst ve Hesaplanan Alt Boşluğu Verir.
            child: Column( // İçeriği Dikey Dizer.
              mainAxisSize: MainAxisSize.min, // Yüksekliği İçerik Kadar Tutar.
              crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
              children: [ // Sheet İçerik Parçalarıdır.
                Center( // Tutma Çubuğunu Ortalar.
                  child: Container( // Sheet'in Tutma Çubuğunu (Handle) Çizer.
                    width: 32, // Çubuk Genişliğidir.
                    height: 4, // Çubuk Yüksekliğidir.
                    margin: const EdgeInsets.only(top: 4, bottom: 14), // Çubuğun Üst ve Alt Boşluğudur.
                    decoration: ShapeDecoration(shape: const StadiumBorder(), color: p.muted.withValues(alpha: 0.5)), // Hap Şeklinde Yarı Saydam Çubuk Çizer.
                  ),
                ),
                _SheetHead(detail: detail, ring: _firstUnseal && !reduce ? _ring : null), // Renk Kutusu, Tarih ve Duygu Başlığını Gösterir.
                const SizedBox(height: 20), // Başlık ile Gövde Arasında Boşluk Bırakır.
                switch (detail) { // Kapsül Tipine Göre Gövdeyi Seçer.
                  LockedCapsule() => _LockedBody(detail: detail), // Kilitliyse Not İçermeyen Gövdeyi Gösterir.
                  OpenedCapsule() => _OpenedBody( // Açılmışsa Notlu Gövdeyi Gösterir.
                    detail: detail, // Açılmış Kapsül Detayını Verir.
                    reveal: detail.firstUnseal ? _reveal : null, // İlk Açılışsa Açılış Animasyonunu Verir.
                    text: detail.firstUnseal ? _text : null, // İlk Açılışsa Metin Animasyonunu Verir.
                  ),
                },
              ],
            ),
          ),
          Positioned( // Kapat Butonunu Sağ Üste Konumlandırır.
            top: 14, // Üstten Uzaklıktır.
            right: 12, // Sağdan Uzaklıktır.
            child: AppIconButton( // Kapat İkon Butonunu Oluşturur.
              icon: AppIcons.close, // Kapat İkonunu Verir.
              tooltip: AppStrings.close, // Butonun İpucu Metnini Verir.
              onPressed: () => Navigator.of(context).maybePop(), // Basılınca Sheet'i Kapatır.
            ),
          ),
        ],
      ),
    );
    final content = Semantics( // Sheet'i Erişilebilirlik İçin Ayrı Bir Route Olarak İşaretler.
      scopesRoute: true, // Yeni Bir Semantik Route Kapsamı Açar.
      namesRoute: true, // Route'a İsim Verildiğini Belirtir.
      explicitChildNodes: true, // Çocuk Semantik Düğümlerini Ayrı Tutar.
      label: AppStrings.capsuleDetail, // Route'un Erişilebilirlik Etiketini Verir.
      child: sheet, // Sheet Widget'ını Sarar.
    );
    if (!reduce) return content; // Hareket Azaltma Kapalıysa İçeriği Doğrudan Döndürür.
    return TweenAnimationBuilder<double>( // Hareket Azaltma Açıkken Solma Animasyonu Uygular.
      tween: Tween(begin: 0, end: 1), // Opaklığı 0'dan 1'e Taşır.
      duration: AppMotion.ui, // Solma Süresini Verir.
      curve: AppMotion.easeOut, // Solma Curve'ünü Verir.
      builder: (context, t, child) => Opacity(opacity: t, child: child), // Animasyon Değerini Opaklığa Uygular.
      child: content, // Solarak Görünecek İçeriği Verir.
    );
  }
}

class _SheetHead extends StatelessWidget { // Sheet'in Renk Kutusu ve Başlık Satırını Gösteren StatelessWidget'tır.
  final CapsuleDetail detail; // Başlıkta Gösterilecek Kapsül Detayıdır.
  final Animation<double>? ring; // Opsiyonel Halka Animasyonudur.

  const _SheetHead({required this.detail, required this.ring}); // detail ve ring Field'larını required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Başlık Satırının Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final color = p.mood(detail.mood); // Kapsülün Duygu Rengini Alır.
    return Row( // Renk Kutusu ve Metinleri Yatay Dizer.
      children: [ // Satır Çocuklarıdır.
        SizedBox.square( // 64 px Kare Alan Ayırır.
          dimension: 64, // Kare Kenar Uzunluğudur.
          child: Stack( // Renk Kutusu ile Halkayı Üst Üste Dizer.
            clipBehavior: Clip.none, // Büyüyen Halkanın Taşmasına İzin Verir.
            children: [ // Stack Katmanlarıdır.
              Positioned.fill( // Renk Kutusunu Tüm Alana Yayar.
                child: DecoratedBox( // Duygu Renginde Kutu Çizer.
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)), // Yuvarlak Köşeli Renk Dekorasyonudur.
                ),
              ),
              if (ring != null) // Halka Animasyonu Varsa Çalışır.
                Positioned.fill( // Halkayı Tüm Alana Yayar.
                  child: AnimatedBuilder( // Halka Animasyonunu Dinleyip Yeniden Çizer.
                    animation: ring!, // Dinlenecek Halka Animasyonudur.
                    builder: (context, _) { // Her Karede Halkayı Oluşturan Builder'dır.
                      final t = ring!.value; // Animasyonun Güncel Değerini Alır.
                      return Opacity( // Halkayı Giderek Soldurur.
                        opacity: (AppMotion.ringOpacityFrom * (1 - t)).clamp(0.0, 1.0), // Opaklığı Animasyonla Azaltır.
                        child: Transform.scale( // Halkayı Büyütür.
                          scale: 1 + (AppMotion.ringTo - 1) * t, // Ölçeği 1'den ringTo Değerine Taşır.
                          child: DecoratedBox( // Halkanın Kenarlığını Çizer.
                            decoration: BoxDecoration( // Halka Dekorasyonunu Tanımlar.
                              borderRadius: BorderRadius.circular(20), // Köşeleri Renk Kutusuyla Aynı Yuvarlatır.
                              border: Border.all(color: color, width: 3), // Duygu Renginde 3 px Kenarlık Çizer.
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16), // Renk Kutusu ile Metin Arasında Boşluk Bırakır.
        Expanded( // Metin Sütununu Kalan Genişliğe Yayar.
          child: Column( // Tarih ve Duygu Adını Dikey Dizer.
            crossAxisAlignment: CrossAxisAlignment.start, // Metinleri Sola Hizalar.
            children: [ // Sütun Çocuklarıdır.
              Text(DateHelpers.formatWithWeekday(detail.entryDate), style: AppTypography.mono(12, color: p.muted)), // Kayıt Tarihini Haftanın Günüyle Gösterir.
              const SizedBox(height: 4), // Tarih ile Duygu Adı Arasında Boşluk Bırakır.
              Text(detail.mood.label, style: AppTypography.display(22, height: 1.2, tracking: -0.015, color: p.fg)), // Duygu Adını Büyük Başlık Olarak Gösterir.
            ],
          ),
        ),
      ],
    );
  }
}

/// Kilitli kapsül: yalnızca sansür çubukları, kalan gün ve ilerleme.
/// Bu widget'a not metni hiçbir koşulda verilmez ([LockedCapsule] not taşımaz).
class _LockedBody extends StatelessWidget { // Kilitli Kapsül Gövdesini Not Olmadan Gösteren StatelessWidget'tır.
  final LockedCapsule detail; // Not Alanı Olmayan Kilitli Kapsül Detayıdır.

  const _LockedBody({required this.detail}); // detail Field'ını required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Kilitli Gövdenin Widget Tree'sini Oluşturur.
    return Column( // Gövde Parçalarını Dikey Dizer.
      crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
      children: [ // Gövde Parçalarıdır.
        const RedactedLines(widths: [0.92, 0.64]), // Not Yerine Sabit Genişlikli Sansür Çubukları Gösterir.
        const SizedBox(height: 14), // Dikey Boşluk Bırakır.
        CapsuleLine(title: AppStrings.capsuleRemaining(detail.remainingDays), unlockDate: detail.unlockDate), // Kalan Gün ve Açılış Tarihini Gösterir.
        const SizedBox(height: 10), // Dikey Boşluk Bırakır.
        CapsuleProgressBar(value: detail.progress), // Kilit İlerleme Çubuğunu Gösterir.
      ],
    );
  }
}

class _OpenedBody extends StatelessWidget { // Açılmış Kapsülün Notunu Gösteren StatelessWidget'tır.
  final OpenedCapsule detail; // Açılmış Kapsül Detayıdır.
  final Animation<double>? reveal; // Opsiyonel Panel Açılış Animasyonudur.
  final Animation<double>? text; // Opsiyonel Metin Belirme Animasyonudur.

  const _OpenedBody({required this.detail, required this.reveal, required this.text}); // Tüm Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Açılmış Gövdenin Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final unsealing = reveal != null && text != null; // İlk Açılış Animasyonunun Oynayıp Oynamadığını Hesaplar.
    final quoteColor = unsealing ? p.onMood(detail.mood) : null; // Açılış Panelindeyse Duygu Üstü Metin Rengini Seçer.
    final quote = Semantics( // Not Metnini Semantik Olarak Sarar.
      liveRegion: unsealing, // Açılış Sırasında Ekran Okuyucuya Duyurulmasını Sağlar.
      child: detail.note.isEmpty // Notun Boş Olup Olmadığını Kontrol Eder.
          ? Text(AppStrings.emptyCapsuleNote, style: AppTypography.body(15, height: 1.4, color: quoteColor ?? p.muted)) // Not Boşsa Boş Not Mesajını Gösterir.
          : Text( // Not Varsa Alıntı Olarak Gösterir.
              AppStrings.quoted(detail.note), // Notu Tırnak İçine Alır.
              style: AppTypography.display( // Alıntı Metin Stilini Tanımlar.
                21, // Font Boyutudur.
                weight: FontWeight.w400, // Normal Kalınlık Verir.
                height: 1.35, // Satır Yüksekliğini Verir.
                tracking: -0.01, // Harf Aralığını Verir.
                color: quoteColor ?? p.fg, // Metin Rengini Verir.
              ),
            ),
    );
    return Column( // Gövde Parçalarını Dikey Dizer.
      crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
      children: [ // Gövde Parçalarıdır.
        Row( // Kilit Açık İkonu ve Açılış Tarihini Yatay Dizer.
          children: [ // Satır Çocuklarıdır.
            AppIcon(AppIcons.unlock, color: p.muted), // Açık Kilit İkonunu Gösterir.
            const SizedBox(width: 6), // İkon ile Metin Arasında Boşluk Bırakır.
            Expanded( // Metni Kalan Genişliğe Yayar.
              child: Text( // Açılış Tarihi Metnini Gösterir.
                AppStrings.capsuleOpened(DateHelpers.formatLong(detail.unlockDate)), // Kapsülün Açıldığı Tarihi Metne Dönüştürür.
                style: AppTypography.mono(12, color: p.muted), // Mono, Soluk Metin Stili Verir.
              ),
            ),
          ],
        ),
        const SizedBox(height: 10), // Dikey Boşluk Bırakır.
        if (!unsealing) quote else _RevealPanel(mood: detail.mood, reveal: reveal!, text: text!, child: quote), // Açılış Yoksa Notu Düz, Varsa Dairesel Açılan Panelde Gösterir.
      ],
    );
  }
}

/// Duygu renginde, renk kutusundan dairesel açılan not paneli.
class _RevealPanel extends StatelessWidget { // Notu Dairesel Açılış Animasyonuyla Gösteren StatelessWidget'tır.
  final Mood mood; // Panel Renginin Alınacağı Duygudur.
  final Animation<double> reveal; // Panel Açılış Animasyonudur.
  final Animation<double> text; // Metin Belirme Animasyonudur.
  final Widget child; // Panel İçinde Gösterilecek Not Widget'ıdır.

  /// Panel köşesine göre renk kutusunun merkezi (`circle(… at 32px -56px)`).
  static const Offset _origin = Offset(32, -56); // Dairesel Açılışın Merkez Noktasıdır.

  const _RevealPanel({required this.mood, required this.reveal, required this.text, required this.child}); // Tüm Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Açılış Panelinin Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    final panel = Container( // Duygu Renginde Panel Kabını Oluşturur.
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), // Panel İç Boşluğunu Verir.
      decoration: BoxDecoration(color: p.mood(mood), borderRadius: BorderRadius.circular(20)), // Duygu Renginde Yuvarlak Köşeli Zemin Çizer.
      child: FadeTransition(opacity: text, child: child), // Not Metnini Animasyonla Belirginleştirir.
    );
    if (context.reduceMotion) return FadeTransition(opacity: reveal, child: panel); // Hareket Azaltma Açıksa Paneli Yalnızca Soldurarak Gösterir.
    return ClipPath(clipper: CircleReveal(reveal, _origin), child: panel); // Paneli Dairesel Kırpmayla Açar.
  }
}
