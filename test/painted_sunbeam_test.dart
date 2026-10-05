import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';
import '../shape_lab/painted_sunbeam_layer.dart';
import 'package:flutter_test/flutter_test.dart';
import '../shape_lab/background_asset_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('A texture decodes, preserves blue gaps and ends above the floor', () async {
    final registry = await BackgroundAssetRegistry.load();
    final path = registry.resolve('background.drop01.shallow_clear.volumetric_a_texture_study_r22').runtimePath!;
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final image = (await codec.getNextFrame()).image;
    codec.dispose();
    expect(image.width, 293);
    expect(image.height, 436);
    final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final row = [for (var x = 0; x < image.width; x++) rgba.getUint8((100 * image.width + x) * 4 + 3)];
    expect(row.reduce(math.max) - row.reduce(math.min), greaterThan(40));
    for (var y = 288; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        expect(rgba.getUint8((y * image.width + x) * 4 + 3), 0);
      }
    }
    image.dispose();
  });
  test('A actual Canvas image painter changes within two seconds and closes the loop', () async {
    final registry = await BackgroundAssetRegistry.load();
    final data = await rootBundle.load(registry.resolve(
      'background.drop01.shallow_clear.volumetric_a_texture_study_r22',
    ).runtimePath!);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final texture = (await codec.getNextFrame()).image;
    codec.dispose();
    Future<List<int>> frame(double phase) async {
      final recorder = ui.PictureRecorder();
      PaintedSunbeamPainter(texture, AlwaysStoppedAnimation(phase / (math.pi * 2)))
          .paint(ui.Canvas(recorder), const ui.Size(180, 320));
      final picture = recorder.endRecording();
      final image = await picture.toImage(180, 320);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List().toList();
      image.dispose(); picture.dispose();
      return bytes;
    }
    final start = await frame(0);
    final later = await frame(math.pi * 2 * 2 / 24);
    final loop = await frame(math.pi * 2);
    var changed = 0;
    var strongChanged = 0;
    var largestLoopDifference = 0;
    for (var i = 3; i < start.length; i += 4) {
      if ((later[i] - start[i]).abs() > 2) changed++;
      if ((later[i] - start[i]).abs() >= 10) strongChanged++;
      largestLoopDifference = math.max(largestLoopDifference, (loop[i] - start[i]).abs());
      if (i ~/ 4 ~/ 180 >= 212) expect(later[i], 0);
    }
    expect(changed, greaterThan(200));
    expect(strongChanged, greaterThan(800));
    expect(largestLoopDifference, lessThanOrEqualTo(1));
    texture.dispose();
  });

  test('motion A-C are visible, distinct, loop cleanly and preserve floor cutoff', () async {
    final registry = await BackgroundAssetRegistry.load();
    final data = await rootBundle.load(registry.resolve(
      'background.drop01.shallow_clear.volumetric_a_texture_study_r22',
    ).runtimePath!);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final texture = (await codec.getNextFrame()).image;
    codec.dispose();
    Future<List<int>> frame(SunbeamMotion motion, double time) async {
      final recorder = ui.PictureRecorder();
      PaintedSunbeamPainter(texture, AlwaysStoppedAnimation(time / 24), motion: motion)
          .paint(ui.Canvas(recorder), const ui.Size(180, 320));
      final picture = recorder.endRecording();
      final image = await picture.toImage(180, 320);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List().toList();
      image.dispose(); picture.dispose();
      return bytes;
    }
    final candidates = [SunbeamMotion.flow, SunbeamMotion.fan, SunbeamMotion.breathe];
    final laterFrames = <List<int>>[];
    for (final motion in candidates) {
      final start = await frame(motion, 0);
      final later = await frame(motion, 2);
      final loop = await frame(motion, 24);
      laterFrames.add(later);
      var changed = 0;
      var visible = 0;
      var loopDifference = 0;
      for (var i = 3; i < start.length; i += 4) {
        if ((later[i] - start[i]).abs() >= 8) changed++;
        if (later[i] >= 12) visible++;
        loopDifference = math.max(loopDifference, (loop[i] - start[i]).abs());
        if (i ~/ 4 ~/ 180 >= 212) expect(later[i], 0, reason: motion.label);
      }
      expect(changed, greaterThan(800), reason: motion.label);
      expect(visible, greaterThan(1500), reason: motion.label);
      expect(loopDifference, lessThanOrEqualTo(1), reason: motion.label);
    }
    for (var a = 0; a < candidates.length; a++) {
      for (var b = a + 1; b < candidates.length; b++) {
        var different = 0;
        for (var i = 3; i < laterFrames[a].length; i += 4) {
          if ((laterFrames[a][i] - laterFrames[b][i]).abs() >= 8) different++;
        }
        expect(different, greaterThan(800), reason: '${candidates[a].label} vs ${candidates[b].label}');
      }
    }
    texture.dispose();
  });

}
