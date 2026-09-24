import 'dart:math';

import 'package:flutter/material.dart';

import 'effects.dart';
import 'models.dart';
import 'shape_geometry.dart';

class LockTokenPainter extends CustomPainter {
  const LockTokenPainter(
    this.token, {
    this.texture = ShapeTexture.glossy,
    this.blueprintOverride,
    this.accentLightness = 0.48,
  });

  final LockToken token;
  final ShapeTexture texture;

  /// Shape Lab can supply a draft blueprint while still using this exact
  /// production painter. Normal app rendering leaves this null.
  final ShapeBlueprint? blueprintOverride;

  /// Blend amount toward white for ShapePartRole.accent.
  final double accentLightness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.31;
    final illustrated = blueprintOverride?.build(center, radius) ??
        buildIllustratedShapeGeometry(token.shape, center, radius);
    if (illustrated != null) {
      _paintIllustratedShape(
        canvas,
        geometry: illustrated,
        center: center,
        radius: radius,
        tone: token.tone,
        texture: texture,
        opacity: 1,
        accentLightness: accentLightness,
      );
      return;
    }

    final path = _tokenShapePath(token.shape, center, radius);
    _paintStyledShape(
      canvas,
      path: path,
      crystalKind: token.shape,
      center: center,
      radius: radius,
      tone: token.tone,
      texture: texture,
      opacity: 1,
    );
  }

  @override
  bool shouldRepaint(covariant LockTokenPainter oldDelegate) =>
      oldDelegate.token.id != token.id ||
      oldDelegate.texture != texture ||
      oldDelegate.blueprintOverride != blueprintOverride ||
      oldDelegate.accentLightness != accentLightness;
}

Path _tokenShapePath(ShapeKind kind, Offset center, double radius) {
  switch (kind) {
    case ShapeKind.circle:
      return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    case ShapeKind.triangle:
      final path = Path();
      for (var i = 0; i < 3; i++) {
        final angle = -pi / 2 + i * pi * 2 / 3;
        final point = center + Offset(cos(angle), sin(angle)) * radius;
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      return path..close();
    case ShapeKind.square:
      final rect = Rect.fromCenter(
        center: center,
        width: radius * 1.58,
        height: radius * 1.58,
      );
      return Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(radius * 0.32),
          ),
        );
    case ShapeKind.star:
      final path = Path();
      for (var i = 0; i < 10; i++) {
        final angle = -pi / 2 + i * pi / 5;
        final r = i.isEven ? radius : radius * 0.46;
        final point = center + Offset(cos(angle), sin(angle)) * r;
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      return path..close();
    case ShapeKind.heart:
      final path = Path()
        ..moveTo(center.dx, center.dy + radius * 0.82)
        ..cubicTo(
          center.dx - radius * 0.96,
          center.dy + radius * 0.10,
          center.dx - radius * 0.82,
          center.dy - radius * 0.74,
          center.dx - radius * 0.38,
          center.dy - radius * 0.62,
        )
        ..cubicTo(
          center.dx - radius * 0.08,
          center.dy - radius * 0.55,
          center.dx,
          center.dy - radius * 0.28,
          center.dx,
          center.dy - radius * 0.16,
        )
        ..cubicTo(
          center.dx,
          center.dy - radius * 0.28,
          center.dx + radius * 0.08,
          center.dy - radius * 0.55,
          center.dx + radius * 0.38,
          center.dy - radius * 0.62,
        )
        ..cubicTo(
          center.dx + radius * 0.82,
          center.dy - radius * 0.74,
          center.dx + radius * 0.96,
          center.dy + radius * 0.10,
          center.dx,
          center.dy + radius * 0.82,
        );
      return path..close();
    case ShapeKind.diamond:
      return Path()
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx + radius * 0.78, center.dy)
        ..lineTo(center.dx, center.dy + radius)
        ..lineTo(center.dx - radius * 0.78, center.dy)
        ..close();
    case ShapeKind.hexagon:
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final angle = -pi / 2 + i * pi / 3;
        final point = center + Offset(cos(angle), sin(angle)) * radius;
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      return path..close();
    case ShapeKind.crescent:
      final outer = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius));
      final cutout = Path()
        ..addOval(
          Rect.fromCircle(
            center: center.translate(radius * 0.38, -radius * 0.10),
            radius: radius * 0.82,
          ),
        );
      return Path.combine(PathOperation.difference, outer, cutout);
    case ShapeKind.dolphin:
      return buildIllustratedShapeGeometry(kind, center, radius)!.combinedPath;
  }
}

