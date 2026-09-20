import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/features/lock_mode/pin_failure_policy.dart';

void main() {
  group('overlay PIN recovery policy', () {
    test('does not offer recovery before three failures', () {
      expect(
        shouldOfferOverlayRecovery(
          failedAttempts: 2,
          appAuthentication: false,
        ),
        isFalse,
      );
    });

    test('offers recovery after three overlay PIN failures', () {
      expect(
        shouldOfferOverlayRecovery(
          failedAttempts: 3,
          appAuthentication: false,
        ),
        isTrue,
      );
    });

    test('does not use overlay failure policy for MyLock app auth', () {
      expect(
        shouldOfferOverlayRecovery(
          failedAttempts: 3,
          appAuthentication: true,
        ),
        isFalse,
      );
    });
  });
}
