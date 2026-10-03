import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Drop 01 palette matches the locked 2D Soft color spec', () {
    expect(ShapeTone.drop01Palette, {
      ShapeTone.deepOcean,
      ShapeTone.aquaMint,
      ShapeTone.coralPink,
      ShapeTone.sandBeige,
      ShapeTone.lavender,
      ShapeTone.peachOrange,
    });
    expect(ShapeTone.drop01Signature, ShapeTone.auroraSea);

    expect(baseColorForTone(ShapeTone.deepOcean), const Color(0xFF4F8EDB));
    expect(baseColorForTone(ShapeTone.aquaMint), const Color(0xFF7CCFC4));
    expect(baseColorForTone(ShapeTone.coralPink), const Color(0xFFF7A7B5));
    expect(baseColorForTone(ShapeTone.sandBeige), const Color(0xFFEFD59A));
    expect(baseColorForTone(ShapeTone.lavender), const Color(0xFFB9A7E8));
    expect(baseColorForTone(ShapeTone.peachOrange), const Color(0xFFF7B385));

    expect(ShapeTone.drop01Palette.every((tone) => tone.directSale), isTrue);
    expect(ShapeTone.auroraSea.premium, isTrue);
    expect(ShapeTone.auroraSea.directSale, isFalse);
  });

  test('Aurora Sea uses the locked three-color signature gradient', () {
    final gradient = ShapeSpecRenderer.auroraSeaGradient(0);
    expect(gradient.colors, const [
      Color(0xFFA7D8F7),
      Color(0xFF7FB8FF),
      Color(0xFFC7B6F3),
      Color(0xFFA7D8F7),
    ]);
  });

  group('vector palette rendering', () {
    setUpAll(() async {
      await ShapeSpecRegistry.instance.load();
    });

    Future<Uint8List> render(ShapeTone tone, double time) async {
      final recorder = ui.PictureRecorder();
      ShapeSpecRenderer.paintToken(
        Canvas(recorder),
        center: const Offset(64, 64),
        radius: 29,
        token: LockToken(shape: ShapeKind.circle, tone: tone),
        style: ShapeStyle.softBasic,
        opacity: 1,
        paletteTimeSeconds: time,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(128, 128);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      picture.dispose();
      return data!.buffer.asUint8List();
    }

    test('static Drop 01 colors remain stable over time', () async {
      for (final tone in ShapeTone.drop01Palette) {
        expect(await render(tone, 0), equals(await render(tone, 2)));
      }
    });

    test('Aurora Sea moves without changing vector alpha', () async {
      final before = await render(ShapeTone.auroraSea, 0);
      final after = await render(ShapeTone.auroraSea, 2);
      var changed = 0;
      for (var i = 0; i < before.length; i += 4) {
        expect(before[i + 3], after[i + 3]);
        if (before[i + 3] > 0 &&
            (before[i] != after[i] ||
                before[i + 1] != after[i + 1] ||
                before[i + 2] != after[i + 2])) {
          changed++;
        }
      }
      expect(changed, greaterThan(100));
    });
  });
}
