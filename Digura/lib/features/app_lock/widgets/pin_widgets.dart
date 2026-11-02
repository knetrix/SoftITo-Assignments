import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // AppPalette ve context.palette Extension'ını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons ve AppIconData Class'larını import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre ve Curve Sabitlerini import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Görünen AppStrings Metinlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/utils/clock.dart'; // Türkçe Büyük Harf İçin trUpper Fonksiyonunu import Eder.
import '../../../core/utils/pin_validator.dart'; // PIN Uzunluğunu Tanımlayan PinValidator'ı import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.
import '../../../core/widgets/pressable.dart'; // Basılma Durumunu Yöneten Pressable Widget'ını import Eder.

enum PinTone { normal, error, success } // PIN Göstergelerinin Normal, Hata ve Başarı Tonlarını Tanımlar.

/// Üst çubuk: mono adım etiketi (`ADIM 1 / 2`) ve isteğe bağlı sağ eylem.
class StepTopBar extends StatelessWidget { // Adım Etiketi ve Eylemler İçeren Üst Çubuk StatelessWidget'ıdır.
  final String? step; // Gösterilecek Adım Etiketidir.
  final Widget? leading; // Solda Adım Etiketi Yerine Gösterilecek Widget'tır.
  final Widget? trailing; // Sağda Gösterilecek İsteğe Bağlı Eylem Widget'ıdır.

  const StepTopBar({super.key, this.step, this.leading, this.trailing}); // Tüm Field'ları İsteğe Bağlı Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Üst Çubuğun Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    return Container( // Çubuğun Kutusunu Oluşturur.
      constraints: const BoxConstraints(minHeight: 48), // Asgari Yüksekliği 48 Yapar.
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 0), // İç Boşlukları Ayarlar.
      child: Row( // Sol ve Sağ Öğeleri Yan Yana Dizer.
        children: [ // Row'un Çocuk Listesidir.
          Expanded( // Sol Alanın Kalan Genişliği Kaplamasını Sağlar.
            child: Align( // Sol Öğeyi Hizalar.
              alignment: Alignment.centerLeft, // Sola ve Dikeyde Ortaya Hizalar.
              child: leading ?? (step == null ? null : Text(trUpper(step!), style: AppTypography.eyebrow(12, p.muted))), // leading Yoksa Adım Etiketini Büyük Harfle Yazar.
            ),
          ),
          ?trailing, // trailing null Değilse Listeye Ekler.
        ],
      ),
    );
  }
}

/// Başlık + açıklama (`.intro`): 28 px başlık, en çok 30ch açıklama.
class PinIntro extends StatelessWidget { // PIN Ekranı Başlık ve Açıklamasını Gösteren StatelessWidget'tır.
  final String title; // Ekran Başlığıdır.
  final String subtitle; // Başlık Altındaki Açıklama Metnidir.

  /// `max-width: 30ch` (15 px Roboto'da ≈ 253 px).
  static const double _maxSubtitleWidth = 253; // Açıklamanın Azami Genişliğidir.

  const PinIntro({super.key, required this.title, required this.subtitle}); // title ve subtitle Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Başlık Bölümünün Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    return Padding( // Üstten Boşluk Ekler.
      padding: const EdgeInsets.only(top: 16), // Üstten 16 Boşluk Verir.
      child: Column( // Başlık ve Açıklamayı Dikey Dizer.
        children: [ // Column'un Çocuk Listesidir.
          const SizedBox(height: 8), // Başlık Öncesine 8 Boşluk Koyar.
          Semantics( // Başlığı Erişilebilirlik İçin İşaretler.
            header: true, // Öğeyi Başlık Olarak Tanımlar.
            child: Text( // Başlık Metnini Yazar.
              title, // Gösterilecek Başlıktır.
              textAlign: TextAlign.center, // Metni Ortalar.
              style: AppTypography.display(28, height: 1.15, tracking: -0.01, color: p.fg), // 28 Punto Display Stili Uygular.
            ),
          ),
          const SizedBox(height: 8), // Başlık İle Açıklama Arasına 8 Boşluk Koyar.
          ConstrainedBox( // Açıklamanın Genişliğini Sınırlar.
            constraints: const BoxConstraints(maxWidth: _maxSubtitleWidth), // Azami Genişliği _maxSubtitleWidth Yapar.
            child: Text( // Açıklama Metnini Yazar.
              subtitle, // Gösterilecek Açıklamadır.
              textAlign: TextAlign.center, // Metni Ortalar.
              style: AppTypography.body(15, color: p.fg2), // 15 Punto Gövde Stili Uygular.
            ),
          ),
        ],
      ),
    );
  }
}

