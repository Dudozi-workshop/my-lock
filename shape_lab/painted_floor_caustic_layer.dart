import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'background_asset_registry.dart';

/// R29 candidate. Static direction selected; motion awaits Live review.
/// Keep inactive until canonical binary and registry registration complete.
class PaintedFloorCausticLayer extends StatefulWidget {
  const PaintedFloorCausticLayer({super.key, required this.animation});
  final Animation<double> animation;
  @override
  State<PaintedFloorCausticLayer> createState() => _PaintedFloorCausticLayerState();
}

class _PaintedFloorCausticLayerState extends State<PaintedFloorCausticLayer> {
  ui.Image? _image;
  Object? _error;
  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    ui.Image? decoded;
    try {
      final record = BackgroundAssetRegistry.instance.resolve(
        'background.drop01.shallow_clear.floor_caustic_static_v1',
      );
      final bytes = await rootBundle.load(record.runtimePath!);
      final codec = await ui.instantiateImageCodec(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      try { decoded = (await codec.getNextFrame()).image; }
      finally { codec.dispose(); }
      if (!mounted) { decoded.dispose(); return; }
      setState(() => _image = decoded);
    } catch (error) {
      decoded?.dispose();
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() { _image?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return const Center(child: Text('바닥빛 레이어 로드 실패'));
    }
    final image = _image;
    if (image == null) return const Center(child: CircularProgressIndicator());
    return RepaintBoundary(child: CustomPaint(
      painter: PaintedFloorCausticPainter(image, widget.animation),
    ));
  }
}

/// Matches Image.asset(..., fit: BoxFit.cover, alignment: center) exactly.
/// Image-only bands use the CPU web-compatible path established in TS-008.
class PaintedFloorCausticPainter extends CustomPainter {
  PaintedFloorCausticPainter(this.image, this.animation) : super(repaint: animation);
  final ui.Image image;
  /// Caller supplies a repeating 24-second clock; phase 0 is the static study.
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final phase = animation.value * 2 * math.pi;
    final scale = math.max(size.width/image.width, size.height/image.height);
    final width = image.width*scale;
    final height = image.height*scale;
    final left = (size.width-width)/2;
    final originY = (size.height-height)/2;
    final floorStart = math.max(0.0, (originY+height*.655).floorToDouble());
    if (floorStart >= size.height) return;
    final floorRect = Rect.fromLTRB(0, floorStart, size.width, size.height);
    final source = Rect.fromLTWH(0,0,image.width.toDouble(),image.height.toDouble());
    final paint = Paint()..filterQuality = FilterQuality.medium;
    canvas.save();
    canvas.clipRect(floorRect, doAntiAlias: false);
    canvas.saveLayer(floorRect, Paint());
    const bands = 48;
    for (var band=0; band<bands; band++) {
      final top = (floorStart+(size.height-floorStart)*band/bands).floorToDouble();
      final bottom = band==bands-1 ? size.height :
          (floorStart+(size.height-floorStart)*(band+1)/bands).floorToDouble();
      if (bottom<=top) continue;
      final canonicalY = ((top+bottom)/2-originY)/height;
      final depth = ((canonicalY-.655)/.345).clamp(0.0,1.0);
      final shift = width*depth*(.009*math.sin(phase*3)*math.sin(canonicalY*19)+
          .004*math.sin(phase*5)*math.cos(canonicalY*31));
      final stretch = 1+depth*.025*math.sin(phase*4)*math.sin(canonicalY*17);
      final vertical = height*depth*.0015*math.sin(phase*5)*math.cos(canonicalY*23);
      final alpha = 1-.26*(.5-.5*math.cos(phase*3))*
          (.5+.5*math.sin(phase*4+canonicalY*19));
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0,top,size.width,bottom),doAntiAlias:false);
      canvas.drawImageRect(image,source,
        Rect.fromLTWH(left+shift-width*(stretch-1)/2,originY+vertical,
          width*stretch,height),paint);
      canvas.restore();
    }
    // Different local bright regions; at phase zero this mask is exactly one.
    final strength = .30*(.5-.5*math.cos(phase*2));
    const samples = 24;
    canvas.drawRect(floorRect,Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = ui.Gradient.linear(Offset.zero,Offset(size.width,0),
        [for(var i=0;i<=samples;i++) Colors.white.withValues(alpha:
          1-strength*(.5+.5*math.sin(i/samples*math.pi*5-phase*3)))],
        [for(var i=0;i<=samples;i++) i/samples]));
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(PaintedFloorCausticPainter oldDelegate) =>
      oldDelegate.image!=image || oldDelegate.animation!=animation;
}
