import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // context.palette Renk Token'larını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons İkon Tanımlarını import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/widgets/app_scope.dart'; // Servislere Erişim İçin AppScope'u import Eder.
import '../../../core/widgets/layout_parts.dart'; // AppBarRow ve FillScrollView Widget'larını import Eder.
import '../controllers/pin_change_controller.dart'; // PinChangeController Class'ını import Eder.
import '../models/pin_flow_model.dart'; // PinChangeState ve PinChangeStep'i import Eder.
import '../widgets/pin_widgets.dart'; // PinIntro, PinDots, PinMessage, PinKeypad ve PinTone'u import Eder.

/// Ayarlar › Güvenlik › PIN'i değiştir. Başarıyla biterse `true` ile kapanır.
class PinChangeView extends StatefulWidget { // PIN Değiştirme Ekranını Oluşturan StatefulWidget'tır.
  const PinChangeView({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<PinChangeView> createState() => _PinChangeViewState(); // Ekranın State Nesnesini Oluşturur.
}

class _PinChangeViewState extends State<PinChangeView> { // PinChangeView'ın Durumunu Yöneten State Class'ıdır.
  PinChangeController? _controller; // İlk didChangeDependencies'te Oluşturulan Controller'dır.

  PinChangeController get controller => _controller!; // Controller'ı null Olmayan Haliyle Döndüren Getter'dır.

  @override // Superclass'taki didChangeDependencies Metodunun Override Edildiğini Belirtir.
  void didChangeDependencies() { // Bağımlılıklar Hazır Olduğunda Çalışır.
    super.didChangeDependencies(); // Superclass'ın didChangeDependencies Metodunu Çağırır.
    _controller ??= PinChangeController(AppScope.of(context).lock)..state.addListener(_onState); // Controller Yoksa Oluşturup Durum Dinleyicisini Ekler.
  }

  void _onState() { // Akış Durumu Değiştiğinde Çalışır.
    if (controller.state.value.completed && mounted) Navigator.of(context).pop(true); // Değişiklik Tamamlandıysa Ekranı true İle Kapatır.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _controller?.dispose(); // Controller'ı dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  static (String, String) _copy(PinChangeStep step) => switch (step) { // Adıma Göre Başlık ve Alt Başlık İkilisini Döndürür.
    PinChangeStep.current => (AppStrings.changeCurrentTitle, AppStrings.changeCurrentSub), // Mevcut PIN Adımının Metinlerini Döndürür.
    PinChangeStep.next => (AppStrings.changeNextTitle, AppStrings.changeNextSub), // Yeni PIN Adımının Metinlerini Döndürür.
    PinChangeStep.confirm => (AppStrings.changeConfirmTitle, AppStrings.changeConfirmSub), // Tekrar Girme Adımının Metinlerini Döndürür.
  };

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Ekranın Widget Tree'sini Oluşturur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return Scaffold( // Sayfanın Temel Material Layout'unu Oluşturur.
      backgroundColor: p.surface, // Arka Planı Yüzey Rengine Ayarlar.
      body: SafeArea( // İçeriği Sistem Alanlarından Korur.
        child: Column( // Üst Çubuk ve İçeriği Dikey Dizer.
          crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Tam Genişliğe Yayar.
          children: [ // Column'un Çocuklarıdır.
            AppBarRow(title: AppStrings.changePinTitle, onBack: () => Navigator.of(context).pop(false)), // Geri Basılınca false İle Kapanan Başlık Çubuğunu Gösterir.
            Expanded( // İçeriğe Kalan Dikey Alanı Verir.
              child: ValueListenableBuilder<PinChangeState>( // Akış Durumu Değiştikçe Yeniden Çizer.
                valueListenable: controller.state, // Controller'ın state ValueNotifier'ını Dinler.
                builder: (context, state, _) { // Mevcut Duruma Göre Arayüzü Kurar.
                  final (title, sub) = _copy(state.step); // Adımın Başlık ve Alt Başlığını Alır.
                  return FillScrollView( // İçeriği Kaydırılabilir ve Alanı Dolduracak Şekilde Sarar.
                    child: Padding( // Yatay Kenar Boşluğu Ekler.
                      padding: const EdgeInsets.symmetric(horizontal: 24), // Sağ ve Sola 24 Birim Boşluk Verir.
                      child: Column( // Öğeleri Dikey Dizer.
                        children: [ // Column'un Çocuklarıdır.
                          PinIntro(title: title, subtitle: sub), // Adımın Başlık ve Alt Başlığını Gösterir.
                          const SizedBox(height: 32), // 32 Birimlik Dikey Boşluk Bırakır.
                          PinDots( // Girilen Hane Sayısını Noktalarla Gösterir.
                            filled: state.entered.length, // Dolu Nokta Sayısını Ayarlar.
                            tone: state.error != null ? PinTone.error : PinTone.normal, // Hata Varsa Hata Tonunu Kullanır.
                            shakeTick: state.shakeTick, // Sallama Animasyonunu Tetikleyen Sayacı Verir.
                          ),
                          const SizedBox(height: 12), // 12 Birimlik Dikey Boşluk Bırakır.
                          state.error != null // Hata Olup Olmadığını Kontrol Eder.
                              ? PinMessage(text: state.error!, tone: PinTone.error, icon: AppIcons.alert) // Hata Varsa Hata Mesajını Gösterir.
                              : PinMessage(text: AppStrings.stepOf(state.step.number, 3)), // Yoksa "X/3" Adım Bilgisini Gösterir.
                          const Spacer(), // Tuş Takımını Alta İter.
                          PinKeypad(onDigit: controller.inputDigit, onDelete: controller.deleteDigit), // Tuş Olaylarını Controller'a İleten Tuş Takımını Gösterir.
                          const SizedBox(height: 12), // 12 Birimlik Dikey Boşluk Bırakır.
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
