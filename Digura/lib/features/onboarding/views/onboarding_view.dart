import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // AppPalette Ve palette Extension'ını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons Simge Sabitlerini import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre/Eğri Sabitlerini Ve reduceMotion'ı import Eder.
import '../../../core/constants/app_strings.dart'; // AppStrings Metin Sabitlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_buttons.dart'; // PrimaryButton Ve AppTextButton Widget'larını import Eder.
import '../../../core/widgets/app_scope.dart'; // AppScope InheritedWidget'ını import Eder.
import '../../../core/widgets/brand.dart'; // Wordmark Ve PageDots Widget'larını import Eder.
import '../../../core/widgets/entrance.dart'; // EntranceScope Ve EntranceItem Giriş Animasyonlarını import Eder.
import '../../../core/widgets/layout_parts.dart'; // FillScrollView Widget'ını import Eder.
import '../controllers/onboarding_controller.dart'; // OnboardingController Class'ını import Eder.
import '../models/onboarding_model.dart'; // OnboardingState Modelini import Eder.
import '../widgets/onboarding_heroes.dart'; // Karşılama Sayfalarının Hero Widget'larını import Eder.

/// 3 adımlı karşılama (`PageView`): Devam / Geri / kaydırma. Üst çubuk,
/// sayfa noktaları ve ana düğme sabit kalır; düğme metni çapraz solar.
class OnboardingView extends StatefulWidget { // Karşılama Ekranını Oluşturan StatefulWidget'tır.
  final VoidCallback onFinished; // Karşılama Bittiğinde Çağrılan Callback'tir.

  const OnboardingView({super.key, required this.onFinished}); // key'i Superclass'a İleten Ve onFinished'i required Yapan const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<OnboardingView> createState() => _OnboardingViewState(); // Widget'ın State Nesnesini Oluşturur.
}

class _OnboardingViewState extends State<OnboardingView> { // OnboardingView'in State Class'ıdır.
  OnboardingController? _controller; // Karşılama Controller'ını Tutar.
  PageController? _pages; // PageView'i Yöneten PageController'dır.
  bool _finishing = false; // Bitirme İşleminin Sürüp Sürmediğini Belirtir.

  OnboardingController get controller => _controller!; // Null Olmayan Controller'ı Döndüren Getter'dır.

  @override // Superclass'taki didChangeDependencies Metodunun Override Edildiğini Belirtir.
  void didChangeDependencies() { // Bağımlılıklar Değiştiğinde Çağrılır.
    super.didChangeDependencies(); // Superclass'ın didChangeDependencies Metodunu Çağırır.
    if (_controller == null) { // Controller Henüz Oluşturulmadıysa Bloğu Çalıştırır.
      final s = AppScope.of(context); // AppScope'tan Uygulama Servislerini Alır.
      _controller = OnboardingController(s.prefs, s.reminders); // Servislerle Controller'ı Oluşturur.
      _pages = PageController(initialPage: controller.state.value.page); // Kayıtlı Sayfadan Başlayan PageController Oluşturur.
    }
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _pages?.dispose(); // PageController'ı Serbest Bırakır.
    _controller?.dispose(); // Controller'ı Serbest Bırakır.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  void _goTo(int page) { // Belirtilen Sayfaya Animasyonla Geçer.
    final target = page.clamp(0, OnboardingState.pageCount - 1); // Hedef Sayfayı Geçerli Aralığa Sınırlar.
    _pages!.animateToPage( // PageView'i Hedef Sayfaya Kaydırır.
      target, // Gidilecek Sayfa İndeksidir.
      duration: context.reduceMotion ? AppMotion.ui : AppMotion.slide, // Azaltılmış Harekete Göre Süreyi Seçer.
      curve: AppMotion.easeOut, // Animasyon Eğrisini Belirler.
    );
  }

  Future<void> _finish() async { // Karşılamayı Bitirip onFinished'i Tetikler.
    if (_finishing) return; // Zaten Bitiriliyorsa Tekrar Çalışmaz.
    _finishing = true; // Bitirme İşleminin Başladığını İşaretler.
    await controller.finish(); // Controller Üzerinden Karşılamayı Tamamlar.
    if (mounted) widget.onFinished(); // Widget Hâlâ Ağaçtaysa onFinished Callback'ini Çağırır.
  }

