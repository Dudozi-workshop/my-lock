import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/platform_lock_bridge.dart';

class NativePermissionsScreen extends StatefulWidget {
  const NativePermissionsScreen({super.key});

  @override
  State<NativePermissionsScreen> createState() =>
      _NativePermissionsScreenState();
}

class _NativePermissionsScreenState extends State<NativePermissionsScreen>
    with WidgetsBindingObserver {
  final MethodChannelPlatformLockBridge _bridge =
      MethodChannelPlatformLockBridge();

  PlatformLockCapabilities? _capabilities;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() => _loading = true);
    }

    final capabilities = await _bridge.getCapabilities();

    if (!mounted) return;
    setState(() {
      _capabilities = capabilities;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final capabilities = _capabilities;

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '기기 권한',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              '선택한 앱을 감지하고 잠금화면을 표시하기 위해 필요한 권한입니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 42),
                child: Center(
                  child: CircularProgressIndicator(
                    color: brandPurple,
                    strokeWidth: 2.4,
                  ),
                ),
              )
            else if (kIsWeb || capabilities?.nativeBridgeAvailable != true)
              _InfoCard(
                icon: Icons.language_rounded,
                title: '웹 미리보기',
                body:
                    '웹에서는 실제 기기 권한을 사용할 수 없습니다. Android 앱 빌드에서 권한 상태를 확인할 수 있습니다.',
              )
            else ...[
              _PermissionCard(
                icon: Icons.query_stats_rounded,
                title: '앱 사용 정보 접근',
                body: '현재 화면에 열린 앱을 감지하는 데 사용합니다.',
                granted: capabilities!.usageAccessGranted,
                onTap: capabilities.usageAccessGranted
                    ? null
                    : _bridge.openUsageAccessSettings,
              ),
              const SizedBox(height: 10),
              _PermissionCard(
                icon: Icons.layers_rounded,
                title: '다른 앱 위에 표시',
                body: '보호 앱 위에 MY LOCK 잠금 화면을 표시하는 데 사용합니다.',
                granted: capabilities.overlayGranted,
                onTap: capabilities.overlayGranted
                    ? null
                    : _bridge.openOverlaySettings,
              ),
              const SizedBox(height: 18),
              _InfoCard(
                icon: capabilities.androidReady
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                title: capabilities.androidReady
                    ? '필수 권한 준비 완료'
                    : '권한 설정이 필요합니다',
                body: capabilities.androidReady
                    ? 'Android 잠금 감지 기능을 연결할 준비가 완료되었습니다.'
                    : '위 두 권한을 모두 허용해야 실제 앱 잠금 기능을 사용할 수 있습니다.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.granted,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool granted;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: granted ? const Color(0xFFCFC4FF) : const Color(0xFFE8E5ED),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: brandLavender,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: brandPurple),
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
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: secondaryInk,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (granted)
            const Icon(
              Icons.check_circle_rounded,
              color: brandPurple,
              size: 26,
            )
          else
            FilledButton(
              onPressed: onTap == null ? null : () => onTap!(),
              child: const Text('설정'),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: brandPurple, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF665C8F),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