(Color, Color) _tokenToneColors(ShapeTone tone) {
  switch (tone) {
    case ShapeTone.pink:
      return (const Color(0xFFFF8FD1), const Color(0xFFE656AB));
    case ShapeTone.blue:
      return (const Color(0xFF79BFFF), const Color(0xFF3F6FEA));
    case ShapeTone.yellow:
      return (const Color(0xFFFFDA72), const Color(0xFFF0A632));
    case ShapeTone.purple:
      return (const Color(0xFFC7A4FF), const Color(0xFF7447D9));
    case ShapeTone.mint:
      return (const Color(0xFF9EF3D2), const Color(0xFF2FAF89));
    case ShapeTone.black:
      return (const Color(0xFF5A5A64), const Color(0xFF17171D));
    case ShapeTone.white:
      return (const Color(0xFFFFFFFF), const Color(0xFFD9D9E2));
  }
}

void _paintStyledShape(
  Canvas canvas, {
  required Path path,
  ShapeKind? crystalKind,
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required ShapeTexture texture,
  required double opacity,
}) {
  final colors = _tokenToneColors(tone);
  final bounds = Rect.fromCircle(center: center, radius: radius);

  if (texture == ShapeTexture.glass) {
    if (crystalKind == ShapeKind.circle) {
      _paintRoundCutCrystal(
        canvas,
        path: path,
        center: center,
        radius: radius,
        tone: tone,
        opacity: opacity,
      );
    } else {
      _paintCrystalShape(
        canvas,
        path: path,
        center: center,
        radius: radius,
        tone: tone,
        opacity: opacity,
      );
    }
    return;
  }

  final shadowAlpha = switch (texture) {
    ShapeTexture.glass => 0.12,
    ShapeTexture.chrome => 0.34,
    ShapeTexture.metal => 0.30,
    _ => 0.24,
  };
  canvas.drawShadow(
    path,
    colors.$2.withValues(alpha: shadowAlpha * opacity),
    texture == ShapeTexture.matte ? 7 : 12,
    true,
  );

  final fill = Paint();
  switch (texture) {
    case ShapeTexture.glossy:
      fill.shader = RadialGradient(
        center: const Alignment(-0.45, -0.55),
        radius: 1.25,
        colors: [
          Colors.white.withValues(alpha: 0.88 * opacity),
          colors.$1.withValues(alpha: 0.95 * opacity),
          colors.$2.withValues(alpha: 0.98 * opacity),
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(bounds);
      break;
    case ShapeTexture.jelly:
      fill.shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 1.15,
        colors: [
          Colors.white.withValues(alpha: 0.76 * opacity),
          colors.$1.withValues(alpha: 0.78 * opacity),
          colors.$2.withValues(alpha: 0.88 * opacity),
        ],
        stops: const [0.0, 0.40, 1.0],
      ).createShader(bounds);
      break;
    case ShapeTexture.glass:
      fill.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.74 * opacity),
          colors.$1.withValues(alpha: 0.28 * opacity),
          colors.$2.withValues(alpha: 0.42 * opacity),
        ],
      ).createShader(bounds);
      break;
    case ShapeTexture.metal:
      fill.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.$1.withValues(alpha: opacity),
          const Color(0xFFE6E7EC).withValues(alpha: opacity),
          colors.$2.withValues(alpha: opacity),
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(bounds);
      break;
    case ShapeTexture.chrome:
      fill.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: opacity),
          colors.$1.withValues(alpha: opacity),
          const Color(0xFF53545E).withValues(alpha: opacity),
          Colors.white.withValues(alpha: opacity),
          colors.$2.withValues(alpha: opacity),
        ],
        stops: const [0.0, 0.20, 0.47, 0.62, 1.0],
      ).createShader(bounds);
      break;
    case ShapeTexture.hologram:
      fill.shader = SweepGradient(
        colors: [
          const Color(0xFFFF87CD).withValues(alpha: opacity),
          const Color(0xFF8BD8FF).withValues(alpha: opacity),
          const Color(0xFF9EF3D2).withValues(alpha: opacity),
          const Color(0xFFFFE27A).withValues(alpha: opacity),
          const Color(0xFFC69CFF).withValues(alpha: opacity),
          const Color(0xFFFF87CD).withValues(alpha: opacity),
        ],
      ).createShader(bounds);
      break;
    case ShapeTexture.matte:
      fill.color = colors.$1.withValues(alpha: opacity);
      break;
  }

  canvas.drawPath(path, fill);

  final borderColor = tone == ShapeTone.white
      ? const Color(0xFFB9B9C4)
      : Colors.white;
  final border = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = max(1.2, radius * 0.035)
    ..color = borderColor.withValues(
      alpha: (texture == ShapeTexture.glass ? 0.88 : 0.58) * opacity,
    );
  canvas.drawPath(path, border);

  if (texture != ShapeTexture.matte) {
    final highlight = Paint()
      ..color = Colors.white.withValues(
        alpha: (texture == ShapeTexture.glass ? 0.58 : 0.40) * opacity,
      );
    canvas.save();
    canvas.clipPath(path);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(-radius * 0.26, -radius * 0.28),
        width: radius * 0.52,
        height: radius * 0.24,
      ),
      highlight,
    );
    canvas.restore();
  }
}


