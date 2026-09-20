import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/lock_mode/lock_mode_screen.dart';
import 'my_lock_settings_controller.dart';
import 'theme.dart';

class MyLockLockApp extends StatelessWidget {
  const MyLockLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK',
      theme: buildMyLockTheme(),
      home: const _LockActivityHost(),
    );
  }
}

class _LockActivityHost extends StatefulWidget {
  const _LockActivityHost();

  @override
  State<_LockActivityHost> createState() => _LockActivityHostState();
}

class _LockActivityHostState extends State<_LockActivityHost> {
  static const _channel = MethodChannel('com.mylock.app/lock');

  late final MyLockSettingsController _settings;
  late final Future<void> _loadFuture;
  String? _targetAppId;
  bool _demoMode = false;

  @override
  void initState() {
    super.initState();
    _settings = MyLockSettingsController();
    _loadFuture = _initialize();
  }

  Future<void> _initialize() async {
    await _settings.load();
    _targetAppId = await _channel.invokeMethod<String>('getLockTarget');
    _demoMode =
        await _channel.invokeMethod<bool>('getLockDemoMode') ?? false;

    if (_targetAppId == null || _settings.password == null) {
      await _channel.invokeMethod<void>('dismissLock');
    }
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  Future<void> _openAppRecovery() async {
    await _channel.invokeMethod<void>('openAppRecovery');
  }

  Future<void> _unlock() async {
    final appId = _targetAppId;
    if (appId == null) return;

    await _channel.invokeMethod<void>(
      'unlockGranted',
      <String, Object?>{'appId': appId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: appBackground,
            body: Center(
              child: CircularProgressIndicator(
                color: brandPurple,
                strokeWidth: 2.4,
              ),
            ),
          );
        }

        if (snapshot.hasError ||
            _targetAppId == null ||
            _settings.password == null) {
          return const Scaffold(
            backgroundColor: appBackground,
            body: SizedBox.expand(),
          );
        }

        return LockModeScreen(
          settings: _settings,
          demoMode: _demoMode,
          onOpenAppRecovery: _demoMode ? null : _openAppRecovery,
          onUnlocked: _unlock,
        );
      },
    );
  }
}
