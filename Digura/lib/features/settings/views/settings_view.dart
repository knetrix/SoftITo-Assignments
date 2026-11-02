import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // palette Uzantısını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons Simge Tanımlarını import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre Sabitlerini import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/widgets/app_page_route.dart'; // Sayfa Geçişleri İçin AppPageRoute'u import Eder.
import '../../../core/widgets/app_scope.dart'; // Servislere Erişim Sağlayan AppScope'u import Eder.
import '../../../core/widgets/app_snack.dart'; // showAppSnack Bildirim Fonksiyonunu import Eder.
import '../../../core/widgets/layout_parts.dart'; // AppBarRow Yerleşim Parçasını import Eder.
import '../../app_lock/views/pin_change_view.dart'; // PIN Değiştirme Ekranı PinChangeView'i import Eder.
import '../controllers/settings_controller.dart'; // SettingsController Class'ını import Eder.
import '../widgets/settings_widgets.dart'; // Ayar Satırı, Etiket ve Diyalog Widget'larını import Eder.

/// Ayarlar: Gizlilik ve güvenlik, Bildirimler, Görünüm, Örnek veri, Hakkında.
class SettingsView extends StatefulWidget { // Ayarlar Ekranını Oluşturan StatefulWidget'tır.
  const SettingsView({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<SettingsView> createState() => _SettingsViewState(); // Widget'ın State Nesnesini Oluşturur.
}

class _SettingsViewState extends State<SettingsView> { // Ayarlar Ekranının Durumunu Yöneten State Class'ıdır.
  SettingsController? _controller; // Ekranın İş Mantığını Taşıyan Controller'dır.

  SettingsController get controller => _controller!; // Oluşturulmuş Controller'ı null Olmadan Döndüren Getter'dır.

  @override // Superclass'taki didChangeDependencies Metodunun Override Edildiğini Belirtir.
  void didChangeDependencies() { // Bağımlılıklar Hazır Olduğunda Çağrılan Metottur.
    super.didChangeDependencies(); // Superclass'ın didChangeDependencies Metodunu Çağırır.
    _controller ??= SettingsController(AppScope.of(context)); // Controller Yoksa AppScope Servisleriyle Oluşturur.
  }

  Future<void> _run(Future<String> Function() action, {Duration duration = AppMotion.snackLong}) async { // Eylemi Çalıştırıp Dönen Metni Bildirim Olarak Gösteren Metottur.
    final message = await action(); // Eylemi Çalıştırır ve Bildirim Metnini Alır.
    if (mounted) showAppSnack(context, message, duration: duration); // Widget Hâlâ Ekrandaysa Bildirimi Gösterir.
  }

  Future<void> _pickTheme() async { // Tema Seçim Diyaloğunu Açan Metottur.
    final picked = await ThemeDialog.show(context, controller.model.theme); // Güncel Temayla Diyaloğu Açar ve Seçimi Alır.
    if (picked != null) await _run(() => controller.setTheme(picked)); // Seçim Yapıldıysa Temayı Uygular.
  }

  Future<void> _resetSample() async { // Örnek Veriye Dönüş Akışını Başlatan Metottur.
    if (await ResetSampleDialog.show(context)) await _run(controller.resetToSampleData); // Onaylanırsa Verileri Örnek Veriye Sıfırlar.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Ekranın Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return Scaffold( // Sayfanın Temel Material Layout'unu Oluşturur.
      backgroundColor: p.surface, // Arka Planı Yüzey Rengi Yapar.
      body: SafeArea( // İçeriği Sistem Alanlarından Korur.
        child: ListenableBuilder( // Ayar Değişikliklerinde Yeniden Çizer.
          listenable: controller.changes, // Dinlenecek Birleşik Listenable'ı Verir.
          builder: (context, _) { // Değişiklikte Çalışan builder Callback'idir.
            final model = controller.model; // Güncel Ayar Modelini Alır.
            return Column( // Başlık ve Listeyi Dikey Dizer.
              crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
              children: [ // Sayfa Öğelerinin Listesidir.
                AppBarRow(title: AppStrings.settingsTitle, onBack: () => Navigator.of(context).pop()), // Geri Butonlu Ayarlar Başlığını Gösterir.
                Expanded( // Listenin Kalan Alanı Doldurmasını Sağlar.
                  child: ListView( // Kaydırılabilir Ayar Listesini Oluşturur.
                    padding: const EdgeInsets.only(bottom: 24), // Alta 24 px Boşluk Verir.
                    children: [ // Ayar Gruplarının ve Satırlarının Listesidir.
                      const SettingsGroupLabel(AppStrings.groupPrivacy), // Gizlilik Grubu Etiketini Gösterir.
                      SettingsRow( // Güvenlik Ayar Satırını Oluşturur.
                        icon: AppIcons.shield, // Kalkan Simgesini Kullanır.
                        title: AppStrings.security, // Güvenlik Başlığını Verir.
                        subtitle: AppStrings.securitySub(model.biometricEnabled), // Biyometri Durumuna Göre Alt Yazı Üretir.
                        onTap: () => // Dokunulunca Çalışan Callback'tir.
                            Navigator.of(context).push(AppPageRoute.of<void>(context, (_) => const SecurityView())), // Güvenlik Ekranına Geçer.
                      ),
                      const SettingsGroupLabel(AppStrings.groupNotifications), // Bildirimler Grubu Etiketini Gösterir.
                      SettingsRow( // Hatırlatıcı Ayar Satırını Oluşturur.
                        icon: AppIcons.bell, // Zil Simgesini Kullanır.
                        title: AppStrings.reminder, // Hatırlatıcı Başlığını Verir.
                        subtitle: model.reminderEnabled ? AppStrings.reminderOn : AppStrings.reminderOff, // Duruma Göre Açık/Kapalı Alt Yazısını Seçer.
                        switchValue: model.reminderEnabled, // Anahtarın Güncel Değerini Verir.
                        onSwitch: (on) => _run(() => controller.setReminder(on)), // Anahtar Değişince Hatırlatıcıyı Günceller.
                      ),
                      const SettingsGroupLabel(AppStrings.groupAppearance), // Görünüm Grubu Etiketini Gösterir.
                      SettingsRow( // Tema Ayar Satırını Oluşturur.
                        icon: AppIcons.theme, // Tema Simgesini Kullanır.
                        title: AppStrings.theme, // Tema Başlığını Verir.
                        subtitle: model.theme.summary, // Seçili Temanın Özetini Gösterir.
                        onTap: _pickTheme, // Dokunulunca Tema Diyaloğunu Açar.
                      ),
                      const SettingsGroupLabel(AppStrings.groupSampleData), // Örnek Veri Grubu Etiketini Gösterir.
                      SettingsRow( // Örnek Veriye Dön Satırını Oluşturur.
                        icon: AppIcons.restore, // Geri Yükleme Simgesini Kullanır.
                        title: AppStrings.resetSample, // Örnek Veriye Dön Başlığını Verir.
                        subtitle: AppStrings.resetSampleSub, // Açıklama Alt Yazısını Verir.
                        onTap: _resetSample, // Dokunulunca Sıfırlama Onayını Açar.
                      ),
                      const SettingsGroupLabel(AppStrings.groupAbout), // Hakkında Grubu Etiketini Gösterir.
                      const SettingsRow( // Uygulama Bilgisi Satırını Oluşturur.
                        icon: AppIcons.info, // Bilgi Simgesini Kullanır.
                        title: AppStrings.appName, // Uygulama Adını Gösterir.
                        subtitle: AppStrings.appVersion, // Uygulama Sürümünü Gösterir.
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

/// Ayarlar › Güvenlik: PIN değiştirme ve parmak izi anahtarı.
class SecurityView extends StatefulWidget { // Güvenlik Ayarları Ekranını Oluşturan StatefulWidget'tır.
  const SecurityView({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<SecurityView> createState() => _SecurityViewState(); // Widget'ın State Nesnesini Oluşturur.
}

class _SecurityViewState extends State<SecurityView> { // Güvenlik Ekranının Durumunu Yöneten State Class'ıdır.
  SettingsController? _controller; // Ekranın İş Mantığını Taşıyan Controller'dır.

  SettingsController get controller => _controller!; // Oluşturulmuş Controller'ı null Olmadan Döndüren Getter'dır.

  @override // Superclass'taki didChangeDependencies Metodunun Override Edildiğini Belirtir.
  void didChangeDependencies() { // Bağımlılıklar Hazır Olduğunda Çağrılan Metottur.
    super.didChangeDependencies(); // Superclass'ın didChangeDependencies Metodunu Çağırır.
    _controller ??= SettingsController(AppScope.of(context)); // Controller Yoksa AppScope Servisleriyle Oluşturur.
  }

  Future<void> _changePin() async { // PIN Değiştirme Ekranını Açan Metottur.
    final changed = await Navigator.of(context) // Navigator'a Erişir.
        .push<bool>(AppPageRoute.of<bool>(context, (_) => const PinChangeView())); // PinChangeView'i Açar ve Sonucu Bekler.
    if (changed == true && mounted) { // PIN Değiştiyse ve Widget Ekrandaysa Kontrol Eder.
      showAppSnack(context, AppStrings.pinChangedSnack, duration: AppMotion.snackLong); // PIN Değişti Bildirimini Gösterir.
    }
  }

  Future<void> _toggleBiometric(bool on) async { // Biyometrik Kilidi Açıp Kapatan Metottur.
    final message = await controller.setBiometric(on); // Tercihi Uygular ve Bildirim Metnini Alır.
    if (mounted) showAppSnack(context, message, duration: AppMotion.snackLong); // Widget Ekrandaysa Bildirimi Gösterir.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Ekranın Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return Scaffold( // Sayfanın Temel Material Layout'unu Oluşturur.
      backgroundColor: p.surface, // Arka Planı Yüzey Rengi Yapar.
      body: SafeArea( // İçeriği Sistem Alanlarından Korur.
        child: ListenableBuilder( // Ayar Değişikliklerinde Yeniden Çizer.
          listenable: controller.changes, // Dinlenecek Birleşik Listenable'ı Verir.
          builder: (context, _) { // Değişiklikte Çalışan builder Callback'idir.
            final bio = controller.model.biometricEnabled; // Biyometrik Kilit Durumunu Alır.
            return Column( // Başlık ve Listeyi Dikey Dizer.
              crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
              children: [ // Sayfa Öğelerinin Listesidir.
                AppBarRow( // Geri Butonlu Başlık Satırını Oluşturur.
                  title: AppStrings.security, // Güvenlik Başlığını Verir.
                  backLabel: AppStrings.backToSettings, // Geri Butonu Etiketini Verir.
                  onBack: () => Navigator.of(context).pop(), // Geri Basılınca Ekranı Kapatır.
                ),
                Expanded( // Listenin Kalan Alanı Doldurmasını Sağlar.
                  child: ListView( // Kaydırılabilir Ayar Listesini Oluşturur.
                    padding: const EdgeInsets.only(bottom: 24), // Alta 24 px Boşluk Verir.
                    children: [ // Güvenlik Satırlarının Listesidir.
                      const SettingsGroupLabel(AppStrings.groupAppLock), // Uygulama Kilidi Grubu Etiketini Gösterir.
                      SettingsRow( // PIN Değiştir Satırını Oluşturur.
                        icon: AppIcons.key, // Anahtar Simgesini Kullanır.
                        title: AppStrings.changePinTitle, // PIN Değiştir Başlığını Verir.
                        subtitle: AppStrings.changePinSub, // Açıklama Alt Yazısını Verir.
                        onTap: _changePin, // Dokunulunca PIN Değiştirme Ekranını Açar.
                      ),
                      const SettingsDivider(), // Satırlar Arasına Ayırıcı Çizgi Koyar.
                      SettingsRow( // Parmak İzi Satırını Oluşturur.
                        icon: AppIcons.fingerprint, // Parmak İzi Simgesini Kullanır.
                        title: AppStrings.bioRow, // Biyometri Başlığını Verir.
                        subtitle: bio ? AppStrings.bioRowOn : AppStrings.bioRowOff, // Duruma Göre Açık/Kapalı Alt Yazısını Seçer.
                        switchValue: bio, // Anahtarın Güncel Değerini Verir.
                        onSwitch: _toggleBiometric, // Anahtar Değişince Biyometriyi Günceller.
                      ),
                      const SettingsNote(AppStrings.securityNote), // Güvenlik Bilgi Notunu Gösterir.
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
