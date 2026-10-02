import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await ShapeSpecRegistry.instance.load();
    await ShapeSpecRegistry.instance.loadRasterShapes();
  });

  Future<Uint8List> render(
    ShapeTone tone,
    double time, {
    double rotation = 0,
    double scale = 1,
  }) async {
    final recorder = ui.PictureRecorder();
    ShapeSpecRenderer.paintToken(
      Canvas(recorder),
      center: const Offset(96, 96),
      radius: 29 * scale,
      token: LockToken(shape: ShapeKind.seaTurtle, tone: tone),
      style: ShapeStyle.softBasic,
      opacity: 1,
      objectRotation: rotation,
      paletteTimeSeconds: time,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(192, 192);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    picture.dispose();
    return data!.buffer.asUint8List();
  }

  test(
    'Runtime master is 256px with metadata framing and transparent edges',
    () async {
      final spec = ShapeSpecRegistry.instance.resolveRasterSpec(
        ShapeKind.seaTurtle,
      );
      expect(spec.master.width, 256);
      expect(spec.master.height, 256);
      expect(spec.metadata.safetyPaddingRatio, greaterThanOrEqualTo(0.125));
      final destination = spec.metadata.destination(const Offset(100, 100), 29);
      final scale = destination.width / 256;
      expect(spec.metadata.contentBbox.width * scale, closeTo(58, 0.0001));
      final rgba = (await spec.master.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      for (var i = 0; i < 256; i++) {
        for (final index in [i, 255 * 256 + i, i * 256, i * 256 + 255]) {
          expect(rgba[index * 4 + 3], 0);
        }
      }
    },
  );

  test('Palette animation changes color without changing shape alpha or fixed finish', () async {
    final before = await render(ShapeTone.auroraSea, 0);
    final after = await render(ShapeTone.auroraSea, 2);
    var changed = 0;
    for (var i = 0; i < before.length; i += 4) {
      expect(before[i + 3], after[i + 3]);
      if (before[i + 3] > 0 && before[i] != after[i]) changed++;
      if (before[i + 3] == 0) expect(before.sublist(i, i + 3), [0, 0, 0]);
    }
    expect(changed, greaterThan(100));
    for (final tone in ShapeTone.defaults) {
      expect(await render(tone, 0), equals(await render(tone, 2)));
    }
    expect(
      await render(ShapeTone.auroraSea, 0),
      equals(await render(ShapeTone.auroraSea, 8)),
    );
  });

  test(
    '58px / rotation / maximum POP keep transparent canvas boundary',
    () async {
      for (final tone in ShapeTone.values) {
        for (final angle in [0.0, 0.7, 1.57, 2.4]) {
          final rgba = await render(tone, 1.5, rotation: angle, scale: 1.42);
          var visible = 0;
          for (var y = 0; y < 192; y++) {
            for (var x = 0; x < 192; x++) {
              final alpha = rgba[(y * 192 + x) * 4 + 3];
              if (alpha > 0) visible++;
              if (x < 20 || y < 20 || x >= 172 || y >= 172) expect(alpha, 0);
            }
          }
          expect(visible, greaterThan(500));
        }
      }
    },
  );
}
