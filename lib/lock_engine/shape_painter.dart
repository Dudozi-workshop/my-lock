import 'dart:math';

import 'package:flutter/material.dart';

import 'effects.dart';
import 'models.dart';
import 'shape_geometry.dart';

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
    final illustrated =
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
      );
      return;
    }

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
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required ShapeTexture texture,
  required double opacity,
}) {
  final colors = _tokenToneColors(tone);
  final bounds = Rect.fromCircle(center: center, radius: radius);

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

void _paintIllustratedShape(
  Canvas canvas, {
  required IllustratedShapeGeometry geometry,
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required ShapeTexture texture,
  required double opacity,
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

  final accentAlpha = switch (texture) {
    ShapeTexture.glossy => 0.92,
    ShapeTexture.jelly => 0.78,
    ShapeTexture.glass => 0.42,
    ShapeTexture.matte => 0.90,
    ShapeTexture.metal => 0.58,
    ShapeTexture.chrome => 0.42,
    ShapeTexture.hologram => 0.34,
  };

  final accentBase = tone == ShapeTone.white
      ? const Color(0xFFEFF0F5)
      : Color.lerp(colors.$1, Colors.white, 0.48)!;

  // Accent zones are structural details of an illustrated Shape, not a second
  // user-selected color. They are always derived from the active ShapeTone.
  canvas.save();
  canvas.clipPath(geometry.combinedPath);
  for (final part in geometry.parts) {
    if (part.role != ShapePartRole.accentZone) continue;
    canvas.drawPath(
      part.path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = accentBase.withValues(alpha: accentAlpha * opacity),
    );
  }
  canvas.restore();

  final shadeAlpha = switch (texture) {
    ShapeTexture.glass => 0.08,
    ShapeTexture.jelly => 0.10,
    ShapeTexture.glossy => 0.12,
    ShapeTexture.matte => 0.08,
    ShapeTexture.metal => 0.18,
    ShapeTexture.chrome => 0.20,
    ShapeTexture.hologram => 0.10,
  };

  // Optional appendages can still receive depth treatment later. Accent zones
  // are excluded so the belly remains a clean light derived tone.
  final appendagePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = colors.$2.withValues(alpha: shadeAlpha * opacity);

  for (final part in geometry.parts) {
    if (part.role == ShapePartRole.body ||
        part.role == ShapePartRole.accentZone) {
      continue;
    }
    canvas.drawPath(part.path, appendagePaint);
  }

  if (texture == ShapeTexture.matte) return;

  final partHighlight = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = max(0.9, radius * 0.025)
    ..strokeCap = StrokeCap.round
    ..color = Colors.white.withValues(
      alpha: (texture == ShapeTexture.glass ? 0.32 : 0.18) * opacity,
    );

  for (final part in geometry.parts) {
    if (part.role == ShapePartRole.body ||
        part.role == ShapePartRole.accentZone) {
      continue;
    }
    canvas.drawPath(part.path, partHighlight);
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
