import 'dart:math' as math;
import 'package:flutter/material.dart';

/// R36 · Fish School Shadow Refined
///
/// Rare · Coral Shelter candidate.
/// One distant-life event only: 3–5 soft blue-grey fish silhouettes cross the
/// upper/mid background as an asynchronous loose school.
///
/// This is still a LABS candidate, not a Production Asset/Master.
class FishSchoolShadowRefined extends AnimatedWidget {
  const FishSchoolShadowRefined({
    super.key,
    required Animation<double> animation,
  }) : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _FishSchoolShadowPainter(animation.value),
        size: Size.infinite,
      ),
    );
  }
}

enum _FishKind { slender, round }

class _FishSchoolShadowPainter extends CustomPainter {
  const _FishSchoolShadowPainter(this.t);

  final double t;

  static const _school = <_FishSeed>[
    _FishSeed(_FishKind.slender, 0.00, 0.285, 0.92, 0.00),
    _FishSeed(_FishKind.round,   0.07, 0.235, 0.76, 0.28),
    _FishSeed(_FishKind.slender, 0.12, 0.345, 0.82, 0.51),
    _FishSeed(_FishKind.round,   0.18, 0.275, 0.67, 0.73),
    _FishSeed(_FishKind.slender, 0.23, 0.385, 0.71, 0.89),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // LABS preview cadence: ~8.5 s visible + long quiet interval.
    // Production cadence will be decided only after visual approval.
    const visibleStart = 0.08;
    const visibleEnd = 0.47;
    if (t < visibleStart || t > visibleEnd) return;

    final raw = ((t - visibleStart) / (visibleEnd - visibleStart)).clamp(0.0, 1.0);
    final travel = Curves.easeInOutSine.transform(raw);

    final fadeIn = Curves.easeOutCubic.transform((raw / 0.10).clamp(0.0, 1.0));
    final fadeOut = 1.0 -
        Curves.easeInCubic.transform(((raw - 0.90) / 0.10).clamp(0.0, 1.0));
    final eventAlpha = fadeIn * fadeOut;

    // Alternate the visual flow inside the long host loop without changing the
    // fish art. First half reads L→R; the second half can later become R→L in
    // production once cadence/random policy is approved. R36 keeps one clean
    // direction for art/motion QA.
    const direction = 1.0;

    for (var i = 0; i < _school.length; i++) {
      final seed = _school[i];
      final follower = ((travel - seed.delay) / (1.0 - seed.delay)).clamp(0.0, 1.0);
      if (follower <= 0 || follower >= 1) continue;

      // Loose-school breathing: followers do not preserve rigid offsets.
      final spread = math.sin((raw * 1.7 + seed.phase) * math.pi * 2);
      final drift = math.sin((raw * 0.82 + seed.phase * .7) * math.pi * 2);
      final xNorm = -0.17 + follower * 1.36 + spread * 0.012;
      final yNorm = seed.y + drift * 0.012 + spread * 0.005;

      final x = direction > 0 ? size.width * xNorm : size.width * (1 - xNorm);
      final y = size.height * yNorm;

      // Each fish gets a different swim frequency/phase so the school never
      // reads as one grouped sprite.
      final swimPhase = raw * (8.6 + i * .47) + seed.phase;
      final tail = math.sin(swimPhase * math.pi * 2);
      final bodyWave = math.sin((swimPhase - .13) * math.pi * 2);
      final tilt =
          0.022 * math.sin((raw * 1.2 + seed.phase) * math.pi * 2) +
          0.014 * bodyWave;

      // Slight depth fluctuation: smaller/softer followers feel farther away.
      final depthPulse = 1.0 + 0.025 * math.sin((raw * 1.1 + seed.phase) * math.pi * 2);
      final scale = (size.width / 390.0) * seed.scale * depthPulse;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(direction > 0 ? tilt : -tilt);
      canvas.scale(direction * scale, scale);

      _drawFish(
        canvas,
        kind: seed.kind,
        tail: tail,
        bodyWave: bodyWave,
        alpha: eventAlpha * (0.74 + i * .035),
      );
      canvas.restore();
    }
  }

