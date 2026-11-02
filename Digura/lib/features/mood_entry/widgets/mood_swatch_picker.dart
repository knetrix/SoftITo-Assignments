import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'u ve palette Uzantısını import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons Simge Tanımlarını import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre ve Eğri Sabitlerini import Eder.
import '../../../core/constants/app_strings.dart'; // Kullanıcıya Gösterilen AppStrings Metinlerini import Eder.
import '../../../core/theme/app_theme.dart'; // AppTypography Yazı Stillerini import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.
import '../../../core/widgets/pressable.dart'; // Basılma Durumunu Veren Pressable Widget'ını import Eder.

/// Beşli duygu seçici (`swatches`): 50 px daire, seçili = `bg` + `fg` çift
/// halka (3 + 5 px) ve onay simgesi. Basılıyken daire 0.94 ölçeklenir.
class MoodSwatchPicker extends StatelessWidget { // Beş Duyguyu Yan Yana Seçtiren StatelessWidget'tır.
  final Mood? selected; // Seçili Duygudur, Seçim Yoksa null'dır.
  final ValueChanged<Mood> onSelect; // Duygu Seçildiğinde Çağrılan Callback'tir.
  final double dotSize; // Renk Dairelerinin Çapıdır.
  final Color? ringGapColor; // Seçim Halkası Arasındaki Boşluğun Rengidir.

