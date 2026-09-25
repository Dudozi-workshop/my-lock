import 'dart:ui';

enum ShapeKind {
  circle('원', false),
  triangle('세모', false),
  square('네모', false);

  const ShapeKind(this.label, this.premium);

  final String label;
  final bool premium;

  static const Set<ShapeKind> defaults = {
    ShapeKind.circle,
    ShapeKind.triangle,
    ShapeKind.square,
  };
}

enum ShapeTone {
  pink('핑크', false),
  blue('블루', false),
  yellow('옐로우', false);

  const ShapeTone(this.label, this.premium);

  final String label;
  final bool premium;

  static const Set<ShapeTone> defaults = {
    ShapeTone.pink,
    ShapeTone.blue,
    ShapeTone.yellow,
  };
}

enum ShapeStyle {
  softBasic('Soft Basic', false, 'soft_basic'),
  crayonSoft('Crayon Soft', false, 'crayon_soft');

  const ShapeStyle(this.label, this.premium, this.assetId);

  final String label;
  final bool premium;
  final String assetId;
}

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
