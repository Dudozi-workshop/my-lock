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
    opticalBounds: Rect.fromLTRB(8.5, 29.5, 94.0, 71.0),
    parts: [
      // Canonical Dolphin v2 silhouette.
      // Short rostrum + rounded melon + gentle back + smaller swept dorsal fin.
      // The two lower flippers remain part of the one-piece silhouette so the
      // token reads as a dolphin rather than assembled colored pieces.
      ShapeTracePart(
        role: ShapePartRole.body,
        points: [
          // Rostrum -> melon -> back
          Offset(8.5, 46.2),
          Offset(12.5, 44.8),
          Offset(16.5, 42.4),
          Offset(19.8, 38.4),
          Offset(24.5, 35.1),
          Offset(30.5, 33.2),
          Offset(37.0, 33.0),
          Offset(43.5, 34.4),
          Offset(49.4, 36.7),
          Offset(53.5, 38.1),

          // Compact rear-swept dorsal fin.
          Offset(56.4, 37.9),
          Offset(60.4, 30.4),
          Offset(63.2, 32.0),
          Offset(62.2, 39.8),

          // Back taper -> tail peduncle.
          Offset(68.2, 42.0),
          Offset(74.2, 43.1),
          Offset(79.3, 44.2),

          // Smaller, softer split tail.
          Offset(84.0, 42.8),
          Offset(89.7, 38.9),
          Offset(92.2, 39.4),
          Offset(89.7, 46.5),
          Offset(94.0, 49.5),
          Offset(89.8, 52.0),
          Offset(91.5, 59.6),
          Offset(88.9, 59.8),
          Offset(83.5, 54.7),
          Offset(79.6, 52.9),

          // Soft belly line approaching the flippers.
          Offset(73.7, 54.7),
          Offset(66.5, 56.7),
          Offset(58.5, 58.0),
          Offset(51.0, 58.2),

          // Far/rear lower flipper: smaller and tucked behind.
          Offset(47.7, 59.0),
          Offset(46.3, 64.8),
          Offset(43.7, 70.1),
          Offset(41.4, 69.7),
          Offset(39.8, 63.1),
          Offset(38.0, 59.0),

          // Near/front flipper: broader connection to the body.
          Offset(35.0, 57.9),
          Offset(34.2, 63.3),
          Offset(31.2, 68.0),
          Offset(28.8, 66.3),
          Offset(29.0, 60.3),
          Offset(26.4, 56.8),

          // Belly -> lower rostrum.
          Offset(22.0, 54.5),
          Offset(18.0, 52.2),
          Offset(14.2, 50.7),
          Offset(10.6, 49.0),
          Offset(8.5, 47.7),
        ],
      ),

      // Mouth is a separate face plane. It stays compact and never joins the
      // belly accent, and receives no independent outline.
      ShapeTracePart(
        role: ShapePartRole.mouthAccent,
        points: [
          Offset(11.5, 46.5),
          Offset(16.0, 45.8),
          Offset(21.0, 46.5),
          Offset(25.8, 47.8),
          Offset(28.3, 49.0),
          Offset(25.4, 50.4),
          Offset(20.8, 51.0),
          Offset(16.2, 50.4),
          Offset(12.5, 49.1),
        ],
      ),

      // A low-contrast belly plane. The near/front flipper is painted after
      // this region so it visually interrupts the belly line.
      ShapeTracePart(
        role: ShapePartRole.bellyAccent,
        points: [
          Offset(24.0, 52.0),
          Offset(30.0, 53.8),
          Offset(37.0, 55.2),
          Offset(45.0, 56.2),
          Offset(54.0, 56.5),
          Offset(63.0, 55.8),
          Offset(71.5, 54.1),
          Offset(75.3, 53.2),
          Offset(72.6, 55.6),
          Offset(65.0, 57.2),
          Offset(56.0, 58.2),
          Offset(47.0, 58.4),
          Offset(38.5, 57.5),
          Offset(31.0, 55.8),
          Offset(25.5, 53.8),
        ],
      ),

      // Near/front flipper: almost Body-colored. Its job is to break the
      // belly plane while still feeling physically attached to the torso.
      ShapeTracePart(
        role: ShapePartRole.frontFinAccent,
        points: [
          Offset(28.8, 57.0),
          Offset(32.4, 57.2),
          Offset(35.1, 58.3),
          Offset(34.1, 63.0),
          Offset(31.2, 67.5),
          Offset(29.0, 66.0),
          Offset(29.1, 60.3),
        ],
      ),

      // Far/rear flipper: same hue, only a little darker to create rear depth.
      ShapeTracePart(
        role: ShapePartRole.rearFinAccent,
        points: [
          Offset(38.0, 58.8),
          Offset(41.0, 59.0),
          Offset(47.7, 59.0),
          Offset(46.2, 64.5),
          Offset(43.7, 69.7),
          Offset(41.6, 69.4),
          Offset(39.9, 63.2),
        ],
      ),
    ],
  ),
};
