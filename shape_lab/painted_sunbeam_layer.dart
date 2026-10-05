import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'background_asset_registry.dart';

/// LABS reference-density study. Not an approved Production light master.
class PaintedSunbeamLayer extends StatefulWidget {
  const PaintedSunbeamLayer({super.key, required this.animation});
  final Animation<double> animation;
  @override
  State<PaintedSunbeamLayer> createState() => _PaintedSunbeamLayerState();
}

class _PaintedSunbeamLayerState extends State<PaintedSunbeamLayer> {
  ui.Image? _image;
  Object? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    ui.Image? decoded;
    try {
      final record = BackgroundAssetRegistry.instance.resolve(
        'background.drop01.shallow_clear.volumetric_a_texture_study_r22',
      );
      final bytes = await rootBundle.load(record.runtimePath!);
      final codec = await ui.instantiateImageCodec(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      try {
        decoded = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
      if (!mounted) {
        decoded.dispose();
        return;
      }
      setState(() => _image = decoded);
    } catch (error) {
      decoded?.dispose();
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return const Center(child: Text('A 텍스처 로드 실패 · R21 비교로 전환해 주세요'));
    }
    final image = _image;
    if (image == null) return const Center(child: CircularProgressIndicator());
    return RepaintBoundary(child: CustomPaint(
      painter: PaintedSunbeamPainter(image, widget.animation),
    ));
  }
}

/// Uses only drawImageRect; compatible with CPU-only web rendering.
/// Clip full-image draws into integer-aligned bands to avoid sampled edges.
class PaintedSunbeamPainter extends CustomPainter {
  PaintedSunbeamPainter(this.image, this.animation) : super(repaint: animation);
  final ui.Image image;
  final Animation<double> animation;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final phase = animation.value * math.pi * 2;
    final source = Rect.fromLTWH(0, 0,
      image.width.toDouble(), image.height.toDouble());
    final paint = Paint()..filterQuality = FilterQuality.medium;
    const bands = 128;
    for (var band = 0; band < bands; band++) {
      final top = (band * size.height / bands).floorToDouble();
      final bottom = band == bands - 1 ? size.height :
          ((band + 1) * size.height / bands).floorToDouble();
      if (bottom <= top) continue;
      final y = (top + bottom) / (2 * size.height);
      final envelope = (y / .08).clamp(0.0, 1.0) *
          (1 - ((y - .35) / .31).clamp(0.0, 1.0));
      final a = y * 4;
      final b = -y * 6;
      final shift = envelope * (.020 * (math.sin(phase * 5 + a) - math.sin(a)) +
          .007 * (math.sin(phase * 3 + b) - math.sin(b)));
      final stretch = 1 + envelope * .025 *
          (math.sin(phase * 3 + a) - math.sin(a));
      final vertical = envelope * .007 *
          (math.sin(phase * 3 + a) - math.sin(a));
      final alpha = (1 + .18 *
          (math.sin(phase * 5 + a) - math.sin(a))).clamp(.55, 1.0);
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, top, size.width, bottom),
        doAntiAlias: false);
      canvas.drawImageRect(image, source,
        Rect.fromLTWH(size.width * (shift - (stretch - 1) / 2),
          -vertical * size.height, size.width * stretch, size.height), paint);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(PaintedSunbeamPainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.animation != animation;
}
