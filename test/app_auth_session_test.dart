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

    test('stays authenticated while the same attempt remains current', () {
      final session = AppAuthSession()
        ..initialize(onboardingCompleted: true, hasPassword: true);
      final generation = session.generation;

      expect(session.markAuthenticated(generation: generation), isTrue);
      expect(
        session.requiresAuthentication(
          onboardingCompleted: true,
          hasPassword: true,
        ),
        isFalse,
      );
    });

    test('relocks and invalidates an attempt after leaving foreground', () {
      final session = AppAuthSession()
        ..initialize(onboardingCompleted: true, hasPassword: true);
      final staleGeneration = session.generation;

      expect(
        session.markAuthenticated(generation: staleGeneration),
        isTrue,
      );

      session.markUnauthenticated();

      expect(session.isAttemptCurrent(staleGeneration), isFalse);
      expect(
        session.requiresAuthentication(
          onboardingCompleted: true,
          hasPassword: true,
        ),
        isTrue,
      );
    });

    test('stale success cannot authenticate a resumed app session', () {
      final session = AppAuthSession()
        ..initialize(onboardingCompleted: true, hasPassword: true);
      final staleGeneration = session.generation;

      session.markUnauthenticated();

      expect(
        session.markAuthenticated(generation: staleGeneration),
        isFalse,
      );
      expect(
        session.requiresAuthentication(
          onboardingCompleted: true,
          hasPassword: true,
        ),
        isTrue,
      );
    });

    test('new attempt can authenticate after resume', () {
      final session = AppAuthSession()
        ..initialize(onboardingCompleted: true, hasPassword: true);

      session.markUnauthenticated();
      final currentGeneration = session.generation;

      expect(
        session.markAuthenticated(generation: currentGeneration),
        isTrue,
      );
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
