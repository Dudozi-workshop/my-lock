import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart' show Colors;

class FloorCausticPainter extends CustomPainter {
  FloorCausticPainter({required this.animation}) : super(repaint: animation);
  final Animation<double> animation;

  double _hash(double x) {
    final v = sin(x * 127.1 + 311.7) * 43758.5453;
    return v - v.floorToDouble();
  }

  Path _flowPath(
    Size size, {
    required double baseY,
    required double phase,
    required double tilt,
    required double seed,
  }) {
    final path = Path();
    const segments = 20;
    for (var i = 0; i <= segments; i++) {
      final u = i / segments;
      final local = _hash(seed + i * 1.73);
      final px = size.width * (u + (local - .5) * .022);
      final waveA = sin(u * pi * 2.4 + phase + seed) * size.height * .009;
      final waveB = sin(u * pi * 5.2 - phase * .63 + seed * .41) *
          size.height *
          .0045;
      final py = baseY +
          (u - .5) * size.width * tilt +
          waveA +
          waveB +
          (local - .5) * size.height * .006;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * pi * 2;
    final top = size.height * .61;
    final region = Rect.fromLTWH(0, top, size.width, size.height - top);
    canvas.save();
    canvas.clipRect(region);

    final fade = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x00FFFFFF),
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
        ],
        stops: [0, .23, 1],
      ).createShader(region);

    canvas.saveLayer(region, fade);

    const rows = 7;
    for (var row = 0; row < rows; row++) {
      final y = size.height * (.665 + row * .047);
      final phase = t * (.28 + row * .018) + row * .71;
      final path = _flowPath(
        size,
        baseY: y,
        phase: phase,
        tilt: -.035 + row * .008,
        seed: 11.0 + row * 3.9,
      );

      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(3.0, size.width * .010)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.screen
        ..color = const Color(0xFFFFF1D8).withValues(alpha: .17)
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, max(4.0, size.width * .012));
      canvas.drawPath(path, glow);

      final core = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.1, size.width * .0036)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.screen
        ..color = const Color(0xFFFFF8EA).withValues(alpha: .34);
      canvas.drawPath(path, core);
    }

    const diagonals = 8;
    for (var column = 0; column < diagonals; column++) {
      final seed = 71.0 + column * 4.7;
      final path = Path();
      const segments = 16;
      for (var i = 0; i <= segments; i++) {
        final v = i / segments;
        final local = _hash(seed + i * 2.17);
        final baseX = size.width * (-.08 + column * .145);
        final px = baseX +
            v * size.width * (.28 + (column % 3) * .025) +
            sin(v * pi * 3.1 + t * .34 + seed) * size.width * .014 +
            (local - .5) * size.width * .010;
        final py = top +
            v * (size.height - top) +
            cos(v * pi * 2.7 - t * .27 + seed * .31) * size.height * .007;
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }

      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(2.5, size.width * .008)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.screen
        ..color = const Color(0xFFDDFEFF).withValues(alpha: .12)
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, max(3.0, size.width * .010));
      canvas.drawPath(path, glow);

      final core = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(.9, size.width * .0030)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.screen
        ..color = const Color(0xFFF7FFFF).withValues(alpha: .25);
      canvas.drawPath(path, core);
    }

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FloorCausticPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

enum VolumetricLightMode { broadCalm, livingRays, softDrift }

class VolumetricLightProfile {
  const VolumetricLightProfile({
    required this.mode,
    required this.energy,
    required this.drift,
    required this.width,
    required this.depth,
  });

  final VolumetricLightMode mode;
  final double energy;
  final double drift;
  final double width;
  final double depth;
}

