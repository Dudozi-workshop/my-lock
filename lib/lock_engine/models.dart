import 'dart:ui';

enum ShapeKind {
  circle('원', false),
  triangle('세모', false),
  square('네모', false),
  star('별', true),
  heart('하트', true),
  diamond('다이아', true),
  hexagon('육각형', true),
  crescent('달', true),
  dolphin('돌고래', true);

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
  yellow('옐로우', false),
  purple('퍼플', true),
  mint('민트', true),
  black('블랙', true),
  white('화이트', true);

  const ShapeTone(this.label, this.premium);

  final String label;
  final bool premium;

  static const Set<ShapeTone> defaults = {
    ShapeTone.pink,
    ShapeTone.blue,
    ShapeTone.yellow,
  };
}

enum ShapeTexture {
  glossy('Basic Glossy', false),
  jelly('Jelly', true),
  glass('Crystal', true),
  metal('Metal', true),
  chrome('Chrome', true),
  hologram('Hologram', true),
  matte('Matte', true);

  const ShapeTexture(this.label, this.premium);

  final String label;
  final bool premium;
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
  double spritePhase = 0;
  double popElapsed = -1;

  bool get isPopping => popElapsed >= 0;
}