// A round brilliant cut: a continuous table, a ring of angled crown facets,
// and a thin directional girdle. Keep faces large enough to read at 58 px.
void _paintRoundCutCrystal(
  Canvas canvas, {
  required Path path,
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required double opacity,
}) {
  final colors = _tokenToneColors(tone);
  final light = Color.lerp(colors.$1, Colors.white, .55)!;
  final pale = Color.lerp(colors.$1, Colors.white, .78)!;
  final shade = Color.lerp(colors.$1, colors.$2, .63)!;
  final deep = Color.lerp(colors.$2, Colors.black, .12)!;
  const count = 12;
  const start = -pi / 2 - pi / 12;
  Offset vertex(int index, double scale) {
    final angle = start + index * 2 * pi / count;
    return center + Offset(cos(angle), sin(angle)) * radius * scale;
  }

  void facet(List<Offset> points, Color color, {double alpha = 1}) {
    canvas.drawPath(
      Path()..addPolygon(points, true),
      Paint()..color = color.withValues(alpha: alpha * opacity),
    );
  }

  canvas.drawShadow(path, colors.$2.withValues(alpha: .24 * opacity), 8, true);
  canvas.save();
  canvas.clipPath(path);
  canvas.drawPath(path, Paint()..color = shade.withValues(alpha: opacity));

  // The exterior vertices extend past the circular silhouette; clipping
  // preserves its smooth edge while exposing the angled crown planes.
  final crown = <Color>[
    pale, light, colors.$1, shade, light, colors.$1,
    shade, light, colors.$1, deep, shade, light,
  ];
  for (var i = 0; i < count; i++) {
    facet([
      vertex(i, 1.08), vertex(i + 1, 1.08),
      vertex(i + 1, .58), vertex(i, .58),
    ], crown[i]);
  }

  final table = Path()
    ..addPolygon([for (var i = 0; i < count; i++) vertex(i, .58)], true);
  canvas.drawPath(
    table,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          pale.withValues(alpha: opacity),
          light.withValues(alpha: opacity),
          colors.$1.withValues(alpha: opacity),
          shade.withValues(alpha: opacity),
        ],
        stops: const [0, .38, .76, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius * .60)),
  );
  // A restrained reflection crosses the table without turning its center
  // into a white stripe or splitting it into many tiny radial wedges.
  facet([
    vertex(10, .58),
    vertex(11, .58),
    vertex(1, .58),
    center.translate(radius * .06, -radius * .10),
  ], pale, alpha: .42);
  canvas.drawPath(
    table,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(.6, radius * .04)
      ..color = deep.withValues(alpha: .42 * opacity),
  );
  canvas.restore();

  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(.9, radius * .05)
      ..color = shade.withValues(alpha: .80 * opacity),
  );
  final rim = Path()
    ..addArc(Rect.fromCircle(center: center, radius: radius),
        -pi * .91, pi * .85);
  canvas.drawPath(
    rim,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = max(.7, radius * .04)
      ..color = Colors.white.withValues(alpha: .78 * opacity),
  );
}

