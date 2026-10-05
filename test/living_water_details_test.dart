import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import '../shape_lab/living_water_details.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final bubbles in [false, true]) {
    test('${bubbles ? "Bubbles" : "Particles"} visibly move, stay sparse and close the loop', () async {
      Future<List<int>> frame(double seconds) async {
        final recorder = ui.PictureRecorder();
        final animation = AlwaysStoppedAnimation(seconds / 18);
        final CustomPainter painter = bubbles
            ? LivingBubblePainter(animation: animation)
            : LivingParticlePainter(animation: animation);
        painter.paint(ui.Canvas(recorder), const ui.Size(240, 360));
        final picture = recorder.endRecording();
        final image = await picture.toImage(240, 360);
        final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List().toList();
        image.dispose(); picture.dispose();
        return rgba;
      }
      final start = await frame(0);
      final later = await frame(2);
      final loop = await frame(18);
      var visible = 0;
      var changed = 0;
      var loopDiff = 0;
      for (var i = 3; i < start.length; i += 4) {
        if (later[i] > 12) visible++;
        if ((later[i] - start[i]).abs() > 12) changed++;
        loopDiff = math.max(loopDiff, (start[i] - loop[i]).abs());
      }
      expect(visible, greaterThan(80));
      expect(visible, lessThan(240 * 360 * .04));
      expect(changed, greaterThan(120));
      expect(loopDiff, lessThanOrEqualTo(2));
      // Wrap positions fade in/out; crossing the loop cannot pop a bubble.
      final before = await frame(17.999);
      final after = await frame(.001);
      var wrapChanged = 0;
      for (var i = 3; i < before.length; i += 4) {
        if ((before[i] - after[i]).abs() > 12) wrapChanged++;
      }
      expect(wrapChanged, lessThan(30));
    });
  }
}
