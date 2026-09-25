import 'dart:math';

import 'package:flutter/material.dart';

import 'effects.dart';
import 'models.dart';
import 'shape_spec/shape_spec.dart';
import 'shape_spec/shape_spec_renderer.dart';

class LockTokenPainter extends CustomPainter {
  const LockTokenPainter(
    this.token, {
    this.style = ShapeStyle.softBasic,
  });

  final LockToken token;
  final ShapeStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.43;
    ShapeSpecRenderer.paintToken(
      canvas,
      center: center,
      radius: radius,
      token: token,
      style: style,
      opacity: 1,
    );
  }

  @override
  bool shouldRepaint(covariant LockTokenPainter oldDelegate) =>
      oldDelegate.token.id != token.id || oldDelegate.style != style;
}

class FloatingShapePainter extends CustomPainter {
  const FloatingShapePainter({
    required this.objects,
    this.popStyle = PopStyle.basicPop,
    this.style = ShapeStyle.softBasic,
  });

  final List<FloatingObject> objects;
  final PopStyle popStyle;
  final ShapeStyle style;

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

    ShapeSpecRenderer.paintToken(
      canvas,
      center: object.position,
      radius: radius,
      token: object.token,
      style: style,
      opacity: opacity,
    );

    canvas.restore();
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

  void _paintPopParticles(
    Canvas canvas,
    FloatingObject object,
    double progress,
  ) {
    final paint = Paint()
      ..color = baseColorForTone(object.token.tone)
          .withValues(alpha: (1 - progress) * 0.9);

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
    final opacity = (1 - progress).clamp(0.0, 1.0).toDouble();

    for (var i = 0; i < 2; i++) {
      final delay = i * 0.18;
      final localProgress =
          ((progress - delay) / (1 - delay)).clamp(0.0, 1.0).toDouble();
      if (progress < delay) continue;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.5, object.radius * 0.055)
        ..color = baseColorForTone(object.token.tone)
            .withValues(alpha: opacity * 0.75);

      canvas.drawCircle(
        object.position,
        object.radius * (0.72 + localProgress * 1.55),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FloatingShapePainter oldDelegate) => true;
}
