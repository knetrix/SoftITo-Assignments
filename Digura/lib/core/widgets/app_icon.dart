import 'package:flutter/material.dart'; // Flutter'ın Material Widget'larını import Eder.

import '../constants/app_colors.dart'; // palette Erişimi İçin AppColors'ı import Eder.
import '../constants/app_icons.dart'; // SVG İşaretlemesi Taşıyan AppIconData Tipini import Eder.

/// Prototip simgelerini (`viewBox 0 0 24 24`, `stroke-linecap: round`) çizer.
///
/// `stroke-width` değeri SVG'deki gibi viewBox biriminde verilir; simge
/// büyüdükçe çizgi de orantılı kalınlaşır.
class AppIcon extends StatelessWidget { // SVG İşaretlemeli Simgeyi Çizen StatelessWidget'tır.
  final AppIconData icon; // Çizilecek Simge Verisidir.
  final double size; // Simgenin Kare Boyutudur.
  final Color? color; // Simge Rengidir.
  final double strokeWidth; // viewBox Biriminde Çizgi Kalınlığıdır.

  const AppIcon(this.icon, {super.key, this.size = 20, this.color, this.strokeWidth = 1.8}); // icon'u Konumsal Alan, Varsayılan Boyut Ve Kalınlıklı const Constructor'dır.

  @override // Superclass'taki build Metodunun Override Edildiğini Belirtir.
  Widget build(BuildContext context) { // Simgeyi Çizen Widget Tree'yi Oluşturur.
    final resolved = color ?? DefaultTextStyle.of(context).style.color ?? context.palette.fg; // Rengi Sırasıyla Parametre, Varsayılan Metin Rengi Ya Da fg'den Belirler.
    return ExcludeSemantics( // Dekoratif Simgeyi Ekran Okuyucudan Gizler.
      child: SizedBox.square( // Kare Çizim Alanı Oluşturur.
        dimension: size, // Kare Boyutunu Belirler.
        child: CustomPaint(painter: _IconPainter(_IconCache.resolve(icon), resolved, strokeWidth)), // Ayrıştırılmış Simgeyi _IconPainter İle Çizer.
      ),
    );
  }
}

class _IconPainter extends CustomPainter { // Ayrıştırılmış Simge Şekillerini Canvas'a Çizen CustomPainter'dır.
  final _ParsedIcon icon; // Çizilecek Ayrıştırılmış Simgedir.
  final Color color; // Çizim Rengidir.
  final double strokeWidth; // Çizgi Kalınlığıdır.

  _IconPainter(this.icon, this.color, this.strokeWidth); // Simge, Renk Ve Kalınlığı Alan Constructor'dır.

  @override // Superclass'taki paint Metodunun Override Edildiğini Belirtir.
  void paint(Canvas canvas, Size size) { // Simgeyi Canvas'a Çizer.
    canvas.save(); // Canvas Durumunu Kaydeder.
    canvas.scale(size.width / 24, size.height / 24); // 24x24 viewBox'ı Hedef Boyuta Ölçekler.
    final stroke = Paint() // Çizgi Boyası Oluşturur.
      ..color = color // Çizgi Rengini Ayarlar.
      ..style = PaintingStyle.stroke // Yalnızca Kontur Çizer.
      ..strokeWidth = strokeWidth // Çizgi Kalınlığını Ayarlar.
      ..strokeCap = StrokeCap.round // Çizgi Uçlarını Yuvarlar.
      ..strokeJoin = StrokeJoin.round // Çizgi Birleşimlerini Yuvarlar.
      ..isAntiAlias = true; // Kenar Yumuşatmayı Açar.
    final fill = Paint() // Dolgu Boyası Oluşturur.
      ..color = color // Dolgu Rengini Ayarlar.
      ..style = PaintingStyle.fill; // İçini Doldurur.
    for (final shape in icon.shapes) { // Simgedeki Her Şekli Dolaşır.
      if (shape.filled) canvas.drawPath(shape.path, fill); // Şekil Dolguluysa İçini Doldurur.
      canvas.drawPath(shape.path, stroke); // Şeklin Konturunu Çizer.
    }
    canvas.restore(); // Canvas Durumunu Geri Yükler.
  }

  @override // Superclass'taki shouldRepaint Metodunun Override Edildiğini Belirtir.
  bool shouldRepaint(_IconPainter old) => old.icon != icon || old.color != color || old.strokeWidth != strokeWidth; // Simge, Renk Ya Da Kalınlık Değiştiyse Yeniden Çizer.
}

class _Shape { // Tek Bir Çizim Yolunu Ve Dolgu Bilgisini Tutan Class'tır.
  final Path path; // Şeklin Çizim Yoludur.
  final bool filled; // Şeklin Dolgulu Olup Olmadığını Belirtir.

  const _Shape(this.path, this.filled); // path Ve filled Alan const Constructor'dır.
}

class _ParsedIcon { // Ayrıştırılmış Simge Şekillerini Tutan Class'tır.
  final List<_Shape> shapes; // Simgeyi Oluşturan Şekillerdir.

