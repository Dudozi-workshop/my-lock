import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../app/theme.dart';
import '../../lock_engine/lock_runtime_coordinator.dart';
import '../../lock_engine/platform_lock_bridge.dart';
import '../app_auth/app_auth_session.dart';
import '../onboarding/onboarding_screen.dart';
import '../customize/customize_screen.dart';
import '../lock_settings/lock_settings_screen.dart';
import '../lock_mode/lock_mode_screen.dart';
import '../shop/shop_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> with WidgetsBindingObserver {
  int _index = 0;
  late final MyLockSettingsController _settings;
  late final LockRuntimeCoordinator _runtime;
  late final PlatformLockBridge _platformBridge;
  WebTestPlatformLockBridge? _webBridge;
  StreamSubscription<LockRequest>? _lockRequestSubscription;
  late final Future<void> _loadFuture;
  final AppAuthSession _appAuth = AppAuthSession();
  Timer? _inactiveRelockTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settings = MyLockSettingsController()..addListener(_refreshSettings);
    if (kIsWeb) {
      _webBridge = WebTestPlatformLockBridge();
      _platformBridge = _webBridge!;
    } else {
      _platformBridge = MethodChannelPlatformLockBridge();
    }
    _runtime = LockRuntimeCoordinator(
      settings: _settings,
      bridge: _platformBridge,
    );
    _lockRequestSubscription = _runtime.lockRequests.listen(_handleLockRequest);
    _loadFuture = _initialize();
  }

  Future<void> _initialize() async {
    await _settings.load();
    _appAuth.initialize(
      onboardingCompleted: _settings.onboardingCompleted,
      hasPassword: _settings.password != null,
    );
    await _runtime.start();
  }

  void _refreshSettings() {
    if (mounted) setState(() {});
  }

  Future<void> _handleLockRequest(LockRequest request) async {
    if (!mounted || _settings.password == null) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => LockModeScreen(
          settings: _settings,
          onUnlocked: () async {
            await _runtime.grantUnlock(request.appId);
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_settings.loaded ||
        !_settings.onboardingCompleted ||
        _settings.password == null) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _inactiveRelockTimer?.cancel();
      _inactiveRelockTimer = Timer(
        const Duration(milliseconds: 700),
        () {
          if (WidgetsBinding.instance.lifecycleState !=
              AppLifecycleState.inactive) {
            return;
          }
          _appAuth.markUnauthenticated();
        },
      );
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _inactiveRelockTimer?.cancel();
      _inactiveRelockTimer = null;
      _appAuth.markUnauthenticated();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _inactiveRelockTimer?.cancel();
      _inactiveRelockTimer = null;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _inactiveRelockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_lockRequestSubscription?.cancel());
    unawaited(_runtime.stop());
    _settings.removeListener(_refreshSettings);
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

        if (!_settings.onboardingCompleted) {
          return OnboardingScreen(
            settings: _settings,
            onCompleted: () {
              if (mounted) setState(() {});
            },
          );
        }

        if (_appAuth.requiresAuthentication(
          onboardingCompleted: _settings.onboardingCompleted,
          hasPassword: _settings.password != null,
        )) {
          final authGeneration = _appAuth.generation;
          return LockModeScreen(
            settings: _settings,
            appAuthentication: true,
            authenticationAttemptIsCurrent: () =>
                _appAuth.isAttemptCurrent(authGeneration),
            onDeviceRecovered: () async {
              _appAuth.markAuthenticated(
                generation: _appAuth.generation,
              );
              if (mounted) setState(() {});
            },
            onUnlocked: () async {
              final authenticated = _appAuth.markAuthenticated(
                generation: authGeneration,
              );
              if (authenticated && mounted) setState(() {});
            },
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              CustomizeScreen(settings: _settings),
              const ShopScreen(),
              LockSettingsScreen(
                settings: _settings,
                webTestBridge: _webBridge,
              ),
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
