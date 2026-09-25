import 'package:flutter/material.dart';

import '../models.dart';

enum ShapeLayerRole { light, shade, spec }

enum ShapeLayerBlend { normal, softLight, multiply, screen }

enum ShapeRotationMode { rotateWithObject, fixed }

enum ShapeRenderMode { layered, crayon }

enum CrayonEdgeMode { vector, none, broken, scribble, overfill, hybrid }

enum CrayonStrokePattern { hatch, zigzag }

class ShapeStyleSpec {
  const ShapeStyleSpec({
    required this.id,
    required this.version,
    required this.canvasSize,
    required this.colorRules,
    required this.renderMode,
    required this.shapeSourceId,
    required this.crayon,
  });

  final String id;
  final int version;
  final double canvasSize;
  final ShapeColorRuleSpec colorRules;
  final ShapeRenderMode renderMode;
  final String? shapeSourceId;
  final CrayonTextureSpec? crayon;

  factory ShapeStyleSpec.fromJson(Map<String, dynamic> json) {
    return ShapeStyleSpec(
      id: json['id'] as String,
      version: (json['version'] as num).toInt(),
      canvasSize: (json['canvasSize'] as num).toDouble(),
      colorRules: ShapeColorRuleSpec.fromJson(
        json['colorRules'] as Map<String, dynamic>,
      ),
      renderMode: ShapeRenderMode.values.byName(
        (json['renderMode'] as String?) ?? 'layered',
      ),
      shapeSourceId: json['shapeSourceId'] as String?,
      crayon: json['crayon'] == null
          ? null
          : CrayonTextureSpec.fromJson(
              json['crayon'] as Map<String, dynamic>,
            ),
    );
  }
}

class CrayonTextureSpec {
  const CrayonTextureSpec({
    required this.darkStrokeCount,
    required this.lightStrokeCount,
    required this.grainCount,
    required this.strokeWidth,
    required this.angleDeg,
    required this.jitter,
    required this.darkOpacity,
    required this.lightOpacity,
    required this.grainOpacity,
    required this.edgeOpacity,
    this.baseStrokeCount = 0,
    this.underpaintOpacity = 1.0,
    this.baseStrokeOpacity = 0.0,
    this.strokeBreakChance = 0.0,
    this.strokeBuiltSurface = false,
    this.broadStrokeCount = 0,
    this.broadStrokeWidth = 4.0,
    this.broadStrokeOpacity = 0.0,
    this.angleJitterDeg = 0.0,
    this.strokeWidthJitter = 0.0,
    this.strokeLengthMin = 1.0,
    this.strokeLengthMax = 1.0,
    this.gapChance = 0.0,
    this.toneVariation = 0.0,
    this.edgeWidth = 0.72,
    this.edgeTexture = 0.0,
    this.edgeMode = CrayonEdgeMode.vector,
    this.edgeSegmentLength = 7.0,
    this.edgeSegmentGap = 3.0,
    this.edgeOffsetJitter = 0.8,
    this.edgeWidthJitter = 0.25,
    this.edgeOpacityJitter = 0.20,
    this.edgeBandWidth = 3.0,
    this.overflowAmount = 1.2,
    this.strokePattern = CrayonStrokePattern.hatch,
    this.zigzagAmplitude = 0.0,
    this.zigzagCycles = 0,
    this.negativeGapCount = 0,
    this.negativeGapWidth = 0.0,
    this.internalGapChance = 0.0,
    this.internalGapWidthRatio = 0.0,
    this.internalGapLengthMin = 4.0,
    this.internalGapLengthMax = 12.0,
    this.internalGapStrength = 1.0,
    this.internalStrandCount = 1,
    this.internalStrandSpread = 0.0,
    this.internalGapOffsetJitter = 0.0,
  });

  final int darkStrokeCount;
  final int lightStrokeCount;
  final int grainCount;
  final double strokeWidth;
  final double angleDeg;
  final double jitter;
  final double darkOpacity;
  final double lightOpacity;
  final double grainOpacity;
  final double edgeOpacity;

  /// Crayon-only coverage controls used by Style Lab and future promoted
  /// presets. Defaults preserve the existing PREVIEW 008 appearance.
  final int baseStrokeCount;
  final double underpaintOpacity;
  final double baseStrokeOpacity;
  final double strokeBreakChance;

