import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';

const int bakedDolphinFrameCount = 24;
const double _sourceSize = 512;
const int _frameSize = 160;
const Rect _sourceCrop = Rect.fromLTRB(18, 68, 493, 447);

class BakedDolphinSpriteCache extends ChangeNotifier {
  BakedDolphinSpriteCache._();

  static final BakedDolphinSpriteCache instance = BakedDolphinSpriteCache._();

  final List<ui.Image> bodyFrames = <ui.Image>[];
  final List<ui.Image> accentFrames = <ui.Image>[];

  Future<void>? _loadingFuture;
  ui.Image? _bodyMask;
  ui.Image? _bellyMask;
  ui.Image? _mouthMask;

  bool get ready =>
      bodyFrames.length == bakedDolphinFrameCount &&
      accentFrames.length == bakedDolphinFrameCount;

  void ensureLoaded() {
    ensureLoadedAsync();
  }

  Future<void> ensureLoadedAsync() {
    if (ready) return Future<void>.value();
    return _loadingFuture ??= _generate();
  }

  Future<void> _generate() async {
    try {
      _bodyMask ??= await _decodeAsset(
        'assets/shapes/dolphin/dolphin_body.png',
      );
      _bellyMask ??= await _decodeAsset(
        'assets/shapes/dolphin/dolphin_belly_accent.png',
      );
      _mouthMask ??= await _decodeAsset(
        'assets/shapes/dolphin/dolphin_mouth_accent.png',
      );

      bodyFrames.clear();
      accentFrames.clear();

      for (var frame = 0; frame < bakedDolphinFrameCount; frame++) {
        final phase = frame / bakedDolphinFrameCount * math.pi * 2;
        bodyFrames.add(await _renderBodyFrame(phase));
        accentFrames.add(await _renderAccentFrame(phase));
      }
    } finally {
      _loadingFuture = null;
      notifyListeners();
    }
  }

  Future<ui.Image> _decodeAsset(String path) async {
    final bytes = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  Future<ui.Image> _renderBodyFrame(double phase) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final frameBounds = const Offset(0, 0) & const Size.square(_frameSize.toDouble());

    canvas.saveLayer(frameBounds, Paint());

    _drawAnimatedMask(
      canvas,
      _bodyMask!,
      phase,
    );

    final movingLightX = math.sin(phase) * 0.08;
    final movingLightY = math.cos(phase) * 0.04;
    final bodyShader = RadialGradient(
      center: Alignment(-0.30 + movingLightX, -0.40 + movingLightY),
      radius: 1.12,
      colors: const [
        Color(0xFFFFFFFF),
        Color(0xFFF8F8F8),
        Color(0xFFD7D7D7),
        Color(0xFF8C8C8C),
      ],
      stops: const [0.0, 0.34, 0.70, 1.0],
    ).createShader(frameBounds);

    canvas.drawRect(
      frameBounds,
      Paint()
        ..shader = bodyShader
        ..blendMode = BlendMode.srcIn,
    );

    final highlightCenter = Offset(
      _frameSize * (0.60 + math.sin(phase) * 0.016),
      _frameSize * (0.33 + math.cos(phase) * 0.010),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: highlightCenter,
        width: _frameSize * 0.19,
        height: _frameSize * 0.075,
      ),
      Paint()
        ..color = const Color(0x70FFFFFF)
        ..blendMode = BlendMode.srcATop
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.restore();

    return recorder.endRecording().toImage(_frameSize, _frameSize);
  }

  Future<ui.Image> _renderAccentFrame(double phase) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final frameBounds = const Offset(0, 0) & const Size.square(_frameSize.toDouble());

    canvas.saveLayer(frameBounds, Paint());

    _drawMask(canvas, _bellyMask!);
    _drawMask(canvas, _mouthMask!);

