import 'shape_spec.dart';

/// Optional, non-production parameter overrides used by Style Lab.
///
/// Production rendering passes no overrides. Labs may inject candidate values
/// without mutating the canonical ShapeSpec or asset files.
class ShapeLayerTransform {
  const ShapeLayerTransform({
    this.scaleX = 1,
    this.scaleY = 1,
    this.offsetX = 0,
    this.offsetY = 0,
  });

  final double scaleX;
  final double scaleY;
  final double offsetX;
  final double offsetY;
}

class ShapeRenderOverrides {
  const ShapeRenderOverrides({
    this.surfaceCenterX,
    this.surfaceCenterY,
    this.surfaceRadius,
    this.layerOpacityScaleById = const <String, double>{},
    this.layerOpacityById = const <String, double>{},
    this.layerTransformById = const <String, ShapeLayerTransform>{},
    this.shadowOpacityScale = 1,
    this.shadowElevationScale = 1,
  });

  final double? surfaceCenterX;
  final double? surfaceCenterY;
  final double? surfaceRadius;

  /// Multiplies the production opacity for a specific layer id.
  final Map<String, double> layerOpacityScaleById;

  /// Replaces the production opacity for a specific layer id.
  /// This takes precedence over [layerOpacityScaleById].
  final Map<String, double> layerOpacityById;
  final Map<String, ShapeLayerTransform> layerTransformById;

  final double shadowOpacityScale;
  final double shadowElevationScale;

  double resolveLayerOpacity(ShapeLayerSpec layer) {
    final absolute = layerOpacityById[layer.id];
    if (absolute != null) return absolute.clamp(0.0, 1.0).toDouble();

    final scale = layerOpacityScaleById[layer.id] ?? 1;
    return (layer.opacity * scale).clamp(0.0, 1.0).toDouble();
  }
}
