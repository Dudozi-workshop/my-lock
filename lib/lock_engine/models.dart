import 'dart:ui';

enum ShapeKind {
  circle('원', false),
  triangle('세모', false),
  square('네모', false),
  seaTurtle('바다거북', true);

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
  pink('핑크', false, false),
  blue('블루', false, false),
  yellow('옐로우', false, false),
  deepOcean('딥 오션 블루', true, true),
  aquaMint('아쿠아 민트', true, true),
  coralPink('코랄 핑크', true, true),
  sandBeige('샌드 베이지', true, true),
  lavender('젤리 바이올렛', true, true),
  peachOrange('쉘 피치', true, true),
  auroraSea('오로라 씨', true, false);

  const ShapeTone(this.label, this.premium, this.directSale);

  final String label;
  final bool premium;
  final bool directSale;

  static const Set<ShapeTone> defaults = {
    ShapeTone.pink,
    ShapeTone.blue,
    ShapeTone.yellow,
  };

  static const Set<ShapeTone> drop01Palette = {
    ShapeTone.deepOcean,
    ShapeTone.aquaMint,
    ShapeTone.coralPink,
    ShapeTone.sandBeige,
    ShapeTone.lavender,
    ShapeTone.peachOrange,
  };

  static const ShapeTone drop01Signature = ShapeTone.auroraSea;
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
