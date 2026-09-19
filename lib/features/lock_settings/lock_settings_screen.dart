import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../lock_engine/models.dart';
import 'password_setup/password_setup_screen.dart';

class LockSettingsScreen extends StatefulWidget {
  const LockSettingsScreen({super.key});

  @override
  State<LockSettingsScreen> createState() => _LockSettingsScreenState();
}

class _LockSettingsScreenState extends State<LockSettingsScreen> {
  List<LockToken>? _password;

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
          const _SettingTile(
            icon: Icons.apps_rounded,
            title: '잠글 앱',
            value: '선택 전',
          ),
          const _SettingTile(
            icon: Icons.tune_rounded,
            title: '화면 동작',
            value: '도형 보통 · 속도 보통',
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
