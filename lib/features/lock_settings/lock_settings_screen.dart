import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../app/theme.dart';
import '../../lock_engine/effects.dart';
import '../../lock_engine/models.dart';
import '../../lock_engine/platform_lock_bridge.dart';
import 'app_selection/app_selection_screen.dart';
import 'native_permissions/native_permissions_screen.dart';
import 'privacy_policy_screen.dart';
import 'password_setup/password_setup_screen.dart';
import 'recovery_pin/recovery_pin_screen.dart';
import 'relock/relock_screen.dart';
import 'screen_behavior/screen_behavior_screen.dart';

class LockSettingsScreen extends StatefulWidget {
  const LockSettingsScreen({
    super.key,
    required this.settings,
    this.webTestBridge,
  });

  final MyLockSettingsController settings;
  final WebTestPlatformLockBridge? webTestBridge;

  @override
  State<LockSettingsScreen> createState() => _LockSettingsScreenState();
}

class _LockSettingsScreenState extends State<LockSettingsScreen>
    with WidgetsBindingObserver {
  final MethodChannelPlatformLockBridge _platformBridge =
      MethodChannelPlatformLockBridge();

  PlatformLockCapabilities? _capabilities;
  bool _serviceRetryScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.settings.addListener(_refreshSettings);
    _refreshCapabilities();
  }

  @override
  void didUpdateWidget(covariant LockSettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings == widget.settings) return;
    oldWidget.settings.removeListener(_refreshSettings);
    widget.settings.addListener(_refreshSettings);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCapabilities();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.settings.removeListener(_refreshSettings);
    super.dispose();
  }

  void _refreshSettings() => setState(() {});

  Future<void> _refreshCapabilities() async {
    final capabilities = await _platformBridge.getCapabilities();
    if (!mounted) return;
    setState(() => _capabilities = capabilities);

    if (capabilities.nativeBridgeAvailable &&
        capabilities.androidReady &&
        !capabilities.monitorServiceRunning &&
        !_serviceRetryScheduled) {
      _serviceRetryScheduled = true;
      Future<void>.delayed(const Duration(milliseconds: 900), () async {
        if (!mounted) return;
        final refreshed = await _platformBridge.getCapabilities();
        if (!mounted) return;
        setState(() {
          _capabilities = refreshed;
          _serviceRetryScheduled = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final protectionReady =
        settings.password != null &&
        settings.selectedAppIds.isNotEmpty &&
        _capabilities?.androidReady == true &&
        _capabilities?.monitorServiceRunning == true;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        children: [
          Text('잠금 설정', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            '잠금 방식과 보호할 앱을 설정합니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          if (protectionReady) ...[
            _CompactProtectionStatus(
              onTap: _openNativePermissions,
            ),
            const SizedBox(height: 14),
          ] else ...[
            _ProtectionStatusCard(
              passwordReady: settings.password != null,
              appsReady: settings.selectedAppIds.isNotEmpty,
              capabilities: _capabilities,
              onPermissionsTap: _openNativePermissions,
            ),
            const SizedBox(height: 14),
            _SettingTile(
              icon: Icons.admin_panel_settings_outlined,
              title: '기기 권한',
              value: 'Android 권한 상태 확인',
              onTap: _openNativePermissions,
            ),
          ],
          _SettingTile(
            icon: Icons.lock_rounded,
            title: settings.password == null ? '비밀번호 설정' : '비밀번호 변경',
            value: settings.password == null
                ? '설정 전'
                : '${settings.password!.length}자리 그래픽 패턴',
            onTap: _openPasswordSetup,
          ),
          _SettingTile(
            icon: Icons.pin_rounded,
            title: settings.recoveryPinReady ? '보조 PIN 변경' : '보조 PIN 설정',
            value: settings.recoveryPinReady ? '4자리 PIN 설정됨' : '설정 전',
            onTap: _openRecoveryPinSetup,
          ),
          _SettingTile(
            icon: Icons.apps_rounded,
            title: '잠글 앱',
            value: settings.selectedAppIds.isEmpty
                ? '선택 전'
                : '${settings.selectedAppIds.length}개 앱 보호 중',
            onTap: _openAppSelection,
          ),
          _SettingTile(
            icon: Icons.tune_rounded,
            title: '화면 동작',
            value:
                '도형 ${settings.objectCount}개 · ${settings.movementArea.label} · 속도 ${_speedLabel(settings.speed)}',
            onTap: _openScreenBehavior,
          ),
          _SettingTile(
            icon: Icons.schedule_rounded,
            title: '다시 잠그기',
            value: settings.relockPolicy.summary,
            onTap: _openRelock,
          ),
          if (kIsWeb && widget.webTestBridge != null) ...[
            _WebTestPanel(
              settings: settings,
              bridge: widget.webTestBridge!,
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 8),
          const _SectionLabel(
            title: '실험 기능',
            badge: 'BETA',
          ),
          const SizedBox(height: 8),
          _ExperimentalScreenLockTile(
            enabled: settings.experimentalScreenLock,
            available: settings.password != null &&
                _capabilities?.overlayGranted == true,
            onChanged: settings.setExperimentalScreenLock,
          ),
          const SizedBox(height: 8),
          _SettingTile(
            icon: Icons.play_circle_outline_rounded,
            title: '잠금화면 테스트',
            value: settings.password == null
                ? '비밀번호 설정 후 테스트 가능'
                : '현재 설정으로 잠금 해제 흐름 확인',
            onTap: settings.password == null ? null : _openLockTest,
          ),
          _SettingTile(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보처리방침',
            value: 'MyLock의 데이터 처리 안내',
            onTap: _openPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  Future<void> _openNativePermissions() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => const NativePermissionsScreen(),
      ),
    );
  }

  Future<void> _openLockTest() async {
    await _platformBridge.presentLockScreen(
      '__my_lock_demo__',
      demoMode: true,
    );
  }

  Future<void> _openPrivacyPolicy() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  Future<void> _openRelock() async {
    final settings = widget.settings;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => RelockScreen(
          selectedPolicy: settings.relockPolicy,
          onChanged: settings.setRelockPolicy,
        ),
      ),
    );
  }

  Future<void> _openScreenBehavior() async {
    final settings = widget.settings;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => ScreenBehaviorScreen(
          objectCount: settings.objectCount,
          speed: settings.speed,
          movementArea: settings.movementArea,
          onChanged: settings.setScreenBehavior,
        ),
      ),
    );
  }

  String _speedLabel(FloatingSpeed speed) {
    switch (speed) {
      case FloatingSpeed.slow:
        return '느리게';
      case FloatingSpeed.normal:
        return '보통';
      case FloatingSpeed.fast:
        return '빠르게';
    }
  }

  Future<void> _openRecoveryPinSetup() async {
    final pin = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const RecoveryPinScreen(),
      ),
    );

    if (pin == null) return;
    widget.settings.setRecoveryPin(pin);
  }

  Future<void> _openAppSelection() async {
    final selected = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (context) => AppSelectionScreen(
          initialSelectedIds: widget.settings.selectedAppIds,
        ),
      ),
    );

    if (selected == null) return;
    widget.settings.setSelectedApps(selected);
  }

  Future<void> _openPasswordSetup() async {
    final pattern = await Navigator.of(context).push<List<LockToken>>(
      MaterialPageRoute(
        builder: (context) => PasswordSetupScreen(
          selectedShapes: widget.settings.selectedShapes,
          selectedTones: widget.settings.selectedTones,
          texture: widget.settings.texture,
        ),
      ),
    );

    if (pattern == null || pattern.isEmpty) return;
    widget.settings.setPassword(pattern);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.badge,
  });

  final String title;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ink,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: brandLavender,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              color: brandPurple,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _WebTestPanel extends StatelessWidget {
  const _WebTestPanel({
    required this.settings,
    required this.bridge,
  });

  final MyLockSettingsController settings;
  final WebTestPlatformLockBridge bridge;

  @override
  Widget build(BuildContext context) {
    final appId =
        settings.selectedAppIds.isEmpty ? null : settings.selectedAppIds.first;
    final ready = appId != null && settings.password != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCFC4FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science_outlined, color: brandPurple),
              SizedBox(width: 9),
              Text(
                'WEB TEST',
                style: TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            ready
                ? 'Android 권한과 앱 전환 이벤트를 웹에서 시뮬레이션합니다.'
                : '비밀번호와 보호 앱을 먼저 설정하면 실제 잠금 흐름을 테스트할 수 있습니다.',
            style: const TextStyle(
              color: secondaryInk,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: ready
                    ? () => bridge.simulateProtectedAppEnter(appId)
                    : null,
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('보호 앱 실행'),
              ),
              FilledButton.tonalIcon(
                onPressed: appId == null
                    ? null
                    : () => bridge.simulateProtectedAppExit(appId),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('앱 종료'),
              ),
              FilledButton.tonalIcon(
                onPressed: bridge.simulateScreenOff,
                icon: const Icon(Icons.screen_lock_portrait_rounded, size: 18),
                label: const Text('화면 OFF'),
              ),
              FilledButton.tonalIcon(
                onPressed: settings.experimentalScreenLock &&
                        settings.password != null
                    ? bridge.simulateScreenOn
                    : null,
                icon: const Icon(Icons.phone_android_rounded, size: 18),
                label: const Text('화면 ON'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExperimentalScreenLockTile extends StatelessWidget {
  const _ExperimentalScreenLockTile({
    required this.enabled,
    required this.available,
    required this.onChanged,
  });

  final bool enabled;
  final bool available;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 12, 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0E2B8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2C9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.phone_android_rounded,
              color: Color(0xFFA77300),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '화면 켤 때 MY LOCK',
                  style: TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  available
                      ? '휴대폰 화면이 켜질 때 MY LOCK을 추가 잠금으로 표시합니다. 시스템 PIN·지문 잠금을 대체하지 않습니다.'
                      : '그래픽 비밀번호와 다른 앱 위에 표시 권한이 필요합니다.',
                  style: const TextStyle(
                    color: secondaryInk,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled && available,
            onChanged: available ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDEBF2)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: brandLavender,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: brandPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB3B0BB),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _CompactProtectionStatus extends StatelessWidget {
  const _CompactProtectionStatus({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0EDFF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFCFC4FF)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.shield_rounded,
                color: brandPurple,
                size: 20,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  '보호 ON',
                  style: TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '정상 작동 중',
                style: TextStyle(
                  color: brandPurple,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: brandPurple,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProtectionStatusCard extends StatelessWidget {
  const _ProtectionStatusCard({
    required this.passwordReady,
    required this.appsReady,
    required this.capabilities,
    required this.onPermissionsTap,
  });

  final bool passwordReady;
  final bool appsReady;
  final PlatformLockCapabilities? capabilities;
  final VoidCallback onPermissionsTap;

  @override
  Widget build(BuildContext context) {
    final nativeAvailable = capabilities?.nativeBridgeAvailable == true;
    final permissionsReady = capabilities?.androidReady == true;
    final serviceRunning = capabilities?.monitorServiceRunning == true;
    final ready =
        passwordReady && appsReady && permissionsReady && serviceRunning;

    final title = ready
        ? '보호 ON'
        : nativeAvailable
            ? '보호 설정을 확인해 주세요'
            : '웹 미리보기 모드';

    final subtitle = ready
        ? '감지 서비스가 실행 중이며 선택한 앱을 보호하고 있습니다.'
        : nativeAvailable
            ? _missingSummary(permissionsReady, serviceRunning)
            : '실제 앱 감지와 권한 상태는 Android 설치본에서 활성화됩니다.';

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: ready ? const Color(0xFFF0EDFF) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ready
              ? const Color(0xFFCFC4FF)
              : const Color(0xFFEDEBF2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: brandLavender,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  ready
                      ? Icons.shield_rounded
                      : Icons.shield_outlined,
                  color: brandPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: secondaryInk,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (nativeAvailable && !ready) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(label: '비밀번호', ready: passwordReady),
                _StatusChip(label: '보호 앱', ready: appsReady),
                _StatusChip(label: '기기 권한', ready: permissionsReady),
                _StatusChip(label: '보호 서비스', ready: serviceRunning),
              ],
            ),
            if (!permissionsReady) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onPermissionsTap,
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: const Text('권한 설정'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _missingSummary(
    bool permissionsReady,
    bool serviceRunning,
  ) {
    final missing = <String>[
      if (!passwordReady) '비밀번호',
      if (!appsReady) '보호 앱',
      if (!permissionsReady) '기기 권한',
      if (!serviceRunning) '보호 서비스',
    ];
    return '${missing.join(' · ')} 설정이 필요합니다.';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.ready,
  });

  final String label;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: ready ? brandLavender : const Color(0xFFF4F3F7),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ready ? Icons.check_rounded : Icons.remove_rounded,
            size: 14,
            color: ready ? brandPurple : secondaryInk,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: ready ? brandPurple : secondaryInk,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
