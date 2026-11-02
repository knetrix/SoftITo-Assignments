import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // context.palette Renk Token'larını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons İkon Tanımlarını import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/widgets/app_buttons.dart'; // PrimaryButton ve AppTextButton Widget'larını import Eder.
import '../../../core/widgets/app_scope.dart'; // Servislere Erişim İçin AppScope'u import Eder.
import '../../../core/widgets/brand.dart'; // PageDots Widget'ını import Eder.
import '../../../core/widgets/layout_parts.dart'; // FillScrollView Widget'ını import Eder.
import '../controllers/pin_setup_controller.dart'; // BiometricSetupController Class'ını import Eder.
import '../models/pin_flow_model.dart'; // BiometricSetupStatus enum'unu import Eder.
import '../widgets/biometric_widgets.dart'; // BiometricHero ve FactRow Widget'larını import Eder.
import '../widgets/pin_widgets.dart'; // StepTopBar, PinIntro, PinMessage ve PinTone'u import Eder.

/// Kurulum 2/2 (isteğe bağlı): tek dokunuşla açılış için parmak izi.
class BiometricSetupView extends StatefulWidget { // Parmak İzi Kurulum Ekranını Oluşturan StatefulWidget'tır.
  /// `skipped == true` ise "Şimdi değil" ile geçildi.
  final ValueChanged<bool> onCompleted; // Kurulum Bitince Atlanıp Atlanmadığını Bildiren Callback'tir.

  const BiometricSetupView({super.key, required this.onCompleted}); // key'i Superclass'a İleten ve onCompleted'ı required Yapan const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<BiometricSetupView> createState() => _BiometricSetupViewState(); // Ekranın State Nesnesini Oluşturur.
}

class _BiometricSetupViewState extends State<BiometricSetupView> { // BiometricSetupView'ın Durumunu Yöneten State Class'ıdır.
  BiometricSetupController? _controller; // İlk didChangeDependencies'te Oluşturulan Controller'dır.

  BiometricSetupController get controller => _controller!; // Controller'ı null Olmayan Haliyle Döndüren Getter'dır.

