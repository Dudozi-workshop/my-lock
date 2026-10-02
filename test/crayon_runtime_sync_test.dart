import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => ShapeSpecRegistry.instance.load());

  test('Production Crayon reads the approved wax, dropout and contour preset', () {
    final config = ShapeSpecRegistry.instance
        .resolve(ShapeStyle.crayonSoft, ShapeKind.square).style.crayon!;
    expect(config.strokeBuiltSurface, isTrue);
    expect(config.broadStrokeCount, 19);
    expect(config.internalGapChance, 0.105);
    expect(config.paperToothCount, 26);
    expect(config.contourBaseWidth, 3.65);
    expect(config.contourGapCount, 14);
  });

  test('Production bootstrap decodes the active padded raster asset', () async {
    await ShapeSpecRegistry.instance.loadRasterShapes();
    final image = ShapeSpecRegistry.instance.resolveRasterShape(ShapeKind.seaTurtle);
    expect(image.width, 58);
    expect(image.height, 58);
    final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer.asUint8List();
    for (var i = 0; i < 58; i++) {
      for (final pixel in [i, 57 * 58 + i, i * 58, i * 58 + 57]) {
        expect(rgba[pixel * 4 + 3], 0);
      }
    }
  });

  test('Approved Crayon renders all basic shapes deterministically at 58px', () async {
    Future<List<int>> render(ShapeKind shape, ShapeTone tone) async {
      final recorder = ui.PictureRecorder();
      ShapeSpecRenderer.paintToken(Canvas(recorder),
        center: const Offset(48, 48), radius: 29,
        token: LockToken(shape: shape, tone: tone),
        style: ShapeStyle.crayonSoft, opacity: 1);
      final picture = recorder.endRecording();
      final image = await picture.toImage(96, 96);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final pixels = data!.buffer.asUint8List().toList();
      image.dispose();
      picture.dispose();
      return pixels;
    }
    for (final shape in ShapeKind.defaults) {
      for (final tone in ShapeTone.defaults) {
        final first = await render(shape, tone);
        expect(await render(shape, tone), first);
        expect(first.where((value) => value > 0).length, greaterThan(1000));
        for (var i = 0; i < 96; i++) {
          for (final index in [i, 95 * 96 + i, i * 96, i * 96 + 95]) {
            expect(first[index * 4 + 3], 0);
          }
        }
      }
    }
  });
}
