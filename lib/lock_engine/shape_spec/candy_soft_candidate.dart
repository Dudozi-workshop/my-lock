import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../models.dart';

/// Review-only atlas. Source pixels remain untouched; unsupported tones retain
/// the existing renderer so password color identity is never substituted.
class CandySoftCandidate {
  CandySoftCandidate._();
  static final instance = CandySoftCandidate._();
  static const enabled = bool.fromEnvironment('CANDY_SOFT_CANDIDATE');
  ui.Image? _atlas;
  final Map<ShapeKind, Map<String, dynamic>> _specs = {};

  Future<void> load() async {
    if (_atlas != null) return;
    for (final shape in ShapeKind.defaults) {
      _specs[shape] = jsonDecode(await rootBundle.loadString(
        'assets/raster_shapes/candy_soft/${shape.name}.json',
      )) as Map<String, dynamic>;
    }
    final data = await rootBundle.load(
      _specs[ShapeKind.circle]!['atlas_asset'] as String,
    );
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    try {
      _atlas = (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }

  bool paint(ui.Canvas canvas, {
    required ui.Offset center,
    required double radius,
    required LockToken token,
    required ShapeStyle style,
    required double opacity,
    required double rotation,
  }) {
    final spec = _specs[token.shape];
    final image = _atlas;
    if (!enabled || image == null || spec == null ||
        style != ShapeStyle.softBasic || spec['authored_tone'] != token.tone.name) {
      return false;
    }
    final rect = (spec['atlas_rect'] as List).cast<num>();
    final anchor = (spec['anchor'] as List).cast<num>();
    final size = (spec['runtime_canvas'] as List).cast<num>();
    final scale = radius * 2 / size[0] * (spec['display_scale'] as num);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawImageRect(image,
      ui.Rect.fromLTWH(rect[0].toDouble(), rect[1].toDouble(),
        rect[2].toDouble(), rect[3].toDouble()),
      ui.Rect.fromLTWH(-anchor[0] * scale, -anchor[1] * scale,
        size[0] * scale, size[1] * scale),
      ui.Paint()
        ..filterQuality = ui.FilterQuality.high
        ..color = ui.Color.fromRGBO(255, 255, 255, opacity.clamp(0, 1)),
    );
    canvas.restore();
    return true;
  }
}
