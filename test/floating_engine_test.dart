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



  test('overlap up to ten percent is left untouched by repulsion', () {
    final engine = FloatingEngine(seed: 12);
    engine.resize(const Size(400, 400));
    // Use a profile without autonomous drift so this test isolates only the
    // pair-repulsion threshold.
    engine.setMovementStyle(MovementStyle.zeroGravity);

    final first = engine.objects[0]
      ..radius = 40
      ..position = const Offset(160, 200)
      ..velocity = Offset.zero;
    final second = engine.objects[1]
      ..radius = 40
      ..position = const Offset(236, 200)
      ..velocity = Offset.zero;
    engine.objects.removeRange(2, engine.objects.length);

    final before = (second.position - first.position).distance;
    engine.step(1 / 60);
    final after = (second.position - first.position).distance;

    expect(after, closeTo(before, 0.0001));
  });

  test('moderate overlap is separated gradually', () {
    final engine = FloatingEngine(seed: 13);
    engine.resize(const Size(400, 400));

    final first = engine.objects[0]
      ..radius = 40
      ..position = const Offset(160, 200)
      ..velocity = Offset.zero;
    final second = engine.objects[1]
      ..radius = 40
      ..position = const Offset(224, 200)
      ..velocity = Offset.zero;
    engine.objects.removeRange(2, engine.objects.length);

    final before = (second.position - first.position).distance;
    engine.step(1 / 60);
    final after = (second.position - first.position).distance;

    expect(after, greaterThan(before));
  });

  test('heavy overlap receives stronger separation than moderate overlap', () {
    double separationGain(double distance, int seed) {
      final engine = FloatingEngine(seed: seed);
      engine.resize(const Size(400, 400));

      final first = engine.objects[0]
        ..radius = 40
        ..position = const Offset(160, 200)
        ..velocity = Offset.zero;
      final second = engine.objects[1]
        ..radius = 40
        ..position = Offset(160 + distance, 200)
        ..velocity = Offset.zero;
      engine.objects.removeRange(2, engine.objects.length);

      final before = (second.position - first.position).distance;
      engine.step(1 / 60);
      final after = (second.position - first.position).distance;
      return after - before;
    }

    final moderateGain = separationGain(64, 14);
    final heavyGain = separationGain(48, 15);

    expect(heavyGain, greaterThan(moderateGain));
  });

  test('bounce overlap near bottom adds horizontal dispersion', () {
    final engine = FloatingEngine(seed: 16);
    engine.resize(const Size(400, 400));
    engine.setMovementStyle(MovementStyle.bounce);

    final first = engine.objects[0]
      ..radius = 40
      ..position = const Offset(180, 320)
      ..velocity = Offset.zero;
    final second = engine.objects[1]
      ..radius = 40
      ..position = const Offset(230, 320)
      ..velocity = Offset.zero;
    engine.objects.removeRange(2, engine.objects.length);

    engine.step(1 / 60);

    expect(first.velocity.dx, lessThan(0));
    expect(second.velocity.dx, greaterThan(0));
  });

  test('all nine required combinations can stay visible at once', () {
    final engine = FloatingEngine(seed: 10);
    engine.resize(const Size(320, 480));
    engine.setObjectCount(12);

    final allTokens = [
      for (final tone in ShapeTone.values)
        for (final shape in ShapeKind.values)
          LockToken(shape: shape, tone: tone),
    ];

    const filler = LockToken(
      shape: ShapeKind.circle,
      tone: ShapeTone.pink,
    );
    for (final object in engine.objects) {
      object.token = filler;
    }

    engine.setRequiredTokens(allTokens);

    final visibleIds = engine.objects
        .where((object) => !object.isPopping)
        .map((object) => object.token.id)
        .toSet();

    expect(visibleIds, containsAll(allTokens.map((token) => token.id)));
  });

  test('full combination set can reserve duplicate next tokens', () {
    final engine = FloatingEngine(seed: 11);
    engine.resize(const Size(320, 480));
    engine.setObjectCount(12);

    final allTokens = [
      for (final tone in ShapeTone.values)
        for (final shape in ShapeKind.values)
          LockToken(shape: shape, tone: tone),
    ];
    final repeated = allTokens.first;

    engine.setRequiredTokens([
      ...allTokens,
      repeated,
      repeated,
    ]);

    final visible = engine.objects.where((object) => !object.isPopping).toList();
    final uniqueIds = visible.map((object) => object.token.id).toSet();
    final repeatedCount =
        visible.where((object) => object.token.id == repeated.id).length;

    expect(uniqueIds, containsAll(allTokens.map((token) => token.id)));
    expect(repeatedCount, greaterThanOrEqualTo(3));
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
  });
  test('lower movement area keeps every object in the bottom half', () {
    final engine = FloatingEngine(seed: 17);
    const size = Size(400, 600);
    engine.resize(size);
    engine.setMovementArea(MovementArea.lower);

    for (var i = 0; i < 600; i++) {
      engine.step(1 / 60);
    }

    for (final object in engine.objects) {
      expect(
        object.position.dy - object.radius,
        greaterThanOrEqualTo(size.height * 0.40 - 1e-9),
      );
      expect(
        object.position.dy + object.radius,
        lessThanOrEqualTo(size.height),
      );
    }
  });

  test('switching to lower area immediately reseeds inside lower bounds', () {
    final engine = FloatingEngine(seed: 18);
    const size = Size(400, 600);
    engine.resize(size);

    engine.setMovementArea(MovementArea.lower);

    expect(
      engine.objects.every(
        (object) => object.position.dy - object.radius >= size.height * 0.40,
      ),
      isTrue,
    );
  });

  test('top inset keeps objects below lock header', () {
    final engine = FloatingEngine(seed: 19);
    const size = Size(400, 700);
    engine.resize(size);
    engine.setTopInset(150);

    for (var i = 0; i < 600; i++) {
      engine.step(1 / 60);
    }

    expect(
      engine.objects.every(
        (object) => object.position.dy - object.radius >= 150,
      ),
      isTrue,
    );
  });

  test('object count can switch between supported presets', () {
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
      closeTo(
        normalSpeed *
            FloatingSpeed.fast.multiplier /
            FloatingSpeed.normal.multiplier,
        0.0001,
      ),
    );
  });
  test('stalled floating object wakes up automatically', () {
    final engine = FloatingEngine(seed: 20);
    engine.resize(const Size(400, 400));

    final object = engine.objects.first
      ..position = const Offset(200, 200)
      ..velocity = Offset.zero;
    engine.objects.removeRange(1, engine.objects.length);

    for (var i = 0; i < 90; i++) {
      engine.step(1 / 60);
    }

    expect(object.velocity.distance, greaterThan(0));
  });

  test('external force accelerates objects in the requested direction', () {
    final engine = FloatingEngine(seed: 21);
    engine.resize(const Size(400, 400));

    final object = engine.objects.first
      ..position = const Offset(200, 200)
      ..velocity = Offset.zero;
    engine.objects.removeRange(1, engine.objects.length);

    engine.setExternalForce(const Offset(1, 0));
    for (var i = 0; i < 10; i++) {
      engine.step(1 / 60);
    }

    expect(object.velocity.dx, greaterThan(0));
  });

  test('bounce collision applies stronger impulse than floating', () {
    double collisionSpeed(MovementStyle style, int seed) {
      final engine = FloatingEngine(seed: seed);
      engine.resize(const Size(400, 400));
      engine.setMovementStyle(style);

      final first = engine.objects[0]
        ..radius = 40
        ..position = const Offset(160, 200)
        ..velocity = Offset.zero;
      final second = engine.objects[1]
        ..radius = 40
        ..position = const Offset(215, 200)
        ..velocity = Offset.zero;
      engine.objects.removeRange(2, engine.objects.length);

      engine.step(1 / 60);
      return first.velocity.distance + second.velocity.distance;
    }

    final floatingSpeed = collisionSpeed(MovementStyle.floating, 22);
    final bounceSpeed = collisionSpeed(MovementStyle.bounce, 23);

    expect(bounceSpeed, greaterThan(floatingSpeed));
  });

  test('floating style adds gentle wandering force', () {
    final engine = FloatingEngine(seed: 24);
    engine.resize(const Size(400, 400));

    final object = engine.objects.first
      ..position = const Offset(200, 200)
      ..velocity = Offset.zero;
    engine.objects.removeRange(1, engine.objects.length);

    for (var i = 0; i < 30; i++) {
      engine.step(1 / 60);
    }

    expect(object.velocity.distance, greaterThan(0));
  });

  test('bounce head-on collision reverses travel direction', () {
    final engine = FloatingEngine(seed: 25);
    engine.resize(const Size(400, 400));
    engine.setMovementStyle(MovementStyle.bounce);

    final first = engine.objects[0]
      ..radius = 40
      ..position = const Offset(170, 200)
      ..velocity = const Offset(70, 0);
    final second = engine.objects[1]
      ..radius = 40
      ..position = const Offset(230, 200)
      ..velocity = const Offset(-70, 0);
    engine.objects.removeRange(2, engine.objects.length);

    engine.step(1 / 120);

    expect(first.velocity.dx, lessThan(0));
    expect(second.velocity.dx, greaterThan(0));
  });

}
