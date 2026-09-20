import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformLockCapabilities {
  const PlatformLockCapabilities({
    required this.nativeBridgeAvailable,
    required this.usageAccessGranted,
    required this.overlayGranted,
    required this.monitorServiceRunning,
  });

  const PlatformLockCapabilities.web()
      : nativeBridgeAvailable = false,
        usageAccessGranted = false,
        overlayGranted = false,
        monitorServiceRunning = false;

  final bool nativeBridgeAvailable;
  final bool usageAccessGranted;
  final bool overlayGranted;
  final bool monitorServiceRunning;

  bool get androidReady => usageAccessGranted && overlayGranted;
}

enum PlatformLockEventType {
  protectedAppEntered,
  protectedAppExited,
  screenOff,
  screenOn,
  lockActivityUnlocked,
}

class PlatformLockEvent {
  const PlatformLockEvent(this.type, {this.appId});

  final PlatformLockEventType type;
  final String? appId;
}

abstract class PlatformLockBridge {
  Stream<PlatformLockEvent> get events;

  Future<void> start();

  Future<void> stop();

  Future<void> syncProtectedApps(Set<String> appIds);

  Future<void> syncExperimentalScreenLock(bool enabled);

  Future<void> syncRelockPolicy(String policy);

  Future<void> syncLockBackground(String background);

  Future<void> syncLockPattern({
    required List<String> tokenIds,
    required Set<String> shapes,
    required Set<String> tones,
  });

  Future<void> syncLockPresentation({
    required int objectCount,
    required String speed,
    required String movementArea,
    required String movementStyle,
  });

  Future<void> notifyUnlockGranted(String appId);

  Future<void> presentLockScreen(String appId);

  Future<PlatformLockCapabilities> getCapabilities();

  Future<void> openUsageAccessSettings();

  Future<void> openOverlaySettings();
}

class MethodChannelPlatformLockBridge implements PlatformLockBridge {
  MethodChannelPlatformLockBridge({
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel('com.mylock.app/lock');

  final MethodChannel _channel;
  final StreamController<PlatformLockEvent> _events =
      StreamController<PlatformLockEvent>.broadcast();

  bool _started = false;

  @override
  Stream<PlatformLockEvent> get events => _events.stream;

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;

    if (kIsWeb) return;

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'protectedAppEntered':
          final appId = _readAppId(call.arguments);
          if (appId != null) {
            _events.add(
              PlatformLockEvent(
                PlatformLockEventType.protectedAppEntered,
                appId: appId,
              ),
            );
          }
          break;
        case 'protectedAppExited':
          final appId = _readAppId(call.arguments);
          if (appId != null) {
            _events.add(
              PlatformLockEvent(
                PlatformLockEventType.protectedAppExited,
                appId: appId,
              ),
            );
          }
          break;
        case 'screenOff':
          _events.add(
            const PlatformLockEvent(PlatformLockEventType.screenOff),
          );
          break;
        case 'screenOn':
          _events.add(
            const PlatformLockEvent(PlatformLockEventType.screenOn),
          );
          break;
        case 'lockActivityUnlocked':
          final appId = _readAppId(call.arguments);
          if (appId != null) {
            _events.add(
              PlatformLockEvent(
                PlatformLockEventType.lockActivityUnlocked,
                appId: appId,
              ),
            );
          }
          break;
      }
    });

  }

  @override
  Future<void> stop() async {
    if (!_started) return;
    _started = false;

    if (!kIsWeb) {
      _channel.setMethodCallHandler(null);
    }

    await _events.close();
  }

  @override
  Future<PlatformLockCapabilities> getCapabilities() async {
    if (kIsWeb) return const PlatformLockCapabilities.web();

    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'getAndroidCapabilities',
      );

      return PlatformLockCapabilities(
        nativeBridgeAvailable: result != null,
        usageAccessGranted: result?['usageAccessGranted'] == true,
        overlayGranted: result?['overlayGranted'] == true,
        monitorServiceRunning: result?['monitorServiceRunning'] == true,
      );
    } on MissingPluginException {
      return const PlatformLockCapabilities.web();
    } on PlatformException {
      return const PlatformLockCapabilities.web();
    }
  }

  @override
  Future<void> openUsageAccessSettings() async {
    if (kIsWeb) return;
    await _invokeSafely('openUsageAccessSettings', const <String, Object?>{});
  }

  @override
  Future<void> openOverlaySettings() async {
    if (kIsWeb) return;
    await _invokeSafely('openOverlaySettings', const <String, Object?>{});
  }

  @override
  Future<void> syncProtectedApps(Set<String> appIds) async {
    if (kIsWeb) return;
    await _invokeSafely(
      'syncProtectedApps',
      <String, Object?>{'appIds': appIds.toList()},
    );
  }

  @override
  Future<void> syncExperimentalScreenLock(bool enabled) async {
    if (kIsWeb) return;
    await _invokeSafely(
      'syncExperimentalScreenLock',
      <String, Object?>{'enabled': enabled},
    );
  }

  Future<void> syncExperimentalOverlayLock(bool enabled) async {
    if (kIsWeb) return;
    await _invokeSafely(
      'syncExperimentalOverlayLock',
      <String, Object?>{'enabled': enabled},
    );
  }

  @override
  Future<void> syncRelockPolicy(String policy) async {
    if (kIsWeb) return;
    await _invokeSafely(
      'syncRelockPolicy',
      <String, Object?>{'policy': policy},
    );
  }

  @override
  Future<void> syncLockBackground(String background) async {
    if (kIsWeb) return;
    await _invokeSafely(
      'syncLockBackground',
      <String, Object?>{'background': background},
    );
  }

  @override
  Future<void> syncLockPattern({
    required List<String> tokenIds,
    required Set<String> shapes,
    required Set<String> tones,
  }) async {
    if (kIsWeb) return;
    await _invokeSafely(
      'syncLockPattern',
      <String, Object?>{
        'tokenIds': tokenIds,
        'shapes': shapes.toList(),
        'tones': tones.toList(),
      },
    );
  }

  @override
  Future<void> syncLockPresentation({
    required int objectCount,
    required String speed,
    required String movementArea,
    required String movementStyle,
  }) async {
    if (kIsWeb) return;
    await _invokeSafely(
      'syncLockPresentation',
      <String, Object?>{
        'objectCount': objectCount,
        'speed': speed,
        'movementArea': movementArea,
        'movementStyle': movementStyle,
      },
    );
  }

  @override
  Future<void> notifyUnlockGranted(String appId) async {
    if (kIsWeb) return;
    await _invokeSafely(
      'unlockGranted',
      <String, Object?>{'appId': appId},
    );
  }

  @override
  Future<void> presentLockScreen(String appId) async {
    if (kIsWeb) return;
    await _invokeSafely(
      'presentLockScreen',
      <String, Object?>{'appId': appId},
    );
  }

  String? _readAppId(Object? arguments) {
    if (arguments is Map) {
      final value = arguments['appId'];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  Future<void> _invokeSafely(
    String method,
    Map<String, Object?> arguments,
  ) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // Native integration is optional until the platform layer is installed.
    } on PlatformException {
      // Native capability/permission handling is surfaced by the platform UI.
    }
  }
}

