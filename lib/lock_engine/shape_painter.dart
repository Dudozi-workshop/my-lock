import 'dart:math';

import 'package:flutter/material.dart';

import 'effects.dart';
import 'models.dart';

class LockTokenPainter extends CustomPainter {
  const LockTokenPainter(
    this.token, {
    this.texture = ShapeTexture.glossy,
  });

  final LockToken token;
  final ShapeTexture texture;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.31;
    final path = _tokenShapePath(token.shape, center, radius);
    _paintStyledShape(
      canvas,
      path: path,
      center: center,
      radius: radius,
      tone: token.tone,
      texture: texture,
      opacity: 1,
    );
  }

  @override
  bool shouldRepaint(covariant LockTokenPainter oldDelegate) =>
      oldDelegate.token.id != token.id || oldDelegate.texture != texture;
}

Path _roundedPolygonPath(List<Offset> points, double cornerRadius) {
  if (points.length < 3) return Path();

  Offset toward(Offset from, Offset to, double distance) {
    final delta = to - from;
    final length = delta.distance;
    if (length == 0) return from;
    return from + delta / length * distance;
  }

  final path = Path();
  for (var i = 0; i < points.length; i++) {
    final previous = points[(i - 1 + points.length) % points.length];
    final current = points[i];
    final next = points[(i + 1) % points.length];
    final start = toward(current, previous, cornerRadius);
    final end = toward(current, next, cornerRadius);

    if (i == 0) {
      path.moveTo(start.dx, start.dy);
    } else {
      path.lineTo(start.dx, start.dy);
    }
    path.quadraticBezierTo(current.dx, current.dy, end.dx, end.dy);
  }
  return path..close();
}

Path _tokenShapePath(ShapeKind kind, Offset center, double radius) {
  switch (kind) {
    case ShapeKind.circle:
      return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    case ShapeKind.triangle:
      final points = <Offset>[
        for (var i = 0; i < 3; i++)
          center +
              Offset(
                    cos(-pi / 2 + i * pi * 2 / 3),
                    sin(-pi / 2 + i * pi * 2 / 3),
                  ) *
                  radius,
      ];
      return _roundedPolygonPath(points, radius * 0.16);
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

Color _adjustSoftBasicTone(
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

({Color base, Color highlight, Color shade}) _softBasicToneColors(
  ShapeTone tone,
) {
  final base = _tokenToneColors(tone).$1;
  return (
    base: base,
    highlight: _adjustSoftBasicTone(
      base,
      lightnessDelta: 0.065,
      saturationDelta: 0.0,
    ),
    shade: _adjustSoftBasicTone(
      base,
      lightnessDelta: -0.04,
      saturationDelta: 0.01,
    ),
  );
}

void _paintStyledShape(
  Canvas canvas, {
  required Path path,
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required ShapeTexture texture,
  required double opacity,
}) {
  final colors = _tokenToneColors(tone);
  final bounds = Rect.fromCircle(center: center, radius: radius);

  final softBasicColors = _softBasicToneColors(tone);
  final shadowAlpha = switch (texture) {
    ShapeTexture.glossy => 0.05,
    ShapeTexture.glass => 0.12,
    ShapeTexture.chrome => 0.34,
    ShapeTexture.metal => 0.30,
    _ => 0.24,
  };
  final shadowElevation = switch (texture) {
    ShapeTexture.glossy => 3.0,
    ShapeTexture.matte => 7.0,
    _ => 12.0,
  };
  canvas.drawShadow(
    path,
    (texture == ShapeTexture.glossy ? softBasicColors.shade : colors.$2)
        .withValues(alpha: shadowAlpha * opacity),
    shadowElevation,
    true,
  );

  final fill = Paint();
  switch (texture) {
    case ShapeTexture.glossy:
      // Soft Basic v2: keep the palette base visible across most of the shape.
      // Tone changes only frame the upper-left light and lower-right depth.
      fill.shader = RadialGradient(
        center: const Alignment(-0.46, -0.52),
        radius: 1.22,
        colors: [
          softBasicColors.highlight.withValues(alpha: opacity),
          softBasicColors.base.withValues(alpha: opacity),
          softBasicColors.base.withValues(alpha: opacity),
          softBasicColors.shade.withValues(alpha: opacity),
        ],
        stops: const [0.0, 0.24, 0.80, 1.0],
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

  if (texture == ShapeTexture.glossy) {
    canvas.save();
    canvas.clipPath(path);

    // Keep white as a small, clean accent only. The body remains dominated by
    // the original palette color instead of stacking extra light/shade layers.
    final highlightCenter =
        center.translate(-radius * 0.28, -radius * 0.31);
    canvas.save();
    canvas.translate(highlightCenter.dx, highlightCenter.dy);
    canvas.rotate(-0.52);
    final specular = Paint()
      ..color = Colors.white.withValues(alpha: 0.50 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, max(0.4, radius * 0.008));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 0.42,
          height: radius * 0.17,
        ),
        Radius.circular(radius * 0.10),
      ),
      specular,
    );
    canvas.restore();

    canvas.restore();
  } else {
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

    final path = _shapePath(object.token.shape, object.position, radius);

    _paintStyledShape(
      canvas,
      path: path,
      center: object.position,
      radius: radius,
      tone: object.token.tone,
      texture: texture,
      opacity: opacity,
    );

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
