import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/effects.dart';
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
  test('next two required tokens are always visible', () {
    final engine = FloatingEngine(seed: 5);
    engine.resize(const Size(320, 480));

    const filler = LockToken(
      shape: ShapeKind.square,
      tone: ShapeTone.yellow,
    );
    const first = LockToken(
      shape: ShapeKind.circle,
      tone: ShapeTone.pink,
    );
    const second = LockToken(
      shape: ShapeKind.triangle,
      tone: ShapeTone.blue,
    );

    for (final object in engine.objects) {
      object.token = filler;
    }

    engine.setRequiredTokens([first, second]);

    final visibleIds = engine.objects
        .where((object) => !object.isPopping)
        .map((object) => object.token.id)
        .toList();

    expect(visibleIds.where((id) => id == first.id).length, greaterThanOrEqualTo(1));
    expect(visibleIds.where((id) => id == second.id).length, greaterThanOrEqualTo(1));
  });

  test('duplicate next tokens require two visible copies', () {
    final engine = FloatingEngine(seed: 6);
    engine.resize(const Size(320, 480));

    const filler = LockToken(
      shape: ShapeKind.square,
      tone: ShapeTone.yellow,
    );
    const repeated = LockToken(
      shape: ShapeKind.circle,
      tone: ShapeTone.pink,
    );

    for (final object in engine.objects) {
      object.token = filler;
    }

    engine.setRequiredTokens([repeated, repeated]);

    final count = engine.objects
        .where((object) => !object.isPopping && object.token.id == repeated.id)
        .length;

    expect(count, greaterThanOrEqualTo(2));
  });

  test('required token is restored when an existing copy is popping', () {
    final engine = FloatingEngine(seed: 7);
    engine.resize(const Size(320, 480));

    const required = LockToken(
      shape: ShapeKind.circle,
      tone: ShapeTone.pink,
    );

    engine.setRequiredTokens([required]);
    final visible = engine.objects.firstWhere(
      (object) => object.token.id == required.id && !object.isPopping,
    );
    visible.popElapsed = 0;

    engine.setRequiredTokens([required]);

    final count = engine.objects
        .where((object) => !object.isPopping && object.token.id == required.id)
        .length;

    expect(count, greaterThanOrEqualTo(1));
  });  test('object count can switch between supported presets', () {
    final engine = FloatingEngine(seed: 8);
    engine.resize(const Size(320, 480));

    engine.setObjectCount(6);
    expect(engine.objects.length, 6);

    engine.setObjectCount(12);
    expect(engine.objects.length, 12);

    engine.setObjectCount(7);
    expect(engine.objects.length, 12);
  });

  test('speed change rescales current velocity without respawning', () {
    final engine = FloatingEngine(seed: 9);
    engine.resize(const Size(320, 480));

    final firstId = engine.objects.first.id;
    final normalSpeed = engine.objects.first.velocity.distance;

    engine.setSpeed(FloatingSpeed.fast);

    expect(engine.objects.first.id, firstId);
    expect(
      engine.objects.first.velocity.distance,
      closeTo(normalSpeed * FloatingSpeed.fast.multiplier, 0.0001),
    );
  });
}
