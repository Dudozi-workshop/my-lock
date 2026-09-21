import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../app/theme.dart';
import '../../lock_engine/floating_preview.dart';
import '../../lock_engine/models.dart';
import '../../lock_engine/platform_lock_bridge.dart';
import '../lock_settings/password_setup/password_setup_screen.dart';
import '../lock_settings/recovery_pin/recovery_pin_screen.dart';
import 'lock_mode_controller.dart';
import 'pin_failure_policy.dart';

class LockModeScreen extends StatefulWidget {
  const LockModeScreen({
    super.key,
    required this.settings,
    this.demoMode = false,
    this.appAuthentication = false,
    this.authenticationAttemptIsCurrent,
    this.onDeviceRecovered,
    this.onOpenAppRecovery,
    this.onUnlocked,
  });

  final MyLockSettingsController settings;
  final bool demoMode;
  final bool appAuthentication;
  final bool Function()? authenticationAttemptIsCurrent;
  final Future<void> Function()? onDeviceRecovered;
  final Future<void> Function()? onOpenAppRecovery;
  final Future<void> Function()? onUnlocked;

  @override
  State<LockModeScreen> createState() => _LockModeScreenState();
}

class _LockModeScreenState extends State<LockModeScreen>
    with WidgetsBindingObserver {
  late final LockModeController _controller;
  bool _finishing = false;
  bool _allowRoutePop = false;
  bool _recoverySheetOpen = false;
  int _recoveryPinFailures = 0;

  bool get _canUseRecoveryPin => widget.settings.recoveryPinReady;

  bool get _authenticationAttemptIsCurrent =>
      widget.authenticationAttemptIsCurrent?.call() ?? true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final password = widget.settings.password;
    assert(password != null && password.length >= 2);
    _controller = LockModeController(password!)..addListener(_refresh);
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
    if (_controller.unlocked && !_finishing) {
      _finishUnlock();
    }
  }

  Future<void> _finishUnlock() async {
    if (_finishing) return;
    if (!_authenticationAttemptIsCurrent) return;

    setState(() {
      _finishing = true;
      _allowRoutePop = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted || !_authenticationAttemptIsCurrent) {
      if (mounted) {
        setState(() {
          _finishing = false;
          _allowRoutePop = false;
          _controller.reset();
        });
      }
      return;
    }
    final onUnlocked = widget.onUnlocked;
    if (onUnlocked != null) {
      await onUnlocked();
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.appAuthentication) return;
    if (state != AppLifecycleState.paused &&
        state != AppLifecycleState.hidden &&
        state != AppLifecycleState.inactive) {
      return;
    }

    _controller.reset();

    if (_recoverySheetOpen && mounted) {
      Navigator.of(context, rootNavigator: true).maybePop(false);
      _recoverySheetOpen = false;
    }

    if (mounted) {
      setState(() {
        _finishing = false;
        _allowRoutePop = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;

    return PopScope(
      canPop: widget.demoMode || _allowRoutePop,
      child: Scaffold(
        body: Container(
        decoration: BoxDecoration(gradient: settings.background.gradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: FloatingPreview(
                selectedShapes: settings.selectedShapes,
                selectedTones: settings.selectedTones,
                movementStyle: settings.movementStyle,
                popStyle: settings.popStyle,
                objectCount: settings.objectCount,
                speed: settings.speed,
                movementArea: settings.movementArea,
                topInset: widget.appAuthentication
                    ? 220
                    : (_canUseRecoveryPin ? 178 : 142),
                requiredTokens: _controller.requiredTokens,
                onTokenTap: _controller.tap,
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: MediaQuery.paddingOf(context).top + 12,
              child: _Header(
                  demoMode: widget.demoMode,
                  appAuthentication: widget.appAuthentication,
                  progress: _controller.progress,
                  passwordLength: _controller.passwordLength,
                  mismatch: _controller.mismatch,
                  showRecoveryPin: _canUseRecoveryPin,
                  onRecoveryPin: _openRecoveryPin,
                  onDeviceRecovery:
                      widget.appAuthentication ? _recoverWithDeviceOwner : null,
                  onClose: () => Navigator.of(context).pop(false),
                ),
              ),
              if (_controller.unlocked)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.46),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F4D3A8A),
                              blurRadius: 30,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: brandPurple,
                              size: 52,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '잠금 해제',
                              style: TextStyle(
                                color: ink,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _recoverWithDeviceOwner() async {
    if (!widget.appAuthentication || _finishing) return;

    final authenticated =
        await MethodChannelPlatformLockBridge().authenticateDeviceOwner();
    if (!authenticated || !mounted) return;

    final pattern = await Navigator.of(context).push<List<LockToken>>(
      MaterialPageRoute(
        builder: (context) => PasswordSetupScreen(
          selectedShapes: widget.settings.selectedShapes,
          selectedTones: widget.settings.selectedTones,
          recoveryMode: true,
        ),
      ),
    );
    if (pattern == null || pattern.isEmpty || !mounted) return;

    final pin = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const RecoveryPinScreen(
          recoveryMode: true,
        ),
      ),
    );
    if (pin == null || !mounted) return;

    widget.settings.setPassword(pattern);
    widget.settings.setRecoveryPin(pin);

    setState(() {
      _finishing = true;
      _allowRoutePop = true;
    });

    final onDeviceRecovered = widget.onDeviceRecovered;
    if (onDeviceRecovered != null) {
      await onDeviceRecovered();
      return;
    }

    final onUnlocked = widget.onUnlocked;
    if (onUnlocked != null) {
      await onUnlocked();
      return;
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _openRecoveryPin() async {
    if (!_canUseRecoveryPin || _finishing) return;

    var input = '';
    var mismatch = false;
    var pinFailures = _recoveryPinFailures;

    _recoverySheetOpen = true;
    final unlocked = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void addDigit(int digit) {
              if (input.length >= 4) return;
              setModalState(() {
                mismatch = false;
                input += digit.toString();
              });

              if (input.length == 4) {
                final correct = widget.settings.verifyRecoveryPin(input);
                if (correct) {
                  _recoveryPinFailures = 0;
                  Navigator.of(sheetContext).pop(true);
                } else {
                  pinFailures++;
                  _recoveryPinFailures = pinFailures;
                  Future<void>.delayed(
                    const Duration(milliseconds: 120),
                    () {
                      if (!sheetContext.mounted) return;
                      setModalState(() {
                        input = '';
                        mismatch = true;
                      });
                    },
                  );
                }
              }
            }

            void removeLast() {
              if (input.isEmpty) return;
              setModalState(() {
                mismatch = false;
                input = input.substring(0, input.length - 1);
              });
            }

            return _RecoveryPinSheet(
              length: input.length,
              mismatch: mismatch,
              failedAttempts: pinFailures,
              appAuthentication: widget.appAuthentication,
              onDigit: addDigit,
              onBackspace: removeLast,
              onOpenAppRecovery: widget.onOpenAppRecovery == null
                  ? null
                  : () async {
                      Navigator.of(sheetContext).pop(false);
                      await widget.onOpenAppRecovery!();
                    },
            );
          },
        );
      },
    );

    _recoverySheetOpen = false;

    if (unlocked != true ||
        !mounted ||
        _finishing ||
        !_authenticationAttemptIsCurrent) {
      return;
    }

    setState(() {
      _finishing = true;
      _allowRoutePop = true;
    });
    final onUnlocked = widget.onUnlocked;
    if (onUnlocked != null) {
      await onUnlocked();
      return;
    }
    Navigator.of(context).pop(true);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.demoMode,
    required this.appAuthentication,
    required this.progress,
    required this.passwordLength,
    required this.mismatch,
    required this.showRecoveryPin,
    required this.onRecoveryPin,
    required this.onDeviceRecovery,
    required this.onClose,
  });

  final bool demoMode;
  final bool appAuthentication;
  final int progress;
  final int passwordLength;
  final bool mismatch;
  final bool showRecoveryPin;
  final VoidCallback onRecoveryPin;
  final VoidCallback? onDeviceRecovery;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (demoMode)
                IconButton(
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded),
                )
              else
                const SizedBox(width: 40),
              Expanded(
                child: Text(
                  appAuthentication ? 'MY LOCK 열기' : 'MY LOCK',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            mismatch
                ? '순서가 달라요. 처음부터 다시 눌러주세요.'
                : appAuthentication
                    ? 'MY LOCK을 열려면 인증하세요.'
                    : '도형을 순서대로 눌러 잠금을 해제하세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mismatch ? const Color(0xFFD94262) : secondaryInk,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < passwordLength; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < progress
                        ? brandPurple
                        : const Color(0xFFDAD7E1),
                  ),
                ),
              ],
            ],
          ),
          if (showRecoveryPin) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRecoveryPin,
              icon: const Icon(Icons.pin_rounded, size: 17),
              label: Text(appAuthentication ? 'PIN으로 인증' : '보조 PIN 사용'),
            ),
          ],
          if (onDeviceRecovery != null) ...[
            const SizedBox(height: 2),
            TextButton(
              onPressed: onDeviceRecovery,
              child: const Text('비밀번호와 PIN을 모두 잊으셨나요?'),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecoveryPinSheet extends StatelessWidget {
  const _RecoveryPinSheet({
    required this.length,
    required this.mismatch,
    required this.failedAttempts,
    required this.appAuthentication,
    required this.onDigit,
    required this.onBackspace,
    required this.onOpenAppRecovery,
  });

  final int length;
  final bool mismatch;
  final int failedAttempts;
  final bool appAuthentication;
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final Future<void> Function()? onOpenAppRecovery;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        decoration: const BoxDecoration(
          color: appBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '보조 PIN',
              style: TextStyle(
                color: ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              mismatch ? 'PIN이 일치하지 않습니다.' : '설정한 4자리 PIN을 입력하세요.',
              style: TextStyle(
                color: mismatch ? const Color(0xFFD94262) : secondaryInk,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < length ? brandPurple : Colors.transparent,
                      border: Border.all(
                        color: i < length
                            ? brandPurple
                            : const Color(0xFFCBC7D3),
                        width: 1.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (shouldOfferOverlayRecovery(
              failedAttempts: failedAttempts,
              appAuthentication: appAuthentication,
            )) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onOpenAppRecovery,
                child: const Text('비밀번호와 PIN을 모두 잊으셨나요?'),
              ),
            ],
            const SizedBox(height: 22),
            _RecoveryNumberPad(
              onDigit: onDigit,
              onBackspace: onBackspace,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryNumberPad extends StatelessWidget {
  const _RecoveryNumberPad({
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const rows = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ];

    return Column(
      children: [
        for (final row in rows) ...[
          Row(
            children: [
              for (var i = 0; i < row.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _PinKey(
                    label: row[i].toString(),
                    onTap: () => onDigit(row[i]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            const Expanded(child: SizedBox(height: 56)),
            const SizedBox(width: 10),
            Expanded(
              child: _PinKey(
                label: '0',
                onTap: () => onDigit(0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 56,
                child: IconButton(
                  onPressed: onBackspace,
                  icon: const Icon(Icons.backspace_outlined),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8E5ED)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: ink,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
