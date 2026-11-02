import 'dart:math' as math; // max Fonksiyonu İçin dart:math Kütüphanesini math Önekiyle import Eder.

import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // AppPalette, Mood ve context.palette Extension'ını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons Simge Tanımlarını import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre ve Curve Sabitlerini import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Görünen AppStrings Metinlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_buttons.dart'; // AppTextButton Widget'ını import Eder.
import '../../../core/widgets/app_dialog.dart'; // AppDialog ve showAppDialog Fonksiyonunu import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.
import '../models/app_lock_model.dart'; // FingerprintSheetStatus Enum'unu import Eder.
import 'biometric_widgets.dart'; // ScanRing Widget'ını import Eder.

/// Biyometrik doğrulama alt paneli (`FingerprintSheet`): kenarlardan 8 px
/// içeride yüzen panel; açılış `sheet` + `drawer`, kapanış `ui` + `easeOut`.
class FingerprintSheetLayer extends StatefulWidget { // Parmak İzi Panelini Animasyonla Açıp Kapatan StatefulWidget'tır.
  final FingerprintSheetStatus? status; // Panelin Durumudur; null İse Panel Kapalıdır.
  final int attemptsLeft; // Kalan Biyometrik Deneme Sayısıdır.
  final VoidCallback onUsePin; // PIN Kullanmaya Geçiş Callback'idir.
  final VoidCallback onRetry; // Yeniden Deneme Callback'idir.

  const FingerprintSheetLayer({ // FingerprintSheetLayer'ın const Constructor'ıdır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.status, // status Field'ını required Yapar.
    required this.attemptsLeft, // attemptsLeft Field'ını required Yapar.
    required this.onUsePin, // onUsePin Field'ını required Yapar.
    required this.onRetry, // onRetry Field'ını required Yapar.
  });

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<FingerprintSheetLayer> createState() => _FingerprintSheetLayerState(); // Katmanın State Nesnesini Oluşturur.
}

class _FingerprintSheetLayerState extends State<FingerprintSheetLayer> with SingleTickerProviderStateMixin { // Panel Açılış/Kapanış Animasyonunu Yöneten State Class'ıdır.
  late final AnimationController _open = AnimationController( // Panelin Açıklık Durumunu Süren Controller'dır.
    vsync: this, // Ticker Sağlayıcısı Olarak Bu State'i Kullanır.
    duration: AppMotion.sheet, // Açılış Süresini sheet Yapar.
    reverseDuration: AppMotion.ui, // Kapanış Süresini ui Yapar.
  );
  late final CurvedAnimation _curve = CurvedAnimation( // Kayma Animasyonu İçin Eğrili Animation'dır.
    parent: _open, // Ebeveyn Olarak _open Controller'ını Kullanır.
    curve: AppMotion.drawer, // Açılışta drawer Curve'ünü Uygular.
    reverseCurve: AppMotion.easeOut, // Kapanışta easeOut Curve'ünü Uygular.
  );
  FingerprintSheetStatus? _shown; // Kapanış Animasyonu Bitene Dek Gösterilen Son Durumdur.

  @override // Superclass'taki initState Metodunun Override Edildiğini Belirtir.
  void initState() { // State İlk Oluşturulduğunda Çalışır.
    super.initState(); // Superclass'ın initState Metodunu Çağırır.
    _shown = widget.status; // Başlangıç Durumunu Gösterilen Duruma Atar.
    if (_shown != null) _open.forward(); // Durum Varsa Paneli Açar.
    _open.addStatusListener((s) { // Animasyon Durum Değişikliklerini Dinler.
      if (s == AnimationStatus.dismissed && mounted) setState(() => _shown = null); // Kapanış Tamamlanınca Paneli Ağaçtan Kaldırır.
    });
  }

