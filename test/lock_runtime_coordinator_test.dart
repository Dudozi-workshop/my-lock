import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/app/my_lock_settings_controller.dart';
import 'package:my_lock/app/my_lock_settings_store.dart';
import 'package:my_lock/features/customize/background/background_style.dart';
import 'package:my_lock/lock_engine/effects.dart';
import 'package:my_lock/lock_engine/lock_runtime_coordinator.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/platform_lock_bridge.dart';
import 'package:my_lock/lock_engine/relock_policy.dart';

void main() {
  const appId = 'demo.app';
  const token = LockToken(
    shape: ShapeKind.circle,
    tone: ShapeTone.pink,
  );

  test('pending lock emitted during bridge start is not lost', () async {
    final bridge = _FakeBridge(
      startEvent: const PlatformLockEvent(
        PlatformLockEventType.protectedAppEntered,
        appId: appId,
      ),
    );
    final settings = MyLockSettingsController(store: _FakeStore())
      ..setSelectedApps({appId})
      ..setPassword([token, token, token]);

    final runtime = LockRuntimeCoordinator(
      settings: settings,
      bridge: bridge,
    );

    final requestFuture = runtime.lockRequests.first;
    await runtime.start();

    final request = await requestFuture;
    expect(request.appId, appId);
    expect(bridge.presentedApps, [appId]);

    await runtime.stop();
    settings.dispose();
  });

  test('protected app entry emits lock request when configured', () async {
    final bridge = _FakeBridge();
    final settings = MyLockSettingsController(store: _FakeStore())
      ..setSelectedApps({appId})
      ..setPassword([token, token, token]);

    final runtime = LockRuntimeCoordinator(
      settings: settings,
      bridge: bridge,
    );

    await runtime.start();
    final requestFuture = runtime.lockRequests.first;

    bridge.emit(
      const PlatformLockEvent(
        PlatformLockEventType.protectedAppEntered,
        appId: appId,
      ),
    );

    final request = await requestFuture;
    expect(request.appId, appId);
    expect(bridge.presentedApps, [appId]);

    await runtime.stop();
    settings.dispose();
  });

  test('screen on emits device lock request when beta is enabled', () async {
    final bridge = _FakeBridge();
    final settings = MyLockSettingsController(store: _FakeStore())
      ..setPassword([token, token, token])
      ..setExperimentalScreenLock(true);

    final runtime = LockRuntimeCoordinator(
      settings: settings,
      bridge: bridge,
    );

    await runtime.start();
    final requestFuture = runtime.lockRequests.first;

    bridge.emit(
      const PlatformLockEvent(PlatformLockEventType.screenOn),
    );

    final request = await requestFuture;
    expect(request.isDeviceScreen, isTrue);
    expect(
      bridge.presentedApps,
      [LockRequest.deviceScreenAppId],
    );

    await runtime.stop();
    settings.dispose();
  });

  test('screen on is ignored when beta screen lock is disabled', () async {
    final bridge = _FakeBridge();
    final settings = MyLockSettingsController(store: _FakeStore())
      ..setPassword([token, token, token]);

    final runtime = LockRuntimeCoordinator(
      settings: settings,
      bridge: bridge,
    );

    await runtime.start();

    var requests = 0;
    final subscription = runtime.lockRequests.listen((_) => requests++);

    bridge.emit(
      const PlatformLockEvent(PlatformLockEventType.screenOn),
    );
    await Future<void>.delayed(Duration.zero);

    expect(requests, 0);
    expect(bridge.presentedApps, isEmpty);

    await subscription.cancel();
    await runtime.stop();
    settings.dispose();
  });

  test('device screen unlock does not unlock protected app session', () async {
    final bridge = _FakeBridge();
    final settings = MyLockSettingsController(store: _FakeStore())
      ..setSelectedApps({appId})
      ..setPassword([token, token, token])
      ..setExperimentalScreenLock(true)
      ..setRelockPolicy(RelockPolicy.immediate);

    final runtime = LockRuntimeCoordinator(
      settings: settings,
      bridge: bridge,
    );

    await runtime.start();
    await runtime.grantUnlock(LockRequest.deviceScreenAppId);

    final requestFuture = runtime.lockRequests.first;
    bridge.emit(
      const PlatformLockEvent(
        PlatformLockEventType.protectedAppEntered,
        appId: appId,
      ),
    );

    final request = await requestFuture;
    expect(request.appId, appId);

    await runtime.stop();
    settings.dispose();
  });

  test('recovery PIN is stored in controller and verified exactly', () {
    final settings = MyLockSettingsController(store: _FakeStore());

    settings.setRecoveryPin('2580');

    expect(settings.recoveryPinReady, isTrue);
    expect(settings.verifyRecoveryPin('2580'), isTrue);
    expect(settings.verifyRecoveryPin('2581'), isFalse);
    expect(settings.verifyRecoveryPin('258'), isFalse);

    settings.dispose();
  });

  test('LockActivity unlock event updates app lock session', () async {
    final bridge = _FakeBridge();
    final settings = MyLockSettingsController(store: _FakeStore())
      ..setSelectedApps({appId})
      ..setPassword([token, token])
      ..setRelockPolicy(RelockPolicy.immediate);

    final runtime = LockRuntimeCoordinator(
      settings: settings,
      bridge: bridge,
    );

    await runtime.start();

    bridge.emit(
      const PlatformLockEvent(
        PlatformLockEventType.lockActivityUnlocked,
        appId: appId,
      ),
    );

    var requests = 0;
    final subscription = runtime.lockRequests.listen((_) => requests++);

    bridge.emit(
      const PlatformLockEvent(
        PlatformLockEventType.protectedAppEntered,
        appId: appId,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(requests, 0);

    bridge.emit(
      const PlatformLockEvent(
        PlatformLockEventType.protectedAppExited,
        appId: appId,
      ),
    );
    bridge.emit(
      const PlatformLockEvent(
        PlatformLockEventType.protectedAppEntered,
        appId: appId,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(requests, 1);

    await subscription.cancel();
    await runtime.stop();
    settings.dispose();
  });

  test('unlock grant suppresses immediate re-lock until app exits', () async {
    final bridge = _FakeBridge();
    final settings = MyLockSettingsController(store: _FakeStore())
      ..setSelectedApps({appId})
      ..setPassword([token, token, token])
      ..setRelockPolicy(RelockPolicy.immediate);

    final runtime = LockRuntimeCoordinator(
      settings: settings,
      bridge: bridge,
    );

    await runtime.start();
    await runtime.grantUnlock(appId);

    var requests = 0;
    final subscription = runtime.lockRequests.listen((_) => requests++);

    bridge.emit(
      const PlatformLockEvent(
        PlatformLockEventType.protectedAppEntered,
        appId: appId,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(requests, 0);

    bridge.emit(
      const PlatformLockEvent(
        PlatformLockEventType.protectedAppExited,
        appId: appId,
      ),
    );
    bridge.emit(
      const PlatformLockEvent(
        PlatformLockEventType.protectedAppEntered,
        appId: appId,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(requests, 1);

    await subscription.cancel();
    await runtime.stop();
    settings.dispose();
  });
}

class _FakeBridge implements PlatformLockBridge {
  _FakeBridge({this.startEvent});

  final PlatformLockEvent? startEvent;
  final StreamController<PlatformLockEvent> _controller =
      StreamController<PlatformLockEvent>.broadcast();

  final List<String> presentedApps = <String>[];

  @override
  Stream<PlatformLockEvent> get events => _controller.stream;

  void emit(PlatformLockEvent event) {
    _controller.add(event);
  }

  @override
  Future<void> notifyUnlockGranted(String appId) async {}

  @override
  Future<void> presentLockScreen(
    String appId, {
    bool demoMode = false,
  }) async {
    presentedApps.add(appId);
  }

  @override
  Future<PlatformLockCapabilities> getCapabilities() async {
    return const PlatformLockCapabilities.web();
  }

  @override
  Future<void> openUsageAccessSettings() async {}

  @override
  Future<void> openOverlaySettings() async {}

  @override
  Future<void> openBatteryOptimizationSettings() async {}

  @override
  Future<bool> authenticateDeviceOwner() async => false;

  @override
  Future<void> start() async {
    final event = startEvent;
    if (event != null) {
      _controller.add(event);
    }
  }

  @override
  Future<void> stop() async {
    await _controller.close();
  }

  @override
  Future<void> syncProtectedApps(Set<String> appIds) async {}

  @override
  Future<void> syncExperimentalScreenLock(bool enabled) async {}

  @override
  Future<void> syncRelockPolicy(String policy) async {}

  @override
  Future<void> syncLockBackground(String background) async {}

  @override
  Future<void> syncLockPattern({
    required List<String> tokenIds,
    required Set<String> shapes,
    required Set<String> tones,
  }) async {}

  @override
  Future<void> syncRecoveryPin(String? pin) async {}

  @override
  Future<void> syncLockPresentation({
    required int objectCount,
    required String speed,
    required String movementArea,
    required String movementStyle,
  }) async {}
}

class _FakeStore implements MyLockSettingsPersistence {
  @override
  Future<MyLockStoredSettings> load() async {
    return const MyLockStoredSettings(
      selectedShapes: {
        ShapeKind.circle,
        ShapeKind.triangle,
        ShapeKind.square,
      },
      selectedTones: {
        ShapeTone.pink,
        ShapeTone.blue,
        ShapeTone.yellow,
      },
      background: LockBackground.softGradient,
      movementStyle: MovementStyle.floating,
      popStyle: PopStyle.basicPop,
      password: null,
      selectedAppIds: <String>{},
      objectCount: 9,
      speed: FloatingSpeed.normal,
      relockPolicy: RelockPolicy.immediate,
    );
  }

  @override
  Future<void> savePassword(List<LockToken> password) async {}

  @override
  Future<void> saveRecoveryPin(String pin) async {}

  @override
  Future<void> savePreferences(MyLockStoredSettings settings) async {}
}
