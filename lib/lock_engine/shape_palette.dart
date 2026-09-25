import 'package:flutter/material.dart';

import 'models.dart';

/// Single source of truth for MY LOCK shape colors.
///
/// Baked assets, runtime basic shapes, shop previews and future style packs
/// must derive their main color from this catalog instead of inventing a
/// separate per-style palette.
class ShapeTonePalette {
  const ShapeTonePalette({
    required this.base,
    required this.shadow,
  });

  final Color base;
  final Color shadow;
}

const Map<ShapeTone, ShapeTonePalette> kShapeTonePalette =
    <ShapeTone, ShapeTonePalette>{
  ShapeTone.pink: ShapeTonePalette(
    base: Color(0xFFFF8FD1),
    shadow: Color(0xFFE656AB),
  ),
  ShapeTone.blue: ShapeTonePalette(
    base: Color(0xFF79BFFF),
    shadow: Color(0xFF3F6FEA),
  ),
  ShapeTone.yellow: ShapeTonePalette(
    base: Color(0xFFFFDA72),
    shadow: Color(0xFFF0A632),
  ),
  ShapeTone.purple: ShapeTonePalette(
    base: Color(0xFFC7A4FF),
    shadow: Color(0xFF7447D9),
  ),
  ShapeTone.mint: ShapeTonePalette(
    base: Color(0xFF9EF3D2),
    shadow: Color(0xFF2FAF89),
  ),
  ShapeTone.black: ShapeTonePalette(
    base: Color(0xFF5A5A64),
    shadow: Color(0xFF17171D),
  ),
  ShapeTone.white: ShapeTonePalette(
    base: Color(0xFFFFFFFF),
    shadow: Color(0xFFD9D9E2),
  ),
};

(Color, Color) shapeToneColors(ShapeTone tone) {
  final palette = kShapeTonePalette[tone]!;
  return (palette.base, palette.shadow);
}
