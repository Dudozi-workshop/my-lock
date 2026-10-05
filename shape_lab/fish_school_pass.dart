import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Rare · Coral Shelter signature PoC.
///
/// Motion-only prototype: five independently phased fish silhouettes travel
/// across the upper/mid water column. This intentionally avoids a fixed
/// school sprite so we can judge whether the scene reads as living swimmers
/// rather than one asset sliding across the screen.
class FishSchoolPass extends AnimatedWidget {
  const FishSchoolPass({
    super.key,
    required Animation<double> animation,
  }) : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _FishSchoolPainter(animation.value),
        size: Size.infinite,
      ),
    );
  }
}

class _FishSchoolPainter extends CustomPainter {
  const _FishSchoolPainter(this.t);

  final double t;

  static const _fish = <_FishSeed>[
    _FishSeed(0.00, 0.29, 0.90, 0.10, 0.00),
    _FishSeed(0.07, 0.23, 0.72, 0.32, 0.75),
    _FishSeed(0.13, 0.35, 0.78, 0.54, 1.45),
    _FishSeed(0.19, 0.27, 0.62, 0.70, 2.20),
    _FishSeed(0.24, 0.39, 0.68, 0.86, 2.95),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 18 s host clock: the school is visible for about 9.5 s, then the scene
    // rests before the next pass.
    final event = ((t - 0.03) / 0.58).clamp(0.0, 1.0);
    final active = t >= 0.03 && t <= 0.61;
    if (!active) return;

    final eased = Curves.easeInOutCubic.transform(event);
    final fadeIn = Curves.easeOut.transform((event / 0.10).clamp(0.0, 1.0));
    final fadeOut = 1.0 -
        Curves.easeIn.transform(((event - 0.88) / 0.12).clamp(0.0, 1.0));
    final groupAlpha = fadeIn * fadeOut;

    for (var i = 0; i < _fish.length; i++) {
      final seed = _fish[i];
      // Independent progress prevents the group from reading as one rigid
      // composition. Followers trail the leader and slightly compress/expand.
      final localProgress = (eased - seed.delay).clamp(0.0, 1.0);
      if (localProgress <= 0 || localProgress >= 1) continue;

      final x = size.width *
          (-0.19 + localProgress * 1.42 +
              0.015 * math.sin((event * 2.0 + seed.phase) * math.pi));
      final yBase = size.height * seed.y;
      final y = yBase +
          size.height *
              (0.018 * math.sin((event * 2.6 + seed.phase) * math.pi * 2) +
                  0.010 * math.sin((event * 1.15 + seed.phase) * math.pi * 2));

      final speedPulse =
          math.sin((event * 5.0 + seed.phase) * math.pi * 2);
      final tilt = 0.035 * speedPulse +
          0.018 * math.sin((event * 1.4 + seed.phase) * math.pi * 2);
      final tailPhase =
          math.sin((event * 12.0 + seed.phase) * math.pi * 2);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(tilt);
      final s = (size.width / 390.0) * seed.scale;
      canvas.scale(s, s);
      _drawFish(
        canvas,
        tailPhase: tailPhase,
        alpha: groupAlpha * (0.70 + i * 0.035),
      );
      canvas.restore();
    }
  }

  void _drawFish(
    Canvas canvas, {
    required double tailPhase,
    required double alpha,
  }) {
    // Soft blue-grey shadow, never black. The two large color masses mirror
    // MY LOCK's Storybook language without pretending this PoC is final art.
    final bodyPaint = Paint()
      ..color = const Color(0xFF315A72).withValues(alpha: 0.18 * alpha)
      ..style = PaintingStyle.fill;
    final deepPaint = Paint()
      ..color = const Color(0xFF244C65).withValues(alpha: 0.14 * alpha)
      ..style = PaintingStyle.fill;

    final body = Path()
      ..moveTo(-16, 0)
      ..cubicTo(-9, -8.5, 7, -9.5, 19, -3.2)
      ..cubicTo(23, -1.0, 23, 1.0, 19, 3.2)
      ..cubicTo(7, 9.5, -9, 8.5, -16, 0)
      ..close();
    canvas.drawPath(body, bodyPaint);

    final tailY = tailPhase * 5.3;
    final tail = Path()
      ..moveTo(-14.5, 0)
      ..cubicTo(-23, -2.0 + tailY, -29, -8.2 + tailY, -33, -10.2 + tailY)
      ..cubicTo(-31, -3.2 + tailY * .35, -31, 3.2 + tailY * .35, -33, 10.2 + tailY)
      ..cubicTo(-28, 7.8 + tailY, -22.5, 2.2 + tailY, -14.5, 0)
      ..close();
    canvas.drawPath(tail, bodyPaint);

    final fin = Path()
      ..moveTo(2, 2.0)
      ..quadraticBezierTo(-1, 8.5 + tailPhase * 1.2, -7.5, 7.2)
      ..quadraticBezierTo(-3.0, 3.5, 2, 2.0)
      ..close();
    canvas.drawPath(fin, deepPaint);

    // Tiny local highlight mass gives a storybook edge instead of a flat icon.
    final highlight = Paint()
      ..color = const Color(0xFF7DA7B8).withValues(alpha: 0.07 * alpha);
    canvas.drawOval(
      const Rect.fromLTWH(2, -5.6, 12.5, 4.4),
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant _FishSchoolPainter oldDelegate) => oldDelegate.t != t;
}

class _FishSeed {
  const _FishSeed(
    this.delay,
    this.y,
    this.scale,
    this.phase,
    this.variant,
  );

  final double delay;
  final double y;
  final double scale;
  final double phase;
  final double variant;
}
