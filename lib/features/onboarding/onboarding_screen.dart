import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../app/theme.dart';
import '../../lock_engine/models.dart';
import '../../lock_engine/platform_lock_bridge.dart';
import '../lock_settings/app_selection/app_selection_screen.dart';
import '../lock_settings/password_setup/password_setup_screen.dart';
import '../lock_settings/recovery_pin/recovery_pin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.settings,
    required this.onCompleted,
  });

  final MyLockSettingsController settings;
  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  final MethodChannelPlatformLockBridge _bridge =
      MethodChannelPlatformLockBridge();

  PlatformLockCapabilities? _capabilities;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.settings.addListener(_refresh);
    _refreshCapabilities();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.settings.removeListener(_refresh);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCapabilities();
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshCapabilities() async {
    final capabilities = await _bridge.getCapabilities();
    if (!mounted) return;

    setState(() {
      _capabilities = capabilities;
      _loading = false;
    });

    _completeIfReady();
  }

  int get _currentStep {
    final capabilities = _capabilities;
    if (capabilities?.accessibilityGranted != true) return 0;
    if (capabilities?.overlayGranted != true) return 1;
    if (widget.settings.password == null) return 2;
    if (!widget.settings.recoveryPinReady) return 3;
    if (widget.settings.selectedAppIds.isEmpty) return 4;
    return 5;
  }

  void _completeIfReady() {
    if (_currentStep != 5 || widget.settings.onboardingCompleted) return;
    widget.settings.completeOnboarding();
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.settings.onboardingStarted) {
      return _IntroScreen(
        onStart: widget.settings.startOnboarding,
      );
    }

    if (_loading) {
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

    if (kIsWeb || _capabilities?.nativeBridgeAvailable != true) {
      return Scaffold(
        backgroundColor: appBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: brandPurple,
                  size: 52,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Android 앱에서 설정을 완료하세요',
                  style: TextStyle(
                    color: ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '앱 잠금 권한과 실제 설치 앱 선택은 Android 설치본에서 사용할 수 있습니다.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final step = _currentStep;
    if (step == 5) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _completeIfReady());
    }

    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'MY LOCK 설정',
                style: TextStyle(
                  color: ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '처음 한 번만 필요한 설정입니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              _ProgressRow(currentStep: step),
              const SizedBox(height: 28),
              Expanded(
                child: _StepCard(
                  step: step,
                  onAction: _handleCurrentStep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCurrentStep() async {
    switch (_currentStep) {
      case 0:
        await _bridge.openAccessibilitySettings();
        break;
      case 1:
        await _bridge.openOverlaySettings();
        break;
      case 2:
        final pattern = await Navigator.of(context).push<List<LockToken>>(
          MaterialPageRoute(
            builder: (context) => PasswordSetupScreen(
              selectedShapes: widget.settings.selectedShapes,
              selectedTones: widget.settings.selectedTones,
            ),
          ),
        );
        if (pattern != null && pattern.isNotEmpty) {
          widget.settings.setPassword(pattern);
        }
        break;
      case 3:
        final pin = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (context) => const RecoveryPinScreen(),
          ),
        );
        if (pin != null) {
          widget.settings.setRecoveryPin(pin);
        }
        break;
      case 4:
        final selected = await Navigator.of(context).push<Set<String>>(
          MaterialPageRoute(
            builder: (context) => AppSelectionScreen(
              initialSelectedIds: widget.settings.selectedAppIds,
            ),
          ),
        );
        if (selected != null && selected.isNotEmpty) {
          widget.settings.setSelectedApps(selected);
        }
        break;
    }

    if (mounted) {
      await _refreshCapabilities();
    }
  }
}

class _IntroScreen extends StatelessWidget {
  const _IntroScreen({
    required this.onStart,
  });

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 78,
                height: 78,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: brandLavender,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  color: brandPurple,
                  size: 40,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                '움직이는 비밀번호로\n앱을 잠그세요',
                style: TextStyle(
                  color: ink,
                  fontSize: 29,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'MY LOCK은 선택한 앱을 열 때 도형과 색상으로 만든 그래픽 비밀번호를 보여주는 앱 잠금 도구입니다.\n\n잠금 화면의 움직임과 배치도 직접 설정할 수 있고, 비밀번호를 잊었을 때는 보조 PIN으로 복구할 수 있습니다.',
                style: TextStyle(
                  color: secondaryInk,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
              const _IntroFeature(
                icon: Icons.apps_rounded,
                text: '원하는 앱만 선택해서 보호',
              ),
              const SizedBox(height: 10),
              const _IntroFeature(
                icon: Icons.motion_photos_on_rounded,
                text: '움직이는 도형 기반 그래픽 비밀번호',
              ),
              const SizedBox(height: 10),
              const _IntroFeature(
                icon: Icons.pin_rounded,
                text: '분실 대비 4자리 보조 PIN',
              ),
              const Spacer(flex: 2),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: brandPurple,
                ),
                onPressed: onStart,
                child: const Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroFeature extends StatelessWidget {
  const _IntroFeature({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EDFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: brandPurple, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 5; i++) ...[
          if (i > 0) const SizedBox(width: 7),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 6,
              decoration: BoxDecoration(
                color: i <= currentStep
                    ? brandPurple
                    : const Color(0xFFE2DFE9),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.onAction,
  });

  final int step;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    final data = _stepData(step);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE9E5EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: brandLavender,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(data.icon, color: brandPurple, size: 28),
          ),
          const SizedBox(height: 22),
          Text(
            data.title,
            style: const TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.body,
            style: const TextStyle(
              color: secondaryInk,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const Spacer(),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: brandPurple,
            ),
            onPressed: step >= 5 ? null : () => onAction(),
            child: Text(data.button),
          ),
        ],
      ),
    );
  }

  _OnboardingStepData _stepData(int step) {
    switch (step) {
      case 0:
        return const _OnboardingStepData(
          icon: Icons.flash_on_rounded,
          title: '빠른 앱 감지',
          body:
              '보호 앱으로 화면이 바뀌는 순간을 Android가 MY LOCK에 알려주는 기능입니다. 화면 내용이나 입력 내용은 읽지 않고 앱 전환만 감지합니다.',
          button: '빠른 감지 켜기',
        );
      case 1:
        return const _OnboardingStepData(
          icon: Icons.layers_rounded,
          title: '다른 앱 위에 표시',
          body: '보호 앱이 열리면 MY LOCK 잠금 화면을 표시하기 위해 필요합니다.',
          button: '권한 설정',
        );
      case 2:
        return const _OnboardingStepData(
          icon: Icons.lock_rounded,
          title: '그래픽 비밀번호',
          body: '도형과 색상 조합을 순서대로 선택해 기본 잠금 비밀번호를 설정합니다.',
          button: '비밀번호 설정',
        );
      case 3:
        return const _OnboardingStepData(
          icon: Icons.pin_rounded,
          title: '보조 PIN',
          body: '그래픽 비밀번호를 잊었을 때 사용할 4자리 복구 PIN을 설정합니다.',
          button: 'PIN 설정',
        );
      case 4:
        return const _OnboardingStepData(
          icon: Icons.apps_rounded,
          title: '보호할 앱 선택',
          body: 'MY LOCK으로 잠글 앱을 하나 이상 선택하면 초기 설정이 완료됩니다.',
          button: '앱 선택',
        );
      default:
        return const _OnboardingStepData(
          icon: Icons.check_circle_rounded,
          title: '설정 완료',
          body: 'MY LOCK 보호 기능을 사용할 준비가 완료되었습니다.',
          button: '완료',
        );
    }
  }
}

class _OnboardingStepData {
  const _OnboardingStepData({
    required this.icon,
    required this.title,
    required this.body,
    required this.button,
  });

  final IconData icon;
  final String title;
  final String body;
  final String button;
}
