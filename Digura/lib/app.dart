import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import 'core/constants/app_motion.dart'; // AppMotion Süre ve Eğri Jetonlarını import Eder.
import 'core/constants/app_strings.dart'; // AppStrings Metin Sabitlerini import Eder.
import 'core/theme/app_theme.dart'; // AppTheme Açık/Koyu Temalarını import Eder.
import 'core/widgets/app_page_route.dart'; // AppPageRoute Sayfa Geçiş Route'unu import Eder.
import 'core/widgets/app_scope.dart'; // AppScope ve AppServices Class'larını import Eder.
import 'core/widgets/app_snack.dart'; // showAppSnack Yardımcısını import Eder.
import 'features/app_lock/views/biometric_setup_view.dart'; // BiometricSetupView Ekranını import Eder.
import 'features/app_lock/views/lock_view.dart'; // LockView Kilit Ekranını import Eder.
import 'features/app_lock/views/pin_setup_view.dart'; // PinSetupView Ekranını import Eder.
import 'features/home/views/home_shell_view.dart'; // HomeShellView Ana Kabuk Ekranını import Eder.
import 'features/onboarding/views/onboarding_view.dart'; // OnboardingView Karşılama Ekranını import Eder.

/// Digura kök widget'ı: tema tercihi, ekran akışı ve arka plandan dönüşte
/// yeniden kilitleme.
///
/// Akış: Karşılama (3 adım) → PIN (1/2) → Parmak izi (2/2) → Bugün;
/// sonraki açılışlarda Açılış Kilidi → Bugün.
class DiguraApp extends StatefulWidget { // Uygulamanın Kök StatefulWidget'ıdır.
  final AppServices services; // Uygulama Genelindeki Servis Paketidir.

  const DiguraApp({super.key, required this.services}); // key'i Superclass'a İleten ve services'i required Yapan const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<DiguraApp> createState() => _DiguraAppState(); // Widget'ın State Nesnesini Oluşturur.
}

class _DiguraAppState extends State<DiguraApp> { // DiguraApp'in Akış ve Kilit Durumunu Tutan State Class'ıdır.
  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>(); // Navigator'a Context Dışından Erişim Sağlayan GlobalKey'dir.
  late final AppLifecycleListener _lifecycle; // Uygulamanın Ön/Arka Plan Geçişlerini Dinleyen Listener'dır.

  /// Kilit açılmış bir oturum var mı (Bugün'e ulaşıldı mı)?
  bool _sessionUnlocked = false; // Oturumun Kilidinin Açık Olup Olmadığını Tutar.
  bool _relockShown = false; // Yeniden Kilit Ekranının Gösterilip Gösterilmediğini Tutar.
  bool _wentToBackground = false; // Uygulamanın Arka Plana Geçip Geçmediğini Tutar.

  AppServices get _s => widget.services; // Servis Paketine Kısa Erişim Sağlayan Getter'dır.

  /// İlk ekran bir kez seçilir; tema değişiminde yeniden hesaplanmaz.
  late final Widget _home = _initialScreen(); // İlk Gösterilecek Ekranı Bir Kez Hesaplar.

