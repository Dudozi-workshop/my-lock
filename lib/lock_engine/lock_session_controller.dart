import 'relock_policy.dart';

class LockSessionController {
  bool _unlocked = false;
  DateTime? _leftProtectedAppAt;

  bool get unlocked => _unlocked;
  DateTime? get leftProtectedAppAt => _leftProtectedAppAt;

  void markUnlocked() {
    _unlocked = true;
    _leftProtectedAppAt = null;
  }

  void markProtectedAppExited({DateTime? at}) {
    if (!_unlocked) return;
    _leftProtectedAppAt = at ?? DateTime.now();
  }

  bool requiresLockOnProtectedAppEnter(
    RelockPolicy policy, {
    DateTime? at,
  }) {
    if (!_unlocked) return true;

    final leftAt = _leftProtectedAppAt;
    if (leftAt == null) return false;

    switch (policy) {
      case RelockPolicy.immediate:
        _lock();
        return true;
      case RelockPolicy.after30Seconds:
      case RelockPolicy.after1Minute:
        final delay = policy.delay!;
        final now = at ?? DateTime.now();
        if (now.difference(leftAt) >= delay) {
          _lock();
          return true;
        }
        _leftProtectedAppAt = null;
        return false;
      case RelockPolicy.screenOff:
        _leftProtectedAppAt = null;
        return false;
    }
  }

  void markScreenOff() {
    _lock();
  }

  void forceLock() {
    _lock();
  }

  void _lock() {
    _unlocked = false;
    _leftProtectedAppAt = null;
  }
}
