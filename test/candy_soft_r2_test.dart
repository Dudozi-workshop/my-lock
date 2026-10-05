import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/aurora_sea_signature.dart';
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
    double rotation = 0, double opacity = 1, double time = 0,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    ShapeSpecRenderer.paintToken(canvas,center:const Offset(32,32),radius:29,
      token:LockToken(shape:shape,tone:tone),style:style,opacity:opacity,
      objectRotation:rotation,paletteTimeSeconds:time,useCandySoft:candidate);
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
  test('production default uses Candy and preserves Crayon and vector recovery', () async {
    const token = LockToken(shape:ShapeKind.circle,tone:ShapeTone.pink);
    final recorder = ui.PictureRecorder();
    LockTokenPainter(token).paint(Canvas(recorder), const Size(64,64));
    final picture = recorder.endRecording();
    final image = await picture.toImage(64,64);
    final pixels = (await image.toByteData(format:ui.ImageByteFormat.rawRgba))!.buffer.asUint8List().toList();
    image.dispose(); picture.dispose();
    final referenceRecorder = ui.PictureRecorder();
    ShapeSpecRenderer.paintToken(Canvas(referenceRecorder), center:const Offset(32,32), radius:64*.43, token:token, style:ShapeStyle.softBasic, opacity:1);
    final referencePicture = referenceRecorder.endRecording();
    final referenceImage = await referencePicture.toImage(64,64);
    final reference = (await referenceImage.toByteData(format:ui.ImageByteFormat.rawRgba))!.buffer.asUint8List().toList();
    referenceImage.dispose(); referencePicture.dispose();
    expect(pixels, reference);
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
  test('premium tones stay on Candy Soft instead of vector fallback', () async {
    const premiumStatic = [
      ShapeTone.deepOcean,
      ShapeTone.aquaMint,
      ShapeTone.coralPink,
      ShapeTone.sandBeige,
      ShapeTone.lavender,
      ShapeTone.peachOrange,
    ];
    for (final shape in [
      ShapeKind.circle,
      ShapeKind.triangle,
      ShapeKind.square,
    ]) {
      final reference = await render(shape, ShapeTone.pink);
      final referenceAlpha = [
        for (var i = 3; i < reference.length; i += 4) reference[i],
      ];
      for (final tone in premiumStatic) {
        final candy = await render(shape, tone);
        final vector = await render(shape, tone, candidate: false);
        expect(candy, isNot(equals(vector)));
        final alpha = [for (var i = 3; i < candy.length; i += 4) candy[i]];
        expect(alpha, referenceAlpha);
      }
    }
  });

  test('Aurora Sea uses moving H02B on Candy Soft geometry', () async {
    for (final shape in [
      ShapeKind.circle,
      ShapeKind.triangle,
      ShapeKind.square,
    ]) {
      final before = await render(shape, ShapeTone.auroraSea, time: 0);
      final after = await render(shape, ShapeTone.auroraSea, time: 1);
      expect(before, isNot(equals(after)));

      final beforeAlpha = [
        for (var i = 3; i < before.length; i += 4) before[i],
      ];
      final afterAlpha = [
        for (var i = 3; i < after.length; i += 4) after[i],
      ];
      expect(afterAlpha, beforeAlpha);

      final vector = await render(
        shape,
        ShapeTone.auroraSea,
        time: 1,
        candidate: false,
      );
      expect(after, isNot(equals(vector)));
    }
  });

  test('Web-safe Aurora canvas path visibly changes at small runtime size', () async {
    Future<List<int>> renderCanvas(double time) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.saveLayer(
        const Rect.fromLTWH(0, 0, 72, 72),
        Paint(),
      );
      canvas.drawCircle(
        const Offset(36, 36),
        31,
        Paint()..color = Colors.white,
      );
      canvas.save();
      canvas.translate(5, 5);
      canvas.scale(62, 62);
      AuroraSeaSignature.paintIntoCurrentMask(
        canvas,
        time,
        forceCanvasFallback: true,
      );
      canvas.restore();
      canvas.restore();

      final picture = recorder.endRecording();
      final image = await picture.toImage(72, 72);
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!
          .buffer
          .asUint8List()
          .toList();
      image.dispose();
      picture.dispose();
      return bytes;
    }

    final frames = <List<int>>[
      await renderCanvas(0),
      await renderCanvas(0.5),
      await renderCanvas(1.0),
      await renderCanvas(1.5),
      await renderCanvas(2.0),
    ];

    for (var i = 1; i < frames.length; i++) {
      var changedRgb = 0;
      for (var p = 0; p < frames[i].length; p += 4) {
        final delta =
            (frames[i][p] - frames[i - 1][p]).abs() +
            (frames[i][p + 1] - frames[i - 1][p + 1]).abs() +
            (frames[i][p + 2] - frames[i - 1][p + 2]).abs();
        if (delta >= 18) changedRgb++;
      }
      expect(
        changedRgb,
        greaterThan(180),
        reason: '72px Aurora preview must show perceptible H02B motion',
      );
    }
  });

}
