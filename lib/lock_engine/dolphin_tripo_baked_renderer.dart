import 'package:flutter/material.dart';

import 'dolphin_tripo_baked_cache.dart';
import 'models.dart';

/// Temporary PoC renderer using the current Tripo dolphin draft baked into a
/// transparent WebP. Blue + glossy only, so the visual test stays isolated.
bool paintDolphinTripoBaked(
  Canvas canvas, {
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required ShapeTexture texture,
  required double opacity,
}) {
  if (tone != ShapeTone.blue || texture != ShapeTexture.glossy) return false;

  final cache = DolphinTripoBakedCache.instance;
  cache.ensureLoaded();
  final image = cache.image;
  if (image == null) return false;

  final src = Rect.fromLTWH(
    0,
    0,
    image.width.toDouble(),
    image.height.toDouble(),
  );

  // Slightly wider than the old illustrated token so the baked 3D silhouette
  // reads at actual runtime size.
  final dst = Rect.fromCenter(
    center: center,
    width: radius * 3.08,
    height: radius * 2.82,
  );

  final paint = Paint()
    ..filterQuality = FilterQuality.high
    ..color = Colors.white.withValues(alpha: opacity);

  canvas.drawImageRect(image, src, dst, paint);
  return true;
}
