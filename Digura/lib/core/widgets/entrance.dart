import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../constants/app_motion.dart'; // Giriş Süreleri, Curve'ler Ve reduceMotion İçin AppMotion'ı import Eder.

/// Kademeli blok girişi (ANIMATION.md 5.2): saydamlık + 8 dp yukarı.
///
/// [EntranceScope] tek bir `AnimationController` tutar; [EntranceItem]'lar
/// kendi gecikmesini `Interval` ile okur. Hareket azaltma açıkken yalnızca
/// solma kalır. [trigger] değiştiğinde giriş baştan oynar.
class EntranceScope extends StatefulWidget { // Kademeli Giriş Animasyonunu Yöneten StatefulWidget'tır.
  final Widget child; // Animasyonlu Öğeleri İçeren Alt Widget'tır.
  final Object? trigger; // Değiştiğinde Girişi Yeniden Oynatan Tetikleyicidir.
  final bool playOnMount; // İlk Yüklemede Animasyonun Oynatılıp Oynatılmayacağını Belirtir.
  final Duration duration; // Her Öğenin Giriş Süresidir.
  final Duration step; // Öğeler Arası Gecikme Adımıdır.
  final Duration maxDelay; // Bir Öğenin Alabileceği En Fazla Gecikmedir.

  const EntranceScope({ // Varsayılan Kademeli Giriş Ayarlarıyla const Constructor'dır.
    super.key, // key Parametresini Superclass'a İletir.
    required this.child, // child Field'ını required Yapar.
    this.trigger, // İsteğe Bağlı Tetikleyiciyi Alır.
    this.playOnMount = false, // Varsayılan Olarak İlk Yüklemede Oynatmaz.
    this.duration = AppMotion.settle, // Varsayılan Giriş Süresini settle Yapar.
    this.step = AppMotion.stagger, // Varsayılan Adım Gecikmesini stagger Yapar.
    this.maxDelay = AppMotion.staggerMax, // Varsayılan En Fazla Gecikmeyi staggerMax Yapar.
  });

  /// İlk açılış girişi: 420 ms, bloklar 0 / 60 / 120 ms.
  const EntranceScope.intro({super.key, required this.child, this.playOnMount = true}) // İlk Açılış İçin Named const Constructor'dır.
    : trigger = null, // Tetikleyici Kullanmaz.
      duration = AppMotion.intro, // Giriş Süresini intro Yapar.
      step = AppMotion.introStep, // Adım Gecikmesini introStep Yapar.
      maxDelay = AppMotion.staggerMax; // En Fazla Gecikmeyi staggerMax Yapar.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<EntranceScope> createState() => _EntranceScopeState(); // Widget'ın State Nesnesini Oluşturur.
}

class _EntranceScopeState extends State<EntranceScope> with SingleTickerProviderStateMixin { // AnimationController İçin Ticker Sağlayan State Class'ıdır.
  late final AnimationController _controller = AnimationController( // Tüm Öğeleri Süren Tek AnimationController'ı Tembel Oluşturur.
    vsync: this, // Ticker Kaynağı Olarak Bu State'i Kullanır.
    duration: widget.duration + widget.maxDelay, // Toplam Süreyi Giriş Süresi Artı En Fazla Gecikme Yapar.
    value: widget.playOnMount ? 0 : 1, // Oynatılacaksa Baştan, Değilse Bitmiş Durumdan Başlatır.
  );

  @override // Superclass'taki initState Metodunun Override Edildiğini Belirtir.
  void initState() { // State İlk Oluşturulduğunda Çalışır.
    super.initState(); // Superclass'ın initState Metodunu Çağırır.
    if (widget.playOnMount) _controller.forward(); // playOnMount Açıksa Animasyonu Başlatır.
  }

  @override // Superclass'taki didUpdateWidget Metodunun Override Edildiğini Belirtir.
  void didUpdateWidget(EntranceScope oldWidget) { // Widget Güncellendiğinde Tetikleyiciyi Kontrol Eder.
    super.didUpdateWidget(oldWidget); // Superclass'ın didUpdateWidget Metodunu Çağırır.
    if (widget.trigger != oldWidget.trigger) _controller.forward(from: 0); // Tetikleyici Değiştiyse Animasyonu Baştan Oynatır.
  }

