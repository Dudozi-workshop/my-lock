import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/features/lock_mode/pin_failure_policy.dart';

void main() {
  group('overlay PIN recovery policy', () {
    test('does not offer recovery before five failures', () {
      expect(
        shouldOfferOverlayRecovery(
          failedAttempts: 4,
          appAuthentication: false,
        ),
        isFalse,
      );
    });

    test('offers recovery after five overlay PIN failures', () {
      expect(
        shouldOfferOverlayRecovery(
          failedAttempts: 5,
          appAuthentication: false,
        ),
        isTrue,
      );
    });

    test('does not use overlay failure policy for MyLock app auth', () {
      expect(
        shouldOfferOverlayRecovery(
          failedAttempts: 5,
          appAuthentication: true,
        ),
        isFalse,
      );
    });
  });
}
