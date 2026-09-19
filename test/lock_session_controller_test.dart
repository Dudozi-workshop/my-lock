import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/lock_session_controller.dart';
import 'package:my_lock/lock_engine/relock_policy.dart';

void main() {
  final base = DateTime(2026, 9, 19, 18);

  test('initial protected app entry requires lock', () {
    final session = LockSessionController();

    expect(
      session.requiresLockOnProtectedAppEnter(RelockPolicy.immediate, at: base),
      isTrue,
    );
  });

  test('immediate policy relocks after protected app exit', () {
    final session = LockSessionController()
      ..markUnlocked()
      ..markProtectedAppExited(at: base);

    expect(
      session.requiresLockOnProtectedAppEnter(
        RelockPolicy.immediate,
        at: base.add(const Duration(seconds: 1)),
      ),
      isTrue,
    );
    expect(session.unlocked, isFalse);
  });

  test('30 second policy keeps session inside grace period', () {
    final session = LockSessionController()
      ..markUnlocked()
      ..markProtectedAppExited(at: base);

    expect(
      session.requiresLockOnProtectedAppEnter(
        RelockPolicy.after30Seconds,
        at: base.add(const Duration(seconds: 29)),
      ),
      isFalse,
    );
    expect(session.unlocked, isTrue);
  });

  test('30 second policy relocks at boundary', () {
    final session = LockSessionController()
      ..markUnlocked()
      ..markProtectedAppExited(at: base);

    expect(
      session.requiresLockOnProtectedAppEnter(
        RelockPolicy.after30Seconds,
        at: base.add(const Duration(seconds: 30)),
      ),
      isTrue,
    );
  });

  test('one minute policy relocks after grace period', () {
    final session = LockSessionController()
      ..markUnlocked()
      ..markProtectedAppExited(at: base);

    expect(
      session.requiresLockOnProtectedAppEnter(
        RelockPolicy.after1Minute,
        at: base.add(const Duration(minutes: 1)),
      ),
      isTrue,
    );
  });

  test('screen off policy stays unlocked across app exit', () {
    final session = LockSessionController()
      ..markUnlocked()
      ..markProtectedAppExited(at: base);

    expect(
      session.requiresLockOnProtectedAppEnter(
        RelockPolicy.screenOff,
        at: base.add(const Duration(hours: 1)),
      ),
      isFalse,
    );
  });

  test('screen off always ends unlocked session', () {
    final session = LockSessionController()..markUnlocked();

    session.markScreenOff();

    expect(session.unlocked, isFalse);
    expect(
      session.requiresLockOnProtectedAppEnter(
        RelockPolicy.screenOff,
        at: base,
      ),
      isTrue,
    );
  });
}
