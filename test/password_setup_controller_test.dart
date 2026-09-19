import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/features/lock_settings/password_setup/password_setup_controller.dart';
import 'package:my_lock/lock_engine/models.dart';

void main() {
  const pinkCircle = LockToken(shape: ShapeKind.circle, tone: ShapeTone.pink);
  const blueSquare = LockToken(shape: ShapeKind.square, tone: ShapeTone.blue);

  test('requires at least two tokens before confirmation', () {
    final controller = PasswordSetupController();
    controller.addToken(pinkCircle);
    expect(controller.canContinue, isFalse);
    controller.addToken(blueSquare);
    expect(controller.canContinue, isTrue);
  });

  test('allows repeated token identities in a password', () {
    final controller = PasswordSetupController();
    controller
      ..addToken(pinkCircle)
      ..addToken(pinkCircle)
      ..addToken(pinkCircle)
      ..startConfirm();
    expect(controller.pattern.length, 3);
    expect(controller.pattern.every((token) => token.id == pinkCircle.id), isTrue);
  });

  test('matching confirmation verifies successfully', () {
    final controller = PasswordSetupController();
    controller
      ..addToken(pinkCircle)
      ..addToken(blueSquare)
      ..addToken(pinkCircle)
      ..startConfirm()
      ..addToken(pinkCircle)
      ..addToken(blueSquare)
      ..addToken(pinkCircle);
    expect(controller.verify(), isTrue);
  });

  test('mismatch clears confirmation input and flags error', () {
    final controller = PasswordSetupController();
    controller
      ..addToken(pinkCircle)
      ..addToken(blueSquare)
      ..addToken(pinkCircle)
      ..startConfirm()
      ..addToken(blueSquare)
      ..addToken(blueSquare)
      ..addToken(pinkCircle);
    expect(controller.verify(), isFalse);
    expect(controller.input, isEmpty);
    expect(controller.mismatch, isTrue);
  });
}