  const _ParsedIcon(this.shapes); // shapes Listesini Alan const Constructor'dır.
}

/// İşaretlemeyi bir kez ayrıştırır (path, rect, circle) ve saklar.
abstract final class _IconCache { // Ayrıştırılmış Simgeleri Önbelleğe Alan Statik Class'tır.
  static final Map<String, _ParsedIcon> _cache = {}; // İşaretlemeye Göre Ayrıştırılmış Simge Önbelleğidir.
  static final RegExp _element = RegExp(r'<(path|rect|circle)\s([^>]*?)/>'); // path, rect Ve circle Elemanlarını Yakalayan RegExp'tir.
  static final RegExp _attr = RegExp(r'([a-z-]+)="([^"]*)"'); // Öznitelik Ad Ve Değerlerini Yakalayan RegExp'tir.

  static _ParsedIcon resolve(AppIconData data) => _cache.putIfAbsent(data.markup, () => _parse(data.markup)); // Simgeyi Önbellekten Döndürür, Yoksa Ayrıştırıp Ekler.

  static _ParsedIcon _parse(String markup) { // SVG İşaretlemesini Şekil Listesine Ayrıştırır.
    final shapes = <_Shape>[]; // Sonuç Şekil Listesini Oluşturur.
    for (final match in _element.allMatches(markup)) { // Her SVG Elemanını Dolaşır.
      final attrs = {for (final a in _attr.allMatches(match.group(2)!)) a.group(1)!: a.group(2)!}; // Elemanın Özniteliklerini Map'e Çevirir.
      double n(String key) => double.tryParse(attrs[key] ?? '') ?? 0; // Özniteliği Sayıya Çeviren, Yoksa 0 Döndüren Yerel Fonksiyondur.
      final filled = attrs['fill'] == 'currentColor'; // fill currentColor İse Şekli Dolgulu Sayar.
      switch (match.group(1)) { // Eleman Türüne Göre Dallanır.
        case 'path': // Eleman path İse.
          shapes.add(_Shape(_SvgPathParser(attrs['d'] ?? '').parse(), filled)); // d Özniteliğini Ayrıştırıp Şekil Ekler.
        case 'rect': // Eleman rect İse.
          final rect = Rect.fromLTWH(n('x'), n('y'), n('width'), n('height')); // Dikdörtgeni Konum Ve Boyuttan Oluşturur.
          shapes.add(_Shape(Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(n('rx')))), filled)); // rx Yarıçaplı Yuvarlatılmış Dikdörtgen Şekli Ekler.
        case 'circle': // Eleman circle İse.
          shapes.add( // Daire Şeklini Listeye Ekler.
            _Shape(Path()..addOval(Rect.fromCircle(center: Offset(n('cx'), n('cy')), radius: n('r'))), filled), // Merkez Ve Yarıçaptan Daire Yolu Oluşturur.
          );
      }
    }
    return _ParsedIcon(shapes); // Ayrıştırılmış Simgeyi Döndürür.
  }
}

/// SVG `d` özniteliği için küçük ayrıştırıcı (M L H V C S Q A Z, mutlak/göreli).
class _SvgPathParser { // SVG Path d Verisini Flutter Path'e Çeviren Ayrıştırıcıdır.
  static final RegExp _token = RegExp(r'[MmLlHhVvCcSsQqAaZz]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?'); // Komut Harflerini Ve Sayıları Yakalayan RegExp'tir.

  final List<String> _tokens; // Ayrıştırılan Token Listesidir.
  int _i = 0; // Okunan Token'ın index'idir.
  final Path _path = Path(); // Oluşturulan Çizim Yoludur.
  Offset _current = Offset.zero; // Kalemin Şu Anki Konumudur.
  Offset _start = Offset.zero; // Alt Yolun Başlangıç Noktasıdır.
  Offset? _lastControl; // S Komutu İçin Son Kübik Kontrol Noktasıdır.

  _SvgPathParser(String d) : _tokens = _token.allMatches(d).map((m) => m.group(0)!).toList(); // d Verisini Token Listesine Bölen Constructor'dır.

  bool get _hasNumber => _i < _tokens.length && !RegExp(r'^[A-Za-z]$').hasMatch(_tokens[_i]); // Sıradaki Token Sayıysa true Döndüren Getter'dır.

  double _num() => double.parse(_tokens[_i++]); // Sıradaki Token'ı Sayı Olarak Okur.

  Offset _point(bool relative) { // Sıradaki İki Sayıdan Nokta Okur.
    final p = Offset(_num(), _num()); // x Ve y Değerlerinden Offset Oluşturur.
    return relative ? _current + p : p; // Göreliyse Mevcut Konuma Ekleyerek Döndürür.
  }