/// 4 PIN noktası (16 px). Yeni dolan nokta 0.6 → 1 (`micro`); hata = kırmızı
/// noktalar + ±8 dp sallanma (`shake`, hareket azaltmada yok).
class PinDots extends StatefulWidget { // Girilen PIN Hanelerini Noktalarla Gösteren StatefulWidget'tır.
  final int filled; // Dolu Nokta Sayısıdır.
  final PinTone tone; // Noktaların Renk Tonudur.
  final int shakeTick; // Her Değiştiğinde Sallanma Animasyonunu Tetikleyen Sayaçtır.

  const PinDots({super.key, required this.filled, this.tone = PinTone.normal, this.shakeTick = 0}); // filled Zorunlu, Diğerleri Varsayılanlı const Constructor'dır.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<PinDots> createState() => _PinDotsState(); // PinDots'un State Nesnesini Oluşturur.
}

class _PinDotsState extends State<PinDots> with SingleTickerProviderStateMixin { // Sallanma Animasyonunu Yöneten State Class'ıdır.
  late final AnimationController _shake = AnimationController(vsync: this, duration: AppMotion.shake); // Sallanma Süresini Yöneten Controller'dır.
  late final Animation<double> _offset = TweenSequence<double>([ // Sola-Sağa Sallanma Ofsetlerini Sıralayan Animation'dır.
    TweenSequenceItem(tween: Tween(begin: 0, end: -AppMotion.shakeOffset), weight: 20), // Önce Sola Kayar.
    TweenSequenceItem( // İkinci Adımı Tanımlar.
      tween: Tween(begin: -AppMotion.shakeOffset, end: AppMotion.shakeOffset), // Soldan Sağa Kayar.
      weight: 40, // Sürenin %40'ını Kaplar.
    ),
    TweenSequenceItem( // Üçüncü Adımı Tanımlar.
      tween: Tween(begin: AppMotion.shakeOffset, end: -AppMotion.shakeOffset), // Sağdan Sola Kayar.
      weight: 20, // Sürenin %20'sini Kaplar.
    ),
    TweenSequenceItem(tween: Tween(begin: -AppMotion.shakeOffset, end: 0), weight: 20), // Sonunda Merkeze Döner.
  ]).animate(CurvedAnimation(parent: _shake, curve: AppMotion.easeOut)); // Diziyi easeOut Eğrili _shake'e Bağlar.

  @override // Superclass'taki didUpdateWidget Metodunun Override Edildiğini Belirtir.
  void didUpdateWidget(PinDots oldWidget) { // Widget Güncellendiğinde Sallanmayı Kontrol Eder.
    super.didUpdateWidget(oldWidget); // Superclass'ın didUpdateWidget Metodunu Çağırır.
    if (widget.shakeTick != oldWidget.shakeTick && !context.reduceMotion) _shake.forward(from: 0); // Sayaç Değiştiyse ve Hareket Azaltma Kapalıysa Sallanmayı Başlatır.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _shake.dispose(); // Sallanma Controller'ını dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Noktaların Widget Tree'sini Oluşturur.
    final row = ExcludeSemantics( // Noktaları Ekran Okuyucudan Gizler.
      child: Row( // Noktaları Yan Yana Dizer.
        mainAxisAlignment: MainAxisAlignment.center, // Noktaları Ortalar.
        children: [ // Row'un Çocuk Listesidir.
          for (var i = 0; i < PinValidator.length; i++) ...[ // PIN Uzunluğu Kadar Nokta Üretir.
            if (i > 0) const SizedBox(width: 20), // İlk Nokta Hariç Aralara 20 Boşluk Koyar.
            _PinDot(filled: i < widget.filled, tone: widget.tone), // Sırası Dolu Sayısından Küçükse Dolu Nokta Çizer.
          ],
        ],
      ),
    );
    return AnimatedBuilder( // Sallanma Animasyonunu Dinleyerek Yeniden Çizer.
      animation: _shake, // Dinlenecek Animasyonu Belirtir.
      child: row, // Yeniden Oluşturulmayacak Nokta Satırını Verir.
      builder: (context, child) => // Her Karede Ofset Uygular.
          _shake.isAnimating ? Transform.translate(offset: Offset(_offset.value, 0), child: child) : child!, // Animasyon Sürüyorsa Yatay Kaydırır, Değilse Olduğu Gibi Gösterir.
    );
  }
}

