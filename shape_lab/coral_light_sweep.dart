import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Rare · Coral Shelter signature candidate.
///
/// This is an independent runtime overlay. It does not alter the approved
/// Base Only v2 pixels or the fixed R27 / R31 motion parameters.
class CoralLightSweep extends StatelessWidget {
  const CoralLightSweep({
    super.key,
    required this.animation,
    this.intensity = 1.0,
  });

  final Animation<double> animation;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CoralLightSweepPainter(
          animation: animation,
          intensity: intensity,
        ),
      ),
    );
  }
}

@immutable
class CoralLightSweepSample {
  const CoralLightSweepSample({
    required this.coral,
    required this.sweep,
    required this.floorFollow,
  });

  final double coral;
  final double sweep;
  final double floorFollow;
}

class CoralLightSweepTimeline {
  const CoralLightSweepTimeline._();

  static CoralLightSweepSample sample(double t) {
    final p = t.clamp(0.0, 1.0);
    // One restrained signature moment during the 18 s detail clock.
    // Coral responds first, broad water light follows, then the floor settles.
    return CoralLightSweepSample(
      coral: _pulse(p, .08, .18, .34),
      sweep: _pulse(p, .14, .28, .48),
      floorFollow: _pulse(p, .25, .39, .58),
    );
  }

  static double _pulse(double p, double start, double peak, double end) {
    if (p <= start || p >= end) return 0;
    if (p <= peak) return _smooth((p - start) / (peak - start));
    return _smooth((end - p) / (end - peak));
  }

  static double _smooth(double x) {
    final v = x.clamp(0.0, 1.0);
    return v * v * (3 - 2 * v);
  }
}

class CoralLightSweepPainter extends CustomPainter {
  CoralLightSweepPainter({
    required this.animation,
    required this.intensity,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final s = CoralLightSweepTimeline.sample(animation.value);
    if (s.coral <= 0 && s.sweep <= 0 && s.floorFollow <= 0) return;

    final strength = intensity.clamp(0.0, 1.5);

    // 1) Very small pre-response around the lower-left coral shelter.
    if (s.coral > 0) {
      final center = Offset(size.width * .19, size.height * .74);
      final radius = size.width * .43;
      final paint = Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE8C9).withValues(alpha: .16 * s.coral * strength),
            const Color(0xFFFFF3DD).withValues(alpha: .07 * s.coral * strength),
            Colors.transparent,
          ],
          stops: const [0, .46, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    // 2) A broad, soft light mass crosses the water column.
    if (s.sweep > 0) {
      final travel = Curves.easeInOut.transform(
        ((animation.value - .14) / (.48 - .14)).clamp(0.0, 1.0),
      );
      final centerX = size.width * (-.12 + 1.24 * travel);
      final rect = Rect.fromCenter(
        center: Offset(centerX, size.height * .39),
        width: size.width * .80,
        height: size.height * .72,
      );
      final paint = Paint()
        ..blendMode = BlendMode.screen
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.transparent,
            const Color(0xFFE8FBFF).withValues(alpha: .055 * s.sweep * strength),
            const Color(0xFFFFF5D8).withValues(alpha: .105 * s.sweep * strength),
            const Color(0xFFE8FBFF).withValues(alpha: .045 * s.sweep * strength),
            Colors.transparent,
          ],
          stops: const [0, .27, .48, .68, 1],
        ).createShader(rect);

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(-math.pi * .075);
      canvas.translate(-rect.center.dx, -rect.center.dy);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(size.width * .28)),
        paint,
      );
      canvas.restore();
    }

    // 3) Floor follow: broad and low-contrast, never a second caustic pattern.
    if (s.floorFollow > 0) {
      final floorRect = Rect.fromLTRB(
        0,
        size.height * .61,
        size.width,
        size.height,
      );
      final paint = Paint()
        ..blendMode = BlendMode.screen
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFFFFEFD3).withValues(
              alpha: .055 * s.floorFollow * strength,
            ),
            const Color(0xFFFFF7E6).withValues(
              alpha: .085 * s.floorFollow * strength,
            ),
          ],
          stops: const [0, .56, 1],
        ).createShader(floorRect);
      canvas.drawRect(floorRect, paint);
    }
  }

  @override
  bool shouldRepaint(CoralLightSweepPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.intensity != intensity;
}
