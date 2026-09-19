import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../lock_engine/effects.dart';
import '../../lock_engine/models.dart';
import 'app_selection/app_selection_screen.dart';
import 'password_setup/password_setup_screen.dart';
import 'screen_behavior/screen_behavior_screen.dart';

class LockSettingsScreen extends StatefulWidget {
  const LockSettingsScreen({super.key});

  @override
  State<LockSettingsScreen> createState() => _LockSettingsScreenState();
}

class _LockSettingsScreenState extends State<LockSettingsScreen> {
  List<LockToken>? _password;
  Set<String> _selectedAppIds = <String>{};
  int _objectCount = 9;
  FloatingSpeed _speed = FloatingSpeed.normal;

  @override
  Widget build(BuildContext context) {
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
          _SettingTile(
            icon: Icons.lock_rounded,
            title: '비밀번호',
            value: _password == null
                ? '설정 전'
                : '${_password!.length}자리 그래픽 패턴',
            onTap: _openPasswordSetup,
          ),
          _SettingTile(
            icon: Icons.apps_rounded,
            title: '잠글 앱',
            value: _selectedAppIds.isEmpty
                ? '선택 전'
                : '${_selectedAppIds.length}개 앱 보호 중',
            onTap: _openAppSelection,
          ),
          _SettingTile(
            icon: Icons.tune_rounded,
            title: '화면 동작',
            value: '도형 ${_objectCount}개 · 속도 ${_speedLabel(_speed)}',
            onTap: _openScreenBehavior,
          ),
          const _SettingTile(
            icon: Icons.schedule_rounded,
            title: '다시 잠그기',
            value: '앱을 벗어나면 즉시',
          ),
        ],
      ),
    );
  }

  Future<void> _openScreenBehavior() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => ScreenBehaviorScreen(
          objectCount: _objectCount,
          speed: _speed,
          onChanged: (objectCount, speed) {
            setState(() {
              _objectCount = objectCount;
              _speed = speed;
            });
          },
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

  Future<void> _openAppSelection() async {
    final selected = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (context) => AppSelectionScreen(
          initialSelectedIds: _selectedAppIds,
        ),
      ),
    );

    if (selected == null) return;
    setState(() => _selectedAppIds = Set<String>.from(selected));
  }

  Future<void> _openPasswordSetup() async {
    final pattern = await Navigator.of(context).push<List<LockToken>>(
      MaterialPageRoute(
        builder: (context) => const PasswordSetupScreen(),
      ),
    );

    if (pattern == null || pattern.isEmpty) return;
    setState(() => _password = pattern);
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFB3B0BB)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
