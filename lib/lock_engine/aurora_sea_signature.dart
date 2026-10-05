import 'dart:ui' as ui;

import 'water_refraction_field.dart';

/// Canonical MY LOCK Signature Color runtime for Aurora Sea v3.
///
/// H02B · Living Water · Brighter is Final / Locked / Active.
///
/// This intentionally mirrors the user-approved Palette LABS renderer:
/// one H02B WaterRefractionField, drawVertices, and alpha-first srcIn
/// compositing. Do not add a platform-specific approximation here.
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

  /// Exact approved LABS optical pass.
  ///
  /// Caller must establish the shape alpha in the active saveLayer first,
  /// then transform the canvas so the H02B unit square maps to the target.
  static void paintIntoCurrentMask(ui.Canvas canvas, double seconds) {
    canvas.drawVertices(
      mesh(seconds),
      ui.BlendMode.src,
      ui.Paint()..blendMode = ui.BlendMode.srcIn,
    );
  }

  /// Exact H02B unit-square painter for already-clipped destinations.
  static void paintUnitSquare(ui.Canvas canvas, double seconds) {
    canvas.drawVertices(
      mesh(seconds),
      ui.BlendMode.src,
      ui.Paint()..blendMode = ui.BlendMode.srcOver,
    );
  }
}