  /// Round 3 experimental renderer: the shape surface is constructed from
  /// layered pigment strokes instead of a solid fill with texture on top.
  final bool strokeBuiltSurface;
  final int broadStrokeCount;
  final double broadStrokeWidth;
  final double broadStrokeOpacity;
  final double angleJitterDeg;
  final double strokeWidthJitter;
  final double strokeLengthMin;
  final double strokeLengthMax;
  final double gapChance;
  final double toneVariation;

  /// Crayon outline controls. edgeWidth is in the 100x100 design space.
  /// edgeTexture adds deterministic offset passes so the contour reads like
  /// a wax-crayon edge instead of a clean vector stroke.
  final double edgeWidth;
  final double edgeTexture;
  final CrayonEdgeMode edgeMode;
  final double edgeSegmentLength;
  final double edgeSegmentGap;
  final double edgeOffsetJitter;
  final double edgeWidthJitter;
  final double edgeOpacityJitter;
  final double edgeBandWidth;
  final double overflowAmount;

  /// Internal mark geometry. hatch preserves the existing diagonal fill.
  /// zigzag produces a hand-coloring lightning / back-and-forth stroke.
  final CrayonStrokePattern strokePattern;
  final double zigzagAmplitude;
  final int zigzagCycles;

  /// True negative-space cuts. These erase pigment inside the isolated token
  /// layer so the runtime background shows through instead of drawing a
  /// lighter pigment mark over the fill.
  final int negativeGapCount;
  final double negativeGapWidth;

  /// Sparse paper reveal inside an otherwise continuous crayon stroke.
  /// Unlike negativeGapCount, these marks never cut across the full stroke
  /// width. They stay inside the pigment band so the outer stroke reads as
  /// one continuous hand motion.
  final double internalGapChance;
  final double internalGapWidthRatio;
  final double internalGapLengthMin;
  final double internalGapLengthMax;
  final double internalGapStrength;
  final int internalStrandCount;
  final double internalStrandSpread;
  final double internalGapOffsetJitter;

