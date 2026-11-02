import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // palette Uzantısını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons ve AppIconData Tanımlarını import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre ve Eğri Sabitlerini import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_buttons.dart'; // AppTextButton Widget'ını import Eder.
import '../../../core/widgets/app_dialog.dart'; // AppDialog ve showAppDialog'u import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.
import '../../../core/widgets/pressable.dart'; // Basılma Durumunu Veren Pressable Widget'ını import Eder.
import '../models/settings_model.dart'; // ThemeOption enum'unu import Eder.

/// Grup etiketi (`.group-label`): 14 / 500, soluk.
class SettingsGroupLabel extends StatelessWidget { // Ayar Grubu Başlığını Gösteren StatelessWidget'tır.
  final String text; // Gösterilecek Grup Adıdır.

  const SettingsGroupLabel(this.text, {super.key}); // text'i Konumsal Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Etiketin Widget Tree'sini Oluşturan Metottur.
    return Padding( // Etikete Kenar Boşluğu Verir.
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8), // Yatay 24, Üst 16, Alt 8 Boşluk Uygular.
      child: Semantics( // Erişilebilirlik Bilgisi Ekler.
        header: true, // Metni Ekran Okuyucuya Başlık Olarak Bildirir.
        child: Text( // Grup Adını Gösterir.
          text, // Gösterilecek Metindir.
          style: AppTypography.body(14, weight: FontWeight.w500, tracking: 0.02, color: context.palette.muted), // 14 / 500 Soluk Stil Uygular.
        ),
      ),
    );
  }
}

/// Ayar satırı (`.set-row`): min 72, 24 px simge, başlık + alt yazı ve
/// sağda ok ya da anahtar. Dokunulabilir satır basılıyken 0.985 ölçeklenir.
class SettingsRow extends StatelessWidget { // Simgeli, Başlıklı Ayar Satırını Gösteren StatelessWidget'tır.
  final AppIconData icon; // Satırın Solundaki Simgedir.
  final String title; // Satır Başlığıdır.
  final String subtitle; // Satır Alt Yazısıdır.
  final VoidCallback? onTap; // Satıra Dokunulduğunda Çağrılan Callback'tir.
  final bool? switchValue; // Anahtar Değeridir, null İse Anahtar Gösterilmez.
  final ValueChanged<bool>? onSwitch; // Anahtar Değiştiğinde Çağrılan Callback'tir.

  const SettingsRow({ // SettingsRow'un const Constructor'ıdır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.icon, // icon Field'ını required Yapar.
    required this.title, // title Field'ını required Yapar.
    required this.subtitle, // subtitle Field'ını required Yapar.
    this.onTap, // İsteğe Bağlı onTap Field'ını Atar.
    this.switchValue, // İsteğe Bağlı switchValue Field'ını Atar.
    this.onSwitch, // İsteğe Bağlı onSwitch Field'ını Atar.
  });

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Satırın Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    Widget content(bool pressed) => AnimatedContainer( // Basılma Durumuna Göre Satır İçeriğini Üreten Yerel Fonksiyondur.
      duration: AppMotion.press, // Geçiş Süresini Belirler.
      curve: AppMotion.easeOut, // Geçiş Eğrisini Belirler.
      constraints: const BoxConstraints(minHeight: 72), // Asgari Satır Yüksekliğini 72 Yapar.
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Satır İç Boşluğunu Belirler.
      color: pressed ? p.borderSoft : Colors.transparent, // Basılıyken Zemini Hafifçe Boyar.
      child: Row( // Simge, Metin ve Sağ Öğeyi Yatay Dizer.
        children: [ // Satır Öğelerinin Listesidir.
          AppIcon(icon, size: 24, color: p.fg2), // 24 px Satır Simgesini Çizer.
          const SizedBox(width: 16), // Simge ile Metin Arasına 16 px Boşluk Koyar.
          Expanded( // Metin Bloğunun Kalan Genişliği Almasını Sağlar.
            child: Column( // Başlık ve Alt Yazıyı Dikey Dizer.
              crossAxisAlignment: CrossAxisAlignment.start, // Metinleri Sola Hizalar.
              children: [ // Metin Öğelerinin Listesidir.
                Text(title, style: AppTypography.body(16, height: 1.35, color: p.fg)), // Başlığı 16 px Gösterir.
                const SizedBox(height: 2), // Başlık ile Alt Yazı Arasına 2 px Boşluk Koyar.
                Text(subtitle, style: AppTypography.body(14, height: 1.35, color: p.muted)), // Alt Yazıyı Soluk Gösterir.
              ],
            ),
          ),
          if (switchValue != null) ...[ // Anahtar Değeri Varsa Anahtar Ekler.
            const SizedBox(width: 16), // Metin ile Anahtar Arasına 16 px Boşluk Koyar.
            Switch(value: switchValue!, onChanged: onSwitch), // Açma/Kapama Anahtarını Gösterir.
          ] else if (onTap != null) ...[ // Dokunulabilir Satırsa Ok Ekler.
            const SizedBox(width: 16), // Metin ile Ok Arasına 16 px Boşluk Koyar.
            AppIcon(AppIcons.chevron, color: p.muted), // Sağa Ok Simgesini Çizer.
          ],
        ],
      ),
    );
    if (switchValue != null) return MergeSemantics(child: content(false)); // Anahtarlı Satırda Semantics'i Birleştirerek Döndürür.
    if (onTap == null) return Semantics(container: true, child: content(false)); // Etkileşimsiz Satırı Ayrı Semantics Düğümüyle Döndürür.
    return Pressable( // Dokunulabilir Satırı Pressable İle Sarar.
      onTap: onTap, // Dokunuşta onTap Callback'ini Çağırır.
      scale: AppMotion.pressRow, // Basılıyken Satır Ölçeğini Uygular.
      semanticLabel: '$title, $subtitle', // Başlık ve Alt Yazıyı Erişilebilirlik Etiketi Yapar.
      builder: (context, pressed) => ExcludeSemantics(child: content(pressed)), // İç Semantics'i Gizleyerek İçeriği Çizer.
    );
  }
}

