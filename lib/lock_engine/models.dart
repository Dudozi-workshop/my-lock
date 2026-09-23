import 'dart:ui';

enum ShapeKind {
  circle('원', false),
  triangle('세모', false),
  square('네모', false),
  star('별', true),
  heart('하트', true),
  diamond('다이아', true),
  hexagon('육각형', true),
  crescent('달', true);

  const ShapeKind(this.label, this.premium);

  final String label;
  final bool premium;

  static const Set<ShapeKind> defaults = {
    ShapeKind.circle,
    ShapeKind.triangle,
    ShapeKind.square,
  };
}

enum ColorPalette {
  basic('Basic', false),
  pastel('Pastel', true),
  neon('Neon', true),
  ocean('Ocean', true),
  cosmic('Cosmic', true);

  const ColorPalette(this.label, this.premium);

  final String label;
  final bool premium;
}

enum ShapeTone {
  pink(
    'Pink',
    ColorPalette.basic,
    false,
    Color(0xFFFF8FD1),
    Color(0xFFE656AB),
  ),
  blue(
    'Blue',
    ColorPalette.basic,
    false,
    Color(0xFF79BFFF),
    Color(0xFF3F6FEA),
  ),
  yellow(
    'Yellow',
    ColorPalette.basic,
    false,
    Color(0xFFFFDA72),
    Color(0xFFF0A632),
  ),

  mint(
    'Mint',
    ColorPalette.pastel,
    false,
    Color(0xFF9EF3D2),
    Color(0xFF55C9A5),
  ),
  lavender(
    'Lavender',
    ColorPalette.pastel,
    false,
    Color(0xFFD5C0FF),
    Color(0xFF9C7BE8),
  ),
  peach(
    'Peach',
    ColorPalette.pastel,
    false,
    Color(0xFFFFC1A8),
    Color(0xFFEF8C73),
  ),
  babyBlue(
    'Baby Blue',
    ColorPalette.pastel,
    false,
    Color(0xFFB9DDFF),
    Color(0xFF77AEE7),
  ),
  butter(
    'Butter',
    ColorPalette.pastel,
    false,
    Color(0xFFFFE8A6),
    Color(0xFFE9C45A),
  ),
  rose(
    'Rose',
    ColorPalette.pastel,
    false,
    Color(0xFFF6A7BD),
    Color(0xFFD86587),
  ),
  dreamLilac(
    'Dream Lilac',
    ColorPalette.pastel,
    true,
    Color(0xFFE8D7FF),
    Color(0xFFB98AF6),
  ),

  neonPink(
    'Neon Pink',
    ColorPalette.neon,
    false,
    Color(0xFFFF4FC3),
    Color(0xFFFF1493),
  ),
  electricBlue(
    'Electric Blue',
    ColorPalette.neon,
    false,
    Color(0xFF4BD9FF),
    Color(0xFF0676FF),
  ),
  acidGreen(
    'Acid Green',
    ColorPalette.neon,
    false,
    Color(0xFFB7FF3C),
    Color(0xFF4EE700),
  ),
  laserPurple(
    'Laser Purple',
    ColorPalette.neon,
    false,
    Color(0xFFC44DFF),
    Color(0xFF7700FF),
  ),
  voltYellow(
    'Volt Yellow',
    ColorPalette.neon,
    false,
    Color(0xFFF4FF3B),
    Color(0xFFC7D900),
  ),
  cyberOrange(
    'Cyber Orange',
    ColorPalette.neon,
    false,
    Color(0xFFFF8A31),
    Color(0xFFFF4E00),
  ),
  prismNeon(
    'Prism Neon',
    ColorPalette.neon,
    true,
    Color(0xFF64F6FF),
    Color(0xFFFF4FD8),
  ),

  aqua(
    'Aqua',
    ColorPalette.ocean,
    false,
    Color(0xFF68E5E8),
    Color(0xFF1BB4C0),
  ),
  lagoon(
    'Lagoon',
    ColorPalette.ocean,
    false,
    Color(0xFF55D6C3),
    Color(0xFF149E8B),
  ),
  marineBlue(
    'Marine Blue',
    ColorPalette.ocean,
    false,
    Color(0xFF64A2FF),
    Color(0xFF2364D2),
  ),
  turquoise(
    'Turquoise',
    ColorPalette.ocean,
    false,
    Color(0xFF51DBC7),
    Color(0xFF11A895),
  ),
  deepSea(
    'Deep Sea',
    ColorPalette.ocean,
    false,
    Color(0xFF3E6D9A),
    Color(0xFF16354F),
  ),
  foam(
    'Foam',
    ColorPalette.ocean,
    false,
    Color(0xFFE8FFFF),
    Color(0xFFAEDFE0),
  ),
  biolume(
    'Biolume',
    ColorPalette.ocean,
    true,
    Color(0xFF7FFFE7),
    Color(0xFF29BFC2),
  ),

  nebulaPurple(
    'Nebula Purple',
    ColorPalette.cosmic,
    false,
    Color(0xFFB97CFF),
    Color(0xFF6C38D3),
  ),
  lunarBlue(
    'Lunar Blue',
    ColorPalette.cosmic,
    false,
    Color(0xFF8FAEFF),
    Color(0xFF506BDC),
  ),
  marsRed(
    'Mars Red',
    ColorPalette.cosmic,
    false,
    Color(0xFFF07A76),
    Color(0xFFB9444D),
  ),
  stardust(
    'Stardust',
    ColorPalette.cosmic,
    false,
    Color(0xFFEED6A6),
    Color(0xFFB99662),
  ),
  cosmicVoid(
    'Void',
    ColorPalette.cosmic,
    false,
    Color(0xFF5B5D78),
    Color(0xFF1E2034),
  ),
  cosmicPink(
    'Cosmic Pink',
    ColorPalette.cosmic,
    false,
    Color(0xFFEB82DA),
    Color(0xFFA842A5),
  ),
  aurora(
    'Aurora',
    ColorPalette.cosmic,
    true,
    Color(0xFF8CEAD6),
    Color(0xFF8075F2),
  );

  const ShapeTone(
    this.label,
    this.palette,
    this.isSignature,
    this.lightColor,
    this.darkColor,
  );

  final String label;
  final ColorPalette palette;
  final bool isSignature;
  final Color lightColor;
  final Color darkColor;

  bool get premium => palette.premium;

  static const Set<ShapeTone> defaults = {
    ShapeTone.pink,
    ShapeTone.blue,
    ShapeTone.yellow,
  };

  static List<ShapeTone> forPalette(ColorPalette palette) => ShapeTone.values
      .where((tone) => tone.palette == palette)
      .toList(growable: false);

  static ShapeTone? signatureFor(ColorPalette palette) {
    for (final tone in ShapeTone.values) {
      if (tone.palette == palette && tone.isSignature) {
        return tone;
      }
    }
    return null;
  }

  static List<ShapeTone> regularForPalette(ColorPalette palette) =>
      ShapeTone.values
          .where((tone) => tone.palette == palette && !tone.isSignature)
          .toList(growable: false);
}

enum ShapeTexture {
  glossy('Basic Glossy', false),
  jelly('Jelly', true),
  glass('Glass', true),
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
  double popElapsed = -1;

  bool get isPopping => popElapsed >= 0;
}
