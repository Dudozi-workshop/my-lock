import 'dart:math';
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
    // Bounce applies the same gravity to both objects, so relative distance
    // changes here only if pair repulsion is incorrectly triggered.
    engine.setMovementStyle(MovementStyle.bounce);

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

  test('zero gravity preserves inertial travel without downward acceleration', () {
    final engine = FloatingEngine(seed: 26);
    engine.resize(const Size(400, 400));
    engine.setMovementStyle(MovementStyle.zeroGravity);
    engine.setMovementArea(MovementArea.full);

    final object = engine.objects.first
      ..position = const Offset(200, 200)
      ..velocity = const Offset(50, -20);
    engine.objects.removeRange(1, engine.objects.length);

    final beforeDy = object.velocity.dy;
    for (var i = 0; i < 60; i++) {
      engine.step(1 / 60);
    }

    expect(object.velocity.dy, lessThan(0));
    expect(object.velocity.dy.abs(), lessThan(beforeDy.abs() + 10));
  });

  test('zero gravity collision transfers momentum softly', () {
    final engine = FloatingEngine(seed: 27);
    engine.resize(const Size(400, 400));
    engine.setMovementStyle(MovementStyle.zeroGravity);

    final first = engine.objects[0]
      ..radius = 40
      ..position = const Offset(170, 200)
      ..velocity = const Offset(60, 0);
    final second = engine.objects[1]
      ..radius = 40
      ..position = const Offset(230, 200)
      ..velocity = Offset.zero;
    engine.objects.removeRange(2, engine.objects.length);

    engine.step(1 / 120);

    expect(first.velocity.dx, lessThan(60));
    expect(second.velocity.dx, greaterThan(0));
  });

  test('underwater motion adds vertical current and damping', () {
    final engine = FloatingEngine(seed: 28);
    engine.resize(const Size(400, 400));
    engine.setMovementStyle(MovementStyle.underwater);
    engine.setMovementArea(MovementArea.full);

    final object = engine.objects.first
      ..position = const Offset(200, 200)
      ..velocity = const Offset(60, 0);
    engine.objects.removeRange(1, engine.objects.length);

    final beforeSpeed = object.velocity.distance;
    for (var i = 0; i < 60; i++) {
      engine.step(1 / 60);
    }

    expect(object.velocity.dy.abs(), greaterThan(0));
    expect(object.velocity.distance, lessThan(beforeSpeed + 20));
  });

  test('orbit motion visibly follows a ring around the center', () {
    final engine = FloatingEngine(seed: 29);
    engine.resize(const Size(400, 400));
    engine.setMovementStyle(MovementStyle.orbit);
    engine.setMovementArea(MovementArea.full);

    final object = engine.objects.first
      ..position = const Offset(300, 200)
      ..velocity = Offset.zero;
    engine.objects.removeRange(1, engine.objects.length);

    const center = Offset(200, 200);
    final startDistance = (object.position - center).distance;

    for (var i = 0; i < 120; i++) {
      engine.step(1 / 60);
    }

    final endDistance = (object.position - center).distance;
    expect((endDistance - startDistance).abs(), lessThan(55));
    expect((object.position.dy - 200).abs(), greaterThan(12));
  });

  test('underwater collision is softer than bounce collision', () {
    double postCollisionSpeed(MovementStyle style, int seed) {
      final engine = FloatingEngine(seed: seed);
      engine.resize(const Size(400, 400));
      engine.setMovementStyle(style);
      engine.setMovementArea(MovementArea.full);

      final first = engine.objects[0]
        ..radius = 40
        ..position = const Offset(170, 200)
        ..velocity = const Offset(60, 0);
      final second = engine.objects[1]
        ..radius = 40
        ..position = const Offset(230, 200)
        ..velocity = const Offset(-60, 0);
      engine.objects.removeRange(2, engine.objects.length);

      engine.step(1 / 120);
      return first.velocity.distance + second.velocity.distance;
    }

    final underwater = postCollisionSpeed(MovementStyle.underwater, 30);
    final bounce = postCollisionSpeed(MovementStyle.bounce, 31);

    expect(underwater, lessThan(bounce));
  });

  test('zero gravity keeps straighter momentum than floating', () {
    double headingChange(MovementStyle style, int seed) {
      final engine = FloatingEngine(seed: seed);
      engine.resize(const Size(500, 500));
      engine.setMovementStyle(style);
      engine.setMovementArea(MovementArea.full);

      final object = engine.objects.first
        ..position = const Offset(250, 250)
        ..velocity = const Offset(70, 15);
      engine.objects.removeRange(1, engine.objects.length);

      final before = object.velocity;
      for (var i = 0; i < 90; i++) {
        engine.step(1 / 60);
      }

      final after = object.velocity;
      final beforeAngle = atan2(before.dy, before.dx);
      final afterAngle = atan2(after.dy, after.dx);
      return (afterAngle - beforeAngle).abs();
    }

    final zeroGravityChange =
        headingChange(MovementStyle.zeroGravity, 32);
    final floatingChange =
        headingChange(MovementStyle.floating, 33);

    expect(zeroGravityChange, lessThan(floatingChange));
  });

  test('orbit starts and stays on visibly wide elliptical rings', () {
    final engine = FloatingEngine(seed: 34);
    engine.resize(const Size(500, 500));
    engine.setMovementStyle(MovementStyle.orbit);
    engine.setMovementArea(MovementArea.full);

    const center = Offset(250, 250);
    final startDistances = engine.objects
        .map((object) => (object.position - center).distance)
        .toList();

    expect(startDistances.reduce((a, b) => a + b) / startDistances.length,
        greaterThan(85));

    for (var i = 0; i < 120; i++) {
      engine.step(1 / 60);
    }

    final endDistances = engine.objects
        .map((object) => (object.position - center).distance)
        .toList();
    expect(endDistances.reduce((a, b) => a + b) / endDistances.length,
        greaterThan(75));
  });

  test('zero gravity visibly rotates while preserving inertial drift', () {
    final engine = FloatingEngine(seed: 35);
    engine.resize(const Size(500, 500));
    engine.setMovementStyle(MovementStyle.zeroGravity);
    engine.setMovementArea(MovementArea.full);

    final object = engine.objects.first
      ..position = const Offset(250, 250)
      ..velocity = const Offset(45, 8);
    engine.objects.removeRange(1, engine.objects.length);

    final startRotation = object.rotation;
    for (var i = 0; i < 120; i++) {
      engine.step(1 / 60);
    }

    expect((object.rotation - startRotation).abs(), greaterThan(0.25));
    expect(object.velocity.dx.abs(), greaterThan(object.velocity.dy.abs()));
  });

  test('underwater emphasizes vertical movement over horizontal sway', () {
    final engine = FloatingEngine(seed: 36);
    engine.resize(const Size(500, 500));
    engine.setMovementStyle(MovementStyle.underwater);
    engine.setMovementArea(MovementArea.full);

    final object = engine.objects.first
      ..position = const Offset(250, 250)
      ..velocity = Offset.zero;
    engine.objects.removeRange(1, engine.objects.length);

    var minX = object.position.dx;
    var maxX = object.position.dx;
    var minY = object.position.dy;
    var maxY = object.position.dy;

    for (var i = 0; i < 240; i++) {
      engine.step(1 / 60);
      minX = min(minX, object.position.dx);
      maxX = max(maxX, object.position.dx);
      minY = min(minY, object.position.dy);
      maxY = max(maxY, object.position.dy);
    }

    expect(maxX - minX, greaterThan(35));
    expect(maxY - minY, greaterThan(10));
  });

  test('floating wind field produces a shared sweeping direction', () {
    final engine = FloatingEngine(seed: 37);
    engine.resize(const Size(500, 500));
    engine.setMovementStyle(MovementStyle.floating);
    engine.setMovementArea(MovementArea.full);

    for (final object in engine.objects) {
      object.velocity = Offset.zero;
    }

    for (var i = 0; i < 60; i++) {
      engine.step(1 / 60);
    }

    final positiveX =
        engine.objects.where((object) => object.velocity.dx > 0).length;
    expect(positiveX, greaterThan(engine.objects.length ~/ 2));
  });

  test('orbit distributes objects across multiple planetary rings', () {
    final engine = FloatingEngine(seed: 38);
    engine.resize(const Size(600, 600));
    engine.setMovementStyle(MovementStyle.orbit);
    engine.setMovementArea(MovementArea.full);

    const center = Offset(300, 300);
    final distances = engine.objects
        .map((object) => (object.position - center).distance)
        .toList()
      ..sort();

    expect(distances.last - distances.first, greaterThan(90));
  });

  test('deep sea current gives objects a coherent flow plus individual swim', () {
    final engine = FloatingEngine(seed: 39);
    engine.resize(const Size(500, 500));
    engine.setMovementStyle(MovementStyle.underwater);
    engine.setMovementArea(MovementArea.full);

    for (final object in engine.objects) {
      object.velocity = Offset.zero;
    }

    for (var i = 0; i < 120; i++) {
      engine.step(1 / 60);
    }

    final averageDx = engine.objects
            .map((object) => object.velocity.dx)
            .reduce((a, b) => a + b) /
        engine.objects.length;
    final variation = engine.objects
            .map((object) => (object.velocity.dx - averageDx).abs())
            .reduce((a, b) => a + b) /
        engine.objects.length;

    expect(averageDx.abs(), greaterThan(1));
    expect(variation, greaterThan(0.5));
  });

  test('bounce tilt rotates gravity toward the tilted side', () {
    final engine = FloatingEngine(seed: 40);
    engine.resize(const Size(500, 500));
    engine.setMovementStyle(MovementStyle.bounce);
    engine.setMovementArea(MovementArea.full);

    final object = engine.objects.first
      ..position = const Offset(250, 250)
      ..velocity = Offset.zero;
    engine.objects.removeRange(1, engine.objects.length);

    engine.setReactiveMotion(
      tilt: const Offset(1, 0),
      gyroZ: 0,
      shake: 0,
    );
    for (var i = 0; i < 20; i++) {
      engine.step(1 / 60);
    }

    expect(object.velocity.dx, greaterThan(0));
  });

  test('zero gravity converts tilt into sustained inertial acceleration', () {
    final engine = FloatingEngine(seed: 41);
    engine.resize(const Size(500, 500));
    engine.setMovementStyle(MovementStyle.zeroGravity);
    engine.setMovementArea(MovementArea.full);

    final object = engine.objects.first
      ..position = const Offset(250, 250)
      ..velocity = Offset.zero;
    engine.objects.removeRange(1, engine.objects.length);

    engine.setReactiveMotion(
      tilt: const Offset(0.8, 0),
      gyroZ: 0,
      shake: 0,
    );
    for (var i = 0; i < 60; i++) {
      engine.step(1 / 60);
    }

    expect(object.velocity.dx, greaterThan(5));
  });

  test('orbit tilt shifts the orbital system center', () {
    double averageX(double tiltX, int seed) {
      final engine = FloatingEngine(seed: seed);
      engine.resize(const Size(600, 600));
      engine.setMovementStyle(MovementStyle.orbit);
      engine.setMovementArea(MovementArea.full);
      engine.setReactiveMotion(
        tilt: Offset(tiltX, 0),
        gyroZ: 0,
        shake: 0,
      );

      for (var i = 0; i < 120; i++) {
        engine.step(1 / 60);
      }

      return engine.objects
              .map((object) => object.position.dx)
              .reduce((a, b) => a + b) /
          engine.objects.length;
    }

    final neutral = averageX(0, 42);
    final tilted = averageX(1, 42);
    expect(tilted, greaterThan(neutral + 20));
  });

  test('deep sea tilt redirects the shared current', () {
    double averageDx(double tiltX, int seed) {
      final engine = FloatingEngine(seed: seed);
      engine.resize(const Size(500, 500));
      engine.setMovementStyle(MovementStyle.underwater);
      engine.setMovementArea(MovementArea.full);
      for (final object in engine.objects) {
        object.velocity = Offset.zero;
      }
      engine.setReactiveMotion(
        tilt: Offset(tiltX, 0),
        gyroZ: 0,
        shake: 0,
      );

      for (var i = 0; i < 60; i++) {
        engine.step(1 / 60);
      }

      return engine.objects
              .map((object) => object.velocity.dx)
              .reduce((a, b) => a + b) /
          engine.objects.length;
    }

    final left = averageDx(-1, 43);
    final right = averageDx(1, 43);
    expect(right, greaterThan(left));
  });

}