  @override // Superclass'taki didUpdateWidget Metodunun Override Edildiğini Belirtir.
  void didUpdateWidget(FingerprintSheetLayer oldWidget) { // Widget Güncellendiğinde Durumu Senkronize Eder.
    super.didUpdateWidget(oldWidget); // Superclass'ın didUpdateWidget Metodunu Çağırır.
    if (widget.status != null) { // Yeni Durum Varsa:
      _shown = widget.status; // Gösterilen Durumu Günceller.
      _open.forward(); // Paneli Açar.
    } else if (oldWidget.status != null) { // Durum Yeni Kaldırıldıysa:
      _open.reverse(); // Paneli Kapatma Animasyonunu Başlatır.
    }
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _curve.dispose(); // CurvedAnimation'ı dispose Eder.
    _open.dispose(); // Açılış Controller'ını dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Katmanın Widget Tree'sini Oluşturur.
    final status = _shown; // Gösterilecek Durumu Yerel Değişkene Alır.
    if (status == null) return const SizedBox.shrink(); // Durum Yoksa Boş Widget Döndürür.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    final reduce = context.reduceMotion; // Hareket Azaltma Tercihini Okur.
    final dismissible = status == FingerprintSheetStatus.failed || status == FingerprintSheetStatus.lockout; // Başarısız veya Kilitliyse Arka Plana Dokunarak Kapatılabilir.
    final bottom = math.max(8.0, MediaQuery.viewPaddingOf(context).bottom); // Alt Boşluğu En Az 8 veya Güvenli Alan Kadar Yapar.
    final panel = _FingerprintPanel( // Panel İçeriğini Oluşturur.
      status: status, // Panel Durumunu Aktarır.
      attemptsLeft: widget.attemptsLeft, // Kalan Deneme Sayısını Aktarır.
      onUsePin: widget.onUsePin, // PIN'e Geçiş Callback'ini Aktarır.
      onRetry: widget.onRetry, // Yeniden Deneme Callback'ini Aktarır.
    );
    return Stack( // Karartma ve Paneli Üst Üste Yerleştirir.
      children: [ // Stack'in Çocuk Listesidir.
        Positioned.fill( // Karartmanın Tüm Ekranı Kaplamasını Sağlar.
          child: GestureDetector( // Karartmaya Dokunmayı Yakalar.
            onTap: dismissible ? widget.onUsePin : null, // Kapatılabilirse Dokununca PIN'e Geçer.
            child: FadeTransition( // Karartmayı Açılışla Birlikte Belirginleştirir.
              opacity: _open, // Saydamlığı _open Değerine Bağlar.
              child: ColoredBox(color: p.scrim), // scrim Renginde Karartma Çizer.
            ),
          ),
        ),
        Positioned( // Paneli Alttan Konumlandırır.
          left: 8, // Soldan 8 Boşluk Bırakır.
          right: 8, // Sağdan 8 Boşluk Bırakır.
          bottom: bottom, // Alttan Hesaplanan Boşluğu Bırakır.
          child: reduce // Hareket Azaltma Açıksa:
              ? FadeTransition(opacity: _open, child: panel) // Paneli Yalnızca Saydamlıkla Gösterir.
              : SlideTransition( // Değilse Paneli Alttan Kaydırarak Getirir.
                  position: Tween(begin: const Offset(0, 1.1), end: Offset.zero).animate(_curve), // Ekran Dışından Yerine Kayma Konumunu Hesaplar.
                  child: panel, // Kaydırılacak Paneli Verir.
                ),
        ),
      ],
    );
  }
}

class _FingerprintPanel extends StatelessWidget { // Parmak İzi Panelinin İçeriğini Çizen StatelessWidget'tır.
  final FingerprintSheetStatus status; // Panelin Mevcut Durumudur.
  final int attemptsLeft; // Kalan Deneme Sayısıdır.
  final VoidCallback onUsePin; // PIN Kullanmaya Geçiş Callback'idir.
  final VoidCallback onRetry; // Yeniden Deneme Callback'idir.