  @override // Superclass'taki dispose Metodunun Override Edildiğini Belirtir.
  void dispose() { // State Kaldırılırken Kaynakları Serbest Bırakır.
    _controller.dispose(); // AnimationController'ı dispose Eder.
    super.dispose(); // Superclass'ın dispose Metodunu Çağırır.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) => _EntranceData( // Animasyon Verisini Alt Ağaca Sağlayan _EntranceData'yı Döndürür.
    animation: _controller, // Ortak Animasyonu Verir.
    duration: widget.duration, // Öğe Giriş Süresini Verir.
    step: widget.step, // Adım Gecikmesini Verir.
    maxDelay: widget.maxDelay, // En Fazla Gecikmeyi Verir.
    child: widget.child, // Alt Widget'ı Verir.
  );
}

class _EntranceData extends InheritedWidget { // Giriş Animasyonu Verisini EntranceItem'lara Taşıyan InheritedWidget'tır.
  final Animation<double> animation; // Ortak Giriş Animasyonudur.
  final Duration duration; // Öğe Giriş Süresidir.
  final Duration step; // Öğeler Arası Gecikme Adımıdır.
  final Duration maxDelay; // En Fazla Gecikmedir.

  const _EntranceData({ // Tüm Alanları required Alan const Constructor'dır.
    required this.animation, // animation Field'ını required Yapar.
    required this.duration, // duration Field'ını required Yapar.
    required this.step, // step Field'ını required Yapar.
    required this.maxDelay, // maxDelay Field'ını required Yapar.
    required super.child, // child'ı Superclass'a required Olarak İletir.
  });

  @override // Superclass'taki updateShouldNotify Metodunun Override Edildiğini Belirtir.
  bool updateShouldNotify(_EntranceData old) => animation != old.animation; // Animasyon Nesnesi Değiştiyse Bağımlıları Bilgilendirir.
}

class EntranceItem extends StatelessWidget { // Sırasına Göre Gecikmeli Giriş Yapan StatelessWidget'tır.
  final int index; // Öğenin Giriş Sırasıdır.
  final Widget child; // Animasyonla Gösterilecek Widget'tır.

  const EntranceItem({super.key, required this.index, required this.child}); // index Ve child'ı required Alan const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Gecikmeli Solma Ve Kayma Animasyonunu Oluşturur.
    final data = context.dependOnInheritedWidgetOfExactType<_EntranceData>(); // Üstteki _EntranceData'ya Bağımlılık Kurarak Alır.
    if (data == null) return child; // EntranceScope Yoksa child'ı Animasyonsuz Döndürür.
    final total = (data.duration + data.maxDelay).inMicroseconds; // Toplam Animasyon Süresini Mikrosaniye Olarak Hesaplar.
    var delay = data.step * index; // Sıraya Göre Gecikmeyi Hesaplar.
    if (delay > data.maxDelay) delay = data.maxDelay; // Gecikmeyi En Fazla Gecikmeyle Sınırlar.
    final start = delay.inMicroseconds / total; // Interval Başlangıç Oranını Hesaplar.
    final end = (delay + data.duration).inMicroseconds / total; // Interval Bitiş Oranını Hesaplar.
    final interval = Interval(start, end.clamp(0.0, 1.0), curve: AppMotion.easeOut); // Öğeye Özel easeOut Interval'ı Oluşturur.
    final reduce = context.reduceMotion; // Hareket Azaltma Tercihini Okur.
    return AnimatedBuilder( // Animasyon Değiştikçe Yeniden Çizer.
      animation: data.animation, // Ortak Animasyonu Dinler.
      child: child, // Yeniden Oluşturulmayacak child'ı Verir.
      builder: (context, child) { // Her Karede Dönüşümü Uygulayan builder'dır.
        final t = interval.transform(data.animation.value); // Öğenin Kendi İlerleme Değerini Hesaplar.
        final faded = Opacity(opacity: t, child: child); // İlerlemeye Göre Saydamlık Uygular.
        if (reduce || t == 1) return faded; // Hareket Azaltma Açıksa Ya Da Animasyon Bittiyse Yalnızca Solmayı Döndürür.
        return Transform.translate(offset: Offset(0, AppMotion.enterOffset * (1 - t)), child: faded); // Öğeyi Aşağıdan Yukarı Kaydırır.
      },
    );
  }
}
