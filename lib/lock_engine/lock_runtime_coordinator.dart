import 'dart:async';

import '../app/my_lock_settings_controller.dart';
import 'lock_session_controller.dart';
import 'platform_lock_bridge.dart';

class LockRequest {
  const LockRequest(this.appId);

  static const deviceScreenAppId = '__device_screen__';

  final String appId;

  bool get isDeviceScreen => appId == deviceScreenAppId;
}

class LockRuntimeCoordinator {
  LockRuntimeCoordinator({
    required MyLockSettingsController settings,
    required PlatformLockBridge bridge,
    LockSessionController? session,
  })  : _settings = settings,
        _bridge = bridge,
        _session = session ?? LockSessionController();

  final MyLockSettingsController _settings;
  final PlatformLockBridge _bridge;
  final LockSessionController _session;

  final StreamController<LockRequest> _lockRequests =
      StreamController<LockRequest>.broadcast();

  StreamSubscription<PlatformLockEvent>? _subscription;
  bool _started = false;

  Stream<LockRequest> get lockRequests => _lockRequests.stream;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    _subscription = _bridge.events.listen(
      (event) => unawaited(_handleEvent(event)),
    );
    _settings.addListener(_syncSettings);
    await _bridge.start();
    await _bridge.syncProtectedApps(_settings.selectedAppIds);
    await _bridge.syncExperimentalScreenLock(
      _settings.experimentalScreenLock,
    );
    await _bridge.syncRelockPolicy(_settings.relockPolicy.name);
    await _bridge.syncLockBackground(_settings.background.name);
    await _syncLockPattern();
    await _syncRecoveryPin();
    await _syncLockPresentation();
  }

  Future<void> stop() async {
    if (!_started) return;
    _started = false;

    _settings.removeListener(_syncSettings);
    await _subscription?.cancel();
    _subscription = null;
    await _bridge.stop();
    await _lockRequests.close();
  }

  Future<void> grantUnlock(String appId) async {
    if (appId != LockRequest.deviceScreenAppId) {
      _session.markUnlocked();
    }
    await _bridge.notifyUnlockGranted(appId);
  }

  void _syncSettings() {
    _bridge.syncProtectedApps(_settings.selectedAppIds);
    _bridge.syncExperimentalScreenLock(
      _settings.experimentalScreenLock,
    );
    _bridge.syncRelockPolicy(_settings.relockPolicy.name);
    _bridge.syncLockBackground(_settings.background.name);
    _syncLockPattern();
    _syncRecoveryPin();
    _syncLockPresentation();
  }

  Future<void> _syncLockPattern() async {
    await _bridge.syncLockPattern(
      tokenIds: _settings.password?.map((token) => token.id).toList() ??
          const <String>[],
      shapes: _settings.selectedShapes.map((value) => value.name).toSet(),
      tones: _settings.selectedTones.map((value) => value.name).toSet(),
    );
  }

  Future<void> _syncRecoveryPin() async {
    await _bridge.syncRecoveryPin(_settings.recoveryPin);
  }

  Future<void> _syncLockPresentation() async {
    await _bridge.syncLockPresentation(
      objectCount: _settings.objectCount,
      speed: _settings.speed.name,
      movementArea: _settings.movementArea.name,
      movementStyle: _settings.movementStyle.name,
    );
  }

  Future<void> _handleEvent(PlatformLockEvent event) async {
    switch (event.type) {
      case PlatformLockEventType.protectedAppEntered:
        final appId = event.appId;
        if (appId == null ||
            !_settings.selectedAppIds.contains(appId) ||
            _settings.password == null) {
          return;
        }

        final needsLock = _session.requiresLockOnProtectedAppEnter(
          _settings.relockPolicy,
        );
        if (needsLock) {
          await _bridge.presentLockScreen(appId);
          _lockRequests.add(LockRequest(appId));
        }
        break;

      case PlatformLockEventType.protectedAppExited:
        final appId = event.appId;
        if (appId != null && _settings.selectedAppIds.contains(appId)) {
          _session.markProtectedAppExited();
        }
        break;

      case PlatformLockEventType.screenOff:
        _session.markScreenOff();
        break;

      case PlatformLockEventType.screenOn:
        if (!_settings.experimentalScreenLock ||
            _settings.password == null) {
          return;
        }
        await _bridge.presentLockScreen(LockRequest.deviceScreenAppId);
        _lockRequests.add(
          const LockRequest(LockRequest.deviceScreenAppId),
        );
        break;

      case PlatformLockEventType.lockActivityUnlocked:
        final appId = event.appId;
        if (appId != null && appId != LockRequest.deviceScreenAppId) {
          _session.markUnlocked();
        }
        break;
    }
  }
}
