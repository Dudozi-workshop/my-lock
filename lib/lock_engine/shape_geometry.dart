import 'dart:ui';

import 'models.dart';

enum ShapePartRole {
  body,
  dorsalFin,
  pectoralFin,
  tail,
}

class ShapePartGeometry {
  const ShapePartGeometry({
    required this.role,
    required this.path,
  });

  final ShapePartRole role;
  final Path path;
}

class IllustratedShapeGeometry {
  IllustratedShapeGeometry({
    required this.parts,
  }) : combinedPath = _combine(parts);

  final List<ShapePartGeometry> parts;
  final Path combinedPath;

  static Path _combine(List<ShapePartGeometry> parts) {
    if (parts.isEmpty) return Path();

    var combined = Path()..addPath(parts.first.path, Offset.zero);
    for (final part in parts.skip(1)) {
      combined = Path.combine(
        PathOperation.union,
        combined,
        part.path,
      );
    }
    return combined;
  }
}

IllustratedShapeGeometry? buildIllustratedShapeGeometry(
  ShapeKind kind,
  Offset center,
  double radius,
) {
  switch (kind) {
    case ShapeKind.dolphin:
      return _buildDolphinGeometry(center, radius);
    case ShapeKind.circle:
    case ShapeKind.triangle:
    case ShapeKind.square:
    case ShapeKind.star:
    case ShapeKind.heart:
    case ShapeKind.diamond:
    case ShapeKind.hexagon:
    case ShapeKind.crescent:
      return null;
  }
}

IllustratedShapeGeometry _buildDolphinGeometry(
  Offset center,
  double radius,
) {
  double x(double value) => center.dx + radius * value;
  double y(double value) => center.dy + radius * value;

  // Reference-traced dolphin silhouette.
  // The goal is optical similarity with the approved 58x58 preview rather
  // than a mathematically generated dolphin. It is intentionally kept as
  // one continuous body silhouette for clean small-size recognition.
  final silhouette = Path()
    ..moveTo(x(-1.05), y(-0.24))
    ..quadraticBezierTo(x(-1.05), y(-0.18), x(-0.96), y(-0.08))
    ..quadraticBezierTo(x(-0.82), y(0.02), x(-0.66), y(0.08))
    ..quadraticBezierTo(x(-0.56), y(0.15), x(-0.48), y(0.14))
    ..quadraticBezierTo(x(-0.45), y(0.11), x(-0.49), y(0.07))
    ..quadraticBezierTo(x(-0.64), y(-0.01), x(-0.83), y(-0.06))
    ..quadraticBezierTo(x(-0.91), y(-0.10), x(-0.91), y(-0.14))
    ..quadraticBezierTo(x(-0.76), y(-0.14), x(-0.60), y(-0.08))
    ..quadraticBezierTo(x(-0.28), y(-0.02), x(-0.16), y(0.03))
    ..quadraticBezierTo(x(-0.15), y(0.19), x(-0.17), y(0.21))
    ..quadraticBezierTo(x(-0.13), y(0.27), x(-0.13), y(0.36))
    ..quadraticBezierTo(x(-0.35), y(0.29), x(-0.48), y(0.19))
    ..quadraticBezierTo(x(-0.51), y(0.18), x(-0.52), y(0.21))
    ..quadraticBezierTo(x(-0.40), y(0.31), x(-0.27), y(0.37))
    ..quadraticBezierTo(x(-0.26), y(0.54), x(-0.19), y(0.68))
    ..quadraticBezierTo(x(-0.15), y(0.70), x(-0.06), y(0.54))
    ..quadraticBezierTo(x(-0.04), y(0.53), x(-0.01), y(0.53))
    ..quadraticBezierTo(x(0.11), y(0.75), x(0.22), y(0.84))
    ..quadraticBezierTo(x(0.30), y(0.85), x(0.32), y(0.84))
    ..quadraticBezierTo(x(0.36), y(0.58), x(0.38), y(0.55))
    ..quadraticBezierTo(x(0.70), y(0.55), x(1.00), y(0.49))
    ..quadraticBezierTo(x(1.20), y(0.47), x(1.24), y(0.49))
    ..quadraticBezierTo(x(1.37), y(0.72), x(1.48), y(0.82))
    ..quadraticBezierTo(x(1.58), y(0.88), x(1.75), y(0.88))
    ..quadraticBezierTo(x(1.74), y(0.79), x(1.67), y(0.68))
    ..quadraticBezierTo(x(1.62), y(0.55), x(1.51), y(0.44))
    ..quadraticBezierTo(x(1.51), y(0.41), x(1.60), y(0.31))
    ..quadraticBezierTo(x(1.63), y(0.20), x(1.75), y(0.02))
    ..quadraticBezierTo(x(1.76), y(-0.03), x(1.69), y(-0.05))
    ..quadraticBezierTo(x(1.52), y(0.03), x(1.39), y(0.13))
    ..quadraticBezierTo(x(1.25), y(0.29), x(1.11), y(0.45))
    ..quadraticBezierTo(x(0.79), y(0.36), x(0.63), y(0.26))
    ..quadraticBezierTo(x(0.53), y(0.17), x(0.43), y(0.08))
    ..quadraticBezierTo(x(0.48), y(-0.07), x(0.64), y(-0.29))
    ..quadraticBezierTo(x(0.64), y(-0.35), x(0.60), y(-0.39))
    ..quadraticBezierTo(x(0.43), y(-0.39), x(0.05), y(-0.21))
    ..quadraticBezierTo(x(-0.13), y(-0.34), x(-0.35), y(-0.42))
    ..quadraticBezierTo(x(-0.57), y(-0.45), x(-0.76), y(-0.37))
    ..quadraticBezierTo(x(-0.92), y(-0.21), x(-1.05), y(-0.18))
    ..close();

  // Keep the illustrated/composite contract even though this approved base
  // currently renders as a single silhouette. Additional material masks or
  // animated sub-parts can be added later without changing ShapeKind again.
  return IllustratedShapeGeometry(
    parts: [
      ShapePartGeometry(role: ShapePartRole.body, path: silhouette),
    ],
  );
}

