enum MovementStyle {
  floating('Floating', false),
  bounce('Bounce', false),
  orbit('Orbit', true),
  zeroGravity('Zero Gravity', true),
  underwater('Underwater', true);

  const MovementStyle(this.label, this.locked);

  final String label;
  final bool locked;
}

enum PopStyle {
  basicPop('Basic Pop', false),
  bubble('Bubble', false),
  spark('Spark', true),
  pixel('Pixel', true),
  glassBreak('Glass Break', true);

  const PopStyle(this.label, this.locked);

  final String label;
  final bool locked;
}

enum MovementArea {
  full('전체'),
  lower('하단 영역');

  const MovementArea(this.label);

  final String label;
}

enum FloatingSpeed {
  slow(0.72),
  normal(1.0),
  fast(1.38);

  const FloatingSpeed(this.multiplier);

  final double multiplier;
}