/// Satır ayırıcı (`.divider`): 1 px `borderSoft`, yatay 24 boşluk.
class SettingsDivider extends StatelessWidget { // Ayar Satırları Arasındaki Ayırıcıyı Çizen StatelessWidget'tır.
  const SettingsDivider({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) => // Ayırıcının Widget Tree'sini Oluşturan Metottur.
      Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 24), color: context.palette.borderSoft); // Yatay 24 Boşluklu 1 px Çizgi Çizer.
}

/// Bilgi notu (`.note`): `bg` zemin, kalkan simgesi.
class SettingsNote extends StatelessWidget { // Kalkan Simgeli Bilgi Notunu Gösteren StatelessWidget'tır.
  final String text; // Gösterilecek Not Metnidir.

  const SettingsNote(this.text, {super.key}); // text'i Konumsal Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Notun Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return Container( // Not Kutusunu Oluşturur.
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0), // Kutunun Dış Boşluğunu Belirler.
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Kutunun İç Boşluğunu Belirler.
      decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(12)), // bg Zemin ve 12 px Yuvarlak Köşe Verir.
      child: Row( // Simge ve Metni Yatay Dizer.
        crossAxisAlignment: CrossAxisAlignment.start, // Öğeleri Üstten Hizalar.
        children: [ // Not Öğelerinin Listesidir.
          Padding( // Simgeye Üst Boşluk Verir.
            padding: const EdgeInsets.only(top: 1), // Üste 1 px Boşluk Uygular.
            child: AppIcon(AppIcons.shield, color: p.fg2), // Kalkan Simgesini Çizer.
          ),
          const SizedBox(width: 12), // Simge ile Metin Arasına 12 px Boşluk Koyar.
          Expanded( // Metnin Kalan Genişliği Almasını Sağlar.
            child: Text(text, style: AppTypography.body(14, color: p.fg2)), // Not Metnini Gösterir.
          ),
        ],
      ),
    );
  }
}

/// Tema seçimi (radyo diyaloğu): Sistem varsayılanı / Açık / Koyu.
class ThemeDialog extends StatefulWidget { // Tema Seçim Diyaloğunu Oluşturan StatefulWidget'tır.
  final ThemeOption initial; // Diyalog Açıldığında Seçili Olan Temadır.

  const ThemeDialog({super.key, required this.initial}); // initial'ı required Yapan const Constructor'dır.

