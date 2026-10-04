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
  ui.FragmentShader? _shader;
  Object? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    ui.Image? decoded;
    ui.FragmentShader? shader;
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
      final program = await ui.FragmentProgram.fromAsset('shaders/volumetric_texture.frag');
      shader = program.fragmentShader()..setImageSampler(0, decoded);
      if (!mounted) {
        shader.dispose();
        decoded.dispose();
        return;
      }
      setState(() { _image = decoded; _shader = shader; });
    } catch (error) {
      shader?.dispose();
      decoded?.dispose();
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return const Center(child: Text('A 텍스처 로드 실패 · R21 비교로 전환해 주세요'));
    }
    final shader = _shader;
    if (shader == null) return const Center(child: CircularProgressIndicator());
    return RepaintBoundary(child: CustomPaint(
      painter: _TextureLightPainter(shader, widget.animation),
    ));
  }
}

class _TextureLightPainter extends CustomPainter {
  _TextureLightPainter(this.shader, this.animation) : super(repaint: animation);
  final ui.FragmentShader shader;
  final Animation<double> animation;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, animation.value * math.pi * 2);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }
  @override
  bool shouldRepaint(_TextureLightPainter oldDelegate) =>
      oldDelegate.shader != shader || oldDelegate.animation != animation;
}
