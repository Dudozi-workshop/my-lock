import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'models.dart';

/// Runtime-only Sea Turtle S02 visual QA path.
///
/// This deliberately does not modify ShapeKind/catalog persistence. On the
/// dedicated PoC branch, LockModeScreen can opt in and render existing circle
/// tokens with the Sea Turtle v2 baked assets so we can evaluate the real
/// FloatingEngine size, movement, collision and background interaction first.
class SeaTurtleRuntimePoc {
  SeaTurtleRuntimePoc._();

  static final SeaTurtleRuntimePoc instance = SeaTurtleRuntimePoc._();

  final Map<ShapeTone, ui.Image> _images = <ShapeTone, ui.Image>{};
  bool _loaded = false;

  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    _images[ShapeTone.blue] = await _loadImage(
      'assets/sea_turtle_runtime_v2/sea_turtle_blue.png',
    );
    _images[ShapeTone.pink] = await _loadImage(
      'assets/sea_turtle_runtime_v2/sea_turtle_pink.png',
    );
    _images[ShapeTone.yellow] = await _loadImage(
      'assets/sea_turtle_runtime_v2/sea_turtle_yellow.png',
    );

    _loaded = true;
  }

  void paint(
    ui.Canvas canvas, {
    required ui.Offset center,
    required double radius,
    required ShapeTone tone,
    required double opacity,
    required double objectRotation,
  }) {
    final image = _images[tone];
    if (image == null) return;

    // The source is a square asset with generous transparent padding around
    // the Long Flipper silhouette. 2.34x radius keeps optical mass close to
    // the current circle token while preserving the original turtle ratio.
    final side = radius * 2.34;
    final destination = ui.Rect.fromCenter(
      center: center,
      width: side,
      height: side,
    );

    canvas.save();
    if (objectRotation != 0) {
      canvas
        ..translate(center.dx, center.dy)
        ..rotate(objectRotation)
        ..translate(-center.dx, -center.dy);
    }

    final paint = ui.Paint()
      ..filterQuality = ui.FilterQuality.high
      ..color = ui.Color.fromRGBO(255, 255, 255, opacity);

    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      ),
      destination,
      paint,
    );
    canvas.restore();
  }

  Future<ui.Image> _loadImage(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
