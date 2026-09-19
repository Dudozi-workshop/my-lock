import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/features/lock_mode/lock_mode_controller.dart';
import 'package:my_lock/lock_engine/models.dart';

void main() {
  const a = LockToken(shape: ShapeKind.circle, tone: ShapeTone.pink);
  const b = LockToken(shape: ShapeKind.square, tone: ShapeTone.blue);

  test('correct sequence unlocks', () {
    final controller = LockModeController([a, b, a]);

    expect(controller.tap(a), LockTapResult.correct);
    expect(controller.tap(b), LockTapResult.correct);
    expect(controller.tap(a), LockTapResult.unlocked);
    expect(controller.unlocked, isTrue);
  });

  test('wrong token resets progress', () {
    final controller = LockModeController([a, b, a]);

    controller.tap(a);
    expect(controller.progress, 1);

    expect(controller.tap(a), LockTapResult.wrong);
    expect(controller.progress, 0);
    expect(controller.mismatch, isTrue);
  });

  test('required tokens track next two positions including duplicates', () {
    final controller = LockModeController([a, a, b]);

    expect(controller.requiredTokens.map((e) => e.id).toList(), [a.id, a.id]);

    controller.tap(a);
    expect(controller.requiredTokens.map((e) => e.id).toList(), [a.id, b.id]);
  });

  test('tap is ignored after unlock', () {
    final controller = LockModeController([a, a, a]);

    controller
      ..tap(a)
      ..tap(a)
      ..tap(a);

    expect(controller.tap(b), LockTapResult.ignored);
    expect(controller.progress, 3);
  });
}
