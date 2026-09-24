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

  final body = Path()
    ..moveTo(x(-1.05), y(0.02))
    ..cubicTo(
      x(-0.98),
      y(-0.24),
      x(-0.72),
      y(-0.47),
      x(-0.35),
      y(-0.54),
    )
    ..cubicTo(
      x(0.02),
      y(-0.61),
      x(0.40),
      y(-0.50),
      x(0.69),
      y(-0.26),
    )
    ..cubicTo(
      x(0.82),
      y(-0.15),
      x(0.91),
      y(-0.07),
      x(1.08),
      y(-0.06),
    )
    ..cubicTo(
      x(1.15),
      y(-0.05),
      x(1.18),
      y(-0.01),
      x(1.10),
      y(0.04),
    )
    ..cubicTo(
      x(0.99),
      y(0.12),
      x(0.90),
      y(0.16),
      x(0.77),
      y(0.18),
    )
    ..cubicTo(
      x(0.61),
      y(0.39),
      x(0.31),
      y(0.52),
      x(-0.02),
      y(0.49),
    )
    ..cubicTo(
      x(-0.39),
      y(0.46),
      x(-0.72),
      y(0.30),
      x(-0.92),
      y(0.13),
    )
    ..cubicTo(
      x(-1.00),
      y(0.10),
      x(-1.06),
      y(0.07),
      x(-1.05),
      y(0.02),
    )
    ..close();

  final dorsalFin = Path()
    ..moveTo(x(-0.18), y(-0.48))
    ..cubicTo(
      x(-0.14),
      y(-0.71),
      x(-0.02),
      y(-0.90),
      x(0.15),
      y(-0.92),
    )
    ..cubicTo(
      x(0.16),
      y(-0.71),
      x(0.20),
      y(-0.55),
      x(0.28),
      y(-0.43),
    )
    ..cubicTo(
      x(0.11),
      y(-0.48),
      x(-0.04),
      y(-0.50),
      x(-0.18),
      y(-0.48),
    )
    ..close();

  final pectoralFin = Path()
    ..moveTo(x(0.02), y(0.28))
    ..cubicTo(
      x(0.08),
      y(0.52),
      x(0.18),
      y(0.69),
      x(0.34),
      y(0.77),
    )
    ..cubicTo(
      x(0.41),
      y(0.61),
      x(0.40),
      y(0.44),
      x(0.32),
      y(0.24),
    )
    ..cubicTo(
      x(0.21),
      y(0.25),
      x(0.10),
      y(0.27),
      x(0.02),
      y(0.28),
    )
    ..close();

  final tail = Path()
    ..moveTo(x(0.73), y(0.11))
    ..cubicTo(
      x(0.89),
      y(0.02),
      x(1.05),
      y(-0.03),
      x(1.16),
      y(-0.17),
    )
    ..cubicTo(
      x(1.25),
      y(-0.08),
      x(1.28),
      y(0.02),
      x(1.23),
      y(0.15),
    )
    ..cubicTo(
      x(1.18),
      y(0.25),
      x(1.10),
      y(0.31),
      x(1.01),
      y(0.33),
    )
    ..cubicTo(
      x(1.12),
      y(0.37),
      x(1.22),
      y(0.46),
      x(1.26),
      y(0.58),
    )
    ..cubicTo(
      x(1.15),
      y(0.63),
      x(1.02),
      y(0.60),
      x(0.91),
      y(0.52),
    )
    ..cubicTo(
      x(0.79),
      y(0.43),
      x(0.73),
      y(0.27),
      x(0.73),
      y(0.11),
    )
    ..close();

  return IllustratedShapeGeometry(
    parts: [
      ShapePartGeometry(role: ShapePartRole.body, path: body),
      ShapePartGeometry(role: ShapePartRole.dorsalFin, path: dorsalFin),
      ShapePartGeometry(role: ShapePartRole.pectoralFin, path: pectoralFin),
      ShapePartGeometry(role: ShapePartRole.tail, path: tail),
    ],
  );
}
