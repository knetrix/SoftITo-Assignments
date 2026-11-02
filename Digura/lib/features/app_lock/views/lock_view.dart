import 'dart:async'; // Timer İçin Dart'ın async Kütüphanesini import Eder.

import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // context.palette Renk Token'larını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons İkon Tanımlarını import Eder.
import '../../../core/constants/app_motion.dart'; // Animasyon Süre ve Curve'lerini İçeren AppMotion'ı import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_buttons.dart'; // AppTextButton Widget'ını import Eder.
import '../../../core/widgets/app_scope.dart'; // Servislere Erişim İçin AppScope'u import Eder.
import '../../../core/widgets/brand.dart'; // Wordmark Widget'ını import Eder.
import '../../../core/widgets/layout_parts.dart'; // FillScrollView Widget'ını import Eder.
import '../controllers/app_lock_controller.dart'; // AppLockController Class'ını import Eder.
import '../models/app_lock_model.dart'; // AppLockState Class'ını import Eder.
import '../widgets/lock_overlays.dart'; // FingerprintSheetLayer, UnlockedOverlay ve ForgotPinDialog'u import Eder.
import '../widgets/pin_widgets.dart'; // PinDots, PinMessage, PinKeypad, PinKey ve PinTone'u import Eder.

/// Açılış kilidi: her açılışta PIN tuş takımı ya da parmak izi.
class LockView extends StatefulWidget { // Açılış Kilidi Ekranını Oluşturan StatefulWidget'tır.
  final VoidCallback onUnlocked; // Kilit Açıldığında Çağrılan Callback'tir.

  /// "PIN'imi unuttum → Her şeyi sil ve sıfırla" onaylandı.
  final VoidCallback onWipeRequested; // Sıfırlama Onaylandığında Çağrılan Callback'tir.

  const LockView({super.key, required this.onUnlocked, required this.onWipeRequested}); // key'i Superclass'a İleten ve Callback'leri required Yapan const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<LockView> createState() => _LockViewState(); // Ekranın State Nesnesini Oluşturur.
}

class _LockViewState extends State<LockView> { // LockView'ın Durumunu Yöneten State Class'ıdır.
  AppLockController? _controller; // İlk didChangeDependencies'te Oluşturulan Controller'dır.
  Timer? _holdTimer; // Kilit Açıldıktan Sonra Geçişi Geciktiren Timer'dır.

  AppLockController get controller => _controller!; // Controller'ı null Olmayan Haliyle Döndüren Getter'dır.

  @override // Superclass'taki didChangeDependencies Metodunun Override Edildiğini Belirtir.
  void didChangeDependencies() { // Bağımlılıklar Hazır Olduğunda Çalışır.
    super.didChangeDependencies(); // Superclass'ın didChangeDependencies Metodunu Çağırır.
    if (_controller == null) { // Controller Henüz Oluşturulmadıysa Kontrol Eder.
      final s = AppScope.of(context); // AppScope'tan Servis Paketini Alır.
      _controller = AppLockController(s.lock, s.prefs, s.biometrics, s.clock)..state.addListener(_onState); // Controller'ı Oluşturup Durum Dinleyicisini Ekler.
    }
  }

  void _onState() { // Kilit Durumu Değiştiğinde Çalışır.
    if (controller.state.value.unlocked && _holdTimer == null) { // Kilit Açıldıysa ve Timer Kurulmadıysa Kontrol Eder.
      _holdTimer = Timer(AppMotion.unlockHold, widget.onUnlocked); // Kısa Bekleme Sonrası onUnlocked'ı Çağıracak Timer Kurar.
    }
  }