  @override // Superclass'taki didChangeDependencies Metodunun Override Edildiğini Belirtir.
  void didChangeDependencies() { // Bağımlılıklar Hazır Olduğunda Çalışır.
    super.didChangeDependencies(); // Superclass'ın didChangeDependencies Metodunu Çağırır.
    final services = AppScope.of(context); // AppScope'tan Servis Paketini Alır.
    _controller ??= BiometricSetupController(services.lock, services.biometrics); // Controller Yoksa Bir Kez Oluşturur.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _controller?.dispose(); // Controller'ı dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  Future<void> _skip() async { // "Şimdi Değil" İle Kurulumu Atlar.
    await controller.skip(); // Biyometriyi Kapalı Olarak Kaydeder.
    widget.onCompleted(true); // Atlandığını Bildirerek Callback'i Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Ekranın Widget Tree'sini Oluşturur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return Scaffold( // Sayfanın Temel Material Layout'unu Oluşturur.
      backgroundColor: p.surface, // Arka Planı Yüzey Rengine Ayarlar.
      body: SafeArea( // İçeriği Sistem Alanlarından Korur.
        child: ValueListenableBuilder<BiometricSetupStatus>( // Kurulum Durumu Değiştikçe Yeniden Çizer.
          valueListenable: controller.status, // Controller'ın status ValueNotifier'ını Dinler.
          builder: (context, status, _) { // Mevcut Duruma Göre Arayüzü Kurar.
            final on = status == BiometricSetupStatus.enabled; // Parmak İzinin Etkinleştirilip Etkinleştirilmediğini Tutar.
            final scanning = status == BiometricSetupStatus.scanning; // Taramanın Sürüp Sürmediğini Tutar.
            return Column( // Öğeleri Dikey Olarak Dizer.
              crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Tam Genişliğe Yayar.
              children: [ // Column'un Çocuk Widget'larıdır.
                StepTopBar( // Adım Bilgisini Gösteren Üst Çubuktur.
                  step: AppStrings.stepOf(2, 2), // "2/2" Adım Metnini Gösterir.
                  trailing: on ? null : AppTextButton(label: AppStrings.notNow, onPressed: scanning ? null : _skip), // Etkin Değilse "Şimdi Değil" Butonunu Gösterir.
                ),
                Expanded( // Kalan Dikey Alanı Kaplar.
                  child: FillScrollView( // İçeriği Kaydırılabilir ve Alanı Dolduracak Şekilde Sarar.
                    child: Padding( // Yatay Kenar Boşluğu Ekler.
                      padding: const EdgeInsets.symmetric(horizontal: 24), // Sağ ve Sola 24 Birim Boşluk Verir.
                      child: Column( // İçerik Öğelerini Dikey Dizer.
                        crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Tam Genişliğe Yayar.
                        children: [ // İçerik Column'unun Çocuklarıdır.
                          PinIntro( // Başlık ve Alt Başlık Bloğunu Gösterir.
                            title: on ? AppStrings.bioOnTitle : AppStrings.bioSetupTitle, // Duruma Göre Başlık Metnini Seçer.
                            subtitle: on ? AppStrings.bioOnSub : AppStrings.bioSetupSub, // Duruma Göre Alt Başlık Metnini Seçer.
                          ),
                          Expanded( // Hero Görseline Kalan Alanı Verir.
                            child: Center( // Görseli Ortalar.
                              child: Padding( // Dikey Boşluk Ekler.
                                padding: const EdgeInsets.symmetric(vertical: 16), // Üst ve Alta 16 Birim Boşluk Verir.
                                child: BiometricHero( // Parmak İzi Hero Görselini Gösterir.
                                  scanning: scanning, // Tarama Animasyonunu Duruma Göre Açar.
                                  enabled: on, // Etkin Görünümünü Duruma Göre Açar.
                                  semanticLabel: on ? AppStrings.bioIconOnLabel : AppStrings.bioIconLabel, // Erişilebilirlik Etiketini Duruma Göre Seçer.
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24), // 24 Birimlik Dikey Boşluk Bırakır.
                          const FactRow(icon: AppIcons.chip, text: AppStrings.bioFactDevice), // Verinin Cihazda Kaldığını Anlatan Satırı Gösterir.
                          const SizedBox(height: 8), // 8 Birimlik Dikey Boşluk Bırakır.
                          const FactRow(icon: AppIcons.alert, text: AppStrings.bioFactFallback), // PIN'in Yedek Olarak Kaldığını Anlatan Satırı Gösterir.
                          const SizedBox(height: 8), // 8 Birimlik Dikey Boşluk Bırakır.
                          switch (status) { // Duruma Göre Gösterilecek Mesajı Seçer.
                            BiometricSetupStatus.scanning => const PinMessage(text: AppStrings.bioPlaceFinger), // Tarama Sırasında Parmağı Yerleştirme Mesajını Gösterir.
                            BiometricSetupStatus.failed => const PinMessage( // Başarısızlıkta Hata Mesajını Gösterir.
                              text: AppStrings.bioSetupFailed, // Kurulum Başarısız Metnini Kullanır.
                              tone: PinTone.error, // Mesajı Hata Tonunda Gösterir.
                              icon: AppIcons.alert, // Uyarı İkonunu Ekler.
                            ),
                            BiometricSetupStatus.unavailable => const PinMessage( // Biyometri Yoksa Hata Mesajını Gösterir.
                              text: AppStrings.bioUnavailable, // Kullanılamaz Metnini Kullanır.
                              tone: PinTone.error, // Mesajı Hata Tonunda Gösterir.
                              icon: AppIcons.alert, // Uyarı İkonunu Ekler.
                            ),
                            _ => const PinMessage(text: ''), // Diğer Durumlarda Boş Mesajla Yeri Korur.
                          },
                        ],
                      ),
                    ),
                  ),
                ),
                Padding( // Alt Bölüme Kenar Boşluğu Ekler.
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), // Sol, Üst, Sağ ve Alt Boşlukları Ayarlar.
                  child: Column( // Alt Öğeleri Dikey Dizer.
                    children: [ // Alt Column'un Çocuklarıdır.
                      const PageDots(count: 2, index: 1), // İki Adımın İkincisinde Olunduğunu Gösterir.
                      const SizedBox(height: 12), // 12 Birimlik Dikey Boşluk Bırakır.
                      PrimaryButton( // Ana Eylem Butonunu Gösterir.
                        label: on ? AppStrings.startToday : (scanning ? AppStrings.bioScanning : AppStrings.bioUse), // Duruma Göre Buton Metnini Seçer.
                        onPressed: scanning // Tarama Sürüyorsa Kontrol Eder.
                            ? null // Tarama Sırasında Butonu Devre Dışı Bırakır.
                            : on // Etkinleştirildiyse Kontrol Eder.
                            ? () => widget.onCompleted(false) // Etkinse Atlanmadan Tamamlandığını Bildirir.
                            : (status == BiometricSetupStatus.unavailable ? null : controller.enable), // Kullanılamıyorsa Kapatır, Değilse Etkinleştirmeyi Başlatır.
                      ),
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
