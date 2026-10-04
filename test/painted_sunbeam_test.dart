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
}
