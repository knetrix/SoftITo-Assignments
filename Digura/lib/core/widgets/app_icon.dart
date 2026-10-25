import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';

/// Prototip simgelerini (`viewBox 0 0 24 24`, `stroke-linecap: round`) çizer.
///
/// `stroke-width` değeri SVG'deki gibi viewBox biriminde verilir; simge
/// büyüdükçe çizgi de orantılı kalınlaşır.
class AppIcon extends StatelessWidget {
  final AppIconData icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppIcon(this.icon, {super.key, this.size = 20, this.color, this.strokeWidth = 1.8});

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? DefaultTextStyle.of(context).style.color ?? context.palette.fg;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _IconPainter(_IconCache.resolve(icon), resolved, strokeWidth)),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  final _ParsedIcon icon;
  final Color color;
  final double strokeWidth;

  _IconPainter(this.icon, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final shape in icon.shapes) {
      if (shape.filled) canvas.drawPath(shape.path, fill);
      canvas.drawPath(shape.path, stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.icon != icon || old.color != color || old.strokeWidth != strokeWidth;
}

class _Shape {
  final Path path;
  final bool filled;

  const _Shape(this.path, this.filled);
}

class _ParsedIcon {
  final List<_Shape> shapes;

  const _ParsedIcon(this.shapes);
}

/// İşaretlemeyi bir kez ayrıştırır (path, rect, circle) ve saklar.
abstract final class _IconCache {
  static final Map<String, _ParsedIcon> _cache = {};
  static final RegExp _element = RegExp(r'<(path|rect|circle)\s([^>]*?)/>');
  static final RegExp _attr = RegExp(r'([a-z-]+)="([^"]*)"');

  static _ParsedIcon resolve(AppIconData data) => _cache.putIfAbsent(data.markup, () => _parse(data.markup));

  static _ParsedIcon _parse(String markup) {
    final shapes = <_Shape>[];
    for (final match in _element.allMatches(markup)) {
      final attrs = {for (final a in _attr.allMatches(match.group(2)!)) a.group(1)!: a.group(2)!};
      double n(String key) => double.tryParse(attrs[key] ?? '') ?? 0;
      final filled = attrs['fill'] == 'currentColor';
      switch (match.group(1)) {
        case 'path':
          shapes.add(_Shape(_SvgPathParser(attrs['d'] ?? '').parse(), filled));
        case 'rect':
          final rect = Rect.fromLTWH(n('x'), n('y'), n('width'), n('height'));
          shapes.add(_Shape(Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(n('rx')))), filled));
        case 'circle':
          shapes.add(
            _Shape(Path()..addOval(Rect.fromCircle(center: Offset(n('cx'), n('cy')), radius: n('r'))), filled),
          );
      }
    }
    return _ParsedIcon(shapes);
  }
}

/// SVG `d` özniteliği için küçük ayrıştırıcı (M L H V C S Q A Z, mutlak/göreli).
class _SvgPathParser {
  static final RegExp _token = RegExp(r'[MmLlHhVvCcSsQqAaZz]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?');

  final List<String> _tokens;
  int _i = 0;
  final Path _path = Path();
  Offset _current = Offset.zero;
  Offset _start = Offset.zero;
  Offset? _lastControl;

  _SvgPathParser(String d) : _tokens = _token.allMatches(d).map((m) => m.group(0)!).toList();

  bool get _hasNumber => _i < _tokens.length && !RegExp(r'^[A-Za-z]$').hasMatch(_tokens[_i]);

  double _num() => double.parse(_tokens[_i++]);

  Offset _point(bool relative) {
    final p = Offset(_num(), _num());
    return relative ? _current + p : p;
  }

  Path parse() {
    var command = 'M';
    while (_i < _tokens.length) {
      if (!_hasNumber) command = _tokens[_i++];
      final relative = command == command.toLowerCase();
      switch (command.toUpperCase()) {
        case 'M':
          _current = _point(relative);
          _start = _current;
          _path.moveTo(_current.dx, _current.dy);
          _lastControl = null;
          // Ardışık koordinat çiftleri örtük lineTo'dur.
          command = relative ? 'l' : 'L';
        case 'L':
          _current = _point(relative);
          _path.lineTo(_current.dx, _current.dy);
          _lastControl = null;
        case 'H':
          final x = _num();
          _current = Offset(relative ? _current.dx + x : x, _current.dy);
          _path.lineTo(_current.dx, _current.dy);
          _lastControl = null;
        case 'V':
          final y = _num();
          _current = Offset(_current.dx, relative ? _current.dy + y : y);
          _path.lineTo(_current.dx, _current.dy);
          _lastControl = null;
        case 'C':
          final c1 = _point(relative);
          final c2 = _point(relative);
          final end = _point(relative);
          _path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
          _lastControl = c2;
          _current = end;
        case 'S':
          final c1 = _lastControl == null ? _current : _current * 2 - _lastControl!;
          final c2 = _point(relative);
          final end = _point(relative);
          _path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
          _lastControl = c2;
          _current = end;
        case 'Q':
          final c = _point(relative);
          final end = _point(relative);
          _path.quadraticBezierTo(c.dx, c.dy, end.dx, end.dy);
          _lastControl = null;
          _current = end;
        case 'A':
          final rx = _num();
          final ry = _num();
          final rotation = _num();
          final largeArc = _num() != 0;
          final sweep = _num() != 0;
          final end = _point(relative);
          _path.arcToPoint(
            end,
            radius: Radius.elliptical(rx, ry),
            rotation: rotation,
            largeArc: largeArc,
            clockwise: sweep,
          );
          _lastControl = null;
          _current = end;
        case 'Z':
          _path.close();
          _current = _start;
          _lastControl = null;
        default:
          _i++;
      }
    }
    return _path;
  }
}