  Path parse() { // Tüm Token'ları İşleyip Path'i Döndürür.
    var command = 'M'; // Varsayılan Komutu M Yapar.
    while (_i < _tokens.length) { // Token Kalmayana Kadar Döner.
      if (!_hasNumber) command = _tokens[_i++]; // Sıradaki Token Harfse Yeni Komut Olarak Okur.
      final relative = command == command.toLowerCase(); // Küçük Harfli Komutları Göreli Sayar.
      switch (command.toUpperCase()) { // Komut Türüne Göre Dallanır.
        case 'M': // Konuma Taşıma Komutu.
          _current = _point(relative); // Yeni Konumu Okur.
          _start = _current; // Alt Yol Başlangıcını Günceller.
          _path.moveTo(_current.dx, _current.dy); // Kalemi Yeni Konuma Taşır.
          _lastControl = null; // Son Kontrol Noktasını Sıfırlar.
          // Ardışık koordinat çiftleri örtük lineTo'dur.
          command = relative ? 'l' : 'L'; // Sonraki Koordinatlar İçin Komutu Çizgiye Çevirir.
        case 'L': // Çizgi Komutu.
          _current = _point(relative); // Hedef Noktayı Okur.
          _path.lineTo(_current.dx, _current.dy); // Hedefe Çizgi Çizer.
          _lastControl = null; // Son Kontrol Noktasını Sıfırlar.
        case 'H': // Yatay Çizgi Komutu.
          final x = _num(); // Hedef x Değerini Okur.
          _current = Offset(relative ? _current.dx + x : x, _current.dy); // Yalnızca x'i Güncelleyerek Yeni Konumu Hesaplar.
          _path.lineTo(_current.dx, _current.dy); // Yatay Çizgi Çizer.
          _lastControl = null; // Son Kontrol Noktasını Sıfırlar.
        case 'V': // Dikey Çizgi Komutu.
          final y = _num(); // Hedef y Değerini Okur.
          _current = Offset(_current.dx, relative ? _current.dy + y : y); // Yalnızca y'yi Güncelleyerek Yeni Konumu Hesaplar.
          _path.lineTo(_current.dx, _current.dy); // Dikey Çizgi Çizer.
          _lastControl = null; // Son Kontrol Noktasını Sıfırlar.
        case 'C': // Kübik Bezier Komutu.
          final c1 = _point(relative); // Birinci Kontrol Noktasını Okur.
          final c2 = _point(relative); // İkinci Kontrol Noktasını Okur.
          final end = _point(relative); // Bitiş Noktasını Okur.
          _path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy); // Kübik Eğri Çizer.
          _lastControl = c2; // İkinci Kontrol Noktasını S İçin Saklar.
          _current = end; // Konumu Bitiş Noktasına Taşır.
        case 'S': // Yumuşak Kübik Bezier Komutu.
          final c1 = _lastControl == null ? _current : _current * 2 - _lastControl!; // Önceki Kontrol Noktasını Yansıtarak Birinci Kontrolü Hesaplar.
          final c2 = _point(relative); // İkinci Kontrol Noktasını Okur.
          final end = _point(relative); // Bitiş Noktasını Okur.
          _path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy); // Kübik Eğri Çizer.
          _lastControl = c2; // İkinci Kontrol Noktasını Saklar.
          _current = end; // Konumu Bitiş Noktasına Taşır.
        case 'Q': // Karesel Bezier Komutu.
          final c = _point(relative); // Kontrol Noktasını Okur.
          final end = _point(relative); // Bitiş Noktasını Okur.
          _path.quadraticBezierTo(c.dx, c.dy, end.dx, end.dy); // Karesel Eğri Çizer.
          _lastControl = null; // Son Kübik Kontrol Noktasını Sıfırlar.
          _current = end; // Konumu Bitiş Noktasına Taşır.
        case 'A': // Eliptik Yay Komutu.
          final rx = _num(); // Yatay Yarıçapı Okur.
          final ry = _num(); // Dikey Yarıçapı Okur.
          final rotation = _num(); // Elips Dönüş Açısını Okur.
          final largeArc = _num() != 0; // Büyük Yay Bayrağını Okur.
          final sweep = _num() != 0; // Saat Yönü Bayrağını Okur.
          final end = _point(relative); // Bitiş Noktasını Okur.
          _path.arcToPoint( // Bitiş Noktasına Yay Çizer.
            end, // Yayın Bitiş Noktasını Verir.
            radius: Radius.elliptical(rx, ry), // Eliptik Yarıçapı Verir.
            rotation: rotation, // Dönüş Açısını Verir.
            largeArc: largeArc, // Büyük Yay Seçimini Verir.
            clockwise: sweep, // Çizim Yönünü Verir.
          );
          _lastControl = null; // Son Kontrol Noktasını Sıfırlar.
          _current = end; // Konumu Bitiş Noktasına Taşır.
        case 'Z': // Yolu Kapatma Komutu.
          _path.close(); // Alt Yolu Kapatır.
          _current = _start; // Konumu Alt Yol Başlangıcına Döndürür.
          _lastControl = null; // Son Kontrol Noktasını Sıfırlar.
        default: // Bilinmeyen Komut İse.
          _i++; // Token'ı Atlar.
      }
    }
    return _path; // Oluşturulan Path'i Döndürür.
  }
}