class VolumetricLightPainter extends CustomPainter {
  VolumetricLightPainter({
    required this.animation,
    required this.profile,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final VolumetricLightProfile profile;

  // R15 A only: a feathered volume, not a blurred straight cone.
  // Vertex alpha carries both lateral falloff and depth attenuation.
  void _drawBroadSunbeams(Canvas canvas, Size size, double t) {
    const centers = [.17, .49, .80];
    const widths = [.20, .25, .19];
    const depths = [.57, .64, .59];
    const phases = [.3, 2.5, 4.6];
    const columns = 24;
    const rows = 28;
    for (var beam = 0; beam < 3; beam++) {
      final phase = phases[beam];
      final sway = sin(t + phase) * profile.drift;
      final angle = .075 + .035 * sin(t + phase + .8);
      final width = widths[beam] * (profile.width / .24) *
          (1 + .16 * sin(t + phase + 1.1));
      final depth = depths[beam] * (profile.depth / .64);
      final energy = (.31 + .065 * sin(t * 2 + phase)) * profile.energy;
      final positions = <Offset>[];
      final colors = <Color>[];
      final indices = <int>[];
      for (var row = 0; row <= rows; row++) {
        final v = row / rows;
        final center = centers[beam] + sway + angle * v +
            sin(v * pi + t + phase) * .012 * v;
        final halfWidth = width * (.58 + .48 * v);
        // Smoothly dissolve through mid-water; nothing reaches the floor.
        final fade = ((v - .18) / .82).clamp(0.0, 1.0);
        final attenuation = 1 - fade * fade * (3 - 2 * fade);
        final depthEnergy = (1 - .28 * v) * attenuation;
        for (var column = 0; column <= columns; column++) {
          final u = column / columns * 2 - 1;
          final feather = (exp(-u * u * 4.2) - exp(-4.2)) /
              (1 - exp(-4.2));
          positions.add(Offset(
            size.width * (center + u * halfWidth),
            size.height * depth * v,
          ));
          colors.add(Color.lerp(
            const Color(0xFFFFF7DE), const Color(0xFFE0FCFF), v,
          )!.withValues(alpha: (energy * feather * depthEnergy).clamp(0.0, 1.0)));
          if (row < rows && column < columns) {
            final a = row * (columns + 1) + column;
            final b = a + columns + 1;
            indices.addAll([a, b, a + 1, a + 1, b, b + 1]);
          }
        }
      }
      canvas.drawVertices(
        ui.Vertices(ui.VertexMode.triangles, positions,
            colors: colors, indices: indices),
        BlendMode.modulate,
        Paint()..color = Colors.white..blendMode = BlendMode.screen,
      );
    }
  }

  Path _beam(
    Size size, {
    required double topCenter,
    required double topWidth,
    required double bottomCenter,
    required double bottomWidth,
    required double bottomY,
  }) {
    return Path()
      ..moveTo(size.width * (topCenter - topWidth * .5), 0)
      ..lineTo(size.width * (topCenter + topWidth * .5), 0)
      ..lineTo(size.width * (bottomCenter + bottomWidth * .5), bottomY)
      ..lineTo(size.width * (bottomCenter - bottomWidth * .5), bottomY)
      ..close();
  }

  void _drawBeam(
    Canvas canvas,
    Size size, {
    required Path path,
    required double alpha,
    required double blur,
  }) {
    final bounds = path.getBounds();
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFE9FFFF),
          Color(0x00FFFFFF),
        ],
        stops: [0, .48, 1],
      ).createShader(bounds)
      ..color = Colors.white.withValues(alpha: alpha)
      ..blendMode = BlendMode.screen
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * pi * 2;
    if (profile.mode == VolumetricLightMode.broadCalm) {
      _drawBroadSunbeams(canvas, size, t);
      return; // B/C keep their exact R14 renderer and veil.
    }
    final bottomY = size.height * profile.depth;
    final breathe = .5 + .5 * sin(t * .43);
    final sway = sin(t * .31) * profile.drift;
    final sway2 = cos(t * .27 + 1.2) * profile.drift * .72;

