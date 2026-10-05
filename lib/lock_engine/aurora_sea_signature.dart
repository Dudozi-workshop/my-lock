import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'water_refraction_field.dart';

/// Canonical MY LOCK Signature Color runtime for Aurora Sea v3.
///
/// H02B · Living Water · Brighter is Final / Locked / Active.
/// Keep the optical field centralized so raster characters and basic shapes
/// cannot drift into different Aurora Sea implementations.
///
/// Flutter Web can run on CPU-backed renderers where drawVertices-based color
/// fields technically repaint but are not reliably visible as motion. On Web,
/// the exact same H02B sampler is therefore emitted through a Canvas-only
/// cell field. Native keeps the higher-resolution vertices path.
class AuroraSeaSignature {
  AuroraSeaSignature._();

  static const String selection = 'H02B · Living Water · Brighter';

  static final WaterRefractionField _field = WaterRefractionField(
    colors: const [
      ui.Color(0xFF0754A3),
      ui.Color(0xFF138BD3),
      ui.Color(0xFF20CCD7),
      ui.Color(0xFF9AF0F3),
    ],
    speed: 1.28,
    refraction: 0.92,
    cellScale: 3.7,
    light: 0.84,
    seed: 29,
  );

  // Small runtime cards are 58–72 px. A 20×20 field keeps the H02B optical
  // motion readable there while avoiding thousands of Web Canvas draw calls.
  static const int _webResolution = 20;
  static int _webFrame = -1;
  static List<ui.Color> _webColors = const <ui.Color>[];

  static ui.Vertices mesh(double seconds) => _field.mesh(seconds);

  /// Applies H02B to alpha already present in the current saveLayer.
  ///
  /// [forceCanvasFallback] exists only so native tests can exercise the exact
  /// browser-safe path. Production callers should leave it false.
  static void paintIntoCurrentMask(
    ui.Canvas canvas,
    double seconds, {
    bool forceCanvasFallback = false,
  }) {
    if (kIsWeb || forceCanvasFallback) {
      _paintCanvasField(
        canvas,
        seconds,
        blendMode: ui.BlendMode.srcIn,
      );
      return;
    }

    canvas.drawVertices(
      mesh(seconds),
      ui.BlendMode.src,
      ui.Paint()..blendMode = ui.BlendMode.srcIn,
    );
  }

  /// Paints H02B directly into the caller's current clip in a unit square.
  ///
  /// Use after translating/scaling the canvas so 0..1 maps to the target
  /// bounds. Opacity should be applied by the surrounding saveLayer.
  static void paintUnitSquare(
    ui.Canvas canvas,
    double seconds, {
    bool forceCanvasFallback = false,
  }) {
    if (kIsWeb || forceCanvasFallback) {
      _paintCanvasField(
        canvas,
        seconds,
        blendMode: ui.BlendMode.srcOver,
      );
      return;
    }

    canvas.drawVertices(
      mesh(seconds),
      ui.BlendMode.src,
      ui.Paint()..blendMode = ui.BlendMode.srcOver,
    );
  }

  static void _paintCanvasField(
    ui.Canvas canvas,
    double seconds, {
    required ui.BlendMode blendMode,
  }) {
    final frame = (seconds * 24).floor();
    if (_webFrame != frame || _webColors.isEmpty) {
      _webFrame = frame;
      _webColors = List<ui.Color>.generate(
        _webResolution * _webResolution,
        (index) {
          final x = index % _webResolution;
          final y = index ~/ _webResolution;
          return _field.sample(
            (x + 0.5) / _webResolution,
            (y + 0.5) / _webResolution,
            frame / 24,
          );
        },
        growable: false,
      );
    }

    final cell = 1 / _webResolution;
    // Slight overlap prevents hairline gaps after device-pixel transforms.
    const overlap = 0.0008;
    final paint = ui.Paint()
      ..blendMode = blendMode
      ..isAntiAlias = false;

    for (var y = 0; y < _webResolution; y++) {
      for (var x = 0; x < _webResolution; x++) {
        paint.color = _webColors[y * _webResolution + x];
        canvas.drawRect(
          ui.Rect.fromLTRB(
            x * cell - overlap,
            y * cell - overlap,
            (x + 1) * cell + overlap,
            (y + 1) * cell + overlap,
          ),
          paint,
        );
      }
    }
  }
}