void _paintCrystalShape(
  Canvas canvas, {
  required Path path,
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required double opacity,
}) {
  final colors = _tokenToneColors(tone);
  // Facets follow the silhouette's own bounds, so the same surface also works
  // on wide illustrated shapes. The silhouette remains the only outer edge.
  final bounds = path.getBounds();
  final isWide = bounds.width > bounds.height * 1.65;
  final pale = Color.lerp(colors.$1, Colors.white, 0.76)!;
  final mid = Color.lerp(colors.$1, colors.$2, isWide ? 0.28 : 0.12)!;
  final deep = isWide
      ? Color.lerp(colors.$2, Colors.black, 0.20)!
      : Color.lerp(colors.$1, colors.$2, 0.72)!;
  Offset point(double x, double y) => Offset(
        bounds.left + bounds.width * x,
        bounds.top + bounds.height * y,
      );

  void facet(List<Offset> points, Color color) {
    final face = Path()..addPolygon(points, true);
    canvas.drawPath(face, Paint()..color = color.withValues(alpha: opacity));
  }

  canvas.drawShadow(
    path,
    colors.$2.withValues(alpha: 0.28 * opacity),
    8,
    true,
  );

  canvas.save();
  canvas.clipPath(path);
  canvas.drawPath(path, Paint()..color = mid.withValues(alpha: opacity));

  // Wide illustrated silhouettes need facets along the body instead of a
  // central radial pattern that would cut the animal in two.
  if (isWide) {
    facet([point(0, 0), point(.33, 0), point(.42, .36), point(.12, .53)],
        Color.lerp(colors.$1, pale, .32)!);
    facet([point(.33, 0), point(.70, 0), point(.77, .35), point(.42, .36)],
        Color.lerp(colors.$1, colors.$2, .28)!);
    facet([point(.70, 0), point(1, 0), point(1, .52), point(.77, .35)],
        Color.lerp(colors.$2, deep, .27)!);
    facet([point(0, .56), point(.12, .53), point(.34, .62), point(.25, 1)],
        Color.lerp(colors.$1, colors.$2, .20)!);
    facet([point(.25, 1), point(.34, .62), point(.59, .69), point(.62, 1)],
        Color.lerp(colors.$1, pale, .38)!);
    facet([point(.62, 1), point(.59, .69), point(.80, .57), point(1, 1)],
        Color.lerp(colors.$2, deep, .16)!);
    facet([point(.12, .53), point(.42, .36), point(.52, .51), point(.34, .62)],
        Color.lerp(colors.$1, pale, .62)!);
    facet([point(.42, .36), point(.77, .35), point(.63, .53), point(.52, .51)],
        Color.lerp(colors.$1, pale, .22)!);
    facet([point(.52, .51), point(.63, .53), point(.59, .69), point(.34, .62)],
        Color.lerp(colors.$1, colors.$2, .18)!);
    facet([point(.77, .35), point(1, .52), point(.80, .57), point(.63, .53)],
        Color.lerp(colors.$2, pale, .22)!);
  } else {
    final topLeft = point(0, 0);
    final top = point(.50, 0);
    final topRight = point(1, 0);
    final right = point(1, .50);
    final bottomRight = point(1, 1);
    final bottom = point(.50, 1);
    final bottomLeft = point(0, 1);
    final left = point(0, .50);
    final a = point(.29, .32);
    final b = point(.54, .27);
    final c = point(.73, .37);
    final d = point(.77, .62);
    final e = point(.51, .73);
    final f = point(.25, .62);
    final hub = point(.50, .50);

    facet([topLeft, top, b, a, left], Color.lerp(colors.$1, pale, .30)!);
    facet([top, topRight, right, c, b],
        Color.lerp(colors.$1, deep, .35)!);
    facet([left, a, f, bottomLeft],
        Color.lerp(colors.$1, deep, .18)!);
    facet([c, right, bottomRight, d],
        Color.lerp(colors.$1, colors.$2, .58)!);
    facet([bottomLeft, f, e, bottom],
        Color.lerp(colors.$1, pale, .25)!);
    facet([d, bottomRight, bottom, e],
        Color.lerp(colors.$1, colors.$2, .46)!);

    // Small adjacent planes replace the oversized white center of v1.
    facet([a, b, hub], Color.lerp(colors.$1, pale, .66)!);
    facet([b, c, hub], Color.lerp(colors.$1, pale, .37)!);
    facet([c, d, hub], Color.lerp(colors.$1, colors.$2, .52)!);
    facet([d, e, hub], Color.lerp(colors.$1, pale, .42)!);
    facet([e, f, hub], Color.lerp(colors.$1, colors.$2, .22)!);
    facet([f, a, hub], Color.lerp(colors.$1, pale, .28)!);
  }

  // Fine seams accent only the largest changes in plane direction.
  final seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = max(0.45, radius * 0.020)
    ..color = Colors.white.withValues(alpha: 0.42 * opacity);
  final seamPoints = isWide
      ? [point(.12, .53), point(.42, .36), point(.77, .35)]
      : [point(.29, .32), point(.54, .27), point(.73, .37)];
  canvas.drawPath(Path()..addPolygon(seamPoints, false), seam);

  canvas.restore();

  final outerRim = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..strokeWidth = max(1.1, radius * 0.055)
    ..color = deep.withValues(alpha: 0.75 * opacity);
  canvas.drawPath(path, outerRim);

  final litRim = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..strokeWidth = max(0.65, radius * 0.026)
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.98 * opacity),
        pale.withValues(alpha: 0.75 * opacity),
        Colors.white.withValues(alpha: 0.08 * opacity),
      ],
    ).createShader(bounds);
  canvas.drawPath(path, litRim);
}

