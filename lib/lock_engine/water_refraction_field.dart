import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Approved Water Wave R2 optical field. No wave paths or strokes.
class WaterRefractionField {
  WaterRefractionField({
    required this.colors,
    required this.speed,
    required this.refraction,
    required this.cellScale,
    required this.light,
    required this.seed,
  });

  final List<ui.Color> colors;
  final double speed, refraction, cellScale, light;
  final int seed;
  static const resolution = 46;
  ui.Vertices? _mesh;
  int _frame = -1;

  double _hash(int x, int y) {
    final n = sin(x * 127.1 + y * 311.7 + seed * 74.7) * 43758.5453;
    return n - n.floorToDouble();
  }

  double _noise(double x, double y) {
    final ix = x.floor(), iy = y.floor();
    var fx = x - ix, fy = y - iy;
    fx = fx * fx * (3 - 2 * fx);
    fy = fy * fy * (3 - 2 * fy);
    final a = _hash(ix, iy), b = _hash(ix + 1, iy);
    final c = _hash(ix, iy + 1), d = _hash(ix + 1, iy + 1);
    return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy;
  }

  double _smooth(double lo, double hi, double v) {
    final q = ((v - lo) / (hi - lo)).clamp(0.0, 1.0);
    return q * q * (3 - 2 * q);
  }

  // Moving, domain-warped cellular separation creates connected optical folds.
  // Unequal cell velocities deform/split the illumination without a tiled loop.
  double _fold(double x, double y, double t) {
    final ix = x.floor(), iy = y.floor();
    var first = 100.0, second = 100.0;
    for (var j = -1; j <= 1; j++) {
      for (var i = -1; i <= 1; i++) {
        final cx = ix + i, cy = iy + j;
        final h = _hash(cx, cy), k = _hash(cx + 41, cy - 27);
        final px = cx + .5 + .37 * sin(t * (.63 + h * .59) + h * 17);
        final py = cy + .5 + .37 * cos(t * (.57 + k * .67) + k * 23);
        final d = (x - px) * (x - px) + (y - py) * (y - py);
        if (d < first) {
          second = first;
          first = d;
        } else if (d < second) {
          second = d;
        }
      }
    }
    final gap = sqrt(second) - sqrt(first);
    // Broad, variable-width focus rather than drawing cell boundaries as lines.
    final aperture = .075 + .09 * _noise(x * .8 + t * .19, y * .8);
    return 1 - _smooth(aperture * .25, aperture * 2.6, gap);
  }

  ui.Color sample(double x, double y, double seconds) {
    final t = seconds * speed;
    final flowX = _noise(x * 2.7 + t * .43, y * 2.7 - t * .27);
    final flowY = _noise(x * 2.4 - t * .31 + 19, y * 2.4 + t * .39);
    final u = x + (flowX - .5) * refraction;
    final v = y + (flowY - .5) * refraction;
    final broad = _noise(u * 2.1 - t * .69, v * 2.1 + t * .44);
    final depth = _noise(u * 1.6 + t * .53 + 31, v * 1.8 - t * .36);
    final band = _smooth(.16, .84, broad * .75 + depth * .25);
    final scaled = band * (colors.length - 1);
    final index = scaled.floor().clamp(0, colors.length - 2).toInt();
    final base = ui.Color.lerp(colors[index], colors[index + 1], scaled - index)!;
    final opticalX = u * cellScale + (flowY - .5) * 1.1 + t * .38;
    final opticalY = v * cellScale + (flowX - .5) * 1.1 - t * .29;
    final focus = _fold(opticalX, opticalY, t);
    final secondary = _fold(opticalX * 1.37 + 7, opticalY * 1.29 - 11, -t * .73);
    // Same refracted coordinates drive palette compression and caustic energy.
    final illumination = (pow(focus, 1.6) * .73 + focus * secondary * .37)
        * light * (.64 + broad * .36);
    final shade = ui.Color.lerp(base, const ui.Color(0xFF053B74), (1 - depth) * .12)!;
    return ui.Color.lerp(shade, const ui.Color(0xFFE2FDFF), illumination.clamp(0.0, .78))!;
  }

  ui.Vertices mesh(double seconds) {
    final frame = (seconds * 24).floor();
    if (_mesh != null && frame == _frame) return _mesh!;
    _frame = frame;
    const n = resolution + 1;
    final points = Float32List(n * n * 2);
    final values = Int32List(n * n);
    final indices = Uint16List(resolution * resolution * 6);
    var triangle = 0;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final i = y * n + x;
        points[i * 2] = x / resolution;
        points[i * 2 + 1] = y / resolution;
        values[i] = sample(x / resolution, y / resolution, frame / 24).toARGB32();
        if (x < resolution && y < resolution) {
          for (final vertex in [i, i + 1, i + n, i + 1, i + n + 1, i + n]) {
            indices[triangle++] = vertex;
          }
        }
      }
    }
    return _mesh = ui.Vertices.raw(ui.VertexMode.triangles, points, colors: values, indices: indices);
  }
}
