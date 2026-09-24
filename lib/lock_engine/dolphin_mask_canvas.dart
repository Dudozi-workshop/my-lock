import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dolphin_mask_assets.dart';
import 'models.dart';

/// Lazily decodes the three PoC alpha masks once and invalidates painters when
/// they become available. The first frame may use the existing vector fallback;
/// subsequent frames use the raster-mask renderer.
class DolphinMaskCanvasCache extends ChangeNotifier {
  DolphinMaskCanvasCache._();

  static final DolphinMaskCanvasCache instance = DolphinMaskCanvasCache._();

  ui.Image? body;
  ui.Image? mouth;
  ui.Image? belly;

  bool _loading = false;

  bool get ready => body != null && mouth != null && belly != null;

  void ensureLoaded() {
    if (ready || _loading) return;
    _loading = true;
    _load();
  }

  Future<void> _load() async {
    try {
      final images = await Future.wait<ui.Image>([
        _decode(dolphinBodyPngBase64),
        _decode(dolphinMouthPngBase64),
        _decode(dolphinBellyPngBase64),
      ]);
      body = images[0];
      mouth = images[1];
      belly = images[2];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<ui.Image> _decode(String source) async {
    final bytes = base64Decode(source);
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 256,
      targetHeight: 256,
    );
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }
}

/// Paints the raster-mask dolphin directly onto the lock canvas.
///
/// Returns false while masks are still decoding so callers can keep the current
/// vector dolphin as a one-frame fallback.
bool paintDolphinMaskCanvas(
  Canvas canvas, {
  required Offset center,
  required double radius,
  required ShapeTone tone,
  required ShapeTexture texture,
  required double opacity,
}) {
  final cache = DolphinMaskCanvasCache.instance;
  cache.ensureLoaded();
  if (!cache.ready) return false;

  final body = cache.body!;
  final mouth = cache.mouth!;
  final belly = cache.belly!;

  // The source is square, with its alpha silhouette inset. 3r keeps the visible
  // body width close to the production vector dolphin at the same slot size.
  final extent = radius * 3.0;
  final dst = Rect.fromCenter(
    center: center,
    width: extent,
    height: extent,
  );
  final src = Rect.fromLTWH(
    0,
    0,
    body.width.toDouble(),
    body.height.toDouble(),
  );

  final colors = _toneColors(tone);
  final bodyGradient = _bodyGradient(texture, colors.$1, colors.$2);
  final mouthColor =
      _lightAccent(colors.$1, 0.78).withValues(alpha: opacity);
  final bellyColor =
      _lightAccent(colors.$1, 0.62).withValues(alpha: opacity);

  _paintOuterGlow(
    canvas,
    image: body,
    src: src,
    dst: dst,
    tone: tone,
    texture: texture,
    opacity: opacity,
    radius: radius,
  );

  _paintGradientThroughMask(
    canvas,
    mask: body,
    src: src,
    dst: dst,
    gradient: bodyGradient,
    opacity: opacity,
  );

  if (texture == ShapeTexture.glass) {
    _paintCrystalFacets(
      canvas,
      bodyMask: body,
      src: src,
      dst: dst,
      light: colors.$1,
      dark: colors.$2,
      opacity: opacity,
    );
  }

  _paintSolidMask(
    canvas,
    image: belly,
    src: src,
    dst: dst,
    color: bellyColor.withValues(
      alpha: _accentAlpha(texture, false) * opacity,
    ),
  );
  _paintSolidMask(
    canvas,
    image: mouth,
    src: src,
    dst: dst,
    color: mouthColor.withValues(
      alpha: _accentAlpha(texture, true) * opacity,
    ),
  );

  if (texture != ShapeTexture.matte) {
    _paintSpecular(
      canvas,
      bodyMask: body,
      src: src,
      dst: dst,
      texture: texture,
      opacity: opacity,
    );
  }

  _paintEye(canvas, dst, opacity);
  return true;
}

void _paintOuterGlow(
  Canvas canvas, {
  required ui.Image image,
  required Rect src,
  required Rect dst,
  required ShapeTone tone,
  required ShapeTexture texture,
  required double opacity,
  required double radius,
}) {
  final rimAlpha = switch (texture) {
    ShapeTexture.glass => 0.78,
    ShapeTexture.chrome => 0.48,
    ShapeTexture.metal => 0.40,
    ShapeTexture.jelly => 0.44,
    ShapeTexture.glossy => 0.48,
    ShapeTexture.hologram => 0.36,
    ShapeTexture.matte => 0.20,
  };

  final rimColor = tone == ShapeTone.white
      ? const Color(0xFFB9B9C4)
      : Colors.white;

  final paint = Paint()
    ..filterQuality = FilterQuality.high
    ..colorFilter = ColorFilter.mode(
      rimColor.withValues(alpha: rimAlpha * opacity),
      BlendMode.srcIn,
    )
    ..maskFilter = MaskFilter.blur(
      BlurStyle.outer,
      (radius * 0.07).clamp(0.8, 4.0),
    );

  canvas.drawImageRect(image, src, dst, paint);
}

void _paintGradientThroughMask(
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

void _paintSolidMask(
  Canvas canvas, {
  required ui.Image image,
  required Rect src,
  required Rect dst,
  required Color color,
}) {
  canvas.drawImageRect(
    image,
    src,
    dst,
    Paint()
      ..filterQuality = FilterQuality.high
      ..colorFilter = ColorFilter.mode(color, BlendMode.srcIn),
  );
}

void _paintCrystalFacets(
  Canvas canvas, {
  required ui.Image bodyMask,
  required Rect src,
  required Rect dst,
  required Color light,
  required Color dark,
  required double opacity,
}) {
  Offset p(double x, double y) =>
      Offset(dst.left + dst.width * x, dst.top + dst.height * y);

  void facet(List<Offset> points, Color color) {
    canvas.drawPath(
      Path()..addPolygon(points, true),
      Paint()..color = color.withValues(alpha: opacity),
    );
  }

  canvas.saveLayer(dst, Paint());

  facet(
    [p(.08, .18), p(.46, .10), p(.55, .42), p(.18, .50)],
    Color.lerp(light, Colors.white, .54)!,
  );
  facet(
    [p(.46, .10), p(.78, .20), p(.74, .48), p(.55, .42)],
    Color.lerp(light, dark, .22)!,
  );
  facet(
    [p(.18, .50), p(.55, .42), p(.48, .72), p(.12, .78)],
    Color.lerp(light, Colors.white, .26)!,
  );
  facet(
    [p(.55, .42), p(.74, .48), p(.88, .72), p(.48, .72)],
    Color.lerp(light, dark, .54)!,
  );
  facet(
    [p(.48, .72), p(.88, .72), p(.73, .92), p(.35, .91)],
    Color.lerp(dark, Colors.black, .10)!,
  );

  canvas.drawImageRect(
    bodyMask,
    src,
    dst,
    Paint()
      ..blendMode = BlendMode.dstIn
      ..filterQuality = FilterQuality.high,
  );
  canvas.restore();
}

void _paintSpecular(
  Canvas canvas, {
  required ui.Image bodyMask,
  required Rect src,
  required Rect dst,
  required ShapeTexture texture,
  required double opacity,
}) {
  final alpha = switch (texture) {
    ShapeTexture.glass => 0.78,
    ShapeTexture.chrome => 0.66,
    ShapeTexture.metal => 0.38,
    ShapeTexture.jelly => 0.56,
    ShapeTexture.hologram => 0.40,
    ShapeTexture.glossy => 0.52,
    ShapeTexture.matte => 0.0,
  };

  final highlight = Rect.fromCenter(
    center: Offset(
      dst.left + dst.width * 0.37,
      dst.top + dst.height * 0.32,
    ),
    width: dst.width * 0.16,
    height: dst.height * 0.055,
  );

  canvas.saveLayer(dst, Paint());
  canvas.drawOval(
    highlight,
    Paint()..color = Colors.white.withValues(alpha: alpha * opacity),
  );
  canvas.drawImageRect(
    bodyMask,
    src,
    dst,
    Paint()
      ..blendMode = BlendMode.dstIn
      ..filterQuality = FilterQuality.high,
  );
  canvas.restore();
}

void _paintEye(Canvas canvas, Rect dst, double opacity) {
  final eyeCenter = Offset(
    dst.left + dst.width * 0.73,
    dst.top + dst.height * 0.435,
  );
  final eyeRadius = dst.width * 0.014;

  canvas.drawCircle(
    eyeCenter,
    eyeRadius,
    Paint()..color = const Color(0xFF11131A).withValues(alpha: opacity),
  );
  canvas.drawCircle(
    eyeCenter.translate(-eyeRadius * .25, -eyeRadius * .28),
    eyeRadius * .30,
    Paint()..color = Colors.white.withValues(alpha: opacity),
  );
}

Gradient _bodyGradient(
  ShapeTexture texture,
  Color light,
  Color dark,
) {
  switch (texture) {
    case ShapeTexture.glossy:
      return RadialGradient(
        center: const Alignment(-0.40, -0.50),
        radius: 1.20,
        colors: [
          Colors.white,
          light,
          dark,
        ],
        stops: const [0.0, 0.40, 1.0],
      );
    case ShapeTexture.jelly:
      return RadialGradient(
        center: const Alignment(-0.34, -0.45),
        radius: 1.16,
        colors: [
          Colors.white.withValues(alpha: 0.88),
          light.withValues(alpha: 0.90),
          dark.withValues(alpha: 0.94),
        ],
        stops: const [0.0, 0.42, 1.0],
      );
    case ShapeTexture.glass:
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Color.lerp(light, Colors.white, 0.44)!,
          light,
          Color.lerp(light, dark, 0.60)!,
          dark,
        ],
        stops: const [0.0, 0.18, 0.43, 0.72, 1.0],
      );
    case ShapeTexture.metal:
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          light,
          const Color(0xFFF2F3F7),
          Color.lerp(light, dark, 0.45)!,
          dark,
        ],
        stops: const [0.0, 0.34, 0.61, 1.0],
      );
    case ShapeTexture.chrome:
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          light,
          const Color(0xFF565866),
          Colors.white,
          dark,
        ],
        stops: const [0.0, 0.18, 0.48, 0.64, 1.0],
      );
    case ShapeTexture.hologram:
      return const SweepGradient(
        colors: [
          Color(0xFFFF87CD),
          Color(0xFF8BD8FF),
          Color(0xFF9EF3D2),
          Color(0xFFFFE27A),
          Color(0xFFC69CFF),
          Color(0xFFFF87CD),
        ],
      );
    case ShapeTexture.matte:
      return LinearGradient(colors: [light, light]);
  }
}

