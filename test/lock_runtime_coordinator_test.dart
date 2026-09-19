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
  final StreamController<PlatformLockEvent> _controller =
      StreamController<PlatformLockEvent>.broadcast();

  @override
  Stream<PlatformLockEvent> get events => _controller.stream;

  void emit(PlatformLockEvent event) {
    _controller.add(event);
  }

  @override
  Future<void> notifyUnlockGranted(String appId) async {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {
    await _controller.close();
  }

  @override
  Future<void> syncProtectedApps(Set<String> appIds) async {}
}

class _FakeStore extends MyLockSettingsStore {
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
  Future<void> savePreferences(MyLockStoredSettings settings) async {}
}
