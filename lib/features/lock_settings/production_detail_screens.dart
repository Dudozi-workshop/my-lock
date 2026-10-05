import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../app/theme.dart';
import '../../widgets/production_ui.dart';
import 'privacy_policy_screen.dart';

class FeedbackSettingsScreen extends StatelessWidget {
  const FeedbackSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        title: const Text('효과음 & 진동'),
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: const [
          ProductionSettingsGroup(
            title: '피드백',
            children: [
              ProductionSettingsRow(
                icon: Icons.vibration_rounded,
                title: '진동',
                value: '도형을 누를 때 가벼운 진동을 사용합니다.',
                iconBackground: productionBlue,
                iconColor: productionBlueInk,
              ),
              ProductionSettingsRow(
                icon: Icons.volume_up_rounded,
                title: '효과음',
                value: '실제 사운드가 준비되는 항목부터 순차 제공됩니다.',
                iconBackground: productionPink,
                iconColor: productionPinkInk,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LaboratoryScreen extends StatelessWidget {
  const LaboratoryScreen({
    super.key,
    required this.settings,
    required this.available,
  });

  final MyLockSettingsController settings;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        title: const Text('실험실'),
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          Container(
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
                    color: productionWarm,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    color: productionWarmInk,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '화면 켤 때 MY LOCK',
                              style: TextStyle(
                                color: ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(width: 7),
                          _BetaBadge(),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '휴대폰 화면이 켜질 때 MY LOCK을 추가 잠금으로 표시합니다.',
                        style: TextStyle(
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
                  value: settings.experimentalScreenLock && available,
                  onChanged:
                      available ? settings.setExperimentalScreenLock : null,
                ),
              ],
            ),
          ),
          if (!available) ...[
            const SizedBox(height: 10),
            const Text(
              '그래픽 비밀번호와 다른 앱 위에 표시 권한이 필요합니다.',
              style: TextStyle(
                color: secondaryInk,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        title: const Text('도움 주신 분들'),
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: const [
          ProductionSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY LOCK을 함께 만들어주신 분들께 감사드립니다.',
                  style: TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '테스트, 아이디어, 디자인 및 피드백 기여 정보는 실제 기여가 확정된 항목부터 이 화면에 표시됩니다.',
                  style: TextStyle(
                    color: secondaryInk,
                    fontSize: 13,
                    height: 1.5,
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

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        title: const Text('앱 정보'),
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          ProductionSettingsGroup(
            title: 'MY LOCK',
            children: [
              const ProductionSettingsRow(
                icon: Icons.info_outline_rounded,
                title: '앱 버전',
                value: '0.1.2 (3)',
                showDivider: true,
              ),
              ProductionSettingsRow(
                icon: Icons.code_rounded,
                title: '오픈소스 라이선스',
                value: '사용 중인 오픈소스 라이선스 보기',
                showDivider: true,
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'MY LOCK',
                    applicationVersion: '0.1.2+3',
                  );
                },
              ),
              ProductionSettingsRow(
                icon: Icons.chat_bubble_outline_rounded,
                title: '문의 · 피드백',
                value: '출시 피드백 채널 연결 예정',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('문의 · 피드백 채널은 출시 준비 중입니다.'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          ProductionSettingsGroup(
            title: '개인정보',
            children: [
              ProductionSettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보처리방침',
                value: 'MY LOCK의 데이터 처리 안내',
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BetaBadge extends StatelessWidget {
  const _BetaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: brandLavender,
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        'BETA',
        style: TextStyle(
          color: brandPurple,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