  Future<void> _forgot() async { // "PIN'imi Unuttum" Diyaloğunu Açar.
    final wipe = await ForgotPinDialog.show(context); // Diyaloğu Gösterip Sıfırlama Onayını Bekler.
    if (wipe && mounted) widget.onWipeRequested(); // Onaylandıysa ve Widget Hâlâ Bağlıysa Sıfırlamayı İster.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _holdTimer?.cancel(); // Bekleyen Geçiş Timer'ını İptal Eder.
    _controller?.dispose(); // Controller'ı dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Ekranın Widget Tree'sini Oluşturur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return PopScope( // Geri Tuşu Davranışını Kontrol Eder.
      canPop: false, // Kilit Ekranından Geri Çıkışı Engeller.
      child: Scaffold( // Sayfanın Temel Material Layout'unu Oluşturur.
        backgroundColor: p.surface, // Arka Planı Yüzey Rengine Ayarlar.
        body: ValueListenableBuilder<AppLockState>( // Kilit Durumu Değiştikçe Yeniden Çizer.
          valueListenable: controller.state, // Controller'ın state ValueNotifier'ını Dinler.
          builder: (context, state, _) { // Mevcut Duruma Göre Arayüzü Kurar.
            return Stack( // Katmanları Üst Üste Dizer.
              children: [ // Stack'in Katmanlarıdır.
                SafeArea( // İçeriği Sistem Alanlarından Korur.
                  child: Column( // Gövde ve Alt Butonu Dikey Dizer.
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Tam Genişliğe Yayar.
                    children: [ // Column'un Çocuklarıdır.
                      Expanded( // Gövdeye Kalan Dikey Alanı Verir.
                        child: _LockBody(state: state, controller: controller), // PIN Girişi Gövdesini Gösterir.
                      ),
                      Padding( // Alt Butona Kenar Boşluğu Ekler.
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16), // Sol, Sağ ve Alt Boşlukları Ayarlar.
                        child: Center( // Butonu Ortalar.
                          child: AppTextButton( // "PIN'imi Unuttum" Metin Butonunu Gösterir.
                            label: AppStrings.forgotPin, // Buton Metnini Ayarlar.
                            onPressed: state.unlocked || state.sheet != null ? null : _forgot, // Kilit Açıksa Ya Da Panel Açıksa Butonu Kapatır.
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill( // Paneli Tüm Alanı Kaplayacak Şekilde Yerleştirir.
                  child: FingerprintSheetLayer( // Parmak İzi Panel Katmanını Gösterir.
                    status: state.sheet, // Panelin Mevcut Durumunu Verir.
                    attemptsLeft: state.biometricAttemptsLeft, // Kalan Biyometrik Deneme Sayısını Verir.
                    onUsePin: controller.closeSheet, // "PIN Kullan" İle Paneli Kapatır.
                    onRetry: controller.startBiometric, // Tekrar Dene İle Taramayı Yeniden Başlatır.
                  ),
                ),
                if (state.unlocked) // Kilit Açıldıysa Kontrol Eder.
                  Positioned.fill( // Overlay'i Tüm Alanı Kaplayacak Şekilde Yerleştirir.
                    child: TweenAnimationBuilder<double>( // Overlay'i 0'dan 1'e Animasyonla Getirir.
                      tween: Tween(begin: 0, end: 1), // Animasyon Aralığını 0-1 Olarak Ayarlar.
                      duration: AppMotion.ui, // Standart UI Animasyon Süresini Kullanır.
                      curve: AppMotion.easeOut, // easeOut Curve'ünü Kullanır.
                      builder: (context, t, child) => Opacity(opacity: t, child: child), // Opaklığı Animasyon Değerine Bağlar.
                      child: const UnlockedOverlay(), // Kilit Açıldı Overlay'ini Gösterir.
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

class _LockBody extends StatelessWidget { // Kilit Ekranının PIN Giriş Gövdesini Oluşturan StatelessWidget'tır.
  final AppLockState state; // Gösterilecek Kilit Durumudur.
  final AppLockController controller; // Tuş Olaylarını İleten Controller'dır.

  const _LockBody({required this.state, required this.controller}); // state ve controller'ı required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Gövdenin Widget Tree'sini Oluşturur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    final bioReady = state.biometricEnabled && !state.biometricTemporarilyDisabled; // Parmak İzinin Hazır Olup Olmadığını Hesaplar.
    final wrongPin = state.error != null && !state.isLockedOut; // Kilitlenme Dışında Bir Hata Olup Olmadığını Hesaplar.
    final Widget message; // Gösterilecek Mesaj Widget'ını Tanımlar.
    if (state.error != null) { // Hata Varsa Kontrol Eder.
      message = PinMessage(text: state.error!, tone: PinTone.error, icon: AppIcons.alert); // Hata Mesajını Uyarı İkonuyla Gösterir.
    } else if (state.biometricEnabled && state.biometricTemporarilyDisabled) { // Biyometri Geçici Olarak Kapalıysa Kontrol Eder.
      message = const PinMessage(text: AppStrings.bioTemporarilyOff, icon: AppIcons.alert); // Biyometrinin Kapalı Olduğunu Bildirir.
    } else { // Diğer Durumlarda Çalışır.
      message = const PinMessage(text: ''); // Boş Mesajla Yeri Korur.
    }
    return FillScrollView( // İçeriği Kaydırılabilir ve Alanı Dolduracak Şekilde Sarar.
      child: Padding( // Yatay Kenar Boşluğu Ekler.
        padding: const EdgeInsets.symmetric(horizontal: 24), // Sağ ve Sola 24 Birim Boşluk Verir.
        child: Column( // Öğeleri Dikey Dizer.
          children: [ // Column'un Çocuklarıdır.
            const SizedBox(height: 32), // 32 Birimlik Dikey Boşluk Bırakır.
            const Wordmark(fontSize: 24), // Digura Logosunu 24 Boyutunda Gösterir.
            const SizedBox(height: 8), // 8 Birimlik Dikey Boşluk Bırakır.
            Text( // Yönlendirme Metnini Gösterir.
              bioReady ? AppStrings.lockPromptBio : AppStrings.lockPromptPin, // Biyometri Hazırsa Ona Uygun Metni Seçer.
              textAlign: TextAlign.center, // Metni Ortalar.
              style: AppTypography.body(15, color: p.fg2), // 15 Boyutlu İkincil Renkli Gövde Stilini Uygular.
            ),
            const SizedBox(height: 32), // 32 Birimlik Dikey Boşluk Bırakır.
            PinDots( // Girilen Hane Sayısını Noktalarla Gösterir.
              filled: state.entered.length, // Dolu Nokta Sayısını Ayarlar.
              tone: wrongPin ? PinTone.error : PinTone.normal, // Yanlış PIN'de Hata Tonunu Kullanır.
              shakeTick: state.shakeTick, // Sallama Animasyonunu Tetikleyen Sayacı Verir.
            ),
            const SizedBox(height: 12), // 12 Birimlik Dikey Boşluk Bırakır.
            message, // Hesaplanan Mesaj Widget'ını Gösterir.
            const Spacer(), // Tuş Takımını Alta İter.
            AnimatedOpacity( // Kilitlenmede Tuş Takımını Soluklaştırır.
              duration: AppMotion.ui, // Standart UI Animasyon Süresini Kullanır.
              curve: AppMotion.easeOut, // easeOut Curve'ünü Kullanır.
              opacity: state.isLockedOut ? 0.6 : 1, // Kilitlenmede Opaklığı 0.6 Yapar.
              child: PinKeypad( // PIN Tuş Takımını Gösterir.
                enabled: state.keypadEnabled, // Tuş Takımının Aktifliğini Duruma Bağlar.
                onDigit: controller.inputDigit, // Rakam Tuşlarını Controller'a İletir.
                onDelete: controller.deleteDigit, // Silme Tuşunu Controller'a İletir.
                leading: state.biometricEnabled // Biyometri Açıksa Kontrol Eder.
                    ? PinKey( // Sol Alt Köşeye Parmak İzi Tuşu Koyar.
                        label: state.biometricTemporarilyDisabled ? AppStrings.bioKeyOffLabel : AppStrings.bioKeyLabel, // Duruma Göre Erişilebilirlik Etiketini Seçer.
                        icon: AppIcons.fingerprint, // Parmak İzi İkonunu Kullanır.
                        ghost: true, // Tuşu Arka Plansız Gösterir.
                        enabled: state.canUseBiometric && state.keypadEnabled, // Biyometri Kullanılabilirse Tuşu Aktif Yapar.
                        onTap: controller.startBiometric, // Dokununca Biyometrik Doğrulamayı Başlatır.
                      )
                    : null, // Biyometri Kapalıysa Tuş Göstermez.
              ),
            ),
            const SizedBox(height: 12), // 12 Birimlik Dikey Boşluk Bırakır.
          ],
        ),
      ),
    );
  }
}
