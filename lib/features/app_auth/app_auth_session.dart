class AppAuthSession {
  bool _authenticated = false;
  bool _initialized = false;

  bool get authenticated => _authenticated;
  bool get initialized => _initialized;

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

  void markAuthenticated() {
    _authenticated = true;
  }

  void markUnauthenticated() {
    if (!_initialized) return;
    _authenticated = false;
  }
}
