import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/floating_engine.dart';
import 'package:my_lock/lock_engine/models.dart';

void main() {
  test('engine seeds nine objects on first layout', () {
    final engine = FloatingEngine(seed: 1);
    engine.resize(const Size(320, 480));

    expect(engine.objects.length, FloatingEngine.defaultObjectCount);
  });

  test('objects remain inside bounds after stepping', () {
    final engine = FloatingEngine(seed: 2);
    const size = Size(320, 480);
    engine.resize(size);

    for (var i = 0; i < 600; i++) {
      engine.step(1 / 60);
    }

    for (final object in engine.objects) {
      expect(object.position.dx, greaterThanOrEqualTo(object.radius));
      expect(
        object.position.dx,
        lessThanOrEqualTo(size.width - object.radius),
      );
      expect(object.position.dy, greaterThanOrEqualTo(object.radius));
      expect(
        object.position.dy,
        lessThanOrEqualTo(size.height - object.radius),
      );
    }
  });

  test('selection filters every spawned token immediately', () {
    final engine = FloatingEngine(seed: 3);
    engine.resize(const Size(320, 480));
    engine.setSelection(
      {ShapeKind.circle},
      {ShapeTone.pink},
    );

    expect(engine.objects.length, FloatingEngine.defaultObjectCount);
    expect(
      engine.objects.every(
        (object) =>
            object.token.shape == ShapeKind.circle &&
            object.token.tone == ShapeTone.pink,
      ),
      isTrue,
    );
  });

  test('empty selection input is rejected and current tokens remain', () {
    final engine = FloatingEngine(seed: 4);
    engine.resize(const Size(320, 480));
    final before = engine.objects.map((object) => object.token.id).toList();

    engine.setSelection(<ShapeKind>{}, {ShapeTone.blue});

    expect(engine.objects.map((object) => object.token.id).toList(), before);
  });
}
