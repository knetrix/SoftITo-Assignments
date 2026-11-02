import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../constants/app_motion.dart'; // Basma Ölçekleri, Süre Ve reduceMotion İçin AppMotion'ı import Eder.

typedef PressedWidgetBuilder = Widget Function(BuildContext context, bool pressed); // Basılı Durumuna Göre Widget Üreten builder Tipidir.

/// Basma geri bildirimi (ANIMATION.md 4.1): basılıyken ölçek küçülür,
/// bırakılınca geri döner. Düğme 0.97 · tuş 0.94 · swatch 0.92–0.94 ·
/// hücre 0.96. Hareket azaltma açıkken ölçek değişmez.
///
/// Yerel UI durumu olduğu için `StatefulWidget` kabul edilen tek istisnadır.
class Pressable extends StatefulWidget { // Basma Ölçek Animasyonu Sağlayan StatefulWidget'tır.
  final Widget? child; // Sabit İçerik Widget'ıdır.
  final PressedWidgetBuilder? builder; // Basılı Durumuna Göre İçerik Üreten builder'dır.
  final VoidCallback? onTap; // Dokunulduğunda Çağrılan Callback'tir.
  final double scale; // Basılıyken Uygulanacak Ölçek Değeridir.
  final String? semanticLabel; // Ekran Okuyucu Etiketidir.
  final bool button; // Semantics'te Düğme Olarak İşaretlenip İşaretlenmeyeceğini Belirtir.
  final bool? selected; // Semantics Seçili Durumudur.
  final bool? checked; // Semantics İşaretli Durumudur.

  const Pressable({ // Pressable'ın const Constructor'ıdır.
    super.key, // key Parametresini Superclass'a İletir.
    this.child, // İsteğe Bağlı child'ı Alır.
    this.builder, // İsteğe Bağlı builder'ı Alır.
    required this.onTap, // onTap Field'ını required Yapar.
    this.scale = AppMotion.pressButton, // Varsayılan Ölçeği Düğme Basma Ölçeği Yapar.
    this.semanticLabel, // İsteğe Bağlı Semantics Etiketini Alır.
    this.button = true, // Varsayılan Olarak Düğme Semantics'i Kullanır.
    this.selected, // İsteğe Bağlı Seçili Durumunu Alır.
    this.checked, // İsteğe Bağlı İşaretli Durumunu Alır.
  }) : assert(child != null || builder != null); // child Ya Da builder'dan En Az Birinin Verilmesini Zorunlu Kılar.

  @override // Superclass'taki createState Metodunun Override Edildiğini Belirtir.
  State<Pressable> createState() => _PressableState(); // Widget'ın State Nesnesini Oluşturur.
}

class _PressableState extends State<Pressable> { // Pressable'ın Basılı Durumunu Yöneten State Class'ıdır.
  bool _down = false; // Parmağın Şu An Basılı Olup Olmadığını Tutar.

  bool get _enabled => widget.onTap != null; // onTap Verildiyse Widget'ı Etkin Sayan Getter'dır.

  void _setDown(bool value) { // Basılı Durumunu Günceller.
    if (!_enabled || _down == value) return; // Pasifse Ya Da Değer Aynıysa Çıkar.
    setState(() => _down = value); // Yeni Basılı Durumunu setState İle Uygular.
  }

  @override // Superclass'taki didUpdateWidget Metodunun Override Edildiğini Belirtir.
  void didUpdateWidget(Pressable oldWidget) { // Widget Güncellendiğinde Basılı Durumunu Düzeltir.
    super.didUpdateWidget(oldWidget); // Superclass'ın didUpdateWidget Metodunu Çağırır.
    if (!_enabled) _down = false; // Widget Pasifleştiyse Basılı Durumunu Sıfırlar.
  }

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Basma Animasyonlu Widget Tree'yi Oluşturur.
    final target = (_down && !context.reduceMotion) ? widget.scale : 1.0; // Basılıysa Ve Hareket Azaltma Kapalıysa Hedef Ölçeği Seçer.
    final content = widget.builder?.call(context, _down) ?? widget.child!; // builder Varsa Onu, Yoksa child'ı İçerik Olarak Kullanır.
    return Semantics( // Erişilebilirlik Bilgilerini Ekler.
      button: widget.button, // Düğme Olarak İşaretler.
      enabled: _enabled, // Etkinlik Durumunu Bildirir.
      selected: widget.selected, // Seçili Durumunu Bildirir.
      checked: widget.checked, // İşaretli Durumunu Bildirir.
      label: widget.semanticLabel, // Ekran Okuyucu Etiketini Verir.
      onTap: widget.onTap, // Erişilebilirlik Dokunma Eylemini Bağlar.
      child: GestureDetector( // Dokunma Hareketlerini Dinler.
        behavior: HitTestBehavior.opaque, // Boş Alanlarda Da Dokunmayı Yakalar.
        onTapDown: (_) => _setDown(true), // Basıldığında Basılı Durumuna Geçer.
        onTapUp: (_) => _setDown(false), // Bırakıldığında Basılı Durumundan Çıkar.
        onTapCancel: () => _setDown(false), // Dokunma İptal Olunca Basılı Durumundan Çıkar.
        onTap: widget.onTap, // Dokunulduğunda onTap Callback'ini Çağırır.
        excludeFromSemantics: true, // Semantics'i Üstteki Semantics Widget'ına Bırakır.
        child: AnimatedScale(scale: target, duration: AppMotion.press, curve: AppMotion.easeOut, child: content), // İçeriği Hedef Ölçeğe Animasyonla Getirir.
      ),
    );
  }
}