    switch (profile.mode) {
      case VolumetricLightMode.broadCalm:
        break;

      case VolumetricLightMode.livingRays:
        final centers = <double>[.24, .49, .72];
        for (var i = 0; i < centers.length; i++) {
          final phase = t * (.34 + i * .035) + i * 1.7;
          final open = .78 + .22 * (.5 + .5 * sin(phase));
          final localSway = sin(phase * .71) * profile.drift;
          final p = _beam(
            size,
            topCenter: centers[i] + localSway,
            topWidth: profile.width * (.55 + i * .07) * open,
            bottomCenter:
                centers[i] + .08 - i * .035 + localSway * .45,
            bottomWidth: profile.width * (1.28 + i * .10) * open,
            bottomY: bottomY * (.88 + i * .045),
          );
          _drawBeam(
            canvas,
            size,
            path: p,
            alpha: (.075 + .055 * (.5 + .5 * cos(phase * .83))) *
                profile.energy,
            blur: max(18.0, size.width * (.052 + i * .006)),
          );
        }
        break;

      case VolumetricLightMode.softDrift:
        for (var i = 0; i < 2; i++) {
          final dir = i == 0 ? 1.0 : -1.0;
          final local = (i == 0 ? sway : sway2) * dir;
          final p = _beam(
            size,
            topCenter: (i == 0 ? .30 : .63) + local,
            topWidth: profile.width * .78,
            bottomCenter: (i == 0 ? .47 : .55) + local * .25,
            bottomWidth: profile.width * 1.30,
            bottomY: bottomY * (i == 0 ? .95 : .82),
          );
          _drawBeam(
            canvas,
            size,
            path: p,
            alpha: (.085 + breathe * .030) * profile.energy,
            blur: max(24.0, size.width * .082),
          );
        }
        break;
    }

    final veil = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: .035 * profile.energy),
          const Color(0xFFDAFFFF).withValues(alpha: .020 * profile.energy),
          Colors.transparent,
        ],
        stops: const [0, .34, 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, bottomY))
      ..blendMode = BlendMode.screen;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, bottomY), veil);
  }

  @override
  bool shouldRepaint(covariant VolumetricLightPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.profile != profile;
}

class AmbientParticlePainter extends CustomPainter {
  AmbientParticlePainter({required this.animation}) : super(repaint: animation);
  final Animation<double> animation;

  static const _particles = <(double, double, double)>[
    (.12,.19,.7),(.28,.31,.5),(.46,.22,.6),(.70,.17,.45),(.84,.34,.55),
    (.18,.48,.45),(.38,.56,.6),(.59,.43,.4),(.76,.59,.55),(.91,.50,.45),
    (.09,.72,.4),(.31,.78,.55),(.52,.69,.45),(.68,.82,.5),(.87,.73,.6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * pi * 2;
    for (var i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final x = (p.$1 + sin(t * .18 + i * .73) * .012) * size.width;
      final y = (p.$2 + cos(t * .13 + i * .51) * .010) * size.height;
      final r = max(.7, size.width * .0024 * p.$3);
      final paint = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: .12 + p.$3 * .08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * .8);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AmbientParticlePainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class BubblePainter extends CustomPainter {
  BubblePainter({required this.animation}) : super(repaint: animation);
  final Animation<double> animation;

  static const _bubbles = <(double, double, double, double)>[
    (.19,.88,.010,.00),(.81,.76,.007,.24),(.63,.94,.005,.51),(.36,.71,.006,.73),
    (.89,.91,.004,.39),(.11,.64,.004,.61),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animation.value;
    for (var i = 0; i < _bubbles.length; i++) {
      final b = _bubbles[i];
      final progress = (phase + b.$4) % 1.0;
      final yNorm = b.$2 - progress * .58;
      if (yNorm < .08) continue;
      final x = (b.$1 + sin(progress * pi * 2 + i) * .012) * size.width;
      final y = yNorm * size.height;
      final r = max(1.2, size.width * b.$3);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(.7, r * .18)
        ..color = const Color(0xFFFFFFFF).withValues(alpha: .20)
        ..blendMode = BlendMode.screen;
      canvas.drawCircle(Offset(x, y), r, paint);
      canvas.drawCircle(
        Offset(x - r * .28, y - r * .28),
        max(.5, r * .16),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: .18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) =>
      oldDelegate.animation != animation;
}
