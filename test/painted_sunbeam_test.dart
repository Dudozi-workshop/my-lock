import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
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
  test('A shader changes within two seconds and closes the loop', () async {
    final registry = await BackgroundAssetRegistry.load();
    final data = await rootBundle.load(registry.resolve(
      'background.drop01.shallow_clear.volumetric_a_texture_study_r22',
    ).runtimePath!);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final texture = (await codec.getNextFrame()).image;
    codec.dispose();
    final program = await ui.FragmentProgram.fromAsset('shaders/volumetric_texture.frag');
    final shader = program.fragmentShader()..setImageSampler(0, texture);
    Future<List<int>> frame(double phase) async {
      shader..setFloat(0, 180)..setFloat(1, 320)..setFloat(2, phase);
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawRect(const ui.Rect.fromLTWH(0, 0, 180, 320), ui.Paint()..shader = shader);
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
    shader.dispose(); texture.dispose();
  });

}
