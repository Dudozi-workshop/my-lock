import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../app/theme.dart';
import '../../lock_engine/floating_preview.dart';
import '../../lock_engine/models.dart';
import 'lock_mode_controller.dart';

class LockModeScreen extends StatefulWidget {
  const LockModeScreen({
    super.key,
    required this.settings,
    this.demoMode = false,
  });

  final MyLockSettingsController settings;
  final bool demoMode;

  @override
  State<LockModeScreen> createState() => _LockModeScreenState();
}

class _LockModeScreenState extends State<LockModeScreen> {
  late final LockModeController _controller;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    final password = widget.settings.password;
    assert(password != null && password.length >= 3);
    _controller = LockModeController(password!)..addListener(_refresh);
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
    if (_controller.unlocked && !_finishing) {
      _finishing = true;
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      });
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: settings.background.gradient),
        child: SafeArea(
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
                  requiredTokens: _controller.requiredTokens,
                  onTokenTap: _controller.tap,
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                top: 12,
                child: _Header(
                  demoMode: widget.demoMode,
                  progress: _controller.progress,
                  passwordLength: _controller.passwordLength,
                  mismatch: _controller.mismatch,
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
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.demoMode,
    required this.progress,
    required this.passwordLength,
    required this.mismatch,
    required this.onClose,
  });

  final bool demoMode;
  final int progress;
  final int passwordLength;
  final bool mismatch;
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
              const Expanded(
                child: Text(
                  'MY LOCK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
        ],
      ),
    );
  }
}
