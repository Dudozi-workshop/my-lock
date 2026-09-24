import 'dart:math';
import 'package:flutter/material.dart';

import 'dolphin_sprite_cache.dart';
import 'models.dart';

/// Draws the pre-rendered 2.5D dolphin sprite.
///
/// Returns false for unsupported tone/texture pairs or while assets are still
/// decoding, allowing the existing visual renderer to act as a fallback.
bool paintDolphinSprite(
  Canvas canvas, {
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required ShapeTexture texture,
  required double opacity,
  required double animationPhase,
  required int animationSeed,
}) {
  if (texture != ShapeTexture.glossy) return false;

  final prefix = switch (tone) {
    ShapeTone.blue => 'blue',
    ShapeTone.pink => 'pink',
    _ => null,
  };
  if (prefix == null) return false;

  final cache = DolphinSpriteCache.instance;
  cache.ensureLoaded();
  if (!cache.ready) return false;

  final body = cache.image('${prefix}_body');
  final tail = cache.image('${prefix}_tail');
  if (body == null || tail == null) return false;

  final src = Rect.fromLTWH(
    0,
    0,
    body.width.toDouble(),
    body.height.toDouble(),
  );
  final dst = Rect.fromCenter(
    center: center,
    width: radius * 2.96,
    height: radius * 2.70,
  );

  final paint = Paint()
    ..filterQuality = FilterQuality.medium
    ..color = Colors.white.withValues(alpha: opacity);

  // One draw for the body, one draw for the independently animated tail.
  canvas.drawImageRect(body, src, dst, paint);

  final phase = animationPhase * 2 * pi * 0.56 + animationSeed * 0.73;
  final tailAngle = sin(phase) * 0.052; // ~3 degrees.
  final pivot = Offset(
    dst.left + dst.width * 0.705,
    dst.top + dst.height * 0.555,
  );

  canvas.save();
  canvas.translate(pivot.dx, pivot.dy);
  canvas.rotate(tailAngle);
  canvas.translate(-pivot.dx, -pivot.dy);
  canvas.drawImageRect(tail, src, dst, paint);
  canvas.restore();

  return true;
}
