import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_spec/candy_soft_candidate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('approved atlas decodes and all three source slot edges are transparent', () async {
    final data = await rootBundle.load('assets/raster_shapes/candy_soft/approved_direction_atlas.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final image = (await codec.getNextFrame()).image;
    expect(image.width, 2172);
    expect(image.height, 724);
    final pixels = (await image.toByteData())!;
    for (var slot = 0; slot < 3; slot++) {
      for (var n = 0; n < 724; n++) {
        for (final point in [[slot * 724, n], [slot * 724 + 723, n], [slot * 724 + n, 0], [slot * 724 + n, 723]]) {
          expect(pixels.getUint8((point[1] * 2172 + point[0]) * 4 + 3), 0);
        }
      }
    }
    image.dispose(); codec.dispose();
  });
  test('candidate never substitutes a password tone or overrides Crayon', () async {
    await CandySoftCandidate.instance.load();
    final recorder = ui.PictureRecorder(); final canvas = ui.Canvas(recorder);
    bool paint(ShapeTone tone, ShapeStyle style) => CandySoftCandidate.instance.paint(canvas,
      center: const ui.Offset(64,64), radius: 29,
      token: LockToken(shape: ShapeKind.circle, tone: tone),
      style: style, opacity: 1, rotation: .4);
    expect(paint(ShapeTone.blue, ShapeStyle.softBasic), false);
    expect(paint(ShapeTone.pink, ShapeStyle.crayonSoft), false);
    expect(paint(ShapeTone.pink, ShapeStyle.softBasic), CandySoftCandidate.enabled);
    final picture = recorder.endRecording();
    final image = await picture.toImage(128,128);
    final pixels = (await image.toByteData())!;
    if (CandySoftCandidate.enabled) {
      expect(pixels.getUint8((64 * 128 + 64) * 4 + 3), greaterThan(0));
    }
    for (var n = 0; n < 128; n++) {
      expect(pixels.getUint8(n * 4 + 3), 0);
      expect(pixels.getUint8((127 * 128 + n) * 4 + 3), 0);
    }
    image.dispose(); picture.dispose();
  });
}