  factory CrayonTextureSpec.fromJson(Map<String, dynamic> json) {
    return CrayonTextureSpec(
      darkStrokeCount: (json['darkStrokeCount'] as num).toInt(),
      lightStrokeCount: (json['lightStrokeCount'] as num).toInt(),
      grainCount: (json['grainCount'] as num).toInt(),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      angleDeg: (json['angleDeg'] as num).toDouble(),
      jitter: (json['jitter'] as num).toDouble(),
      darkOpacity: (json['darkOpacity'] as num).toDouble(),
      lightOpacity: (json['lightOpacity'] as num).toDouble(),
      grainOpacity: (json['grainOpacity'] as num).toDouble(),
      edgeOpacity: (json['edgeOpacity'] as num).toDouble(),
      baseStrokeCount: (json['baseStrokeCount'] as num?)?.toInt() ?? 0,
      underpaintOpacity:
          (json['underpaintOpacity'] as num?)?.toDouble() ?? 1.0,
      baseStrokeOpacity:
          (json['baseStrokeOpacity'] as num?)?.toDouble() ?? 0.0,
      strokeBreakChance:
          (json['strokeBreakChance'] as num?)?.toDouble() ?? 0.0,
      strokeBuiltSurface: json['strokeBuiltSurface'] as bool? ?? false,
      broadStrokeCount:
          (json['broadStrokeCount'] as num?)?.toInt() ?? 0,
      broadStrokeWidth:
          (json['broadStrokeWidth'] as num?)?.toDouble() ?? 4.0,
      broadStrokeOpacity:
          (json['broadStrokeOpacity'] as num?)?.toDouble() ?? 0.0,
      angleJitterDeg:
          (json['angleJitterDeg'] as num?)?.toDouble() ?? 0.0,
      strokeWidthJitter:
          (json['strokeWidthJitter'] as num?)?.toDouble() ?? 0.0,
      strokeLengthMin:
          (json['strokeLengthMin'] as num?)?.toDouble() ?? 1.0,
      strokeLengthMax:
          (json['strokeLengthMax'] as num?)?.toDouble() ?? 1.0,
      gapChance:
          (json['gapChance'] as num?)?.toDouble() ?? 0.0,
      toneVariation:
          (json['toneVariation'] as num?)?.toDouble() ?? 0.0,
      edgeWidth:
          (json['edgeWidth'] as num?)?.toDouble() ?? 0.72,
      edgeTexture:
          (json['edgeTexture'] as num?)?.toDouble() ?? 0.0,
      edgeMode: CrayonEdgeMode.values.byName(
        (json['edgeMode'] as String?) ?? 'vector',
      ),
      edgeSegmentLength:
          (json['edgeSegmentLength'] as num?)?.toDouble() ?? 7.0,
      edgeSegmentGap:
          (json['edgeSegmentGap'] as num?)?.toDouble() ?? 3.0,
      edgeOffsetJitter:
          (json['edgeOffsetJitter'] as num?)?.toDouble() ?? 0.8,
      edgeWidthJitter:
          (json['edgeWidthJitter'] as num?)?.toDouble() ?? 0.25,
      edgeOpacityJitter:
          (json['edgeOpacityJitter'] as num?)?.toDouble() ?? 0.20,
      edgeBandWidth:
          (json['edgeBandWidth'] as num?)?.toDouble() ?? 3.0,
      overflowAmount:
          (json['overflowAmount'] as num?)?.toDouble() ?? 1.2,
      strokePattern: CrayonStrokePattern.values.byName(
        (json['strokePattern'] as String?) ?? 'hatch',
      ),
      zigzagAmplitude:
          (json['zigzagAmplitude'] as num?)?.toDouble() ?? 0.0,
      zigzagCycles:
          (json['zigzagCycles'] as num?)?.toInt() ?? 0,
      negativeGapCount:
          (json['negativeGapCount'] as num?)?.toInt() ?? 0,
      negativeGapWidth:
          (json['negativeGapWidth'] as num?)?.toDouble() ?? 0.0,
      internalGapChance:
          (json['internalGapChance'] as num?)?.toDouble() ?? 0.0,
      internalGapWidthRatio:
          (json['internalGapWidthRatio'] as num?)?.toDouble() ?? 0.0,
      internalGapLengthMin:
          (json['internalGapLengthMin'] as num?)?.toDouble() ?? 4.0,
      internalGapLengthMax:
          (json['internalGapLengthMax'] as num?)?.toDouble() ?? 12.0,
      internalGapStrength:
          (json['internalGapStrength'] as num?)?.toDouble() ?? 1.0,
      internalStrandCount:
          (json['internalStrandCount'] as num?)?.toInt() ?? 1,
      internalStrandSpread:
          (json['internalStrandSpread'] as num?)?.toDouble() ?? 0.0,
      internalGapOffsetJitter:
          (json['internalGapOffsetJitter'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ShapeColorRuleSpec {
  const ShapeColorRuleSpec({
    required this.lightnessUp,
    required this.lightSaturationDelta,
    required this.lightnessDown,
    required this.shadeSaturationDelta,
    required this.specColor,
  });

  final double lightnessUp;
  final double lightSaturationDelta;
  final double lightnessDown;
  final double shadeSaturationDelta;
  final Color specColor;

  factory ShapeColorRuleSpec.fromJson(Map<String, dynamic> json) {
    return ShapeColorRuleSpec(
      lightnessUp: (json['lightnessUp'] as num).toDouble(),
      lightSaturationDelta:
          (json['lightSaturationDelta'] as num).toDouble(),
      lightnessDown: (json['lightnessDown'] as num).toDouble(),
      shadeSaturationDelta:
          (json['shadeSaturationDelta'] as num).toDouble(),
      specColor: _parseHexColor(json['specColor'] as String),
    );
  }
}

class ShapeSpec {
  const ShapeSpec({
    required this.styleId,
    required this.shapeId,
    required this.version,
    required this.body,
    required this.surface,
    required this.rotationMode,
    required this.layers,
    required this.shadow,
  });

  final String styleId;
  final String shapeId;
  final int version;
  final ShapeGeometrySpec body;
  final ShapeSurfaceSpec surface;
  final ShapeRotationMode rotationMode;
  final List<ShapeLayerSpec> layers;
  final ShapeShadowSpec shadow;

  factory ShapeSpec.fromJson(Map<String, dynamic> json) {
    return ShapeSpec(
      styleId: json['styleId'] as String,
      shapeId: json['shapeId'] as String,
      version: (json['version'] as num).toInt(),
      body: ShapeGeometrySpec.fromJson(json['body'] as Map<String, dynamic>),
      surface: ShapeSurfaceSpec.fromJson(
        (json['surface'] as Map<String, dynamic>?) ??
            const <String, dynamic>{'kind': 'solid'},
      ),
      rotationMode: ShapeRotationMode.values.byName(
        (json['rotationMode'] as String?) ?? 'rotateWithObject',
      ),
      layers: [
        for (final value in json['layers'] as List<dynamic>)
          ShapeLayerSpec.fromJson(value as Map<String, dynamic>),
      ],
      shadow:
          ShapeShadowSpec.fromJson(json['shadow'] as Map<String, dynamic>),
    );
  }
}

class ShapeLayerSpec {
  const ShapeLayerSpec({
    required this.id,
    required this.role,
    required this.blend,
    required this.opacity,
    required this.blur,
    required this.rotationDeg,
    required this.geometry,
  });

  final String id;
  final ShapeLayerRole role;
  final ShapeLayerBlend blend;
  final double opacity;
  final double blur;
  final double rotationDeg;
  final ShapeGeometrySpec geometry;

  factory ShapeLayerSpec.fromJson(Map<String, dynamic> json) {
    return ShapeLayerSpec(
      id: json['id'] as String,
      role: ShapeLayerRole.values.byName(json['role'] as String),
      blend: ShapeLayerBlend.values.byName(
        (json['blend'] as String?) ?? 'normal',
      ),
      opacity: (json['opacity'] as num).toDouble(),
      blur: (json['blur'] as num).toDouble(),
      rotationDeg: (json['rotationDeg'] as num?)?.toDouble() ?? 0,
      geometry: ShapeGeometrySpec.fromJson(
        json['geometry'] as Map<String, dynamic>,
      ),
    );
  }
}


class ShapeSurfaceSpec {
  const ShapeSurfaceSpec({
    required this.kind,
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.stops,
  });

  final String kind;
  final double centerX;
  final double centerY;
  final double radius;
  final List<double> stops;

  factory ShapeSurfaceSpec.fromJson(Map<String, dynamic> json) {
    return ShapeSurfaceSpec(
      kind: (json['kind'] as String?) ?? 'solid',
      centerX: (json['centerX'] as num?)?.toDouble() ?? -0.45,
      centerY: (json['centerY'] as num?)?.toDouble() ?? -0.55,
      radius: (json['radius'] as num?)?.toDouble() ?? 1.25,
      stops: [
        for (final value
            in (json['stops'] as List<dynamic>? ??
                const <dynamic>[0.0, 0.34, 0.74, 1.0]))
          (value as num).toDouble(),
      ],
    );
  }
}

class ShapeShadowSpec {
  const ShapeShadowSpec({
    required this.opacity,
    required this.elevation,
    required this.offsetX,
    required this.offsetY,
  });

  final double opacity;
  final double elevation;
  final double offsetX;
  final double offsetY;

  factory ShapeShadowSpec.fromJson(Map<String, dynamic> json) {
    return ShapeShadowSpec(
      opacity: (json['opacity'] as num).toDouble(),
      elevation: (json['elevation'] as num).toDouble(),
      offsetX: (json['offsetX'] as num).toDouble(),
      offsetY: (json['offsetY'] as num).toDouble(),
    );
  }
}

class ShapeGeometrySpec {
  const ShapeGeometrySpec(this.kind, this.values);

  final String kind;
  final Map<String, dynamic> values;

  factory ShapeGeometrySpec.fromJson(Map<String, dynamic> json) {
    return ShapeGeometrySpec(
      json['kind'] as String,
      Map<String, dynamic>.from(json),
    );
  }
}

class ShapeSpecBundle {
  const ShapeSpecBundle({
    required this.style,
    required this.shape,
  });

  final ShapeStyleSpec style;
  final ShapeSpec shape;
}

Color baseColorForTone(ShapeTone tone) {
  switch (tone) {
    case ShapeTone.pink:
      return const Color(0xFFFF8FD1);
    case ShapeTone.blue:
      return const Color(0xFF79BFFF);
    case ShapeTone.yellow:
      return const Color(0xFFFFDA72);
  }
}

Color adjustTone(
  Color base, {
  required double lightnessDelta,
  required double saturationDelta,
}) {
  final hsl = HSLColor.fromColor(base);
  return hsl
      .withLightness(
        (hsl.lightness + lightnessDelta).clamp(0.0, 1.0).toDouble(),
      )
      .withSaturation(
        (hsl.saturation + saturationDelta).clamp(0.0, 1.0).toDouble(),
      )
      .toColor();
}

Color _parseHexColor(String value) {
  final normalized = value.replaceFirst('#', '');
  final argb = normalized.length == 6 ? 'FF$normalized' : normalized;
  return Color(int.parse(argb, radix: 16));
}
