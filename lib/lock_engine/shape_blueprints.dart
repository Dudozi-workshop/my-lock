import 'dart:ui';

import 'models.dart';

enum ShapeSmoothing {
  polygon,
  midpointQuadratic,
}

class ShapeBlueprint {
  const ShapeBlueprint({
    required this.viewBoxSize,
    required this.opticalRadius,
    required this.points,
    this.smoothing = ShapeSmoothing.midpointQuadratic,
  });

  /// Coordinate space used when the shape was approved.
  /// Keep source points in this space instead of hand-normalizing them.
  final double viewBoxSize;

  /// Radius of the comparison circle in the approved preview.
  /// This keeps optical size identical between preview and production.
  final double opticalRadius;

  /// Approved source points. These are the single source of truth.
  final List<Offset> points;

  final ShapeSmoothing smoothing;
}

const dolphinBlueprint = ShapeBlueprint(
  viewBoxSize: 100,
  opticalRadius: 31,
  points: <Offset>[
    Offset(8, 39.4),
    Offset(8, 41),
    Offset(11.5, 44.3),
    Offset(18.6, 47.3),
    Offset(22.4, 49.8),
    Offset(23.3, 49.5),
    Offset(23, 48.6),
    Offset(19.4, 46.3),
    Offset(13.5, 43.8),
    Offset(11.3, 42.5),
    Offset(11.2, 41.7),
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
);

const illustratedShapeBlueprints = <ShapeKind, ShapeBlueprint>{
  ShapeKind.dolphin: dolphinBlueprint,
};
