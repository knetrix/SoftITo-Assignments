import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../../../core/constants/app_colors.dart'; // Mood enum'u, palette ve cssShadow'u import Eder.
import '../../../core/constants/app_icons.dart'; // AppIcons Simge Tanımlarını import Eder.
import '../../../core/constants/app_motion.dart'; // AppMotion Süre ve Eğri Sabitlerini import Eder.
import '../../../core/widgets/app_icon.dart'; // SVG Tabanlı AppIcon Widget'ını import Eder.

/// Büyük renk dairesi (`orb`, 152 px). Boşken `empty` + iç çizgi; doluyken
/// duygu rengi + renk gölgesi. Renk değişince 0.94 → 1 ölçek ve 0.7 → 1
/// saydamlıkla yerleşir (`settle`); [popKey] değişince bir kez `savedPop`.
class MoodOrb extends StatefulWidget { // Animasyonlu Büyük Renk Dairesini Çizen StatefulWidget'tır.
  final Mood? mood; // Dairenin Gösterdiği Duygudur, Boşsa null'dır.
  final bool showCheck; // Dairede Onay Simgesi Gösterilip Gösterilmeyeceğidir.
  final double size; // Dairenin Çapıdır.
  final Object? popKey; // Değiştiğinde savedPop Animasyonunu Tetikleyen Anahtardır.

  /// Kayıttan hemen sonra yeni oluşturulan dairenin bir kez yerleşmesi.
  final bool popOnMount; // İlk Oluşturulmada Animasyon Oynatılıp Oynatılmayacağıdır.

  const MoodOrb({ // MoodOrb'un const Constructor'ıdır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.mood, // mood Field'ını required Yapar.
    this.showCheck = false, // showCheck Varsayılanını false Yapar.
    this.size = 152, // Varsayılan Çapı 152 Yapar.
    this.popKey, // İsteğe Bağlı popKey Field'ını Atar.
    this.popOnMount = false, // popOnMount Varsayılanını false Yapar.
  });

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<MoodOrb> createState() => _MoodOrbState(); // Widget'ın State Nesnesini Oluşturur.
}

class _MoodOrbState extends State<MoodOrb> with SingleTickerProviderStateMixin { // Daire Animasyonunu Yöneten State Class'ıdır.
  late final AnimationController _pop = AnimationController(vsync: this, value: 1); // Yerleşme Animasyonunu Süren, Tamamlanmış Başlayan AnimationController'dır.

  @override // Superclass'taki initState Metodunun Override Edildiğini Belirtir.
  void initState() { // State İlk Oluşturulduğunda Çağrılan Metottur.
    super.initState(); // Superclass'ın initState Metodunu Çağırır.
    if (widget.popOnMount) _play(AppMotion.savedPop); // popOnMount true İse savedPop Animasyonunu Oynatır.
  }

  @override // Superclass'taki didUpdateWidget Metodunun Override Edildiğini Belirtir.
  void didUpdateWidget(MoodOrb oldWidget) { // Widget Parametreleri Değiştiğinde Çağrılan Metottur.
    super.didUpdateWidget(oldWidget); // Superclass'ın didUpdateWidget Metodunu Çağırır.
    if (widget.popKey != oldWidget.popKey && widget.popKey != null) { // popKey Değiştiyse Kontrol Eder.
      _play(AppMotion.savedPop); // savedPop Animasyonunu Oynatır.
    } else if (widget.mood != oldWidget.mood && widget.mood != null) { // Duygu Yeni Bir Değere Değiştiyse Kontrol Eder.
      _play(AppMotion.settle); // settle Animasyonunu Oynatır.
    }
  }

  void _play(Duration duration) { // Animasyonu Verilen Süreyle Baştan Oynatan Metottur.
    _pop.duration = duration; // Animasyon Süresini Ayarlar.
    _pop.forward(from: 0); // Animasyonu Sıfırdan İleri Oynatır.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Temizleyen Metottur.
    _pop.dispose(); // AnimationController'ı dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Dairenin Widget Tree'sini Oluşturan Metottur.
    final p = context.palette; // Temanın Renk Paletini Alır.
    final mood = widget.mood; // Gösterilecek Duyguyu Alır.
    final fill = mood == null ? p.empty : p.mood(mood); // Duyguya Göre Dolgu Rengini Belirler.
    final reduce = context.reduceMotion; // Hareket Azaltma Tercihini Okur.
    final orb = AnimatedContainer( // Renk Geçişini Animasyonlu Yapan Daireyi Oluşturur.
      duration: AppMotion.ui, // Geçiş Süresini Belirler.
      curve: AppMotion.easeOut, // Geçiş Eğrisini Belirler.
      width: widget.size, // Genişliği Daire Çapına Eşitler.
      height: widget.size, // Yüksekliği Daire Çapına Eşitler.
      decoration: BoxDecoration( // Dairenin Görünümünü Tanımlar.
        shape: BoxShape.circle, // Şekli Daire Yapar.
        color: fill, // Dolgu Rengini Uygular.
        border: mood == null ? Border.all(color: p.border) : null, // Boşken Kenar Çizgisi Ekler.
        boxShadow: [if (mood != null) cssShadow(color: fill, y: 18, blur: 40, spread: -16)], // Doluyken Renkli Gölge Ekler.
      ),
      alignment: Alignment.center, // İçeriği Ortalar.
      child: mood == null // Duygu Seçili Mi Kontrol Eder.
          ? AppIcon(AppIcons.dot, size: 30, color: p.muted) // Boşken Soluk Nokta Simgesi Gösterir.
          : (widget.showCheck ? AppIcon(AppIcons.check, size: 30, color: p.onMood(mood)) : null), // İstenirse Onay Simgesi Gösterir.
    );
    return AnimatedBuilder( // Animasyon Değeriyle Daireyi Yeniden Çizer.
      animation: _pop, // Dinlenecek AnimationController'ı Verir.
      child: orb, // Yeniden Oluşturulmayacak Daire child'ını Verir.
      builder: (context, child) { // Her Karede Çalışan builder Callback'idir.
        final t = AppMotion.easeOut.transform(_pop.value); // Animasyon İlerlemesini Eğriye Göre Dönüştürür.
        final opacity = AppMotion.orbOpacityFrom + (1 - AppMotion.orbOpacityFrom) * t; // Başlangıçtan 1'e Saydamlığı Hesaplar.
        if (reduce) return Opacity(opacity: opacity, child: child); // Hareket Azaltılmışsa Yalnızca Saydamlık Uygular.
        final scale = AppMotion.orbFrom + (1 - AppMotion.orbFrom) * t; // Başlangıçtan 1'e Ölçeği Hesaplar.
        return Opacity( // Saydamlık Uygulayan Widget Döndürür.
          opacity: opacity, // Hesaplanan Saydamlığı Verir.
          child: Transform.scale(scale: scale, child: child), // Daireyi Hesaplanan Ölçekle Büyütür.
        );
      },
    );
  }
}
