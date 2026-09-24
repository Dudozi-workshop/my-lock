import 'dart:ui';

import 'models.dart';
import 'shape_blueprints.dart';

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
  final blueprint = illustratedShapeBlueprints[kind];
  if (blueprint == null) return null;

  return IllustratedShapeGeometry(
    parts: [
      ShapePartGeometry(
        role: ShapePartRole.body,
        path: _buildBlueprintPath(
          blueprint,
          center: center,
          radius: radius,
        ),
      ),
    ],
  );
}

Path _buildBlueprintPath(
  ShapeBlueprint blueprint, {
  required Offset center,
  required double radius,
}) {
  final points = blueprint.points;
  if (points.isEmpty) return Path();

  final viewCenter = blueprint.viewBoxSize / 2;
  final unit = radius / blueprint.opticalRadius;

  Offset mapPoint(Offset point) => Offset(
        center.dx + (point.dx - viewCenter) * unit,
        center.dy + (point.dy - viewCenter) * unit,
      );

  final mapped = points.map(mapPoint).toList(growable: false);

  switch (blueprint.smoothing) {
    case ShapeSmoothing.polygon:
      final path = Path()
        ..moveTo(mapped.first.dx, mapped.first.dy);
      for (final point in mapped.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      return path..close();

    case ShapeSmoothing.midpointQuadratic:
      Offset midpoint(Offset a, Offset b) => Offset(
            (a.dx + b.dx) / 2,
            (a.dy + b.dy) / 2,
          );

      final first = midpoint(mapped[0], mapped[1]);
      final path = Path()..moveTo(first.dx, first.dy);

      for (var i = 1; i < mapped.length; i++) {
        final point = mapped[i];
        final next = mapped[(i + 1) % mapped.length];
        final mid = midpoint(point, next);
        path.quadraticBezierTo(point.dx, point.dy, mid.dx, mid.dy);
      }

      final point0 = mapped[0];
      return path
        ..quadraticBezierTo(point0.dx, point0.dy, first.dx, first.dy)
        ..close();
  }
}
