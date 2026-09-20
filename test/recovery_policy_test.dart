import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/features/lock_mode/recovery_policy.dart';

void main() {
  group('recovery PIN policy', () {
    test('PIN is an unlock-only authentication method', () {
      expect(
        recoveryPinActionFor(appAuthentication: true),
        RecoveryPinAction.unlockOnly,
      );
      expect(
        recoveryPinActionFor(appAuthentication: false),
        RecoveryPinAction.unlockOnly,
      );
    });

    test('PIN authentication never commits a graphical password change', () {
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
