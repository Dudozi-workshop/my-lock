import 'dart:ui';

import 'models.dart';

enum ShapePartRole {
  body,

  // Generic detail role retained for simple illustrated shapes.
  accent,

  // High-detail Shape Accent Map roles.
  mouthAccent,
  bellyAccent,
  frontFinAccent,
  rearFinAccent,

  // Optional silhouette roles for future composite shapes.
  dorsalFin,
  pectoralFin,
  tail,
}

extension ShapePartRoleRules on ShapePartRole {
  bool get contributesToSilhouette =>
      this == ShapePartRole.body ||
      this == ShapePartRole.dorsalFin ||
      this == ShapePartRole.pectoralFin ||
      this == ShapePartRole.tail;

  bool get isLightAccent =>
      this == ShapePartRole.accent ||
      this == ShapePartRole.mouthAccent ||
      this == ShapePartRole.bellyAccent;

  bool get isDepthAccent =>
      this == ShapePartRole.frontFinAccent ||
      this == ShapePartRole.rearFinAccent;
}

class ShapeTracePart {
  const ShapeTracePart({
    required this.role,
    required this.points,
    this.smooth = true,
  });

  final ShapePartRole role;
  final List<Offset> points;
  final bool smooth;
}

class ShapeBlueprint {
  const ShapeBlueprint({
    required this.kind,
    required this.parts,
    this.viewBox = const Size(100, 100),
    this.designCenter = const Offset(50, 50),
    this.referenceRadius = 31,
    this.opticalBounds,
  });

  final ShapeKind kind;
  final List<ShapeTracePart> parts;
  final Size viewBox;
  final Offset designCenter;
  final double referenceRadius;

  /// Optional design-space bounds used by Shape Lab for visual diagnostics.
  /// Rendering never depends on this value.
  final Rect? opticalBounds;