class _PinDot extends StatelessWidget { // Tek Bir PIN Noktasını Çizen StatelessWidget'tır.
  final bool filled; // Noktanın Dolu Olup Olmadığıdır.
  final PinTone tone; // Noktanın Renk Tonudur.

  const _PinDot({required this.filled, required this.tone}); // filled ve tone Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Noktanın Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    final (Color fill, Color border) = switch (tone) { // Tona Göre Dolgu ve Kenar Rengini Seçer.
      PinTone.success => (p.success, p.success), // Başarıda Tamamen Yeşil Yapar.
      PinTone.error => (filled ? p.danger : Colors.transparent, p.danger), // Hatada Kırmızı Kenar ve Doluysa Kırmızı Dolgu Verir.
      PinTone.normal => (filled ? p.fg : Colors.transparent, filled ? p.fg : p.fg2), // Normalde Doluysa fg, Boşsa Şeffaf Dolgu Verir.
    };
    final reduce = context.reduceMotion; // Hareket Azaltma Tercihini Okur.
    return TweenAnimationBuilder<double>( // Dolma Anında Belirme Animasyonu Oynatır.
      key: ValueKey(filled), // Doluluk Değişince Animasyonu Yeniden Başlatır.
      tween: Tween(begin: filled ? 0 : 1, end: 1), // Yalnızca Yeni Dolan Noktada 0'dan 1'e Animasyon Yapar.
      duration: AppMotion.micro, // Animasyon Süresini micro Yapar.
      curve: AppMotion.easeOut, // Animasyon Curve'ünü easeOut Yapar.
      builder: (context, t, child) => t == 1 // Animasyon Bittiyse:
          ? child! // Çocuğu Olduğu Gibi Gösterir.
          : reduce // Hareket Azaltma Açıksa:
          ? Opacity(opacity: AppMotion.dotOpacityFrom + (1 - AppMotion.dotOpacityFrom) * t, child: child) // Yalnızca Saydamlıkla Belirtir.
          : Transform.scale(scale: AppMotion.dotFrom + (1 - AppMotion.dotFrom) * t, child: child), // Değilse dotFrom'dan 1'e Ölçekler.
      child: AnimatedContainer( // Renk Geçişlerini Animasyonlu Yapan Noktadır.
        duration: AppMotion.micro, // Geçiş Süresini micro Yapar.
        curve: AppMotion.easeOut, // Geçiş Curve'ünü easeOut Yapar.
        width: 16, // Nokta Genişliğini 16 Yapar.
        height: 16, // Nokta Yüksekliğini 16 Yapar.
        decoration: BoxDecoration( // Noktanın Görünümünü Tanımlar.
          shape: BoxShape.circle, // Daire Şekli Verir.
          color: fill, // Dolgu Rengini Uygular.
          border: Border.all(color: border, width: 2), // 2 Kalınlığında Kenar Çizer.
        ),
      ),
    );
  }
}

/// Durum satırı (`.msg`): min 42 px, hata = kırmızı + uyarı simgesi.
class PinMessage extends StatelessWidget { // PIN Ekranındaki Durum Mesajını Gösteren StatelessWidget'tır.
  final String text; // Gösterilecek Mesaj Metnidir.
  final PinTone tone; // Mesajın Renk Tonudur.
  final AppIconData? icon; // Mesajın Önündeki İsteğe Bağlı Simgedir.