  @override // Superclass'taki initState Metodunun Override Edildiğini Belirtir.
  void initState() { // State İlk Oluşturulduğunda Çalışır.
    super.initState(); // Superclass'ın initState Metodunu Çağırır.
    _lifecycle = AppLifecycleListener(onPause: _onPause, onResume: _onResume); // Pause ve Resume Callback'lerini Bağlar.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _lifecycle.dispose(); // Lifecycle Listener'ını Kapatır.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  void _onPause() => _wentToBackground = true; // Uygulama Duraklatılınca Arka Plan Bayrağını Açar.

  void _onResume() { // Uygulama Öne Geldiğinde Çalışır.
    _s.today.refresh(); // Bugünün Tarihini Yeniler.
    if (!_wentToBackground) return; // Arka Plana Geçilmediyse Bir Şey Yapmaz.
    _wentToBackground = false; // Arka Plan Bayrağını Sıfırlar.
    if (_sessionUnlocked && !_relockShown && _s.lock.hasPin.value) _relock(); // Açık Oturum ve PIN Varsa Kilit Ekranını Açar.
  }

  BuildContext? get _navContext => _navigator.currentContext; // Navigator'ın Güncel Context'ini Döndürür.

  bool get _reduceMotion => _navContext?.reduceMotion ?? false; // Sistem Hareketi Azalt Ayarını Okur.

  void _replace(WidgetBuilder builder, {bool fade = false}) { // Mevcut Ekranı Yeni Ekranla Değiştirir.
    _navigator.currentState?.pushReplacement( // Mevcut Route'u Yenisiyle Değiştirir.
      AppPageRoute<void>(builder: builder, reduceMotion: _reduceMotion, fadeOnly: fade), // Geçiş Ayarlarıyla Yeni AppPageRoute Oluşturur.
    );
  }

  Widget _initialScreen() { // Duruma Göre İlk Ekranı Seçer.
    if (!_s.prefs.onboardingDone) return OnboardingView(onFinished: _toPinSetup); // Karşılama Bitmediyse OnboardingView Döndürür.
    if (!_s.lock.hasPin.value) return PinSetupView(onCompleted: _toBiometricSetup); // PIN Yoksa PinSetupView Döndürür.
    return LockView(onUnlocked: _toHomeAfterUnlock, onWipeRequested: _wipe); // Aksi Halde Kilit Ekranını Döndürür.
  }

  void _toPinSetup() => _replace((_) => PinSetupView(onCompleted: _toBiometricSetup)); // PIN Kurulum Ekranına Geçer.

  void _toBiometricSetup() => _replace((_) => BiometricSetupView(onCompleted: _toHomeAfterSetup)); // Biyometrik Kurulum Ekranına Geçer.

  void _toHomeAfterSetup(bool skipped) { // Kurulum Sonrası Ana Ekrana Geçer.
    _sessionUnlocked = true; // Oturumu Kilidi Açık Olarak İşaretler.
    _replace((_) => const HomeShellView()); // HomeShellView Ekranına Geçer.
    final context = _navContext; // Navigator Context'ini Alır.
    if (skipped && context != null) { // Biyometrik Atlandıysa ve Context Varsa Çalışır.
      showAppSnack(context, AppStrings.bioSkippedSnack, duration: AppMotion.snackLong); // Parmak İzinin Kapalı Olduğunu Bildiren Snackbar Gösterir.
    }
  }

  void _toHomeAfterUnlock() { // Kilit Açıldıktan Sonra Ana Ekrana Geçer.
    _sessionUnlocked = true; // Oturumu Kilidi Açık Olarak İşaretler.
    _replace((_) => const HomeShellView(), fade: true); // Solma Geçişiyle HomeShellView'a Geçer.
  }

  /// Uygulama öne geldiğinde açık oturumun üstüne kilit ekranı açılır.
  void _relock() { // Açık Oturumun Üstüne Kilit Ekranı Ekler.
    final nav = _navigator.currentState; // Navigator State'ini Alır.
    if (nav == null) return; // Navigator Yoksa Çıkar.
    _relockShown = true; // Kilit Ekranının Gösterildiğini İşaretler.
    nav.push( // Yeni Bir Route'u Yığına Ekler.
      AppPageRoute<void>( // Kilit Ekranı İçin AppPageRoute Oluşturur.
        reduceMotion: true, // Animasyonu Azaltılmış Olarak Ayarlar.
        fadeOnly: true, // Yalnızca Solma Geçişi Kullanır.
        builder: (context) => LockView( // Route İçeriği Olarak LockView Oluşturur.
          onUnlocked: () { // Kilit Açıldığında Çalışan Callback'tir.
            _relockShown = false; // Kilit Ekranı Bayrağını Sıfırlar.
            Navigator.of(context).pop(); // Kilit Ekranını Kapatır.
          },
          onWipeRequested: _wipe, // Sıfırlama İsteğinde _wipe'ı Çağırır.
        ),
      ),
    );
  }

  /// "Her şeyi sil ve sıfırla": PIN, ayarlar ve tüm kayıtlar kalıcı olarak silinir.
  Future<void> _wipe() async { // Tüm Verileri Silip Karşılama Ekranına Döner.
    await _s.reminders.disable(); // Hatırlatıcıyı Kapatır.
    await _s.lock.wipe(); // PIN ve Kilit Ayarlarını Siler.
    await _s.prefs.wipe(); // Tüm Tercihleri ve Kayıtları Siler.
    _s.moods.clearInMemory(); // Bellekteki Kayıtları Boşaltır.
    _sessionUnlocked = false; // Oturum Kilidini Kapalı Duruma Getirir.
    _relockShown = false; // Kilit Ekranı Bayrağını Sıfırlar.
    _navigator.currentState?.pushAndRemoveUntil( // Tüm Route'ları Kaldırıp Yeni Route Ekler.
      AppPageRoute<void>( // Karşılama Ekranı İçin AppPageRoute Oluşturur.
        reduceMotion: _reduceMotion, // Sistem Hareket Ayarını Uygular.
        fadeOnly: true, // Yalnızca Solma Geçişi Kullanır.
        builder: (_) => OnboardingView(onFinished: _toPinSetup), // Route İçeriği Olarak OnboardingView Oluşturur.
      ),
      (_) => false, // Önceki Tüm Route'ları Kaldırır.
    );
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Widget Tree'yi Oluşturur.
    return AppScope( // Servisleri Alt Widget'lara Sağlayan AppScope'u Döndürür.
      services: _s, // Paylaşılacak Servis Paketini Verir.
      child: ValueListenableBuilder<ThemeMode>( // Tema Tercihi Değiştikçe Yeniden Çizer.
        valueListenable: _s.prefs.themeMode, // Dinlenecek Tema Notifier'ını Verir.
        builder: (context, mode, _) => MaterialApp( // Seçili Temayla MaterialApp Oluşturur.
          navigatorKey: _navigator, // Navigator'a GlobalKey Bağlar.
          title: AppStrings.appName, // Uygulama Başlığını Ayarlar.
          debugShowCheckedModeBanner: false, // Debug Bandını Gizler.
          theme: AppTheme.light(), // Açık Temayı Ayarlar.
          darkTheme: AppTheme.dark(), // Koyu Temayı Ayarlar.
          themeMode: mode, // Kullanıcının Seçtiği Tema Modunu Uygular.
          themeAnimationDuration: AppTheme.themeAnimation, // Tema Geçiş Süresini Ayarlar.
          themeAnimationCurve: AppMotion.easeOut, // Tema Geçiş Eğrisini Ayarlar.
          home: _home, // İlk Ekranı Ayarlar.
        ),
      ),
    );
  }
}