class WebTestPlatformLockBridge implements PlatformLockBridge {
  final StreamController<PlatformLockEvent> _events =
      StreamController<PlatformLockEvent>.broadcast();

  bool _started = false;

  @override
  Stream<PlatformLockEvent> get events => _events.stream;

  @override
  Future<void> start() async {
    _started = true;
  }

  @override
  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    await _events.close();
  }

  @override
  Future<PlatformLockCapabilities> getCapabilities() async {
    return const PlatformLockCapabilities(
      nativeBridgeAvailable: true,
      usageAccessGranted: true,
      overlayGranted: true,
      monitorServiceRunning: true,
    );
  }

  void simulateProtectedAppEnter(String appId) {
    if (!_started || appId.isEmpty) return;
    _events.add(
      PlatformLockEvent(
        PlatformLockEventType.protectedAppEntered,
        appId: appId,
      ),
    );
  }

  void simulateProtectedAppExit(String appId) {
    if (!_started || appId.isEmpty) return;
    _events.add(
      PlatformLockEvent(
        PlatformLockEventType.protectedAppExited,
        appId: appId,
      ),
    );
  }

  void simulateScreenOff() {
    if (!_started) return;
    _events.add(const PlatformLockEvent(PlatformLockEventType.screenOff));
  }

  void simulateScreenOn() {
    if (!_started) return;
    _events.add(const PlatformLockEvent(PlatformLockEventType.screenOn));
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
  Future<void> syncLockPresentation({
    required int objectCount,
    required String speed,
    required String movementArea,
    required String movementStyle,
  }) async {}

  @override
  Future<void> notifyUnlockGranted(String appId) async {}

  @override
  Future<void> presentLockScreen(String appId) async {}

  @override
  Future<void> openUsageAccessSettings() async {}

  @override
  Future<void> openOverlaySettings() async {}
}