  void _next() { // Ana Düğmeye Basıldığında Sonraki Adıma Geçer.
    final state = controller.state.value; // Güncel Karşılama State'ini Alır.
    if (state.isLast) { // Son Sayfadaysa Bloğu Çalıştırır.
      _finish(); // Karşılamayı Bitirir.
    } else { // Son Sayfada Değilse Bloğu Çalıştırır.
      _goTo(state.page + 1); // Bir Sonraki Sayfaya Geçer.
    }
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Karşılama Ekranının Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    return Scaffold( // Sayfanın Temel Material Layout'unu Oluşturur.
      backgroundColor: p.surface, // Arka Plan Rengini Yüzey Rengi Yapar.
      body: SafeArea( // İçeriği Sistem Alanlarından Korur.
        child: EntranceScope.intro( // Giriş Animasyonu Kapsamını Oluşturur.
          playOnMount: controller.playIntro, // Giriş Animasyonunun Oynayıp Oynamayacağını Belirler.
          child: ValueListenableBuilder<OnboardingState>( // State Değiştikçe Arayüzü Yeniden Çizer.
            valueListenable: controller.state, // Dinlenecek ValueNotifier'ı Belirtir.
            builder: (context, state, _) { // Güncel State İle Arayüzü Oluşturan Builder'dır.
              return Column( // Üst Çubuk, Sayfalar Ve Alt Alanı Dikey Dizer.
                crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
                children: [ // Column'un Çocuk Widget'larıdır.
                  _TopBar(page: state.page, onBack: () => _goTo(state.page - 1), onSkip: _finish), // Geri Ve Atla Düğmeli Üst Çubuğu Gösterir.
                  Expanded( // PageView'in Kalan Alanı Doldurmasını Sağlar.
                    child: PageView( // Kaydırılabilir Karşılama Sayfalarını Oluşturur.
                      controller: _pages, // PageView'i PageController'a Bağlar.
                      onPageChanged: controller.setPage, // Sayfa Değişince Controller'ı Günceller.
                      children: [ // Karşılama Sayfalarının Listesidir.
                        _Pane( // 1. Karşılama Sayfasını Oluşturur.
                          index: 0, // Sayfanın İndeksidir.
                          pages: _pages!, // Opaklık Hesabı İçin PageController'ı Verir.
                          currentPage: state.page, // Etkin Sayfa Numarasını Verir.
                          intro: true, // Giriş Animasyonunu Bu Sayfada Etkinleştirir.
                          hero: Center( // Hero Görselini Ortalar.
                            child: MoodPaletteHero(selected: state.previewMood, onSelect: controller.selectMood), // Duygu Renk Çemberini Gösterir.
                          ),
                          title: AppStrings.welcomeTitle, // Karşılama Başlığıdır.
                          body: AppStrings.welcomeBody, // Karşılama Açıklamasıdır.
                        ),
                        _Pane( // 2. Karşılama Sayfasını Oluşturur.
                          index: 1, // Sayfanın İndeksidir.
                          pages: _pages!, // Opaklık Hesabı İçin PageController'ı Verir.
                          currentPage: state.page, // Etkin Sayfa Numarasını Verir.
                          hero: Center(child: CapsulePreviewHero(active: state.page == 1)), // Kapsül Önizlemesini Sayfa Etkinken Oynatır.
                          title: AppStrings.capsuleTitle, // Kapsül Sayfasının Başlığıdır.
                          body: AppStrings.capsuleBody, // Kapsül Sayfasının Açıklamasıdır.
                        ),
                        _Pane( // 3. Karşılama Sayfasını Oluşturur.
                          index: 2, // Sayfanın İndeksidir.
                          pages: _pages!, // Opaklık Hesabı İçin PageController'ı Verir.
                          currentPage: state.page, // Etkin Sayfa Numarasını Verir.
                          hero: const Align( // Hero Görselini Üst Ortaya Hizalar.
                            alignment: Alignment.topCenter, // Üst Orta Hizalamasını Belirler.
                            child: Padding(padding: EdgeInsets.only(top: 8), child: HeatmapPreviewHero()), // Örnek Isı Haritasını Üst Boşlukla Gösterir.
                          ),
                          title: AppStrings.startTitle, // Başlangıç Sayfasının Başlığıdır.
                          body: AppStrings.startBody, // Başlangıç Sayfasının Açıklamasıdır.
                          copyBottom: 0, // Metin Altı Boşluğunu Sıfırlar.
                          footer: Padding( // Gizlilik Kartına Üst Boşluk Ekler.
                            padding: const EdgeInsets.only(top: 16), // Üstten 16 Birim Boşluk Verir.
                            child: PrivacyCard(reminder: state.reminder, onReminderChanged: controller.setReminder), // Gizlilik Ve Hatırlatıcı Kartını Gösterir.
                          ),
                        ),
                      ],
                    ),
                  ),
                  EntranceItem( // Alt Alanı Giriş Animasyonuyla Gösterir.
                    index: 2, // Giriş Animasyonundaki Sırasıdır.
                    child: Padding( // Alt Alana Kenar Boşlukları Ekler.
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), // Sol, Üst, Sağ Ve Alt Boşlukları Belirler.
                      child: Column( // Sayfa Noktalarını Ve Düğmeyi Dikey Dizer.
                        children: [ // Column'un Çocuk Widget'larıdır.
                          PageDots(count: OnboardingState.pageCount, index: state.page), // Etkin Sayfayı Gösteren Noktaları Çizer.
                          const SizedBox(height: 16), // Noktalar İle Düğme Arasına Boşluk Koyar.
                          PrimaryButton(label: state.ctaLabel, animateLabel: true, onPressed: _next), // Metni Çapraz Solan Ana Düğmeyi Gösterir.
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Sabit üst çubuk: 1. adımda marka, sonrasında "Geri"; son adımda "Atla" gizlenir.
class _TopBar extends StatelessWidget { // Karşılamanın Üst Çubuğunu Oluşturan StatelessWidget'tır.
  final int page; // Etkin Sayfa İndeksidir.
  final VoidCallback onBack; // Geri Düğmesine Basılınca Çağrılan Callback'tir.
  final VoidCallback onSkip; // Atla Düğmesine Basılınca Çağrılan Callback'tir.

  const _TopBar({required this.page, required this.onBack, required this.onSkip}); // Tüm Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Üst Çubuğun Widget Tree'sini Oluşturur.
    Widget fade(bool visible, Widget child) => IgnorePointer( // Görünürlüğe Göre Solan Ve Dokunmayı Engelleyen Yardımcı Fonksiyondur.
      ignoring: !visible, // Gizliyken Dokunmaları Yok Sayar.
      child: ExcludeSemantics( // Gizliyken Erişilebilirlikten Çıkarır.
        excluding: !visible, // Gizliyse Semantics'i Hariç Tutar.
        child: AnimatedOpacity( // Opaklığı Animasyonla Değiştirir.
          opacity: visible ? 1 : 0, // Görünürse Tam, Değilse Sıfır Opaklık Verir.
          duration: AppMotion.ui, // Solma Süresini Belirler.
          curve: AppMotion.easeOut, // Solma Eğrisini Belirler.
          child: child, // Solacak Widget'tır.
        ),
      ),
    );
    return Container( // Üst Çubuk Kapsayıcısını Oluşturur.
      constraints: const BoxConstraints(minHeight: 48), // En Az 48 Birim Yükseklik Verir.
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 0), // İç Boşlukları Belirler.
      child: Row( // Öğeleri Yatay Dizer.
        children: [ // Row'un Çocuk Widget'larıdır.
          // `.lead { min-width: 96px; height: 44px }`: marka ve "Geri" aynı yerde çapraz solar.
          ConstrainedBox( // Sol Alana En Az Boyut Verir.
            constraints: const BoxConstraints(minWidth: 96, minHeight: 44), // En Az 96x44 Boyutu Belirler.
            child: Stack( // Marka Ve Geri Düğmesini Üst Üste Koyar.
              alignment: Alignment.centerLeft, // Öğeleri Sol Ortaya Hizalar.
              children: [ // Stack'in Çocuk Widget'larıdır.
                fade(page == 0, const Wordmark()), // İlk Sayfada Markayı Gösterir.
                Transform.translate( // Geri Düğmesini Sola Kaydırır.
                  offset: const Offset(-8, 0), // 8 Birim Sola Öteler.
                  child: fade( // Geri Düğmesini Görünürlüğe Göre Soldurur.
                    page > 0, // İlk Sayfadan Sonra Görünür Yapar.
                    AppTextButton(label: AppStrings.back, leadingIcon: AppIcons.back, onPressed: onBack), // Simgeli Geri Düğmesini Oluşturur.
                  ),
                ),
              ],
            ),
          ),
          const Spacer(), // Kalan Boşluğu Doldurur.
          fade(page < OnboardingState.pageCount - 1, AppTextButton(label: AppStrings.skip, onPressed: onSkip)), // Son Sayfa Dışında Atla Düğmesini Gösterir.
        ],
      ),
    );
  }
}

/// Tek karşılama sayfası: görsel + başlık/açıklama. Kayarken ayrılan sayfa
/// solar, gelen sayfa belirir.
class _Pane extends StatelessWidget { // Tek Bir Karşılama Sayfasını Oluşturan StatelessWidget'tır.
  final int index; // Sayfanın İndeksidir.
  final PageController pages; // Kaydırma Konumunu Okumak İçin PageController'dır.

  /// Kontrolcü henüz ölçülmediğinde opaklık için kullanılan etkin sayfa.
  final int currentPage; // Etkin Sayfa Numarasıdır.
  final Widget hero; // Sayfanın Üst Görselidir.
  final String title; // Sayfa Başlığıdır.
  final String body; // Sayfa Açıklama Metnidir.
  final bool intro; // Giriş Animasyonu Uygulanıp Uygulanmayacağını Belirtir.
  final double copyBottom; // Metin Bloğunun Alt Boşluğudur.
  final Widget? footer; // Metnin Altında Gösterilen İsteğe Bağlı Widget'tır.

  const _Pane({ // Sayfa Parametrelerini Alan const Constructor'dır.
    required this.index, // index Field'ını required Yapar.
    required this.pages, // pages Field'ını required Yapar.
    required this.currentPage, // currentPage Field'ını required Yapar.
    required this.hero, // hero Field'ını required Yapar.
    required this.title, // title Field'ını required Yapar.
    required this.body, // body Field'ını required Yapar.
    this.intro = false, // intro Varsayılan Olarak false'tur.
    this.copyBottom = 20, // copyBottom Varsayılan Olarak 20'dir.
    this.footer, // İsteğe Bağlı footer Field'ıdır.
  });

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Sayfanın Widget Tree'sini Oluşturur.
    final p = context.palette; // Tema Renk Paletini Alır.
    Widget wrap(int i, Widget child) => intro ? EntranceItem(index: i, child: child) : child; // intro Açıksa Widget'ı Giriş Animasyonuyla Sarar.
    final content = FillScrollView( // Ekranı Dolduran Kaydırılabilir İçerik Oluşturur.
      child: Padding( // Yatay Kenar Boşluğu Ekler.
        padding: const EdgeInsets.symmetric(horizontal: 24), // Yatayda 24 Birim Boşluk Verir.
        child: Column( // Görsel Ve Metinleri Dikey Dizer.
          crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
          children: [ // Column'un Çocuk Widget'larıdır.
            Expanded(child: wrap(0, hero)), // Hero Görselinin Kalan Alanı Doldurmasını Sağlar.
            wrap( // Metin Bloğunu Giriş Animasyonuyla Sarar.
              1, // Giriş Animasyonundaki Sırasıdır.
              Padding( // Metin Bloğuna Alt Boşluk Ekler.
                padding: EdgeInsets.only(bottom: copyBottom), // Alt Boşluğu copyBottom Kadar Verir.
                child: Column( // Başlık Ve Açıklamayı Dikey Dizer.
                  crossAxisAlignment: CrossAxisAlignment.start, // Metinleri Sola Hizalar.
                  children: [ // Column'un Çocuk Widget'larıdır.
                    Semantics( // Başlığa Erişilebilirlik Bilgisi Ekler.
                      header: true, // Metni Başlık Olarak İşaretler.
                      child: Text(title, style: AppTypography.display(30, height: 1.15, tracking: -0.01, color: p.fg)), // Sayfa Başlığını Display Stiliyle Gösterir.
                    ),
                    const SizedBox(height: 12), // Başlık İle Açıklama Arasına Boşluk Koyar.
                    Text(body, style: AppTypography.body(15, color: p.fg2)), // Açıklama Metnini Gösterir.
                  ],
                ),
              ),
            ),
            ?footer, // footer null Değilse Listeye Ekler.
          ],
        ),
      ),
    );
    return Semantics( // Sayfaya Adım Etiketi Ekler.
      label: AppStrings.stepOf(index + 1, OnboardingState.pageCount), // "Adım X / Y" Erişilebilirlik Etiketini Verir.
      container: true, // Sayfayı Ayrı Bir Semantics Düğümü Yapar.
      child: AnimatedBuilder( // Kaydırma Konumuna Göre Yeniden Çizer.
        animation: pages, // PageController'ı Dinler.
        child: content, // Yeniden Oluşturulmayan Sayfa İçeriğidir.
        builder: (context, child) { // Opaklığı Hesaplayan Builder'dır.
          final page = pages.hasClients && pages.position.haveDimensions // PageController Ölçüldüyse Kaydırma Konumunu Kullanır.
              ? pages.page ?? index.toDouble() // Anlık Kesirli Sayfa Değerini Alır.
              : currentPage.toDouble(); // Ölçülmediyse Etkin Sayfayı Kullanır.
          final opacity = (1 - (page - index).abs()).clamp(0.0, 1.0); // Sayfaya Uzaklığa Göre Opaklık Hesaplar.
          return Opacity(opacity: opacity, child: child); // İçeriği Hesaplanan Opaklıkla Gösterir.
        },
      ),
    );
  }
}
