import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
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

/// Standard image shader + shared-edge mesh, including CPU web rendering.
class PaintedSunbeamPainter extends CustomPainter {
  PaintedSunbeamPainter(this.image, this.animation) : super(repaint: animation);
  final ui.Image image;
  final Animation<double> animation;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final phase = animation.value * math.pi * 2;
    final positions = <Offset>[];
    final coordinates = <Offset>[];
    final colors = <Color>[];
    final indices = <int>[];
    const rows = 64;
    const columns = 8;
    for (var row = 0; row <= rows; row++) {
      final y = row / rows;
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
      for (var col = 0; col <= columns; col++) {
        final x = col / columns;
        positions.add(Offset(size.width * (.5 + (x - .5) * stretch + shift),
          size.height * (y + vertical)));
        coordinates.add(Offset(x * image.width, y * image.height));
        colors.add(Colors.white.withValues(alpha: alpha));
        if (row < rows && col < columns) {
          final i = row * (columns + 1) + col;
          indices.addAll([i, i + 1, i + columns + 1,
            i + 1, i + columns + 2, i + columns + 1]);
        }
      }
    }
    final shader = ui.ImageShader(image, TileMode.clamp, TileMode.clamp,
      Float64List.fromList([1, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 1, 0, 0, 0, 0, 1]), filterQuality: FilterQuality.medium);
    final mesh = ui.Vertices(VertexMode.triangles, positions,
      textureCoordinates: coordinates, colors: colors, indices: indices);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawVertices(mesh, BlendMode.modulate, Paint()..shader = shader);
    canvas.restore();
    mesh.dispose();
    shader.dispose();
  }
  @override
  bool shouldRepaint(PaintedSunbeamPainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.animation != animation;
}
