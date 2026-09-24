import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'dolphin_mask_canvas.dart';
import 'material_preset.dart';
import 'models.dart';

/// High-detail dolphin renderer for the production canvas.
///
/// v2 keeps geometry/hit-testing separate from presentation. The approved
/// dolphin alpha masks define the visual silhouette while a low-frequency
/// lighting stack creates volume that remains legible at real lock-screen size.
bool paintDolphinVisualV2(
  Canvas canvas, {
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required ShapeTexture texture,
  required double opacity,
}) {
  if (texture != ShapeTexture.glossy && texture != ShapeTexture.jelly) {
    return paintDolphinMaskCanvas(
      canvas,
      center: center,
      radius: radius,
      tone: tone,
      texture: texture,
      opacity: opacity,
    );
  }

  final cache = DolphinMaskCanvasCache.instance;
  cache.ensureLoaded();
  if (!cache.ready) return false;

  final body = cache.body!;
  final mouth = cache.mouth!;
  final belly = cache.belly!;
  final preset = materialPresetFor(tone);
  final jelly = texture == ShapeTexture.jelly;

  final dst = Rect.fromCenter(
    center: center,
    width: radius * 2.90,
    height: radius * 2.64,
  );
  final src = Rect.fromLTWH(
    0,
    0,
    body.width.toDouble(),
    body.height.toDouble(),
  );

  _paintOuterGlow(
    canvas,
    mask: body,
    src: src,
    dst: dst,
    preset: preset,
    opacity: opacity,
    radius: radius,
    jelly: jelly,
  );

  _paintMaskedGradient(
    canvas,
    mask: body,
    src: src,
    dst: dst,
    gradient: RadialGradient(
      center: const Alignment(-0.28, -0.48),
      radius: 1.16,
      colors: [
        preset.highlight.withValues(alpha: jelly ? 0.94 : 1.0),
        Color.lerp(preset.highlight, preset.base, 0.42)!
            .withValues(alpha: 0.98),
        preset.base.withValues(alpha: jelly ? 0.92 : 1.0),
        Color.lerp(preset.base, preset.shadow, 0.46)!
            .withValues(alpha: 0.98),
        preset.shadow.withValues(alpha: jelly ? 0.93 : 1.0),
      ],
      stops: const [0.00, 0.22, 0.50, 0.78, 1.00],
    ),
    opacity: opacity,
  );

  _paintBodyVolume(
    canvas,
    mask: body,
    src: src,
    dst: dst,
    preset: preset,
    opacity: opacity,
    radius: radius,
    jelly: jelly,
  );

  _paintAccent(
    canvas,
    mask: belly,
    src: src,
    dst: dst,
    preset: preset,
    opacity: opacity * (jelly ? 0.74 : 0.88),
    radius: radius,
    yBias: 0.08,
  );
  _paintAccent(
    canvas,
    mask: mouth,
    src: src,
    dst: dst,
    preset: preset,
    opacity: opacity * (jelly ? 0.82 : 0.96),
    radius: radius,
    yBias: -0.04,
  );

  _paintInternalBloom(
    canvas,
    mask: body,
    src: src,
    dst: dst,
    preset: preset,
    opacity: opacity,
    jelly: jelly,
  );

  _paintInnerRim(
    canvas,
    mask: body,
    src: src,
    dst: dst,
    preset: preset,
    opacity: opacity,
    radius: radius,
    jelly: jelly,
  );

  _paintSpecular(
    canvas,
    mask: body,
    src: src,
    dst: dst,
    preset: preset,
    opacity: opacity,
    radius: radius,
    jelly: jelly,
  );

  return true;
}

void _paintOuterGlow(
  Canvas canvas, {
  required ui.Image mask,
  required Rect src,
  required Rect dst,
  required ShapeMaterialPreset preset,
  required double opacity,
  required double radius,
  required bool jelly,
}) {
  canvas.drawImageRect(
    mask,
    src,
    dst,
    Paint()
      ..filterQuality = FilterQuality.high
      ..colorFilter = ColorFilter.mode(
        preset.glow.withValues(alpha: (jelly ? 0.24 : 0.18) * opacity),
        BlendMode.srcIn,
      )
      ..maskFilter = MaskFilter.blur(
        BlurStyle.outer,
        (radius * 0.105).clamp(1.6, 5.8),
      ),
  );

  canvas.drawImageRect(
    mask,
    src,
    dst,
    Paint()
      ..filterQuality = FilterQuality.high
      ..colorFilter = ColorFilter.mode(
        preset.rim.withValues(alpha: (jelly ? 0.70 : 0.62) * opacity),
        BlendMode.srcIn,
      )
      ..maskFilter = MaskFilter.blur(
        BlurStyle.outer,
        (radius * 0.035).clamp(0.7, 2.4),
      ),
  );
}

