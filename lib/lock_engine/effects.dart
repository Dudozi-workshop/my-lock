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
