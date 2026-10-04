import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_spec/candy_soft_runtime.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await ShapeSpecRegistry.instance.load();
    await CandySoftRuntime.instance.load();
  });
  Future<List<int>> render(ShapeKind shape, ShapeTone tone, {
    bool candidate = true, ShapeStyle style = ShapeStyle.softBasic,
    double rotation = 0, double opacity = 1,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    ShapeSpecRenderer.paintToken(canvas,center:const Offset(32,32),radius:29,
      token:LockToken(shape:shape,tone:tone),style:style,opacity:opacity,
      objectRotation:rotation,candySoftCandidate:candidate);
    final picture = recorder.endRecording();
    final image = await picture.toImage(64,64);
    final bytes = (await image.toByteData(format:ui.ImageByteFormat.rawRgba))!.buffer.asUint8List().toList();
    image.dispose(); picture.dispose(); return bytes;
  }
  test('all nine Candy identities preserve alpha and leave safe canvas edges', () async {
    for(final shape in [ShapeKind.circle,ShapeKind.triangle,ShapeKind.square]) {
      List<int>? alpha;
      final rgb = <List<int>>[];
      for(final tone in [ShapeTone.pink,ShapeTone.blue,ShapeTone.yellow]) {
        final pixels = await render(shape,tone);
        final next = [for(var i=3;i<pixels.length;i+=4) pixels[i]];
        if(alpha != null) expect(next,alpha);
        alpha = next;
        expect(next.where((v)=>v>128).length,greaterThan(800));
        for(var i=0;i<64;i++) {
          expect(next[i],0);expect(next[63*64+i],0);
          expect(next[i*64],0);expect(next[i*64+63],0);
        }
        rgb.add(pixels);
      }
      expect(rgb[0],isNot(equals(rgb[1])));
      expect(rgb[1],isNot(equals(rgb[2])));
    }
  });
  test('opt-in never changes Crayon and default painter remains off', () async {
    const token = LockToken(shape:ShapeKind.circle,tone:ShapeTone.pink);
    expect(LockTokenPainter(token).candySoftCandidate,isFalse);
    expect(await render(ShapeKind.circle,ShapeTone.pink,style:ShapeStyle.crayonSoft),
      await render(ShapeKind.circle,ShapeTone.pink,style:ShapeStyle.crayonSoft,candidate:false));
    expect(await render(ShapeKind.circle,ShapeTone.pink),
      isNot(equals(await render(ShapeKind.circle,ShapeTone.pink,candidate:false))));
  });
  test('rotation retains transparency and POP opacity fades the whole token', () async {
    final full = await render(ShapeKind.triangle,ShapeTone.blue,rotation:.7);
    final faded = await render(ShapeKind.triangle,ShapeTone.blue,rotation:.7,opacity:.5);
    expect(full[3],0);expect(full[full.length-1],0);
    var fullAlpha=0;var fadedAlpha=0;
    for(var i=3;i<full.length;i+=4){fullAlpha+=full[i];fadedAlpha+=faded[i];}
    expect(fadedAlpha/fullAlpha,closeTo(.5,.015));
  });
}