void _paintMaskedGradient(
  Canvas canvas, {
  required ui.Image mask,
  required Rect src,
  required Rect dst,
  required Gradient gradient,
  required double opacity,
}) {
  canvas.saveLayer(dst, Paint());
  canvas.drawRect(
    dst,
    Paint()
      ..shader = gradient.createShader(dst)
      ..color = Colors.white.withValues(alpha: opacity),
  );
  canvas.drawImageRect(
    mask,
    src,
    dst,
    Paint()
      ..blendMode = BlendMode.dstIn
      ..filterQuality = FilterQuality.high,
  );
  canvas.restore();
}

void _paintBodyVolume(
  Canvas canvas, {
  required ui.Image mask,
  required Rect src,
  required Rect dst,
  required ShapeMaterialPreset preset,
  required double opacity,
  required double radius,
  required bool jelly,
}) {
  canvas.saveLayer(dst, Paint());

  canvas.drawRect(
    dst,
    Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-0.72, -0.82),
        end: const Alignment(0.72, 0.92),
        colors: [
          preset.highlight.withValues(alpha: (jelly ? 0.30 : 0.36) * opacity),
          Colors.transparent,
          Colors.transparent,
          preset.shadow.withValues(alpha: (jelly ? 0.18 : 0.30) * opacity),
        ],
        stops: const [0.00, 0.34, 0.63, 1.00],
      ).createShader(dst),
  );

  final dorsal = Rect.fromCenter(
    center: Offset(
      dst.left + dst.width * 0.52,
      dst.top + dst.height * 0.27,
    ),
    width: dst.width * 0.56,
    height: dst.height * 0.34,
  );
  canvas.drawOval(
    dorsal,
    Paint()
      ..shader = RadialGradient(
        colors: [
          preset.highlight.withValues(alpha: (jelly ? 0.28 : 0.34) * opacity),
          preset.rim.withValues(alpha: (jelly ? 0.08 : 0.10) * opacity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(dorsal)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        (radius * 0.065).clamp(1.0, 3.6),
      ),
  );

  void ao(double x, double y, double w, double h, double alpha) {
    final rect = Rect.fromCenter(
      center: Offset(
        dst.left + dst.width * x,
        dst.top + dst.height * y,
      ),
      width: dst.width * w,
      height: dst.height * h,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = preset.shadow.withValues(alpha: alpha * opacity)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          (radius * 0.10).clamp(1.4, 4.4),
        ),
    );
  }

  ao(.55, .58, .20, .060, jelly ? .10 : .16);
  ao(.64, .62, .15, .050, jelly ? .08 : .13);
  ao(.20, .70, .13, .045, jelly ? .05 : .08);

  canvas.drawImageRect(
    mask,
    src,
    dst,
    Paint()
      ..blendMode = BlendMode.dstIn
      ..filterQuality = FilterQuality.high,
  );
  canvas.restore();
}

void _paintAccent(
  Canvas canvas, {
  required ui.Image mask,
  required Rect src,
  required Rect dst,
  required ShapeMaterialPreset preset,
  required double opacity,
  required double radius,
  required double yBias,
}) {
  canvas.drawImageRect(
    mask,
    src,
    dst.translate(0, radius * 0.018),
    Paint()
      ..filterQuality = FilterQuality.high
      ..colorFilter = ColorFilter.mode(
        preset.shadow.withValues(alpha: 0.15 * opacity),
        BlendMode.srcIn,
      )
      ..maskFilter = MaskFilter.blur(
        BlurStyle.outer,
        (radius * 0.030).clamp(0.7, 2.0),
      ),
  );

  canvas.saveLayer(dst, Paint());
  canvas.drawRect(
    dst,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment(0, -1 + yBias),
        end: Alignment(0, 1 + yBias),
        colors: [
          preset.specular.withValues(alpha: 0.92 * opacity),
          preset.lightAccent.withValues(alpha: 0.95 * opacity),
          Color.lerp(preset.lightAccent, preset.base, 0.22)!
              .withValues(alpha: 0.90 * opacity),
        ],
        stops: const [0.0, 0.54, 1.0],
      ).createShader(dst),
  );
  canvas.drawImageRect(
    mask,
    src,
    dst,
    Paint()
      ..blendMode = BlendMode.dstIn
      ..filterQuality = FilterQuality.high,
  );
  canvas.restore();
}