  const _FingerprintPanel({ // _FingerprintPanel'in const Constructor'ıdır.
    required this.status, // status Field'ını required Yapar.
    required this.attemptsLeft, // attemptsLeft Field'ını required Yapar.
    required this.onUsePin, // onUsePin Field'ını required Yapar.
    required this.onRetry, // onRetry Field'ını required Yapar.
  });

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Panelin Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    final lockout = status == FingerprintSheetStatus.lockout; // Biyometrinin Kilitlenip Kilitlenmediğidir.
    final failed = status == FingerprintSheetStatus.failed || lockout; // Hata veya Kilit Durumu Olup Olmadığıdır.
    final ok = status == FingerprintSheetStatus.verified; // Doğrulamanın Başarılı Olup Olmadığıdır.
    final scanning = status == FingerprintSheetStatus.scanning; // Taramanın Sürüp Sürmediğidir.
    final text = switch (status) { // Duruma Göre Gösterilecek Mesajı Seçer.
      FingerprintSheetStatus.lockout => AppStrings.bioSheetLockout, // Kilitlenme Mesajını Döndürür.
      FingerprintSheetStatus.failed => AppStrings.bioFail(attemptsLeft), // Kalan Denemeyi İçeren Hata Mesajını Döndürür.
      FingerprintSheetStatus.verified => AppStrings.bioSheetOk, // Başarı Mesajını Döndürür.
      FingerprintSheetStatus.scanning => AppStrings.bioSheetPlace, // Parmağı Yerleştirme Mesajını Döndürür.
    };
    final tone = failed ? p.danger : (ok ? p.success : p.muted); // Mesaj Rengini Duruma Göre Seçer.
    final circle = failed ? p.dangerSoft : (ok ? p.successSoft : p.surfaceWarm); // Simge Dairesinin Zemin Rengini Seçer.
    final icon = failed ? AppIcons.alert : (ok ? AppIcons.check : AppIcons.fingerprint); // Duruma Göre Simgeyi Seçer.
    final iconColor = failed ? p.danger : (ok ? p.success : p.fg); // Simge Rengini Duruma Göre Seçer.
    final reduce = context.reduceMotion; // Hareket Azaltma Tercihini Okur.
    return Semantics( // Paneli Erişilebilirlik İçin Ayrı Bir Route Olarak Tanımlar.
      scopesRoute: true, // Paneli Kendi Route Kapsamı Olarak İşaretler.
      namesRoute: true, // Route'a label İle İsim Verir.
      explicitChildNodes: true, // Çocukların Ayrı Semantik Düğüm Olmasını Sağlar.
      label: AppStrings.bioSheetTitle, // Panelin Erişilebilirlik Etiketini Ayarlar.
      child: Material( // Metin ve Mürekkep Efektleri İçin Material Zemini Sağlar.
        type: MaterialType.transparency, // Material'ı Şeffaf Yapar.
        child: Container( // Panelin Görsel Kutusunu Oluşturur.
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16), // Panel İç Boşluklarını Ayarlar.
          decoration: BoxDecoration(color: p.raisedSheet, borderRadius: BorderRadius.circular(28), boxShadow: p.raised), // Yükseltilmiş Zemin, 28 Yarıçap ve Gölge Uygular.
          child: Column( // Panel İçeriğini Dikey Dizer.
            mainAxisSize: MainAxisSize.min, // Yüksekliği İçerik Kadar Tutar.
            children: [ // Column'un Çocuk Listesidir.
              Text(AppStrings.bioSheetTitle, style: AppTypography.display(18, height: 1.5, color: p.fg)), // Panel Başlığını Yazar.
              const SizedBox(height: 4), // Başlık Altına 4 Boşluk Koyar.
              Text(AppStrings.bioSheetSub, style: AppTypography.body(14, color: p.fg2)), // Panel Alt Başlığını Yazar.
              const SizedBox(height: 20), // Simge Öncesine 20 Boşluk Koyar.
              SizedBox.square( // Simge ve Halka İçin Kare Alan Ayırır.
                dimension: 86, // Alanın Kenar Uzunluğunu 86 Yapar.
                child: Stack( // Simge Dairesi ve Tarama Halkasını Üst Üste Koyar.
                  alignment: Alignment.center, // Çocukları Ortalar.
                  children: [ // Stack'in Çocuk Listesidir.
                    AnimatedSwitcher( // Simge Değişiminde Geçiş Animasyonu Oynatır.
                      duration: AppMotion.ui, // Geçiş Süresini ui Yapar.
                      switchInCurve: AppMotion.easeOut, // Giriş Curve'ünü easeOut Yapar.
                      transitionBuilder: (child, animation) => FadeTransition( // Geçişi Saydamlıkla Oluşturur.
                        opacity: animation, // Saydamlığı Geçiş Animasyonuna Bağlar.
                        child: reduce // Hareket Azaltma Açıksa:
                            ? child // Ölçeklemeden Doğrudan Çocuğu Gösterir.
                            : ScaleTransition( // Değilse Ölçek Animasyonu Ekler.
                                scale: Tween<double>(begin: AppMotion.dialogFrom, end: 1).animate(animation), // dialogFrom'dan 1'e Ölçek Hesaplar.
                                child: child, // Ölçeklenecek Çocuğu Verir.
                              ),
                      ),
                      child: Container( // Durum Simgesinin Dairesini Oluşturur.
                        key: ValueKey(icon), // Simge Değişince Geçişi Tetiklemek İçin key Verir.
                        width: 76, // Dairenin Genişliğini 76 Yapar.
                        height: 76, // Dairenin Yüksekliğini 76 Yapar.
                        decoration: BoxDecoration(shape: BoxShape.circle, color: circle), // Duruma Göre Renkli Daire Çizer.
                        alignment: Alignment.center, // Simgeyi Ortalar.
                        child: AppIcon(icon, size: 40, strokeWidth: 1.6, color: iconColor), // Durum Simgesini Çizer.
                      ),
                    ),
                    if (scanning) ScanRing(size: 86, color: p.fg), // Tarama Sürüyorsa Dönen Halkayı Gösterir.
                  ],
                ),
              ),
              const SizedBox(height: 12 - 5), // Simge Altına 7 Boşluk Koyar.
              Semantics( // Mesaj Değişikliklerini Ekran Okuyucuya Duyurur.
                liveRegion: true, // Alanı Canlı Bölge Olarak İşaretler.
                child: ConstrainedBox( // Mesaj Alanına Asgari Yükseklik Verir.
                  constraints: const BoxConstraints(minHeight: 42), // Asgari Yüksekliği 42 Yapar.
                  child: Text( // Durum Mesajını Yazar.
                    text, // Seçilen Mesaj Metnidir.
                    textAlign: TextAlign.center, // Metni Ortalar.
                    style: AppTypography.body(14, color: tone), // Duruma Uygun Renkte Gövde Stili Uygular.
                  ),
                ),
              ),
              const SizedBox(height: 8), // Butonlar Öncesine 8 Boşluk Koyar.
              Row( // Eylem Butonlarını Yan Yana Dizer.
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Butonları İki Uca Yaslar.
                children: lockout // Kilitliyse:
                    ? [ // Yalnızca PIN İle Devam Butonunu İçeren Liste.
                        const SizedBox.shrink(), // Sol Tarafı Boş Bırakır.
                        Flexible( // Butonun Esnek Genişlik Almasını Sağlar.
                          child: AppTextButton(label: AppStrings.continueWithPin, onPressed: onUsePin), // PIN İle Devam Et Butonunu Gösterir.
                        ),
                      ]
                    : [ // Değilse PIN Kullan ve Gerekirse Tekrar Dene Butonları.
                        Flexible( // Butonun Esnek Genişlik Almasını Sağlar.
                          child: AppTextButton(label: AppStrings.usePin, onPressed: ok || scanning ? null : onUsePin), // Tarama veya Başarı Sırasında Pasif PIN Kullan Butonudur.
                        ),
                        if (failed) // Doğrulama Başarısızsa:
                          Flexible( // Butonun Esnek Genişlik Almasını Sağlar.
                            child: AppTextButton(label: AppStrings.retry, onPressed: onRetry), // Tekrar Dene Butonunu Gösterir.
                          ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Kilit açıldı" katmanı: içerik 0.96 → 1 ölçek + saydamlıkla, 40 ms arayla.
class UnlockedOverlay extends StatefulWidget { // Kilit Açıldı Animasyonlu Katmanını Gösteren StatefulWidget'tır.
  const UnlockedOverlay({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<UnlockedOverlay> createState() => _UnlockedOverlayState(); // Katmanın State Nesnesini Oluşturur.
}

class _UnlockedOverlayState extends State<UnlockedOverlay> with SingleTickerProviderStateMixin { // Kademeli Belirme Animasyonunu Yöneten State Class'ıdır.
  late final AnimationController _c = AnimationController( // Tüm Kademeleri Kapsayan Animasyon Controller'ıdır.
    vsync: this, // Ticker Sağlayıcısı Olarak Bu State'i Kullanır.
    duration: AppMotion.unlockPop + AppMotion.stagger * 2, // Süreyi Bir Belirme Artı İki Kademe Gecikmesi Yapar.
  )..forward(); // Oluşturulur Oluşturulmaz Animasyonu Başlatır.

  Widget _pop(int index, Widget child) { // Verilen Çocuğu Sırasına Göre Gecikmeli Belirten Yardımcı Metottur.
    final total = _c.duration!.inMicroseconds; // Toplam Süreyi Mikrosaniye Olarak Alır.
    final start = (AppMotion.stagger * index).inMicroseconds / total; // Bu Öğenin Başlangıç Oranını Hesaplar.
    final end = (AppMotion.stagger * index + AppMotion.unlockPop).inMicroseconds / total; // Bu Öğenin Bitiş Oranını Hesaplar.
    final interval = Interval(start, end, curve: AppMotion.easeOut); // Öğeye Ait Zaman Aralığını Tanımlar.
    final reduce = context.reduceMotion; // Hareket Azaltma Tercihini Okur.
    return AnimatedBuilder( // Controller Değiştikçe Yeniden Çizer.
      animation: _c, // Dinlenecek Animasyonu Belirtir.
      child: child, // Yeniden Oluşturulmayacak Çocuğu Verir.
      builder: (context, child) { // Her Karede Dönüşümü Uygular.
        final t = interval.transform(_c.value); // Genel İlerlemeyi Öğenin Aralığına Dönüştürür.
        final faded = Opacity(opacity: t, child: child); // Çocuğu t Oranında Saydam Gösterir.
        if (reduce) return faded; // Hareket Azaltma Açıksa Yalnızca Saydamlık Uygular.
        return Transform.scale(scale: AppMotion.dialogFrom + (1 - AppMotion.dialogFrom) * t, child: faded); // Ayrıca dialogFrom'dan 1'e Ölçekler.
      },
    );
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _c.dispose(); // Animasyon Controller'ını dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Katmanın Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    return Semantics( // İçeriği Ekran Okuyucuya Duyurur.
      liveRegion: true, // Alanı Canlı Bölge Olarak İşaretler.
      child: ColoredBox( // Tüm Ekranı Yüzey Rengiyle Boyar.
        color: p.surface, // Zemin Rengini surface Yapar.
        child: Center( // İçeriği Ekranın Ortasına Yerleştirir.
          child: Column( // Öğeleri Dikey Dizer.
            mainAxisSize: MainAxisSize.min, // Yüksekliği İçerik Kadar Tutar.
            children: [ // Column'un Çocuk Listesidir.
              _pop( // İlk Kademede Ruh Hali Noktalarını Belirtir.
                0, // Kademe Sırası 0'dır.
                Padding( // Noktaların Altına Boşluk Ekler.
                  padding: const EdgeInsets.only(bottom: 8), // Alttan 8 Boşluk Verir.
                  child: Row( // Ruh Hali Noktalarını Yan Yana Dizer.
                    mainAxisSize: MainAxisSize.min, // Genişliği İçerik Kadar Tutar.
                    children: [ // Row'un Çocuk Listesidir.
                      for (var i = 0; i < Mood.values.length; i++) ...[ // Her Mood İçin Nokta Üretir.
                        if (i > 0) const SizedBox(width: 6), // İlk Nokta Hariç Aralara 6 Boşluk Koyar.
                        Container( // Tek Bir Ruh Hali Noktasıdır.
                          width: 14, // Nokta Genişliğini 14 Yapar.
                          height: 14, // Nokta Yüksekliğini 14 Yapar.
                          decoration: BoxDecoration(shape: BoxShape.circle, color: p.mood(Mood.values[i])), // Noktayı İlgili Mood Rengiyle Boyar.
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12), // Başlık Öncesine 12 Boşluk Koyar.
              _pop(1, Text(AppStrings.unlockedTitle, style: AppTypography.display(24, height: 1.3, color: p.fg))), // İkinci Kademede Kilit Açıldı Başlığını Belirtir.
              const SizedBox(height: 12), // Alt Metin Öncesine 12 Boşluk Koyar.
              _pop(2, Text(AppStrings.unlockedSub, style: AppTypography.body(14, color: p.muted))), // Üçüncü Kademede Alt Metni Belirtir.
            ],
          ),
        ),
      ),
    );
  }
}

/// "PIN kurtarılamaz" onayı: tek seçenek her şeyi silmek.
class ForgotPinDialog extends StatelessWidget { // PIN Unutuldu Onay Diyaloğunu Gösteren StatelessWidget'tır.
  const ForgotPinDialog({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  static Future<bool> show(BuildContext context) async => // Diyaloğu Açıp Kullanıcının Seçimini Döndüren Yardımcı Metottur.
      await showAppDialog<bool>(context: context, builder: (_) => const ForgotPinDialog()) ?? false; // Diyalog Sonucunu Bekler; null İse false Döndürür.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Diyaloğun Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    final style = AppTypography.body(14, color: p.fg2); // Gövde Metinleri İçin Ortak Stili Tanımlar.
    return AppDialog.lock( // Kilit Ekranı Stilinde Diyalog Oluşturur.
      title: AppStrings.forgotTitle, // Diyalog Başlığını Ayarlar.
      body: Column( // Diyalog Gövdesini Dikey Dizer.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları Yatayda Genişletir.
        children: [ // Column'un Çocuk Listesidir.
          Text(AppStrings.forgotBody1, style: style), // İlk Açıklama Paragrafını Yazar.
          const SizedBox(height: 12), // Paragraflar Arasına 12 Boşluk Koyar.
          Text.rich( // Kısmen Kalın İkinci Paragrafı Yazar.
            const TextSpan( // Parçalı Metnin Kök TextSpan'idir.
              children: [ // Metin Parçalarının Listesidir.
                TextSpan(text: AppStrings.forgotBody2Lead), // Paragrafın Giriş Kısmıdır.
                TextSpan( // Vurgulu Orta Kısımdır.
                  text: AppStrings.forgotBody2Strong, // Vurgulanacak Metindir.
                  style: TextStyle(fontWeight: FontWeight.w600), // Metni Yarı Kalın Yapar.
                ),
                TextSpan(text: AppStrings.forgotBody2Tail), // Paragrafın Son Kısmıdır.
              ],
            ),
            style: style, // Ortak Gövde Stilini Uygular.
          ),
          const SizedBox(height: 12), // Gövde Sonuna 12 Boşluk Koyar.
        ],
      ),
      actions: [ // Diyalog Eylem Butonlarının Listesidir.
        AppTextButton(label: AppStrings.cancel, onPressed: () => Navigator.of(context).pop(false)), // Diyaloğu false İle Kapatan İptal Butonudur.
        AppTextButton(label: AppStrings.wipeAll, color: p.danger, onPressed: () => Navigator.of(context).pop(true)), // Diyaloğu true İle Kapatan Kırmızı Her Şeyi Sil Butonudur.
      ],
    );
  }
}