  static Future<ThemeOption?> show(BuildContext context, ThemeOption initial) => showAppDialog<ThemeOption>( // Diyaloğu Açıp Seçilen Temayı Döndüren static Metottur.
    context: context, // Diyaloğun Açılacağı context'i Verir.
    builder: (_) => ThemeDialog(initial: initial), // Diyalog İçeriğini Oluşturur.
  );

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<ThemeDialog> createState() => _ThemeDialogState(); // Widget'ın State Nesnesini Oluşturur.
}

class _ThemeDialogState extends State<ThemeDialog> { // Tema Diyaloğunun Seçim Durumunu Yöneten State Class'ıdır.
  late ThemeOption _selected = widget.initial; // Geçerli Seçimi Başlangıç Temasıyla Başlatır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Diyaloğun Widget Tree'sini Oluşturan Metottur.
    return AppDialog.lock( // Kilit Stili Uygulama Diyaloğunu Döndürür.
      title: AppStrings.theme, // Tema Başlığını Verir.
      // `.radios { margin: 0 -12px }`: satırlar diyalog iç boşluğuna 12 px taşar.
      bodyBleed: 12, // Gövdenin Yanlara 12 px Taşmasını Sağlar.
      body: Semantics( // Radyo Grubuna Erişilebilirlik Etiketi Ekler.
        label: AppStrings.theme, // Grup Etiketini Tema Yapar.
        container: true, // Grubu Ayrı Bir Semantics Düğümü Yapar.
        child: Column( // Seçenekleri Dikey Dizer.
          mainAxisSize: MainAxisSize.min, // Yüksekliği İçerik Kadar Tutar.
          children: [ // Seçenek Satırlarının Listesidir.
            for (final option in ThemeOption.values) ...[ // Her Tema Seçeneği İçin Satır Üretir.
              if (option != ThemeOption.values.first) const SizedBox(height: 2), // İlk Satır Dışında Aralara 2 px Boşluk Koyar.
              _ThemeRadioRow( // Radyo Satırını Oluşturur.
                option: option, // Satırın Temsil Ettiği Seçeneği Verir.
                selected: option == _selected, // Geçerli Seçimle Eşleşiyorsa Seçili Yapar.
                onTap: () => setState(() => _selected = option), // Dokunulunca Seçimi Günceller.
              ),
            ],
          ],
        ),
      ),
      actions: [ // Diyalog Butonlarının Listesidir.
        AppTextButton(label: AppStrings.cancel, onPressed: () => Navigator.of(context).pop()), // Vazgeç Butonu Diyaloğu Sonuçsuz Kapatır.
        AppTextButton(label: AppStrings.ok, onPressed: () => Navigator.of(context).pop(_selected)), // Tamam Butonu Seçili Temayla Kapatır.
      ],
    );
  }
}

class _ThemeRadioRow extends StatelessWidget { // Tek Bir Tema Seçeneğini Radyo Satırı Olarak Gösteren StatelessWidget'tır.
  final ThemeOption option; // Satırın Temsil Ettiği Tema Seçeneğidir.
  final bool selected; // Satırın Seçili Olup Olmadığıdır.
  final VoidCallback onTap; // Satıra Dokunulduğunda Çağrılan Callback'tir.

