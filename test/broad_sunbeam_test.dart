import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../shape_lab/background_easy_effects.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<Uint8List> frame(double phase, int height) async {
    final recorder = ui.PictureRecorder();
    VolumetricLightPainter(
      animation: AlwaysStoppedAnimation(phase),
      profile: const VolumetricLightProfile(
        mode: VolumetricLightMode.broadCalm,
        energy: 1, drift: .045, width: .24, depth: .64,
      ),
    ).paint(ui.Canvas(recorder), ui.Size(180, height.toDouble()));
    final picture = recorder.endRecording();
    final image = await picture.toImage(180, height);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer.asUint8List();
    image.dispose();
    picture.dispose();
    return bytes;
  }

  test('A produces readable upper light and leaves the floor untouched', () async {
    for (final height in [320, 420]) {
      final pixels = await frame(0, height);
      var peakAlpha = 0;
      var floorAlpha = 0;
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < 180; x++) {
          final alpha = pixels[(y * 180 + x) * 4 + 3];
          if (y < height * .2 && alpha > peakAlpha) peakAlpha = alpha;
          if (y > height * .66) floorAlpha += alpha;
        }
      }
      expect(peakAlpha, greaterThan(55));
      expect(floorAlpha, 0);
    }
  });

  test('A changes in two seconds and its loop has no discontinuity', () async {
    final a = await frame(0, 320);
    final b = await frame(2 / 24, 320);
    final end = await frame(1, 320);
    var changed = 0;
    for (var i = 3; i < a.length; i += 4) {
      if ((a[i] - b[i]).abs() > 4) changed++;
      expect((a[i] - end[i]).abs(), lessThanOrEqualTo(1));
    }
    expect(changed, greaterThan(180 * 320 * .08));
    // Temporal pixel change is evidence of motion, not art approval.
  });
}