  IllustratedShapeGeometry build(Offset center, double radius) {
    final unit = radius / referenceRadius;

    Offset mapPoint(Offset point) => Offset(
          center.dx + (point.dx - designCenter.dx) * unit,
          center.dy + (point.dy - designCenter.dy) * unit,
        );

    return IllustratedShapeGeometry(
      parts: parts
          .map(
            (part) => ShapePartGeometry(
              role: part.role,
              path: _tracePath(
                part.points.map(mapPoint).toList(growable: false),
                smooth: part.smooth,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
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
    final silhouetteParts = parts
        .where((part) => part.role.contributesToSilhouette)
        .toList(growable: false);
    if (silhouetteParts.isEmpty) return Path();

    var combined = Path()
      ..addPath(silhouetteParts.first.path, Offset.zero);
    for (final part in silhouetteParts.skip(1)) {
      combined = Path.combine(
        PathOperation.union,
        combined,
        part.path,
      );
    }
    return combined;
  }
}

Path _tracePath(List<Offset> points, {required bool smooth}) {
  if (points.isEmpty) return Path();

  if (!smooth || points.length < 3) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  Offset midpoint(Offset a, Offset b) => Offset(
        (a.dx + b.dx) / 2,
        (a.dy + b.dy) / 2,
      );

  final first = midpoint(points[0], points[1]);
  final path = Path()..moveTo(first.dx, first.dy);

  for (var i = 1; i < points.length; i++) {
    final point = points[i];
    final next = points[(i + 1) % points.length];
    final mid = midpoint(point, next);
    path.quadraticBezierTo(point.dx, point.dy, mid.dx, mid.dy);
  }

  final point0 = points[0];
  return path
    ..quadraticBezierTo(point0.dx, point0.dy, first.dx, first.dy)
    ..close();
}

ShapeBlueprint? shapeBlueprintFor(ShapeKind kind) =>
    illustratedShapeBlueprints[kind];

IllustratedShapeGeometry? buildIllustratedShapeGeometry(
  ShapeKind kind,
  Offset center,
  double radius,
) =>
    shapeBlueprintFor(kind)?.build(center, radius);

const illustratedShapeBlueprints = <ShapeKind, ShapeBlueprint>{
  ShapeKind.dolphin: ShapeBlueprint(
    kind: ShapeKind.dolphin,
    referenceRadius: 31,
    opticalBounds: Rect.fromLTRB(8, 29.1, 91.8, 70.7),
    parts: [
      // Canonical silhouette. The old inner-mouth loop has been removed so
      // the lower snout is one continuous outer contour.
      ShapeTracePart(
        role: ShapePartRole.body,
        points: [
          Offset(8, 39.4),
          Offset(8, 41),
          Offset(11.5, 44.3),
          Offset(18.6, 47.3),
          Offset(22.4, 49.8),
          Offset(15.7, 41.9),
          Offset(20.3, 43.8),
          Offset(29.9, 45.4),
          Offset(33.4, 46.7),
          Offset(33.7, 50.8),
          Offset(33.2, 51.3),
          Offset(34.3, 52.7),
          Offset(34.4, 55.4),
          Offset(28.5, 53.3),
          Offset(24.7, 50.4),
          Offset(23.9, 50.4),
          Offset(23.6, 51.1),
          Offset(27, 53.9),
          Offset(30.6, 55.8),
          Offset(30.9, 60.7),
          Offset(32.9, 65),
          Offset(34, 65.3),
          Offset(36.4, 60.7),
          Offset(37.2, 60.6),
          Offset(40.5, 66.6),
          Offset(43.4, 69.2),
          Offset(45.4, 69.5),
          Offset(46, 69.1),
          Offset(47.2, 61.6),
          Offset(47.8, 60.7),
          Offset(56.6, 60.7),
          Offset(66.5, 58.9),
          Offset(74.2, 58.3),
          Offset(75.7, 58.7),
          Offset(79.5, 65.7),
          Offset(82.7, 68.8),
          Offset(85.8, 70.7),
          Offset(91.1, 70.7),
          Offset(90.9, 68),
          Offset(88.8, 64.5),
          Offset(87.4, 60.3),
          Offset(84.4, 56.6),
          Offset(84.4, 55.8),
          Offset(87, 52.8),
          Offset(87.9, 49.6),
          Offset(91.5, 44.3),
          Offset(91.8, 42.8),
          Offset(89.6, 42.2),
          Offset(84.4, 44.5),
          Offset(80.5, 47.3),
          Offset(76.4, 52.1),
          Offset(67.4, 49.5),
          Offset(62.8, 46.9),
          Offset(59.9, 44.3),
          Offset(61.3, 39.9),
          Offset(65.9, 33.4),
          Offset(66, 31.8),
          Offset(64.8, 30.8),
          Offset(59.9, 30.8),
          Offset(48.4, 35.8),
          Offset(43.1, 32.3),
          Offset(36.9, 29.9),
          Offset(30.8, 29.1),
          Offset(25.6, 29.4),
          Offset(20.2, 31.7),
          Offset(15.7, 36.3),
          Offset(11.3, 37.3),
        ],
      ),

      // High-detail Accent Map. These are clipped inside the canonical
      // silhouette and never receive their own outline.
      ShapeTracePart(
        role: ShapePartRole.mouthAccent,
        points: [
          Offset(10.6, 41.5),
          Offset(14.8, 41.8),
          Offset(19.7, 43.4),
          Offset(24.3, 45.5),
          Offset(29.7, 46.8),
          Offset(32.4, 48.0),
          Offset(33.0, 49.6),
          Offset(31.5, 50.8),
          Offset(28.0, 50.8),
          Offset(23.5, 49.4),
          Offset(19.2, 47.4),
          Offset(15.0, 45.0),
          Offset(11.6, 43.2),
        ],
      ),
      ShapeTracePart(
        role: ShapePartRole.bellyAccent,
        points: [
          Offset(46.4, 56.9),
          Offset(52.5, 57.5),
          Offset(60.3, 57.7),
          Offset(67.8, 57.0),
          Offset(74.6, 56.3),
          Offset(75.0, 57.6),
          Offset(72.3, 58.5),
          Offset(66.0, 59.3),
          Offset(58.3, 60.0),
          Offset(51.0, 60.5),
          Offset(47.2, 60.0),
          Offset(46.0, 58.6),
        ],
      ),
      ShapeTracePart(
        role: ShapePartRole.frontFinAccent,
        points: [
          Offset(30.3, 54.6),
          Offset(33.8, 55.5),
          Offset(36.4, 60.5),
          Offset(34.4, 64.2),
          Offset(32.9, 63.8),
          Offset(31.0, 60.4),
          Offset(30.0, 57.2),
        ],
      ),
      ShapeTracePart(
        role: ShapePartRole.rearFinAccent,
        points: [
          Offset(37.4, 60.7),
          Offset(40.5, 66.5),
          Offset(43.4, 69.1),
          Offset(45.3, 69.4),
          Offset(45.9, 69.0),
          Offset(47.0, 61.8),
          Offset(44.5, 61.1),
          Offset(41.0, 60.8),
        ],
      ),
    ],
  ),
};