void _paintIllustratedShape(
  Canvas canvas, {
  required IllustratedShapeGeometry geometry,
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required ShapeTexture texture,
  required double opacity,
  double accentLightness = 0.48,
}) {
  // First render the union silhouette through the existing material pipeline.
  // This keeps illustrated shapes visually consistent with the basic catalog.
  _paintStyledShape(
    canvas,
    path: geometry.combinedPath,
    center: center,
    radius: radius,
    tone: tone,
    texture: texture,
    opacity: opacity,
  );

  final colors = _tokenToneColors(tone);

  // High-detail Shape Accent Map
  // --------------------------------
  // Accent regions describe form/depth but must still read as one object.
  // They are always clipped to the canonical silhouette and never receive
  // their own outline.
  final mouthAlpha = switch (texture) {
    ShapeTexture.glossy => 0.78,
    ShapeTexture.jelly => 0.66,
    ShapeTexture.glass => 0.46,
    ShapeTexture.matte => 0.74,
    ShapeTexture.metal => 0.54,
    ShapeTexture.chrome => 0.40,
    ShapeTexture.hologram => 0.30,
  };
  final bellyAlpha = switch (texture) {
    ShapeTexture.glossy => 0.44,
    ShapeTexture.jelly => 0.38,
    ShapeTexture.glass => 0.30,
    ShapeTexture.matte => 0.42,
    ShapeTexture.metal => 0.34,
    ShapeTexture.chrome => 0.28,
    ShapeTexture.hologram => 0.20,
  };
  final frontFinShadeAlpha = switch (texture) {
    ShapeTexture.glossy => 0.055,
    ShapeTexture.jelly => 0.050,
    ShapeTexture.glass => 0.055,
    ShapeTexture.matte => 0.050,
    ShapeTexture.metal => 0.075,
    ShapeTexture.chrome => 0.080,
    ShapeTexture.hologram => 0.045,
  };
  final rearFinShadeAlpha = switch (texture) {
    ShapeTexture.glossy => 0.16,
    ShapeTexture.jelly => 0.14,
    ShapeTexture.glass => 0.14,
    ShapeTexture.matte => 0.14,
    ShapeTexture.metal => 0.20,
    ShapeTexture.chrome => 0.22,
    ShapeTexture.hologram => 0.12,
  };

  final mouthLightness =
      (accentLightness + 0.12).clamp(0.0, 0.88).toDouble();
  final bellyLightness =
      (accentLightness - 0.08).clamp(0.0, 0.76).toDouble();

  Color lightAccent(double lightness) {
    if (tone == ShapeTone.white) {
      return Color.lerp(
        const Color(0xFFE4E6ED),
        Colors.white,
        lightness,
      )!;
    }
    return Color.lerp(colors.$1, Colors.white, lightness)!;
  }

  final mouthPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = lightAccent(mouthLightness)
        .withValues(alpha: mouthAlpha * opacity);
  final bellyPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = lightAccent(bellyLightness)
        .withValues(alpha: bellyAlpha * opacity);
  final frontFinPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = colors.$2.withValues(alpha: frontFinShadeAlpha * opacity);
  final rearFinPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = colors.$2.withValues(alpha: rearFinShadeAlpha * opacity);

  canvas.save();
  canvas.clipPath(geometry.combinedPath);
  for (final part in geometry.parts) {
    final paint = switch (part.role) {
      ShapePartRole.accent => bellyPaint,
      ShapePartRole.mouthAccent => mouthPaint,
      ShapePartRole.bellyAccent => bellyPaint,
      ShapePartRole.frontFinAccent => frontFinPaint,
      ShapePartRole.rearFinAccent => rearFinPaint,
      _ => null,
    };
    if (paint != null) {
      canvas.drawPath(part.path, paint);
    }
  }
  canvas.restore();

  // Deliberately no per-part stroke/highlight here. The only outline belongs
  // to the outer silhouette rendered by _paintStyledShape. This keeps mouth,
  // belly and fins connected as a single glossy object.
}

