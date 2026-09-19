import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../app/theme.dart';
import '../../lock_engine/lock_runtime_coordinator.dart';
import '../../lock_engine/platform_lock_bridge.dart';
import '../lock_mode/lock_mode_screen.dart';
import '../customize/customize_screen.dart';
import '../lock_settings/lock_settings_screen.dart';
import '../shop/shop_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  late final MyLockSettingsController _settings;
  late final LockRuntimeCoordinator _runtime;
  late final Future<void> _loadFuture;
  StreamSubscription<LockRequest>? _lockRequestSubscription;
  bool _lockScreenOpen = false;

  @override
  void initState() {
    super.initState();
    _settings = MyLockSettingsController();
    _runtime = LockRuntimeCoordinator(
      settings: _settings,
      bridge: MethodChannelPlatformLockBridge(),
    );
    _loadFuture = _initialize();
  }

  Future<void> _initialize() async {
    await _settings.load();
    await _runtime.start();
    _lockRequestSubscription = _runtime.lockRequests.listen(_handleLockRequest);
  }

  Future<void> _handleLockRequest(LockRequest request) async {
    if (!mounted || _lockScreenOpen || _settings.password == null) return;

    _lockScreenOpen = true;
    final unlocked = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => LockModeScreen(
          settings: _settings,
        ),
      ),
    );
    _lockScreenOpen = false;

    if (unlocked == true) {
      await _runtime.grantUnlock(request.appId);
    }
  }

  @override
  void dispose() {
    unawaited(_lockRequestSubscription?.cancel());
    unawaited(_runtime.stop());
    _settings.dispose();
    super.dispose();
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

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: appBackground,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: brandPurple,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '설정을 불러오지 못했습니다.',
                        style: TextStyle(
                          color: ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '앱을 다시 실행해 주세요.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              CustomizeScreen(settings: _settings),
              const ShopScreen(),
              LockSettingsScreen(settings: _settings),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome),
                label: '꾸미기',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: '상점',
              ),
              NavigationDestination(
                icon: Icon(Icons.lock_outline_rounded),
                selectedIcon: Icon(Icons.lock_rounded),
                label: '잠금 설정',
              ),
            ],
          ),
        );
      },
    );
  }
}