  const PinMessage({super.key, required this.text, this.tone = PinTone.normal, this.icon}); // text Zorunlu, Diğerleri İsteğe Bağlı const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Mesaj Satırının Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    final color = switch (tone) { // Tona Göre Metin Rengini Seçer.
      PinTone.error => p.danger, // Hatada Kırmızı Kullanır.
      PinTone.success => p.success, // Başarıda Yeşil Kullanır.
      PinTone.normal => p.muted, // Normalde Soluk Renk Kullanır.
    };
    return Semantics( // Mesaj Değişikliklerini Ekran Okuyucuya Duyurur.
      liveRegion: true, // Alanı Canlı Bölge Olarak İşaretler.
      child: ConstrainedBox( // Mesaj Alanına Asgari Yükseklik Verir.
        constraints: const BoxConstraints(minHeight: 42), // Asgari Yüksekliği 42 Yapar.
        child: Row( // Simge ve Metni Yan Yana Dizer.
          mainAxisAlignment: MainAxisAlignment.center, // İçeriği Yatayda Ortalar.
          crossAxisAlignment: CrossAxisAlignment.start, // İçeriği Üstten Hizalar.
          children: [ // Row'un Çocuk Listesidir.
            if (icon != null) ...[ // Simge Varsa:
              Padding( // Simgeyi Metinle Hizalamak İçin Boşluk Ekler.
                padding: const EdgeInsets.only(top: 1), // Üstten 1 Boşluk Verir.
                child: AppIcon(icon!, size: 18, strokeWidth: 2, color: color), // Mesaj Simgesini Çizer.
              ),
              const SizedBox(width: 6), // Simge İle Metin Arasına 6 Boşluk Koyar.
            ],
            Flexible( // Metnin Taşmadan Sarılmasını Sağlar.
              child: Text( // Mesaj Metnini Yazar.
                text, // Gösterilecek Metindir.
                textAlign: TextAlign.center, // Metni Ortalar.
                style: AppTypography.body(14, color: color), // Tona Uygun Renkte Gövde Stili Uygular.
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PIN tuş takımı: 3 × 76 px, satır aralığı 12, sütun aralığı 24.
/// Sol alt köşe parmak izi tuşu ya da boşluk; sağ alt silme tuşu.
class PinKeypad extends StatelessWidget { // Rakam ve Silme Tuşlarından Oluşan Tuş Takımı StatelessWidget'ıdır.
  final ValueChanged<String> onDigit; // Rakam Tuşuna Basılınca Çağrılan Callback'tir.
  final VoidCallback onDelete; // Silme Tuşuna Basılınca Çağrılan Callback'tir.
  final bool enabled; // Tuşların Etkin Olup Olmadığıdır.
  final Widget? leading; // Sol Alt Köşede Gösterilecek İsteğe Bağlı Widget'tır.

  const PinKeypad({super.key, required this.onDigit, required this.onDelete, this.enabled = true, this.leading}); // Callback'leri Zorunlu Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Tuş Takımının Widget Tree'sini Oluşturur.
    Widget digit(String d) => PinKey(label: d, enabled: enabled, onTap: () => onDigit(d)); // Verilen Rakam İçin Tuş Üreten Yerel Fonksiyondur.
    Widget row(List<Widget> keys) => Row( // Tuşları Bir Satırda Dizen Yerel Fonksiyondur.
      mainAxisSize: MainAxisSize.min, // Genişliği İçerik Kadar Tutar.
      children: [ // Row'un Çocuk Listesidir.
        for (var i = 0; i < keys.length; i++) ...[if (i > 0) const SizedBox(width: 24), keys[i]], // Tuşlar Arasına 24 Boşluk Koyarak Dizer.
      ],
    );
    return Semantics( // Tuş Takımına Erişilebilirlik Etiketi Ekler.
      label: AppStrings.keypadLabel, // Tuş Takımı Etiketini Ayarlar.
      container: true, // Tuş Takımını Ayrı Semantik Kapsayıcı Yapar.
      child: Column( // Tuş Satırlarını Dikey Dizer.
        mainAxisSize: MainAxisSize.min, // Yüksekliği İçerik Kadar Tutar.
        children: [ // Column'un Çocuk Listesidir.
          row([digit('1'), digit('2'), digit('3')]), // 1-2-3 Satırını Oluşturur.
          const SizedBox(height: 12), // Satırlar Arasına 12 Boşluk Koyar.
          row([digit('4'), digit('5'), digit('6')]), // 4-5-6 Satırını Oluşturur.
          const SizedBox(height: 12), // Satırlar Arasına 12 Boşluk Koyar.
          row([digit('7'), digit('8'), digit('9')]), // 7-8-9 Satırını Oluşturur.
          const SizedBox(height: 12), // Satırlar Arasına 12 Boşluk Koyar.
          row([ // Son Satırı Oluşturur.
            leading ?? const SizedBox.square(dimension: PinKey.size), // leading Yoksa Tuş Boyutunda Boşluk Koyar.
            digit('0'), // 0 Tuşunu Ekler.
            PinKey( // Silme Tuşunu Oluşturur.
              icon: AppIcons.backspace, // Geri Silme Simgesini Kullanır.
              ghost: true, // Tuşu Zeminsiz Yapar.
              enabled: enabled, // Etkinlik Durumunu Aktarır.
              onTap: onDelete, // Basılınca onDelete'i Çağırır.
              label: AppStrings.deleteKey, // Erişilebilirlik Etiketini Ayarlar.
            ),
          ]),
        ],
      ),
    );
  }
}

class PinKey extends StatelessWidget { // Tuş Takımındaki Tek Bir Yuvarlak Tuşu Çizen StatelessWidget'tır.
  static const double size = 76; // Tuşun Çapıdır.

  final String label; // Tuş Metni ve Erişilebilirlik Etiketidir.
  final AppIconData? icon; // Metin Yerine Gösterilecek İsteğe Bağlı Simgedir.
  final bool ghost; // Tuşun Zeminsiz Olup Olmadığıdır.
  final bool enabled; // Tuşun Etkin Olup Olmadığıdır.
  final VoidCallback onTap; // Tuşa Basılınca Çağrılan Callback'tir.

  const PinKey({ // PinKey'in const Constructor'ıdır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.label, // label Field'ını required Yapar.
    required this.onTap, // onTap Field'ını required Yapar.
    this.icon, // icon Field'ını İsteğe Bağlı Alır.
    this.ghost = false, // ghost Varsayılanını false Yapar.
    this.enabled = true, // enabled Varsayılanını true Yapar.
  });

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Tuşun Widget Tree'sini Oluşturur.
    final p = context.palette; // Aktif Temanın Renk Paletini Alır.
    return Pressable( // Basılma Durumunu ve Ölçeklemeyi Yönetir.
      onTap: enabled ? onTap : null, // Etkinse onTap'i, Değilse null Verir.
      scale: AppMotion.pressKey, // Basılıyken Uygulanacak Ölçeği Ayarlar.
      semanticLabel: label, // Erişilebilirlik Etiketini Ayarlar.
      builder: (context, pressed) { // Basılma Durumuna Göre Tuşu Oluşturur.
        final background = ghost ? (pressed ? p.borderSoft : Colors.transparent) : (pressed ? p.keyActive : p.key); // Tuş Türü ve Basılma Durumuna Göre Zemin Rengini Seçer.
        final color = enabled ? (icon == null ? p.fg : p.fg2) : p.keyDisabled; // Etkinlik ve Simge Durumuna Göre İçerik Rengini Seçer.
        return AnimatedContainer( // Renk Değişimini Animasyonlu Yapan Tuş Gövdesidir.
          duration: AppMotion.press, // Geçiş Süresini press Yapar.
          curve: AppMotion.easeOut, // Geçiş Curve'ünü easeOut Yapar.
          width: size, // Tuş Genişliğini size Yapar.
          height: size, // Tuş Yüksekliğini size Yapar.
          decoration: BoxDecoration(shape: BoxShape.circle, color: background), // Zemin Renkli Daire Çizer.
          alignment: Alignment.center, // İçeriği Ortalar.
          child: icon != null // Simge Varsa:
              ? AppIcon(icon!, size: 28, strokeWidth: 1.7, color: color) // Simgeyi Çizer.
              : AnimatedDefaultTextStyle( // Değilse Metin Stilini Animasyonlu Uygular.
                  duration: AppMotion.ui, // Stil Geçiş Süresini ui Yapar.
                  style: AppTypography.display(28, weight: FontWeight.w400, height: 1.2, color: color), // 28 Punto Rakam Stilini Tanımlar.
                  child: Text(label), // Tuş Rakamını Yazar.
                ),
        );
      },
    );
  }
}
