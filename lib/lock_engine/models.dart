import 'dart:ui';

enum ShapeKind { circle, triangle, square }

enum ShapeTone { pink, blue, yellow }

class LockToken {
  const LockToken({required this.shape, required this.tone});

  final ShapeKind shape;
  final ShapeTone tone;

  String get id => '${tone.name}_${shape.name}';
}

class FloatingObject {
  FloatingObject({
    required this.id,
    required this.token,
    required this.position,
    required this.velocity,
    required this.radius,
  });

  final int id;
  LockToken token;
  Offset position;
  Offset velocity;
  double radius;

  double rotation = 0;
  double angularVelocity = 0;
  double popElapsed = -1;

  bool get isPopping => popElapsed >= 0;
}
