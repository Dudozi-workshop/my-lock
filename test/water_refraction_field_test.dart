import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import '../shape_lab/water_refraction_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  WaterRefractionField field() => WaterRefractionField(
    colors: const [ui.Color(0xFF0754A3), ui.Color(0xFF138BD3), ui.Color(0xFF20CCD7), ui.Color(0xFF9AF0F3)],
    speed: 1.28, refraction: .92, cellScale: 3.7, light: .72, seed: 29,
  );

  test('58px field changes color and illumination within two seconds', () {
    final f = field();
    var changed = 0, sum = 0.0;
    for (var y = 0; y < 58; y++) {
      for (var x = 0; x < 58; x++) {
        final a = f.sample(x / 57, y / 57, .2);
        final b = f.sample(x / 57, y / 57, 2.2);
        final delta = ((a.r - b.r).abs() + (a.g - b.g).abs() + (a.b - b.b).abs()) / 3;
        if (delta > .04) changed++;
        sum += delta;
        expect(a.a, 1);
      }
    }
    expect(changed / (58 * 58), greaterThan(.35));
    expect(sum / (58 * 58), greaterThan(.06));
    // Objective temporal difference alone does not certify an ocean impression.
  });

  test('frozen frame reuses mesh; subsequent frame updates it', () {
    final f = field();
    final a = f.mesh(1.0);
    expect(identical(a, f.mesh(1.001)), isTrue);
    expect(identical(a, f.mesh(1.1)), isFalse);
  });

  test('actual 58px vertex raster contains a continuous colored field', () async {
    final f = field();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)..scale(58, 58);
    canvas.drawVertices(f.mesh(.4), ui.BlendMode.src, ui.Paint());
    final picture = recorder.endRecording();
    final image = await picture.toImage(58, 58);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final rgba = bytes.buffer.asUint8List();
    final reds = <int>{};
    for (var i = 0; i < rgba.length; i += 4) {
      expect(rgba[i + 3], 255);
      reds.add(rgba[i]);
    }
    expect(reds.length, greaterThan(25));
    image.dispose();
    picture.dispose();
  });
}
