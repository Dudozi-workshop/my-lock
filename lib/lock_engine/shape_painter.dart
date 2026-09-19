import 'dart:math';

import 'package:flutter/material.dart';

import 'effects.dart';
import 'models.dart';

class FloatingShapePainter extends CustomPainter {
  const FloatingShapePainter({
    required this.objects,
    this.popStyle = PopStyle.basicPop,
  });

  final List<FloatingObject> objects;
  final PopStyle popStyle;

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
    final path = _shapePath(object.token.shape, object.position, radius);
    final colors = _toneColors(object.token.tone);

    canvas.drawShadow(
      path,
      colors.$2.withValues(alpha: 0.26 * opacity),
      12,
      true,
    );

    final fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.55),
        radius: 1.25,
        colors: [
          Colors.white.withValues(alpha: 0.88 * opacity),
          colors.$1.withValues(alpha: 0.95 * opacity),
          colors.$2.withValues(alpha: 0.98 * opacity),
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(
        Rect.fromCircle(center: object.position, radius: radius),
      );

    canvas.drawPath(path, fill);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.2, radius * 0.035)
      ..color = Colors.white.withValues(alpha: 0.62 * opacity);
    canvas.drawPath(path, border);

    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.42 * opacity);
    canvas.drawOval(
      Rect.fromCenter(
        center: object.position.translate(-radius * 0.26, -radius * 0.28),
        width: radius * 0.52,
        height: radius * 0.24,
      ),
      highlight,
    );
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

  Path _shapePath(ShapeKind kind, Offset center, double radius) {
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
    }
  }

  (Color, Color) _toneColors(ShapeTone tone) {
    switch (tone) {
      case ShapeTone.pink:
        return (const Color(0xFFFF8FD1), const Color(0xFFE656AB));
      case ShapeTone.blue:
        return (const Color(0xFF79BFFF), const Color(0xFF3F6FEA));
      case ShapeTone.yellow:
        return (const Color(0xFFFFDA72), const Color(0xFFF0A632));
    }
  }

  @override
  bool shouldRepaint(covariant FloatingShapePainter oldDelegate) => true;
}
