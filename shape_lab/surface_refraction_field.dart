import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

enum SurfaceRefractionMode {
  broadField,
  organicCaustic,
  surfaceSweep,
}

class SurfaceRefractionProfile {
  const SurfaceRefractionProfile({
    required this.mode,
    required this.seed,
    required this.speed,
    required this.scale,
    required this.warp,
    required this.energy,
    required this.softness,
    required this.warmth,
    required this.topFraction,
  });

  final SurfaceRefractionMode mode;
  final int seed;
  final double speed;
  final double scale;
  final double warp;
  final double energy;
  final double softness;
  final double warmth;
  final double topFraction;
}

/// Continuous, domain-warped refraction field for Background LABS.
///
/// This intentionally avoids stroked wave paths and repeated polygon cells.
/// The output is a translucent per-vertex illumination field that can be
/// composited over an immutable approved Base.
class SurfaceRefractionFieldPainter extends CustomPainter {
  SurfaceRefractionFieldPainter({
    required this.profile,
    required this.animation,
    required this.intensity,
  }) : super(repaint: animation);

  final SurfaceRefractionProfile profile;
  final Animation<double> animation;
  final double intensity;

  static const int _xResolution = 34;
  static const int _yResolution = 26;

  double _hash(int x, int y, int salt) {
    final n = sin(
          x * 127.1 +
              y * 311.7 +
              (profile.seed + salt * 97) * 74.7,
        ) *
        43758.5453123;
    return n - n.floorToDouble();
  }

  double _smooth(double v) => v * v * (3 - 2 * v);

  double _noise(double x, double y, int salt) {
    final ix = x.floor();
    final iy = y.floor();
    var fx = x - ix;
    var fy = y - iy;
    fx = _smooth(fx);
    fy = _smooth(fy);
    final a = _hash(ix, iy, salt);
    final b = _hash(ix + 1, iy, salt);
    final c = _hash(ix, iy + 1, salt);
    final d = _hash(ix + 1, iy + 1, salt);
    return a +
        (b - a) * fx +
        (c - a) * fy +
        (a - b - c + d) * fx * fy;
  }

  double _fbm(double x, double y, int salt) {
    var value = 0.0;
    var amplitude = .56;
    var norm = 0.0;
    for (var octave = 0; octave < 4; octave++) {
      value += _noise(x, y, salt + octave * 17) * amplitude;
      norm += amplitude;
      x = x * 1.93 + 13.7;
      y = y * 1.89 - 9.4;
      amplitude *= .49;
    }
    return value / norm;
  }

