class AppAuthSession {
  bool _authenticated = false;
  bool _initialized = false;
  int _generation = 0;

  bool get authenticated => _authenticated;
  bool get initialized => _initialized;
  int get generation => _generation;

  void initialize({
    required bool onboardingCompleted,
    required bool hasPassword,
  }) {
    if (_initialized) return;
    _authenticated = !onboardingCompleted || !hasPassword;
    _initialized = true;
  }

  bool requiresAuthentication({
    required bool onboardingCompleted,
    required bool hasPassword,
  }) {
    if (!_initialized) return false;
    return onboardingCompleted && hasPassword && !_authenticated;
  }

  bool isAttemptCurrent(int generation) =>
      _initialized && generation == _generation;

  bool markAuthenticated({required int generation}) {
    if (!isAttemptCurrent(generation)) return false;
    _authenticated = true;
    return true;
  }

  void markUnauthenticated() {
    if (!_initialized) return;
    _authenticated = false;
    _generation++;
  }
}