double _accentAlpha(ShapeTexture texture, bool mouth) {
  return switch (texture) {
    ShapeTexture.glossy => mouth ? 0.94 : 0.84,
    ShapeTexture.jelly => mouth ? 0.78 : 0.70,
    ShapeTexture.glass => mouth ? 0.72 : 0.62,
    ShapeTexture.matte => mouth ? 0.92 : 0.84,
    ShapeTexture.metal => mouth ? 0.74 : 0.66,
    ShapeTexture.chrome => mouth ? 0.66 : 0.58,
    ShapeTexture.hologram => mouth ? 0.60 : 0.50,
  };
}

Color _lightAccent(Color base, double amount) =>
    Color.lerp(base, Colors.white, amount)!;

(Color, Color) _toneColors(ShapeTone tone) {
  switch (tone) {
    case ShapeTone.pink:
      return (const Color(0xFFFF8FD1), const Color(0xFFE656AB));
    case ShapeTone.blue:
      return (const Color(0xFF79BFFF), const Color(0xFF3F6FEA));
    case ShapeTone.yellow:
      return (const Color(0xFFFFDA72), const Color(0xFFF0A632));
    case ShapeTone.purple:
      return (const Color(0xFFC7A4FF), const Color(0xFF7447D9));
    case ShapeTone.mint:
      return (const Color(0xFF9EF3D2), const Color(0xFF2FAF89));
    case ShapeTone.black:
      return (const Color(0xFF5A5A64), const Color(0xFF17171D));
    case ShapeTone.white:
      return (const Color(0xFFFFFFFF), const Color(0xFFD9D9E2));
  }
}
