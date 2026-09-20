import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/features/app_auth/app_auth_session.dart';

void main() {
  group('AppAuthSession', () {
    test('requires auth after onboarding when a password exists', () {
      final session = AppAuthSession()
        ..initialize(onboardingCompleted: true, hasPassword: true);

      expect(
        session.requiresAuthentication(
          onboardingCompleted: true,
          hasPassword: true,
        ),
        isTrue,
      );
    });

    test('stays authenticated for the rest of the app session', () {
      final session = AppAuthSession()
        ..initialize(onboardingCompleted: true, hasPassword: true)
        ..markAuthenticated();

      expect(
        session.requiresAuthentication(
          onboardingCompleted: true,
          hasPassword: true,
        ),
        isFalse,
      );
    });

    test('does not gate onboarding or users without a password', () {
      final onboarding = AppAuthSession()
        ..initialize(onboardingCompleted: false, hasPassword: false);
      expect(
        onboarding.requiresAuthentication(
          onboardingCompleted: false,
          hasPassword: false,
        ),
        isFalse,
      );

      final noPassword = AppAuthSession()
        ..initialize(onboardingCompleted: true, hasPassword: false);
      expect(
        noPassword.requiresAuthentication(
          onboardingCompleted: true,
          hasPassword: false,
        ),
        isFalse,
      );
    });
  });
}