  double _smoothStep(double lo, double hi, double v) {
    final t = ((v - lo) / (hi - lo)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  double _cellFold(double x, double y, double t) {
    final ix = x.floor();
    final iy = y.floor();
    var first = 99.0;
    var second = 99.0;

    for (var j = -1; j <= 1; j++) {
      for (var i = -1; i <= 1; i++) {
        final cx = ix + i;
        final cy = iy + j;
        final h = _hash(cx, cy, 31);
        final k = _hash(cx + 19, cy - 23, 47);
        final px =
            cx + .5 + .31 * sin(t * (.43 + h * .31) + h * 19.0);
        final py =
            cy + .5 + .31 * cos(t * (.39 + k * .35) + k * 17.0);
        final dx = x - px;
        final dy = y - py;
        final d = dx * dx + dy * dy;
        if (d < first) {
          second = first;
          first = d;
        } else if (d < second) {
          second = d;
        }
      }
    }

    final gap = sqrt(second) - sqrt(first);
    final aperture = .10 +
        .055 * _noise(x * .57 + t * .11, y * .61 - t * .07, 71);
    return 1 - _smoothStep(aperture * .52, aperture * 2.55, gap);
  }

  double _broadField(double u, double v, double t) {
    final flowX = _fbm(u * 1.65 + t * .11, v * 1.45 - t * .08, 3);
    final flowY = _fbm(u * 1.35 - t * .07 + 20, v * 1.75 + t * .10, 7);
    final x = u + (flowX - .5) * profile.warp;
    final y = v + (flowY - .5) * profile.warp;
    final broad = _fbm(
      x * profile.scale + t * .10,
      y * profile.scale - t * .07,
      11,
    );
    final secondary = _fbm(
      x * profile.scale * .63 - t * .06 + 33,
      y * profile.scale * .74 + t * .05,
      13,
    );
    return (broad * .68 + secondary * .32).clamp(0.0, 1.0);
  }

  double _organicCaustic(double u, double v, double t) {
    final flowX = _fbm(u * 2.0 + t * .17, v * 1.8 - t * .12, 19);
    final flowY = _fbm(u * 1.7 - t * .13 + 9, v * 2.1 + t * .15, 23);
    final x = u + (flowX - .5) * profile.warp;
    final y = v + (flowY - .5) * profile.warp;
    final foldA = _cellFold(
      x * profile.scale + t * .13,
      y * profile.scale - t * .09,
      t,
    );
    final foldB = _cellFold(
      x * profile.scale * 1.27 - 5.4,
      y * profile.scale * 1.16 + 7.1,
      -t * .77,
    );
    final broad = _fbm(x * 1.5 - t * .05, y * 1.4 + t * .04, 29);
    final focus = pow(foldA, 1.72) * .64 + foldA * foldB * .28;
    return (focus * .78 + broad * .22).clamp(0.0, 1.0);
  }

  double _surfaceSweep(double u, double v, double t) {
    final flow = _fbm(
      u * 1.9 + t * .12,
      v * 1.55 - t * .08,
      41,
    );
    final cross = _fbm(
      u * 1.35 - t * .08 + 17,
      v * 1.8 + t * .10,
      43,
    );
    final x = u + (flow - .5) * profile.warp;
    final y = v + (cross - .5) * profile.warp * .72;

    final phaseA = sin(
      x * pi * 2.0 * profile.scale * .58 +
          y * pi * 1.35 +
          t * .48,
    );
    final phaseB = sin(
      x * pi * 2.0 * profile.scale * .31 -
          y * pi * 1.76 -
          t * .33 +
          1.7,
    );
    final interference = (phaseA * .54 + phaseB * .46) * .5 + .5;
    final organic = _fbm(x * 1.55 + t * .05, y * 1.42 - t * .04, 53);
    return (interference * .42 + organic * .58).clamp(0.0, 1.0);
  }

  double _sample(double u, double v, double seconds) {
    final t = seconds * profile.speed;
    return switch (profile.mode) {
      SurfaceRefractionMode.broadField => _broadField(u, v, t),
      SurfaceRefractionMode.organicCaustic => _organicCaustic(u, v, t),
      SurfaceRefractionMode.surfaceSweep => _surfaceSweep(u, v, t),
    };
  }

  ui.Color _fieldColor(double value, double v) {
    final contrastLo = .40 - profile.softness * .10;
    final contrastHi = .82 + profile.softness * .08;
    final shaped = _smoothStep(contrastLo, contrastHi, value);

    // Strong near the surface, then gently fades into the approved Base.
    final verticalFade =
        (1 - _smoothStep(.08, 1.0, v)).clamp(0.0, 1.0);
    final alpha = (shaped * profile.energy * intensity * verticalFade)
        .clamp(0.0, .44);

    final cool = ui.Color.lerp(
      const ui.Color(0xFFDFFFFF),
      const ui.Color(0xFFFFFFFF),
      shaped * .66,
    )!;
    final warm = const ui.Color(0xFFFFE4D7);
    final color = ui.Color.lerp(cool, warm, profile.warmth * shaped)!;
    return color.withValues(alpha: alpha);
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final fieldHeight = size.height * profile.topFraction;
    final cols = _xResolution + 1;
    final rows = _yResolution + 1;
    final positions = Float32List(cols * rows * 2);
    final colors = Int32List(cols * rows);
    final indices =
        Uint16List(_xResolution * _yResolution * 6);

    final seconds = animation.value * 12.0;
    var vertex = 0;
    for (var y = 0; y < rows; y++) {
      final v = y / _yResolution;
      for (var x = 0; x < cols; x++) {
        final u = x / _xResolution;
        positions[vertex * 2] = u * size.width;
        positions[vertex * 2 + 1] = v * fieldHeight;
        colors[vertex] = _fieldColor(_sample(u, v, seconds), v).toARGB32();
        vertex++;
      }
    }

    var cursor = 0;
    for (var y = 0; y < _yResolution; y++) {
      for (var x = 0; x < _xResolution; x++) {
        final i = y * cols + x;
        for (final index in [
          i,
          i + 1,
          i + cols,
          i + 1,
          i + cols + 1,
          i + cols,
        ]) {
          indices[cursor++] = index;
        }
      }
    }

    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      positions,
      colors: colors,
      indices: indices,
    );

    canvas.save();
    canvas.clipRect(ui.Rect.fromLTWH(0, 0, size.width, fieldHeight));
    canvas.drawVertices(
      vertices,
      ui.BlendMode.screen,
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );

    // A very soft surface veil prevents isolated bright islands and makes the
    // light read as refracted water rather than decorative blobs.
    final veilAlpha = (.045 * intensity).clamp(0.0, .065);
    final veil = ui.Paint()
      ..shader = ui.Gradient.linear(
        ui.Offset.zero,
        ui.Offset(0, fieldHeight),
        [
          const ui.Color(0xFFFFFFFF).withValues(alpha: veilAlpha),
          const ui.Color(0xFFBFF9FA).withValues(alpha: veilAlpha * .55),
          const ui.Color(0x00FFFFFF),
        ],
        const [0.0, .46, 1.0],
      )
      ..blendMode = ui.BlendMode.screen;
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.width, fieldHeight),
      veil,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SurfaceRefractionFieldPainter oldDelegate) {
    return oldDelegate.profile != profile ||
        oldDelegate.intensity != intensity ||
        oldDelegate.animation != animation;
  }
}
