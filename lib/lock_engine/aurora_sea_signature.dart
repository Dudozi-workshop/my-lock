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

  /// Paints the approved field into a caller-provided unit square.
  ///
  /// The destination alpha/mask must already exist in the active layer.
  static void paintIntoCurrentMask(ui.Canvas canvas, double seconds) {
    canvas.drawVertices(
      mesh(seconds),
      ui.BlendMode.src,
      ui.Paint()..blendMode = ui.BlendMode.srcIn,
    );
  }
}