    final accentShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF4FAFF),
        Color(0xFFCEE5F8),
      ],
    ).createShader(frameBounds);

    canvas.drawRect(
      frameBounds,
      Paint()
        ..shader = accentShader
        ..blendMode = BlendMode.srcIn,
    );

    canvas.restore();

    return recorder.endRecording().toImage(_frameSize, _frameSize);
  }

  void _drawAnimatedMask(
    Canvas canvas,
    ui.Image image,
    double phase,
  ) {
    final src = _sourceCrop;
    const dst = Rect.fromLTWH(0, 0, _frameSize.toDouble(), _frameSize.toDouble());

    // Main body stays stable. A generous overlap hides the tail seam.
    final mainSource = Rect.fromLTRB(
      128,
      src.top,
      src.right,
      src.bottom,
    );
    final mainLeft = ((mainSource.left - src.left) / src.width) * _frameSize;
    final mainDst = Rect.fromLTRB(
      mainLeft - 5,
      0,
      _frameSize.toDouble(),
      _frameSize.toDouble(),
    );

    canvas.drawImageRect(
      image,
      mainSource,
      mainDst,
      Paint()..filterQuality = FilterQuality.high,
    );

    final tailSource = Rect.fromLTRB(
      src.left,
      src.top,
      176,
      src.bottom,
    );
    final tailWidth = ((tailSource.width / src.width) * _frameSize) + 8;
    final tailDst = Rect.fromLTWH(
      0,
      0,
      tailWidth,
      _frameSize.toDouble(),
    );

    final pivot = Offset(
      _frameSize * 0.31,
      _frameSize * 0.58,
    );
    final swayRadians = math.sin(phase) * 0.095;

    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(swayRadians);
    canvas.translate(-pivot.dx, -pivot.dy);
    canvas.drawImageRect(
      image,
      tailSource,
      tailDst,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  void _drawMask(Canvas canvas, ui.Image image) {
    canvas.drawImageRect(
      image,
      _sourceCrop,
      const Rect.fromLTWH(
        0,
        0,
        _frameSize.toDouble(),
        _frameSize.toDouble(),
      ),
      Paint()..filterQuality = FilterQuality.high,
    );
  }
}

class BakedDolphinSpritePainter extends CustomPainter {
  BakedDolphinSpritePainter({
    required this.objects,
    required this.animationSeconds,
  }) : super(repaint: BakedDolphinSpriteCache.instance) {
    BakedDolphinSpriteCache.instance.ensureLoaded();
  }

  final List<FloatingObject> objects;
  final double animationSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final cache = BakedDolphinSpriteCache.instance;
    if (!cache.ready) return;

    final bodySrc = Rect.fromLTWH(
      0,
      0,
      cache.bodyFrames.first.width.toDouble(),
      cache.bodyFrames.first.height.toDouble(),
    );

    for (final object in objects) {
      if (object.token.shape != ShapeKind.dolphin) continue;

      final progress = object.isPopping
          ? (object.popElapsed / 0.18).clamp(0.0, 1.0).toDouble()
          : 0.0;
      final scale = object.isPopping ? 1.0 + progress * 0.34 : 1.0;
      final opacity =
          object.isPopping ? (1.0 - progress).clamp(0.0, 1.0).toDouble() : 1.0;

      final width = object.radius * 2.95 * scale;
      final height = object.radius * 2.62 * scale;

      final frame =
          ((animationSeconds * 18.0 + object.id * 2.15).floor()) %
              bakedDolphinFrameCount;

      final body = cache.bodyFrames[frame];
      final accent = cache.accentFrames[frame];
      final tint = _dolphinTone(object.token.tone);

      canvas.save();
      canvas.translate(object.position.dx, object.position.dy);

      final facesLeft = object.velocity.dx < -1.5;
      if (facesLeft) {
        canvas.scale(-1, 1);
      }

      canvas.rotate(object.rotation * 0.12);

      final dst = Rect.fromCenter(
        center: Offset.zero,
        width: width,
        height: height,
      );

      canvas.drawImageRect(
        body,
        bodySrc,
        dst,
        Paint()
          ..filterQuality = FilterQuality.high
          ..colorFilter = ColorFilter.mode(
            tint.withValues(alpha: opacity),
            BlendMode.modulate,
          ),
      );

      canvas.drawImageRect(
        accent,
        bodySrc,
        dst,
        Paint()
          ..filterQuality = FilterQuality.high
          ..color = Colors.white.withValues(alpha: opacity),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant BakedDolphinSpritePainter oldDelegate) {
    return true;
  }
}

Color _dolphinTone(ShapeTone tone) {
  return switch (tone) {
    ShapeTone.pink => const Color(0xFFFF7FC6),
    ShapeTone.blue => const Color(0xFF66B8FF),
    ShapeTone.yellow => const Color(0xFFFFD05A),
    ShapeTone.purple => const Color(0xFFAC86FF),
    ShapeTone.mint => const Color(0xFF70E7C2),
    ShapeTone.black => const Color(0xFF4C4E58),
    ShapeTone.white => const Color(0xFFF2F4FF),
  };
}
