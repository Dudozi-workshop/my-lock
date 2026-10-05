import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../aurora_sea_signature.dart';
import '../models.dart';
import 'shape_spec.dart';

/// Approved Candy Soft R2 assets for the three default shapes.
///
/// Geometry/appearance stays on Candy Soft for every ShapeTone. Static tones
/// recolor the approved palette field; Aurora Sea uses the locked H02B
/// Signature Color field while retaining the Candy silhouette/tonal finish.
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
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }

  Future<void> _load() async {
    final pending = <ShapeKind, (ShapeTone, ui.Image, ui.Image)>{};
    final allocated = <ui.Image>[];
    try {
      for (final shape in [
        ShapeKind.circle,
        ShapeKind.triangle,
        ShapeKind.square,
      ]) {
        final authored = await _decode(
          'assets/raster_shapes/candy_soft_r2/${shape.name}_authored_256.b64',
        );
        allocated.add(authored);
        final field = await _decode(
          'assets/raster_shapes/candy_soft_r2/${shape.name}_field_256.b64',
        );
        allocated.add(field);
        if (authored.width != 256 ||
            authored.height != 256 ||
            field.width != 256 ||
            field.height != 256) {
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
      for (final image in allocated) {
        image.dispose();
      }
      rethrow;
    }
  }

  bool paint(
    ui.Canvas canvas, {
    required ui.Offset center,
    required double radius,
    required LockToken token,
    required ShapeStyle style,
    required double opacity,
    required double paletteTimeSeconds,
    double rotation = 0,
  }) {
    final images = _images[token.shape];
    if (style != ShapeStyle.softBasic || images == null) return false;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final bounds = ui.Rect.fromLTWH(-radius, -radius, radius * 2, radius * 2);
    const source = ui.Rect.fromLTWH(0, 0, 256, 256);

    // Opacity is applied once to the complete token.
    if (opacity < 1) {
      canvas.saveLayer(
        bounds,
        ui.Paint()
          ..color = ui.Color.fromRGBO(
            255,
            255,
            255,
            opacity.clamp(0, 1),
          ),
      );
    }

    if (token.tone == ShapeTone.auroraSea) {
      _paintAurora(
        canvas,
        images.$3,
        source,
        bounds,
        paletteTimeSeconds,
      );
    } else {
      _paintStaticTone(canvas, images, source, bounds, token.tone);
    }

    if (opacity < 1) canvas.restore();
    canvas.restore();
    return true;
  }

  void _paintStaticTone(
    ui.Canvas canvas,
    (ShapeTone, ui.Image, ui.Image) images,
    ui.Rect source,
    ui.Rect bounds,
    ShapeTone tone,
  ) {
    final authored = tone == images.$1;
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.high;

    if (!authored) {
      final hue = HSVColor.fromColor(baseColorForTone(tone)).hue;
      final target = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
      paint.colorFilter = ui.ColorFilter.matrix([
        target.r, 1, 0, 0, 0,
        target.g, 1, 0, 0, 0,
        target.b, 1, 0, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }

    canvas.drawImageRect(
      authored ? images.$2 : images.$3,
      source,
      bounds,
      paint,
    );
  }

  void _paintAurora(
    ui.Canvas canvas,
    ui.Image field,
    ui.Rect source,
    ui.Rect bounds,
    double paletteTimeSeconds,
  ) {
    final sampling = ui.Paint()..filterQuality = ui.FilterQuality.high;

    // Alpha-first H02B pass: the approved Candy field establishes the exact
    // Candy silhouette, then the shared Signature Color is clipped into it.
    canvas.saveLayer(bounds, ui.Paint());
    canvas.drawImageRect(field, source, bounds, sampling);
    canvas.save();
    canvas.translate(bounds.left, bounds.top);
    canvas.scale(bounds.width, bounds.height);
    AuroraSeaSignature.paintIntoCurrentMask(canvas, paletteTimeSeconds);
    canvas.restore();
    canvas.restore();

    // Re-apply only a restrained achromatic finish so Candy's approved
    // dimensional cues survive without changing H02B hue identity.
    canvas.drawImageRect(
      field,
      source,
      bounds,
      ui.Paint()
        ..filterQuality = ui.FilterQuality.high
        ..blendMode = ui.BlendMode.softLight
        ..color = const ui.Color.fromRGBO(255, 255, 255, 0.24)
        ..colorFilter = const ui.ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
    );
  }
}
