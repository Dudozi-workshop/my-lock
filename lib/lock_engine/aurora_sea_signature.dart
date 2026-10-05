import 'dart:ui' as ui;

import 'water_refraction_field.dart';

/// Canonical MY LOCK Signature Color runtime for Aurora Sea v3.
///
/// H02B · Living Water · Brighter is Final / Locked / Active.
/// Keep the optical field centralized so raster characters and basic shapes
/// cannot drift into different Aurora Sea implementations.
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

  static ui.Vertices mesh(double seconds) => _field.mesh(seconds);

  /// Applies H02B to alpha already present in the current saveLayer.
  static void paintIntoCurrentMask(ui.Canvas canvas, double seconds) {
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
  static void paintUnitSquare(ui.Canvas canvas, double seconds) {
    canvas.drawVertices(
      mesh(seconds),
      ui.BlendMode.src,
      ui.Paint()..blendMode = ui.BlendMode.srcOver,
    );
  }
}
