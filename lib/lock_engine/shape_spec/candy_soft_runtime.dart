import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';

/// Opt-in review assets. Production callers keep the candidate flag false.
class CandySoftRuntime {
  CandySoftRuntime._();
  static final instance = CandySoftRuntime._();
  final Map<ShapeKind, (ShapeTone, ui.Image, ui.Image)> _images = {};
  Future<void>? _loading;

  Future<void> load() => _loading ??= _load().catchError((Object error) {
    _loading = null;
    throw error;
  });

  Future<ui.Image> _decode(String path) async {
    final bytes = base64Decode((await rootBundle.loadString(path)).trim());
    final codec = await ui.instantiateImageCodec(bytes);
    try { return (await codec.getNextFrame()).image; }
    finally { codec.dispose(); }
  }

  Future<void> _load() async {
    final pending = <ShapeKind, (ShapeTone, ui.Image, ui.Image)>{};
    final allocated = <ui.Image>[];
    try {
      for (final shape in [ShapeKind.circle, ShapeKind.triangle, ShapeKind.square]) {
        final authored = await _decode('assets/raster_shapes/candy_soft_r2/${shape.name}_authored_256.b64');
        allocated.add(authored);
        final field = await _decode('assets/raster_shapes/candy_soft_r2/${shape.name}_field_256.b64');
        allocated.add(field);
        if (authored.width != 256 || authored.height != 256 || field.width != 256 || field.height != 256) {
          throw StateError('Candy Soft canvas mismatch');
        }
        final tone = switch (shape) {
          ShapeKind.circle => ShapeTone.pink,
          ShapeKind.triangle => ShapeTone.yellow,
          _ => ShapeTone.blue,
        };
        pending[shape] = (tone, authored, field);
      }
      _images.addAll(pending);
    } catch (_) {
      for (final image in allocated) { image.dispose(); }
      rethrow;
    }
  }

  bool paint(ui.Canvas canvas, {required ui.Offset center, required double radius,
    required LockToken token, required ShapeStyle style, required double opacity,
    double rotation = 0}) {
    final images = _images[token.shape];
    if (style != ShapeStyle.softBasic || images == null ||
        ![ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow].contains(token.tone)) return false;
    final authored = token.tone == images.$1;
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.high;
    if (!authored) {
      final hue = HSVColor.fromColor(baseColorForTone(token.tone)).hue;
      final target = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
      paint.colorFilter = ui.ColorFilter.matrix([
        target.r, 1, 0, 0, 0,
        target.g, 1, 0, 0, 0,
        target.b, 1, 0, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final bounds = ui.Rect.fromLTWH(-radius, -radius, radius*2, radius*2);
    // Opacity is applied once to the composite, including POP feedback.
    if (opacity < 1) {
      canvas.saveLayer(bounds, ui.Paint()..color = ui.Color.fromRGBO(255,255,255,opacity.clamp(0,1)));
    }
    canvas.drawImageRect(authored ? images.$2 : images.$3,
      const ui.Rect.fromLTWH(0,0,256,256), bounds, paint);
    if (opacity < 1) canvas.restore();
    canvas.restore();
    return true;
  }
}
