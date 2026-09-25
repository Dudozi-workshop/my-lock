import 'package:flutter/material.dart';

import 'dolphin_baked_only_cache.dart';
import 'models.dart';

/// Baked-only production-path PoC.
///
/// No vector dolphin, mask renderer, realtime material renderer or legacy
/// sprite fallback is used. If the asset is still decoding, this function
/// simply skips the frame; the cache notification repaints when ready.
void paintDolphinBakedOnly(
  Canvas canvas, {
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required double opacity,
}) {
  final cache = DolphinBakedOnlyCache.instance;
  cache.ensureLoaded();

  final image = cache.image(tone);
  if (image == null) return;

  final src = Rect.fromLTWH(
    0,
    0,
    image.width.toDouble(),
    image.height.toDouble(),
  );
  final dst = Rect.fromCenter(
    center: center,
    width: radius * 3.08,
    height: radius * 2.82,
  );

  final paint = Paint()
    ..filterQuality = FilterQuality.medium
    ..color = Colors.white.withValues(alpha: opacity);

  canvas.drawImageRect(image, src, dst, paint);
}
