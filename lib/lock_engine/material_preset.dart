import 'package:flutter/material.dart';

import 'models.dart';

/// Runtime material palette used by high-detail visual renderers.
///
/// A "color" in MY LOCK is intentionally more than one flat swatch: each
/// preset carries the tonal range needed for body volume, rim light, glow,
/// specular highlights and light accents. This keeps small 58px-class shapes
/// readable while preserving a premium semi-3D look.
class ShapeMaterialPreset {
  const ShapeMaterialPreset({
    required this.base,
    required this.highlight,
    required this.shadow,
    required this.rim,
    required this.glow,
    required this.specular,
    required this.lightAccent,
  });

  final Color base;
  final Color highlight;
  final Color shadow;
  final Color rim;
  final Color glow;
  final Color specular;
  final Color lightAccent;
}

ShapeMaterialPreset materialPresetFor(ShapeTone tone) {
  return switch (tone) {
    ShapeTone.blue => const ShapeMaterialPreset(
        base: Color(0xFF3F9CFF),
        highlight: Color(0xFFD9F4FF),
        shadow: Color(0xFF2859D8),
        rim: Color(0xFF8BEFFF),
        glow: Color(0xFF28B9FF),
        specular: Color(0xFFFFFFFF),
        lightAccent: Color(0xFFC9E9FF),
      ),
    ShapeTone.pink => const ShapeMaterialPreset(
        base: Color(0xFFFF78B9),
        highlight: Color(0xFFFFE1F1),
        shadow: Color(0xFFD9438A),
        rim: Color(0xFFFFB7DE),
        glow: Color(0xFFFF5FAE),
        specular: Color(0xFFFFFFFF),
        lightAccent: Color(0xFFFFD4E9),
      ),
    ShapeTone.yellow => const ShapeMaterialPreset(
        base: Color(0xFFFFC95B),
        highlight: Color(0xFFFFF2C4),
        shadow: Color(0xFFD58A25),
        rim: Color(0xFFFFE59A),
        glow: Color(0xFFFFC44D),
        specular: Color(0xFFFFFFFF),
        lightAccent: Color(0xFFFFE8AF),
      ),
    ShapeTone.purple => const ShapeMaterialPreset(
        base: Color(0xFF9B78FF),
        highlight: Color(0xFFE6DCFF),
        shadow: Color(0xFF6344C7),
        rim: Color(0xFFCAB5FF),
        glow: Color(0xFF8F67FF),
        specular: Color(0xFFFFFFFF),
        lightAccent: Color(0xFFD9CCFF),
      ),
    ShapeTone.mint => const ShapeMaterialPreset(
        base: Color(0xFF38D8C8),
        highlight: Color(0xFFD8FFF8),
        shadow: Color(0xFF1E9E90),
        rim: Color(0xFF8CFFF1),
        glow: Color(0xFF2DE7D5),
        specular: Color(0xFFFFFFFF),
        lightAccent: Color(0xFFC8F7F0),
      ),
    ShapeTone.black => const ShapeMaterialPreset(
        base: Color(0xFF4A5268),
        highlight: Color(0xFFCED8F5),
        shadow: Color(0xFF151925),
        rim: Color(0xFF8EA2D2),
        glow: Color(0xFF536A9B),
        specular: Color(0xFFF5F8FF),
        lightAccent: Color(0xFFB9C4DE),
      ),
    ShapeTone.white => const ShapeMaterialPreset(
        base: Color(0xFFE9EDF7),
        highlight: Color(0xFFFFFFFF),
        shadow: Color(0xFFB7C0D4),
        rim: Color(0xFFFFFFFF),
        glow: Color(0xFFDCE9FF),
        specular: Color(0xFFFFFFFF),
        lightAccent: Color(0xFFF8FAFF),
      ),
  };
}
