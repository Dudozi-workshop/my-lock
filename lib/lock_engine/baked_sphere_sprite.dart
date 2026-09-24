import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'models.dart';

const int bakedSphereFrameCount = 12;
const int _bakedSphereFrameSize = 128;

/// Runtime contract for the future 3D -> sprite pipeline.
///
/// The PoC generates the baked frames once in memory so we can validate the
/// exact runtime cost without committing placeholder artwork. Production
/// Dolphin assets can later replace these cached frames with Blender/GLB
/// renders without changing the FloatingEngine integration.
class BakedSphereSpriteCache extends ChangeNotifier {
  BakedSphereSpriteCache._();

  static final BakedSphereSpriteCache instance = BakedSphereSpriteCache._();

  ui.Image? body;
  final List<ui.Image> specularFrames = <ui.Image>[];

  Future<void>? _loadingFuture;

  bool get ready =>
      body != null && specularFrames.length == bakedSphereFrameCount;

  void ensureLoaded() {
    ensureLoadedAsync();
  }

  Future<void> ensureLoadedAsync() {
    if (ready) return Future<void>.value();
    return _loadingFuture ??= _generate();
  }

  Future<void> _generate() async {
    try {
      body ??= await _renderBody();

      if (specularFrames.isEmpty) {
        for (var i = 0; i < bakedSphereFrameCount; i++) {
          specularFrames.add(await _renderSpecularFrame(i));
        }
      }
    } finally {
      _loadingFuture = null;
      notifyListeners();
    }
  }

  Future<ui.Image> _renderBody() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size.square(_bakedSphereFrameSize.toDouble());
    final bounds = Offset.zero & size;

    final sphere = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.84,
      height: size.height * 0.84,
    );

    canvas.drawOval(
      sphere,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.34, -0.40),
          radius: 1.12,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF6F6F6),
            Color(0xFFD7D7D7),
            Color(0xFF929292),
          ],
          stops: [0.0, 0.33, 0.68, 1.0],
        ).createShader(sphere),
    );

    // Broad lower form shadow, already baked so runtime needs no shader.
    canvas.saveLayer(bounds, Paint());
    canvas.drawOval(
      sphere,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color(0x11000000),
            Color(0x42000000),
          ],
          stops: [0.38, 0.68, 1.0],
        ).createShader(sphere),
    );
    canvas.restore();

    return recorder
        .endRecording()
        .toImage(_bakedSphereFrameSize, _bakedSphereFrameSize);
  }

  Future<ui.Image> _renderSpecularFrame(int frame) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final phase = frame / bakedSphereFrameCount * math.pi * 2;
    final dx = math.sin(phase) * 4.2;
    final dy = math.cos(phase) * 2.2;

    final primary = Rect.fromCenter(
      center: Offset(48 + dx, 39 + dy),
      width: 30,
      height: 13,
    );
    final pin = Rect.fromCenter(
      center: Offset(55 + dx * 0.82, 43 + dy * 0.72),
      width: 8.0,
      height: 8.0,
    );

    canvas.drawOval(
      primary,
      Paint()
        ..color = const Color(0xA6FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );
    canvas.drawOval(
      pin,
      Paint()
        ..color = const Color(0xF0FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
    );

    // Soft studio rim. This stays broad so it survives the 80-110px token size.
    final rim = Rect.fromCenter(
      center: const Offset(64, 64),
      width: 107,
      height: 107,
    );
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = const Color(0x46FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4),
    );

    return recorder
        .endRecording()
        .toImage(_bakedSphereFrameSize, _bakedSphereFrameSize);
  }
}

class BakedSphereSpritePainter extends CustomPainter {
  BakedSphereSpritePainter({
    required this.objects,
    required this.animationSeconds,
  }) : super(repaint: BakedSphereSpriteCache.instance) {
    BakedSphereSpriteCache.instance.ensureLoaded();
  }

  final List<FloatingObject> objects;
  final double animationSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final cache = BakedSphereSpriteCache.instance;
    if (!cache.ready) return;

    final src = Rect.fromLTWH(
      0,
      0,
      cache.body!.width.toDouble(),
      cache.body!.height.toDouble(),
    );

    for (final object in objects) {
      if (object.token.shape != ShapeKind.dolphin) continue;

      final progress = object.isPopping
          ? (object.popElapsed / 0.18).clamp(0.0, 1.0).toDouble()
          : 0.0;
      final scale = object.isPopping ? 1.0 + progress * 0.34 : 1.0;
      final opacity =
          object.isPopping ? (1.0 - progress).clamp(0.0, 1.0).toDouble() : 1.0;

      final extent = object.radius * 2.12 * scale;
      final dst = Rect.fromCenter(
        center: object.position,
        width: extent,
        height: extent,
      );

      final frame =
          ((animationSeconds * 12.0 + object.id * 1.73).floor()) %
              bakedSphereFrameCount;
      final bodyTone = _spriteTone(object.token.tone);

      canvas.save();
      canvas.translate(object.position.dx, object.position.dy);
      canvas.rotate(object.rotation * 0.16);
      canvas.translate(-object.position.dx, -object.position.dy);

      canvas.drawImageRect(
        cache.body!,
        src,
        dst,
        Paint()
          ..filterQuality = FilterQuality.high
          ..colorFilter = ColorFilter.mode(
            bodyTone.withValues(alpha: opacity),
            BlendMode.modulate,
          ),
      );

      final specular = cache.specularFrames[frame];
      canvas.drawImageRect(
        specular,
        Rect.fromLTWH(
          0,
          0,
          specular.width.toDouble(),
          specular.height.toDouble(),
        ),
        dst,
        Paint()
          ..filterQuality = FilterQuality.high
          ..color = Colors.white.withValues(alpha: opacity),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant BakedSphereSpritePainter oldDelegate) {
    return true;
  }
}

Color _spriteTone(ShapeTone tone) {
  return switch (tone) {
    ShapeTone.pink => const Color(0xFFFF7FC6),
    ShapeTone.blue => const Color(0xFF67B7FF),
    ShapeTone.yellow => const Color(0xFFFFD05A),
    ShapeTone.purple => const Color(0xFFAC86FF),
    ShapeTone.mint => const Color(0xFF70E7C2),
    ShapeTone.black => const Color(0xFF454751),
    ShapeTone.white => const Color(0xFFF2F4FF),
  };
}