  const MoodSwatchPicker({ // MoodSwatchPicker'ın const Constructor'ıdır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.selected, // selected Field'ını required Yapar.
    required this.onSelect, // onSelect Field'ını required Yapar.
    this.dotSize = 50, // Varsayılan Daire Çapını 50 Yapar.
    this.ringGapColor, // İsteğe Bağlı ringGapColor Field'ını Atar.
  });

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Seçicinin Widget Tree'sini Oluşturan Metottur.
    return Semantics( // Seçiciye Erişilebilirlik Etiketi Ekler.
      label: AppStrings.moodPickerLabel, // Ekran Okuyucu Etiketini Verir.
      container: true, // Seçiciyi Ayrı Bir Semantics Düğümü Yapar.
      child: Padding( // Seçiciye Yatay Boşluk Verir.
        padding: const EdgeInsets.symmetric(horizontal: 12), // Yatay 12 px Boşluk Uygular.
        child: Row( // Renkleri Yatay Dizer.
          crossAxisAlignment: CrossAxisAlignment.start, // Öğeleri Üstten Hizalar.
          children: [ // Renk Öğelerinin Listesidir.
            for (var i = 0; i < Mood.values.length; i++) ...[ // Her Duygu İçin Öğe Üretir.
              if (i > 0) const SizedBox(width: 6), // İlk Öğe Dışında Aralara 6 px Boşluk Koyar.
              Expanded( // Her Rengin Eşit Genişlik Almasını Sağlar.
                child: MoodSwatch( // Tek Bir Renk Seçeneğini Gösterir.
                  mood: Mood.values[i], // Öğenin Duygusunu Verir.
                  selected: selected == Mood.values[i], // Seçili Duyguyla Eşleşiyorsa Seçili Yapar.
                  onTap: () => onSelect(Mood.values[i]), // Dokunulunca Bu Duyguyu Seçer.
                  dotSize: dotSize, // Daire Çapını İletir.
                  ringGapColor: ringGapColor, // Halka Boşluk Rengini İletir.
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MoodSwatch extends StatelessWidget { // Tek Bir Duygu Rengini ve Etiketini Gösteren StatelessWidget'tır.
  final Mood mood; // Gösterilen Duygudur.
  final bool selected; // Bu Rengin Seçili Olup Olmadığıdır.
  final VoidCallback onTap; // Dokunulduğunda Çağrılan Callback'tir.
  final double dotSize; // Renk Dairesinin Çapıdır.
  final Color? ringGapColor; // Seçim Halkası Arasındaki Boşluğun Rengidir.

  const MoodSwatch({ // MoodSwatch'ın const Constructor'ıdır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.mood, // mood Field'ını required Yapar.
    required this.selected, // selected Field'ını required Yapar.
    required this.onTap, // onTap Field'ını required Yapar.
    this.dotSize = 50, // Varsayılan Daire Çapını 50 Yapar.
    this.ringGapColor, // İsteğe Bağlı ringGapColor Field'ını Atar.
  });

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Renk Öğesinin Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    final reduce = context.reduceMotion; // Hareket Azaltma Tercihini Okur.
    return Semantics( // Radyo Benzeri Erişilebilirlik Bilgisi Ekler.
      inMutuallyExclusiveGroup: true, // Öğeyi Tekli Seçim Grubunun Parçası Yapar.
      checked: selected, // Seçili Durumunu Ekran Okuyucuya Bildirir.
      child: Pressable( // Basılma Durumunu Takip Eden Dokunulabilir Alandır.
        onTap: onTap, // Dokunuşta onTap Callback'ini Çağırır.
        scale: 1, // Tüm Öğenin Ölçeklenmesini Kapatır.
        semanticLabel: mood.label, // Erişilebilirlik Etiketi Olarak Duygu Adını Verir.
        button: false, // Öğeyi Buton Olarak İşaretlemez.
        builder: (context, pressed) => Padding( // Basılma Durumuna Göre İçeriği Oluşturur.
          padding: const EdgeInsets.symmetric(vertical: 4), // Dikey 4 px Boşluk Uygular.
          child: Column( // Daire ve Etiketi Dikey Dizer.
            children: [ // Öğe İçeriğinin Listesidir.
              AnimatedScale( // Basılıyken Daireyi Animasyonla Küçültür.
                scale: pressed && !reduce ? AppMotion.pressSwatch : 1, // Basılıysa ve Hareket Açıksa Basma Ölçeğini Uygular.
                duration: AppMotion.press, // Ölçek Geçiş Süresini Belirler.
                curve: AppMotion.easeOut, // Ölçek Geçiş Eğrisini Belirler.
                child: AnimatedContainer( // Seçim Halkasını Animasyonlu Çizen Daireyi Oluşturur.
                  duration: AppMotion.press, // Geçiş Süresini Belirler.
                  curve: AppMotion.easeOut, // Geçiş Eğrisini Belirler.
                  width: dotSize, // Genişliği Daire Çapına Eşitler.
                  height: dotSize, // Yüksekliği Daire Çapına Eşitler.
                  decoration: BoxDecoration( // Dairenin Görünümünü Tanımlar.
                    shape: BoxShape.circle, // Şekli Daire Yapar.
                    color: p.mood(mood), // Duygunun Rengini Uygular.
                    boxShadow: [ // Çift Halkayı Gölgelerle Oluşturur.
                      BoxShadow(color: p.fg, spreadRadius: selected ? 5 : 0), // Seçiliyken Dış fg Halkasını Çizer.
                      BoxShadow(color: ringGapColor ?? p.bg, spreadRadius: selected ? 3 : 0), // Seçiliyken İç Boşluk Halkasını Çizer.
                    ],
                  ),
                  alignment: Alignment.center, // İçeriği Ortalar.
                  child: AnimatedOpacity( // Onay Simgesini Animasyonla Gösterip Gizler.
                    opacity: selected ? 1 : 0, // Seçiliyse Görünür Yapar.
                    duration: AppMotion.press, // Saydamlık Geçiş Süresini Belirler.
                    child: AppIcon(AppIcons.check, size: 22, strokeWidth: 2.6, color: p.onMood(mood)), // Renk Üzerinde Okunur Onay Simgesini Çizer.
                  ),
                ),
              ),
              const SizedBox(height: 6), // Daire ile Etiket Arasına 6 px Boşluk Koyar.
              ConstrainedBox( // Etikete Asgari Yükseklik Verir.
                constraints: const BoxConstraints(minHeight: 29), // Asgari Yüksekliği 29 Yapar.
                child: Text( // Duygu Etiketini Gösterir.
                  mood.stackedLabel, // Alt Alta Bölünmüş Duygu Adını Kullanır.
                  textAlign: TextAlign.center, // Metni Ortalar.
                  style: AppTypography.body( // Gövde Yazı Stilini Uygular.
                    12, // Yazı Boyutunu 12 Yapar.
                    height: 1.2, // Satır Yüksekliğini 1.2 Yapar.
                    weight: selected ? FontWeight.w600 : FontWeight.w400, // Seçiliyse Kalın Yazar.
                    color: selected ? p.fg : p.muted, // Seçiliyse Normal, Değilse Soluk Renk Kullanır.
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
