import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/features/lock_mode/lock_mode_controller.dart';
import 'package:my_lock/lock_engine/models.dart';

void main() {
  const a = LockToken(shape: ShapeKind.circle, tone: ShapeTone.pink);
  const b = LockToken(shape: ShapeKind.square, tone: ShapeTone.blue);

  test('two-token sequence unlocks', () {
    final controller = LockModeController([a, b]);

    expect(controller.tap(a), LockTapResult.correct);
    expect(controller.tap(b), LockTapResult.unlocked);
    expect(controller.unlocked, isTrue);
  });

  test('correct sequence unlocks', () {
    final controller = LockModeController([a, b, a]);

    expect(controller.tap(a), LockTapResult.correct);
    expect(controller.tap(b), LockTapResult.correct);
    expect(controller.tap(a), LockTapResult.unlocked);
    expect(controller.unlocked, isTrue);
  });

  test('wrong input is not revealed until the full sequence is entered', () {
    final controller = LockModeController([a, b, a]);

    expect(controller.tap(b), LockTapResult.correct);
    expect(controller.progress, 1);
    expect(controller.mismatch, isFalse);
    expect(controller.failedAttempts, 0);

    expect(controller.tap(b), LockTapResult.correct);
    expect(controller.progress, 2);
    expect(controller.mismatch, isFalse);

    expect(controller.tap(b), LockTapResult.wrong);
    expect(controller.progress, 0);
    expect(controller.mismatch, isTrue);
    expect(controller.failedAttempts, 1);
  });

  test('recovery PIN eligibility counts failed full sequences', () {
    final controller = LockModeController([a, b, a]);

    for (var attempt = 0; attempt < 3; attempt++) {
      controller
        ..tap(b)
        ..tap(b)
        ..tap(b);
    }

    expect(controller.failedAttempts, 3);

    controller.reset();
    expect(controller.failedAttempts, 0);
  });

  test('required tokens follow input position without revealing correctness', () {
    final controller = LockModeController([a, a, b]);

    expect(controller.requiredTokens.map((e) => e.id).toList(), [a.id, a.id]);

    controller.tap(b);
    expect(controller.requiredTokens.map((e) => e.id).toList(), [a.id, b.id]);
    expect(controller.mismatch, isFalse);
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