void _paintInternalBloom(
  Canvas canvas, {
  required ui.Image mask,
  required Rect src,
  required Rect dst,
  required ShapeMaterialPreset preset,
  required double opacity,
  required bool jelly,
}) {
  final bloom = Rect.fromCenter(
    center: Offset(
      dst.left + dst.width * 0.58,
      dst.top + dst.height * 0.50,
    ),
    width: dst.width * 0.48,
    height: dst.height * 0.30,
  );

  canvas.saveLayer(dst, Paint());
  canvas.drawOval(
    bloom,
    Paint()
      ..shader = RadialGradient(
        colors: [
          preset.glow.withValues(alpha: (jelly ? 0.26 : 0.14) * opacity),
          preset.rim.withValues(alpha: (jelly ? 0.09 : 0.05) * opacity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.46, 1.0],
      ).createShader(bloom)
      ..blendMode = BlendMode.screen,
  );
  canvas.drawImageRect(
    mask,
    src,
    dst,
    Paint()
      ..blendMode = BlendMode.dstIn
      ..filterQuality = FilterQuality.high,
  );
  canvas.restore();
}

void _paintInnerRim(
  Canvas canvas, {
  required ui.Image mask,
  required Rect src,
  required Rect dst,
  required ShapeMaterialPreset preset,
  required double opacity,
  required double radius,
  required bool jelly,
}) {
  canvas.drawImageRect(
    mask,
    src,
    dst,
    Paint()
      ..filterQuality = FilterQuality.high
      ..colorFilter = ColorFilter.mode(
        preset.rim.withValues(alpha: (jelly ? 0.22 : 0.18) * opacity),
        BlendMode.srcIn,
      )
      ..maskFilter = MaskFilter.blur(
        BlurStyle.inner,
        (radius * 0.040).clamp(0.7, 2.4),
      ),
  );
}

void _paintSpecular(
  Canvas canvas, {
  required ui.Image mask,
  required Rect src,
  required Rect dst,
  required ShapeMaterialPreset preset,
  required double opacity,
  required double radius,
  required bool jelly,
}) {
  final primary = Rect.fromCenter(
    center: Offset(
      dst.left + dst.width * 0.43,
      dst.top + dst.height * 0.24,
    ),
    width: dst.width * 0.27,
    height: dst.height * 0.075,
  );

  final secondary = Rect.fromCenter(
    center: Offset(
      dst.left + dst.width * 0.64,
      dst.top + dst.height * 0.34,
    ),
    width: dst.width * 0.12,
    height: dst.height * 0.036,
  );

  canvas.saveLayer(dst, Paint());
  final blur = MaskFilter.blur(
    BlurStyle.normal,
    (radius * 0.050).clamp(0.8, 2.8),
  );

  canvas.save();
  canvas.translate(primary.center.dx, primary.center.dy);
  canvas.rotate(-0.18);
  canvas.translate(-primary.center.dx, -primary.center.dy);
  canvas.drawRRect(
    RRect.fromRectAndRadius(primary, Radius.circular(primary.height)),
    Paint()
      ..color = preset.specular.withValues(
        alpha: (jelly ? 0.64 : 0.76) * opacity,
      )
      ..maskFilter = blur,
  );
  canvas.restore();

  canvas.drawOval(
    secondary,
    Paint()
      ..color = preset.specular.withValues(
        alpha: (jelly ? 0.24 : 0.34) * opacity,
      )
      ..maskFilter = blur,
  );

  canvas.drawImageRect(
    mask,
    src,
    dst,
    Paint()
      ..blendMode = BlendMode.dstIn
      ..filterQuality = FilterQuality.high,
  );
  canvas.restore();
}