class FloatingShapePainter extends CustomPainter {
  const FloatingShapePainter({
    required this.objects,
    this.popStyle = PopStyle.basicPop,
    this.texture = ShapeTexture.glossy,
  });

  final List<FloatingObject> objects;
  final PopStyle popStyle;
  final ShapeTexture texture;

  @override
  void paint(Canvas canvas, Size size) {
    for (final object in objects) {
      final progress = object.isPopping
          ? (object.popElapsed / 0.18).clamp(0.0, 1.0).toDouble()
          : 0.0;

      if (object.isPopping) {
        _paintPopFeedback(canvas, object, progress);
      }

      final scale = object.isPopping
          ? popStyle == PopStyle.bubble
              ? 1 + progress * 0.16
              : 1 + progress * 0.42
          : 1.0;
      final opacity = object.isPopping
          ? (1 - progress).clamp(0.0, 1.0).toDouble()
          : 1.0;
      _paintShape(canvas, object, scale: scale, opacity: opacity);
    }
  }

  void _paintPopFeedback(
    Canvas canvas,
    FloatingObject object,
    double progress,
  ) {
    switch (popStyle) {
      case PopStyle.bubble:
        _paintBubbleRings(canvas, object, progress);
        break;
      case PopStyle.basicPop:
      case PopStyle.spark:
      case PopStyle.pixel:
      case PopStyle.glassBreak:
        _paintPopParticles(canvas, object, progress);
        break;
    }
  }

  void _paintShape(
    Canvas canvas,
    FloatingObject object, {
    required double scale,
    required double opacity,
  }) {
    final radius = object.radius * scale;

    canvas.save();
    canvas.translate(object.position.dx, object.position.dy);
    canvas.rotate(object.rotation);
    canvas.translate(-object.position.dx, -object.position.dy);

    final illustrated = buildIllustratedShapeGeometry(
      object.token.shape,
      object.position,
      radius,
    );

    if (illustrated != null) {
      _paintIllustratedShape(
        canvas,
        geometry: illustrated,
        center: object.position,
        radius: radius,
        tone: object.token.tone,
        texture: texture,
        opacity: opacity,
      );
    } else {
      final path = _shapePath(object.token.shape, object.position, radius);
      _paintStyledShape(
        canvas,
        path: path,
        crystalKind: object.token.shape,
        center: object.position,
        radius: radius,
        tone: object.token.tone,
        texture: texture,
        opacity: opacity,
      );
    }

    canvas.restore();
  }

  void _paintPopParticles(
    Canvas canvas,
    FloatingObject object,
    double progress,
  ) {
    final colors = _toneColors(object.token.tone);
    final paint = Paint()
      ..color = colors.$1.withValues(alpha: (1 - progress) * 0.9);

    for (var i = 0; i < 8; i++) {
      final angle = pi * 2 * i / 8;
      final distance = object.radius * (0.55 + progress * 1.2);
      final particle =
          object.position + Offset(cos(angle), sin(angle)) * distance;
      final particleRadius = object.radius * (0.09 - progress * 0.045);
      canvas.drawCircle(particle, max(1.2, particleRadius), paint);
    }
  }

  void _paintBubbleRings(
    Canvas canvas,
    FloatingObject object,
    double progress,
  ) {
    final colors = _toneColors(object.token.tone);
    final opacity = (1 - progress).clamp(0.0, 1.0).toDouble();

    for (var i = 0; i < 2; i++) {
      final delay = i * 0.18;
      final localProgress =
          ((progress - delay) / (1 - delay)).clamp(0.0, 1.0).toDouble();
      if (progress < delay) continue;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.5, object.radius * 0.055)
        ..color = colors.$1.withValues(alpha: opacity * 0.75);

      canvas.drawCircle(
        object.position,
        object.radius * (0.72 + localProgress * 1.55),
        paint,
      );
    }
  }

  Path _shapePath(ShapeKind kind, Offset center, double radius) =>
      _tokenShapePath(kind, center, radius);

  (Color, Color) _toneColors(ShapeTone tone) => _tokenToneColors(tone);

  @override
  bool shouldRepaint(covariant FloatingShapePainter oldDelegate) => true;
}
