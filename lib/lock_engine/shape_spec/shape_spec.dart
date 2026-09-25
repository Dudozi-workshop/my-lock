import 'package:flutter/material.dart';

import '../models.dart';

enum ShapeLayerRole { light, shade, spec }

class ShapeStyleSpec {
  const ShapeStyleSpec({
    required this.id,
    required this.version,
    required this.canvasSize,
    required this.colorRules,
  });

  final String id;
  final int version;
  final double canvasSize;
  final ShapeColorRuleSpec colorRules;

  factory ShapeStyleSpec.fromJson(Map<String, dynamic> json) {
    return ShapeStyleSpec(
      id: json['id'] as String,
      version: (json['version'] as num).toInt(),
      canvasSize: (json['canvasSize'] as num).toDouble(),
      colorRules: ShapeColorRuleSpec.fromJson(
        json['colorRules'] as Map<String, dynamic>,
      ),
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
    required this.layers,
    required this.shadow,
  });

  final String styleId;
  final String shapeId;
  final int version;
  final ShapeGeometrySpec body;
  final List<ShapeLayerSpec> layers;
  final ShapeShadowSpec shadow;

  factory ShapeSpec.fromJson(Map<String, dynamic> json) {
    return ShapeSpec(
      styleId: json['styleId'] as String,
      shapeId: json['shapeId'] as String,
      version: (json['version'] as num).toInt(),
      body: ShapeGeometrySpec.fromJson(json['body'] as Map<String, dynamic>),
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
    required this.opacity,
    required this.blur,
    required this.rotationDeg,
    required this.geometry,
  });

  final String id;
  final ShapeLayerRole role;
  final double opacity;
  final double blur;
  final double rotationDeg;
  final ShapeGeometrySpec geometry;

  factory ShapeLayerSpec.fromJson(Map<String, dynamic> json) {
    return ShapeLayerSpec(
      id: json['id'] as String,
      role: ShapeLayerRole.values.byName(json['role'] as String),
      opacity: (json['opacity'] as num).toDouble(),
      blur: (json['blur'] as num).toDouble(),
      rotationDeg: (json['rotationDeg'] as num?)?.toDouble() ?? 0,
      geometry: ShapeGeometrySpec.fromJson(
        json['geometry'] as Map<String, dynamic>,
      ),
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
