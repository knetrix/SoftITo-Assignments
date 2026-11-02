import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // context.palette Renk Token'larını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons İkon Tanımlarını import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_buttons.dart'; // PrimaryButton ve AppTextButton Widget'larını import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.
import '../../../core/widgets/app_scope.dart'; // Servislere Erişim İçin AppScope'u import Eder.
import '../../../core/widgets/brand.dart'; // PageDots Widget'ını import Eder.
import '../../../core/widgets/layout_parts.dart'; // FillScrollView Widget'ını import Eder.
import '../controllers/pin_setup_controller.dart'; // PinSetupController Class'ını import Eder.
import '../models/pin_flow_model.dart'; // PinSetupState ve PinSetupStage'i import Eder.
import '../widgets/pin_widgets.dart'; // StepTopBar, PinIntro, PinDots, PinMessage, PinKeypad ve PinTone'u import Eder.

/// Kurulum 1/2: 4 haneli PIN oluştur ve tekrar girerek doğrula.
class PinSetupView extends StatefulWidget { // PIN Kurulum Ekranını Oluşturan StatefulWidget'tır.
  final VoidCallback onCompleted; // Kurulum Tamamlanıp İleri Basılınca Çağrılan Callback'tir.

  const PinSetupView({super.key, required this.onCompleted}); // key'i Superclass'a İleten ve onCompleted'ı required Yapan const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<PinSetupView> createState() => _PinSetupViewState(); // Ekranın State Nesnesini Oluşturur.
}

class _PinSetupViewState extends State<PinSetupView> { // PinSetupView'ın Durumunu Yöneten State Class'ıdır.
  PinSetupController? _controller; // İlk didChangeDependencies'te Oluşturulan Controller'dır.

  PinSetupController get controller => _controller!; // Controller'ı null Olmayan Haliyle Döndüren Getter'dır.

