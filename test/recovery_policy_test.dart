import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/features/lock_mode/recovery_policy.dart';

void main() {
  group('recovery PIN policy', () {
    test('MyLock app authentication requires graphical password reset', () {
      expect(
        recoveryPinActionFor(appAuthentication: true),
        RecoveryPinAction.resetGraphicalPassword,
      );
    });

    test('protected app overlay unlocks without resetting password', () {
      expect(
        recoveryPinActionFor(appAuthentication: false),
        RecoveryPinAction.unlockOnly,
      );
    });

    test('cancelled recovery setup never replaces existing password', () {
      expect(
        shouldCommitRecoveredPassword(
          action: RecoveryPinAction.resetGraphicalPassword,
          completedSetup: false,
        ),
        isFalse,
      );
    });

    test('completed MyLock recovery setup may replace password', () {
      expect(
        shouldCommitRecoveredPassword(
          action: RecoveryPinAction.resetGraphicalPassword,
          completedSetup: true,
        ),
        isTrue,
      );
    });

    test('overlay PIN never replaces graphical password', () {
      expect(
        shouldCommitRecoveredPassword(
          action: RecoveryPinAction.unlockOnly,
          completedSetup: true,
        ),
        isFalse,
      );
    });
  });
}
