import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'background_asset_registry.dart';

enum SunbeamMotion { baseline, flow, fan, breathe }

extension SunbeamMotionLabel on SunbeamMotion {
  String get label => switch (this) {
    SunbeamMotion.baseline => '기존 R26',
    SunbeamMotion.flow => 'A · 옆 줄기로 흐름',
    SunbeamMotion.fan => 'B · 부채꼴 펼침',
    SunbeamMotion.breathe => 'C · 호흡과 잔빛',
  };
  String get description => switch (this) {
    SunbeamMotion.baseline => '기존 움직임 · 비교 기준',
    SunbeamMotion.flow => '밝은 구간이 좌우 줄기를 따라 이동 · 밝기 대비 4배 · 주기 8초',
    SunbeamMotion.fan => '위쪽 도입점은 유지 · 아래쪽 폭이 크게 벌어지고 모임 · 주기 8초',
    SunbeamMotion.breathe => '전체 빛의 밝기가 크게 호흡 · 안쪽 잔빛은 다른 속도로 일렁임 · 주기 6초',
  };
}

/// LABS reference-density study. Not an approved Production light master.
class PaintedSunbeamLayer extends StatefulWidget {
  const PaintedSunbeamLayer({super.key, required this.animation, this.motion = SunbeamMotion.baseline});
  final Animation<double> animation;
  final SunbeamMotion motion;
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
      painter: PaintedSunbeamPainter(image, widget.animation, motion: widget.motion),
    ));
  }
}

/// Uses only drawImageRect; compatible with CPU-only web rendering.
/// Clip full-image draws into integer-aligned bands to avoid sampled edges.
class PaintedSunbeamPainter extends CustomPainter {
  PaintedSunbeamPainter(this.image, this.animation, {this.motion = SunbeamMotion.baseline}) : super(repaint: animation);
  final ui.Image image;
  final Animation<double> animation;
  final SunbeamMotion motion;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final phase = animation.value * math.pi * 2;
    final source = Rect.fromLTWH(0, 0,
      image.width.toDouble(), image.height.toDouble());
    final paint = Paint()..filterQuality = FilterQuality.medium;
    // Flow uses a conventional Canvas gradient alpha mask, never ImageShader.
    if (motion == SunbeamMotion.flow) {
      canvas.saveLayer(Offset.zero & size, Paint());
    }
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
      var shift = envelope * (.020 * (math.sin(phase * 5 + a) - math.sin(a)) +
          .007 * (math.sin(phase * 3 + b) - math.sin(b)));
      var stretch = 1 + envelope * .025 *
          (math.sin(phase * 3 + a) - math.sin(a));
      var vertical = envelope * .007 *
          (math.sin(phase * 3 + a) - math.sin(a));
      var alpha = (1 + .18 *
          (math.sin(phase * 5 + a) - math.sin(a))).clamp(.55, 1.0);
      switch (motion) {
        case SunbeamMotion.baseline:
          break;
        case SunbeamMotion.flow:
          shift = envelope * .012 * math.sin(phase * 3 + y * 7);
          stretch = 1 + envelope * .012 * math.sin(phase * 5 - y * 4);
          vertical = 0;
          alpha = 1;
          break;
        case SunbeamMotion.fan:
          // Symmetric fan: one coherent perspective, not random beam angles.
          final depth = (y / .5).clamp(0.0, 1.0);
          stretch = 1 + envelope * depth * .24 * math.sin(phase * 3);
          shift = 0;
          vertical = 0;
          alpha = .85 + .15 * math.sin(phase * 3 + .6);
          break;
        case SunbeamMotion.breathe:
          shift = envelope * (.018 * math.sin(phase * 7 + y * 13) +
              .009 * math.sin(phase * 11 - y * 8));
          stretch = 1 + envelope * .025 * math.sin(phase * 7 + y * 11);
          vertical = 0;
          alpha = (.22 + .78 * (.5 + .5 * math.sin(phase * 4)) +
              .09 * math.sin(phase * 9 + y * 19)).clamp(.15, 1.0);
          break;
      }
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, top, size.width, bottom),
        doAntiAlias: false);
      canvas.drawImageRect(image, source,
        Rect.fromLTWH(size.width * (shift - (stretch - 1) / 2),
          -vertical * size.height, size.width * stretch, size.height), paint);
      canvas.restore();
    }
    if (motion == SunbeamMotion.flow) {
      const samples = 24;
      final mask = Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = ui.Gradient.linear(
          Offset.zero, Offset(size.width, 0),
          [for (var i = 0; i <= samples; i++)
            Colors.white.withValues(alpha: .25 + .75 *
              (.5 + .5 * math.sin(i / samples * math.pi * 4 - phase * 3)))],
          [for (var i = 0; i <= samples; i++) i / samples],
        );
      canvas.drawRect(Offset.zero & size, mask);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(PaintedSunbeamPainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.animation != animation ||
      oldDelegate.motion != motion;
}