  void _drawFish(
    Canvas canvas, {
    required _FishKind kind,
    required double tail,
    required double bodyWave,
    required double alpha,
  }) {
    // Distant blue-grey shadow, intentionally lower contrast than foreground
    // shapes. No eyes/face/hard outline.
    final bodyPaint = Paint()
      ..color = const Color(0xFF294F68).withValues(alpha: 0.13 * alpha)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.55);
    final deepPaint = Paint()
      ..color = const Color(0xFF203F55).withValues(alpha: 0.08 * alpha)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.45);

    final body = kind == _FishKind.slender
        ? _slenderBody(bodyWave)
        : _roundBody(bodyWave);
    canvas.drawPath(body, bodyPaint);

    final tailPath = kind == _FishKind.slender
        ? _slenderTail(tail)
        : _roundTail(tail);
    canvas.drawPath(tailPath, bodyPaint);

    final fin = kind == _FishKind.slender
        ? (Path()
          ..moveTo(1.5, 2.2)
          ..quadraticBezierTo(-3.5, 8.0 + bodyWave * 1.0, -10.0, 6.2)
          ..quadraticBezierTo(-4.0, 3.0, 1.5, 2.2)
          ..close())
        : (Path()
          ..moveTo(0.0, 3.0)
          ..quadraticBezierTo(-4.0, 9.5 + bodyWave * .8, -9.0, 7.2)
          ..quadraticBezierTo(-4.0, 4.2, 0.0, 3.0)
          ..close());
    canvas.drawPath(fin, deepPaint);
  }

  Path _slenderBody(double wave) {
    final bend = wave * 1.25;
    return Path()
      ..moveTo(-18.0, bend * .15)
      ..cubicTo(-10.0, -7.2 + bend, 6.5, -8.5 - bend * .25, 19.5, -3.1)
      ..cubicTo(23.0, -1.4, 23.5, 1.2, 19.5, 3.1)
      ..cubicTo(7.0, 8.4 + bend * .25, -10.2, 7.0 - bend, -18.0, bend * .15)
      ..close();
  }

  Path _roundBody(double wave) {
    final bend = wave * .9;
    return Path()
      ..moveTo(-16.0, bend * .2)
      ..cubicTo(-8.5, -9.5 + bend, 7.5, -10.5, 18.0, -4.0)
      ..cubicTo(21.5, -1.8, 21.5, 1.8, 18.0, 4.0)
      ..cubicTo(7.5, 10.5, -8.5, 9.5 - bend, -16.0, bend * .2)
      ..close();
  }

  Path _slenderTail(double tail) {
    final y = tail * 5.0;
    return Path()
      ..moveTo(-16.0, 0)
      ..cubicTo(-23.0, -2.0 + y * .55, -29.0, -8.5 + y, -34.0, -11.0 + y)
      ..cubicTo(-31.8, -4.0 + y * .25, -31.6, 4.0 + y * .25, -34.0, 11.0 + y)
      ..cubicTo(-29.0, 8.5 + y, -23.0, 2.0 + y * .55, -16.0, 0)
      ..close();
  }

  Path _roundTail(double tail) {
    final y = tail * 4.2;
    return Path()
      ..moveTo(-14.5, 0)
      ..quadraticBezierTo(-23.0, -8.5 + y, -30.0, -8.0 + y)
      ..quadraticBezierTo(-26.0, -2.0 + y * .25, -29.0, 0.0 + y * .20)
      ..quadraticBezierTo(-26.0, 2.0 + y * .25, -30.0, 8.0 + y)
      ..quadraticBezierTo(-23.0, 8.5 + y, -14.5, 0)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _FishSchoolShadowPainter oldDelegate) =>
      oldDelegate.t != t;
}

class _FishSeed {
  const _FishSeed(
    this.kind,
    this.delay,
    this.y,
    this.scale,
    this.phase,
  );

  final _FishKind kind;
  final double delay;
  final double y;
  final double scale;
  final double phase;
}