  const _ThemeRadioRow({required this.option, required this.selected, required this.onTap}); // Tüm Field'ları required Yapan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Radyo Satırının Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return Semantics( // Radyo Benzeri Erişilebilirlik Bilgisi Ekler.
      inMutuallyExclusiveGroup: true, // Satırı Tekli Seçim Grubunun Parçası Yapar.
      checked: selected, // Seçili Durumunu Ekran Okuyucuya Bildirir.
      child: Pressable( // Basılma Durumunu Takip Eden Dokunulabilir Alandır.
        onTap: onTap, // Dokunuşta onTap Callback'ini Çağırır.
        scale: AppMotion.pressRow, // Basılıyken Satır Ölçeğini Uygular.
        button: false, // Satırı Buton Olarak İşaretlemez.
        semanticLabel: '${option.label}, ${option.description}', // Seçenek Adı ve Açıklamasını Erişilebilirlik Etiketi Yapar.
        builder: (context, pressed) => ExcludeSemantics( // İç Semantics'i Gizleyerek İçeriği Oluşturur.
          child: AnimatedContainer( // Basılma Zeminini Animasyonlu Değiştiren Kutudur.
            duration: AppMotion.press, // Geçiş Süresini Belirler.
            curve: AppMotion.easeOut, // Geçiş Eğrisini Belirler.
            constraints: const BoxConstraints(minHeight: 56), // Asgari Satır Yüksekliğini 56 Yapar.
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Satır İç Boşluğunu Belirler.
            decoration: BoxDecoration( // Satırın Görünümünü Tanımlar.
              color: pressed ? p.borderSoft : Colors.transparent, // Basılıyken Zemini Hafifçe Boyar.
              borderRadius: BorderRadius.circular(12), // Köşeleri 12 px Yuvarlar.
            ),
            child: Row( // Radyo Dairesi ve Metni Yatay Dizer.
              children: [ // Satır Öğelerinin Listesidir.
                AnimatedContainer( // Radyo Dış Halkasını Animasyonlu Çizer.
                  duration: AppMotion.press, // Geçiş Süresini Belirler.
                  curve: AppMotion.easeOut, // Geçiş Eğrisini Belirler.
                  width: 20, // Genişliği 20 Yapar.
                  height: 20, // Yüksekliği 20 Yapar.
                  decoration: BoxDecoration( // Halkanın Görünümünü Tanımlar.
                    shape: BoxShape.circle, // Şekli Daire Yapar.
                    color: selected ? p.surface : Colors.transparent, // Seçiliyken Yüzey Rengiyle Doldurur.
                    border: Border.all(color: selected ? p.accent : p.muted, width: 2), // Seçiliyken Vurgu Renkli Kenar Çizer.
                  ),
                  alignment: Alignment.center, // İç Noktayı Ortalar.
                  child: AnimatedContainer( // Radyo İç Noktasını Animasyonlu Çizer.
                    duration: AppMotion.press, // Geçiş Süresini Belirler.
                    curve: AppMotion.easeOut, // Geçiş Eğrisini Belirler.
                    width: selected ? 10 : 0, // Seçiliyken Genişliği 10 Yapar.
                    height: selected ? 10 : 0, // Seçiliyken Yüksekliği 10 Yapar.
                    decoration: BoxDecoration(shape: BoxShape.circle, color: p.accent), // Vurgu Renkli Daire Çizer.
                  ),
                ),
                const SizedBox(width: 16), // Radyo ile Metin Arasına 16 px Boşluk Koyar.
                Expanded( // Metin Bloğunun Kalan Genişliği Almasını Sağlar.
                  child: Column( // Ad ve Açıklamayı Dikey Dizer.
                    crossAxisAlignment: CrossAxisAlignment.start, // Metinleri Sola Hizalar.
                    children: [ // Metin Öğelerinin Listesidir.
                      Text(option.label, style: AppTypography.body(16, height: 1.35, color: p.fg)), // Seçenek Adını Gösterir.
                      Text(option.description, style: AppTypography.body(14, height: 1.35, color: p.muted)), // Seçenek Açıklamasını Soluk Gösterir.
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Örnek veriye dön" onayı.
class ResetSampleDialog extends StatelessWidget { // Örnek Veriye Dönüş Onay Diyaloğunu Oluşturan StatelessWidget'tır.
  const ResetSampleDialog({super.key}); // key Parametresini Superclass'a İleten const Constructor'dır.

  static Future<bool> show(BuildContext context) async => // Diyaloğu Açıp Onay Sonucunu Döndüren static Metottur.
      await showAppDialog<bool>(context: context, builder: (_) => const ResetSampleDialog()) ?? false; // Diyalog Kapatılırsa false Döndürür.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Diyaloğun Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    return AppDialog.lock( // Kilit Stili Uygulama Diyaloğunu Döndürür.
      title: AppStrings.resetSampleTitle, // Sıfırlama Başlığını Verir.
      body: Padding( // Gövde Metnine Alt Boşluk Verir.
        padding: const EdgeInsets.only(bottom: 12), // Alta 12 px Boşluk Uygular.
        child: Text(AppStrings.resetSampleBody, style: AppTypography.body(14, color: p.fg2)), // Sıfırlama Açıklamasını Gösterir.
      ),
      actions: [ // Diyalog Butonlarının Listesidir.
        AppTextButton(label: AppStrings.cancel, onPressed: () => Navigator.of(context).pop(false)), // Vazgeç Butonu Diyaloğu false İle Kapatır.
        AppTextButton(label: AppStrings.resetSample, onPressed: () => Navigator.of(context).pop(true)), // Onay Butonu Diyaloğu true İle Kapatır.
      ],
    );
  }
}