  @override // Superclass'taki didChangeDependencies Metodunun Override Edildiğini Belirtir.
  void didChangeDependencies() { // Bağımlılıklar Hazır Olduğunda Çalışır.
    super.didChangeDependencies(); // Superclass'ın didChangeDependencies Metodunu Çağırır.
    _controller ??= PinSetupController(AppScope.of(context).lock); // Controller Yoksa Bir Kez Oluşturur.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _controller?.dispose(); // Controller'ı dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Ekranın Widget Tree'sini Oluşturur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return Scaffold( // Sayfanın Temel Material Layout'unu Oluşturur.
      backgroundColor: p.surface, // Arka Planı Yüzey Rengine Ayarlar.
      body: SafeArea( // İçeriği Sistem Alanlarından Korur.
        child: ValueListenableBuilder<PinSetupState>( // Kurulum Durumu Değiştikçe Yeniden Çizer.
          valueListenable: controller.state, // Controller'ın state ValueNotifier'ını Dinler.
          builder: (context, state, _) { // Mevcut Duruma Göre Arayüzü Kurar.
            final confirm = state.stage == PinSetupStage.confirm; // Doğrulama Aşamasında Olunup Olunmadığını Tutar.
            final done = state.stage == PinSetupStage.done; // Kurulumun Bitip Bitmediğini Tutar.
            return Column( // Öğeleri Dikey Dizer.
              crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Tam Genişliğe Yayar.
              children: [ // Column'un Çocuklarıdır.
                StepTopBar( // Adım Bilgisini Gösteren Üst Çubuktur.
                  step: AppStrings.stepOf(1, 2), // "1/2" Adım Metnini Gösterir.
                  trailing: confirm // Doğrulama Aşamasında Olunup Olunmadığını Kontrol Eder.
                      ? AppTextButton( // Doğrulamadaysa "Baştan" Butonunu Gösterir.
                          label: AppStrings.restart, // Buton Metnini Ayarlar.
                          leadingIcon: AppIcons.back, // Başına Geri İkonu Ekler.
                          onPressed: controller.restart, // Basılınca Kurulumu Baştan Başlatır.
                        )
                      : null, // Diğer Aşamalarda Buton Göstermez.
                ),
                Expanded( // İçeriğe Kalan Dikey Alanı Verir.
                  child: done ? const _PinCreated() : _PinEntry(state: state, controller: controller), // Bittiyse Başarı Görünümünü, Değilse PIN Girişini Gösterir.
                ),
                Padding( // Alt Bölüme Kenar Boşluğu Ekler.
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), // Sol, Üst, Sağ ve Alt Boşlukları Ayarlar.
                  child: Column( // Alt Öğeleri Dikey Dizer.
                    children: [ // Alt Column'un Çocuklarıdır.
                      const PageDots(count: 2, index: 0), // İki Adımın İlkinde Olunduğunu Gösterir.
                      if (done) ...[ // Kurulum Bittiyse Aşağıdaki Öğeleri Ekler.
                        const SizedBox(height: 12), // 12 Birimlik Dikey Boşluk Bırakır.
                        PrimaryButton(label: AppStrings.next, onPressed: widget.onCompleted), // Sonraki Adıma Geçiren İleri Butonunu Gösterir.
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PinEntry extends StatelessWidget { // PIN Oluşturma ve Doğrulama Girişini Gösteren StatelessWidget'tır.
  final PinSetupState state; // Gösterilecek Kurulum Durumudur.
  final PinSetupController controller; // Tuş Olaylarını İleten Controller'dır.

  const _PinEntry({required this.state, required this.controller}); // state ve controller'ı required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Giriş Alanının Widget Tree'sini Oluşturur.
    final confirm = state.stage == PinSetupStage.confirm; // Doğrulama Aşamasında Olunup Olunmadığını Tutar.
    return FillScrollView( // İçeriği Kaydırılabilir ve Alanı Dolduracak Şekilde Sarar.
      child: Padding( // Yatay Kenar Boşluğu Ekler.
        padding: const EdgeInsets.symmetric(horizontal: 24), // Sağ ve Sola 24 Birim Boşluk Verir.
        child: Column( // Öğeleri Dikey Dizer.
          children: [ // Column'un Çocuklarıdır.
            PinIntro( // Başlık ve Alt Başlık Bloğunu Gösterir.
              title: confirm ? AppStrings.pinConfirmTitle : AppStrings.pinCreateTitle, // Aşamaya Göre Başlık Metnini Seçer.
              subtitle: confirm ? AppStrings.pinConfirmSub : AppStrings.pinCreateSub, // Aşamaya Göre Alt Başlık Metnini Seçer.
            ),
            const SizedBox(height: 32), // 32 Birimlik Dikey Boşluk Bırakır.
            PinDots( // Girilen Hane Sayısını Noktalarla Gösterir.
              filled: state.entered.length, // Dolu Nokta Sayısını Ayarlar.
              tone: state.error != null ? PinTone.error : PinTone.normal, // Hata Varsa Hata Tonunu Kullanır.
              shakeTick: state.shakeTick, // Sallama Animasyonunu Tetikleyen Sayacı Verir.
            ),
            const SizedBox(height: 12), // 12 Birimlik Dikey Boşluk Bırakır.
            state.error != null // Hata Olup Olmadığını Kontrol Eder.
                ? PinMessage(text: state.error!, tone: PinTone.error, icon: AppIcons.alert) // Hata Varsa Hata Mesajını Gösterir.
                : PinMessage(text: confirm ? AppStrings.pinHintConfirm : AppStrings.pinHintCreate), // Yoksa Aşamaya Uygun İpucunu Gösterir.
            const Spacer(), // Tuş Takımını Alta İter.
            PinKeypad(onDigit: controller.inputDigit, onDelete: controller.deleteDigit), // Tuş Olaylarını Controller'a İleten Tuş Takımını Gösterir.
            const SizedBox(height: 12), // 12 Birimlik Dikey Boşluk Bırakır.
          ],
        ),
      ),
    );
  }
}

class _PinCreated extends StatelessWidget { // PIN Oluşturuldu Başarı Görünümünü Gösteren StatelessWidget'tır.
  const _PinCreated(); // Parametresiz const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Başarı Görünümünün Widget Tree'sini Oluşturur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return Center( // İçeriği Ortalar.
      child: Padding( // Yatay Kenar Boşluğu Ekler.
        padding: const EdgeInsets.symmetric(horizontal: 24), // Sağ ve Sola 24 Birim Boşluk Verir.
        child: Semantics( // Erişilebilirlik Bilgisi Ekler.
          liveRegion: true, // Ekran Okuyucunun Değişikliği Duyurmasını Sağlar.
          child: Column( // Öğeleri Dikey Dizer.
            mainAxisSize: MainAxisSize.min, // Column'u İçeriği Kadar Küçük Tutar.
            children: [ // Column'un Çocuklarıdır.
              Container( // Onay İkonu İçin Yuvarlak Zemin Oluşturur.
                width: 88, // Genişliği 88 Birim Yapar.
                height: 88, // Yüksekliği 88 Birim Yapar.
                margin: const EdgeInsets.only(bottom: 8), // Altına 8 Birim Boşluk Bırakır.
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.successSoft), // Yumuşak Başarı Renginde Daire Çizer.
                alignment: Alignment.center, // İkonu Ortalar.
                child: AppIcon(AppIcons.check, size: 40, strokeWidth: 2.2, color: p.success), // Başarı Renginde Onay İkonunu Gösterir.
              ),
              const SizedBox(height: 12), // 12 Birimlik Dikey Boşluk Bırakır.
              Text(AppStrings.pinCreated, style: AppTypography.display(24, height: 1.3, color: p.fg)), // "PIN Oluşturuldu" Başlığını Display Stiliyle Gösterir.
              const SizedBox(height: 12), // 12 Birimlik Dikey Boşluk Bırakır.
              ConstrainedBox( // Açıklama Metninin Genişliğini Sınırlar.
                constraints: const BoxConstraints(maxWidth: 236), // En Fazla 236 Birim Genişliğe İzin Verir.
                child: Text( // Açıklama Metnini Gösterir.
                  AppStrings.pinCreatedSub, // PIN Oluşturuldu Alt Metnini Kullanır.
                  textAlign: TextAlign.center, // Metni Ortalar.
                  style: AppTypography.body(15, color: p.fg2), // 15 Boyutlu İkincil Renkli Gövde Stilini Uygular.
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
