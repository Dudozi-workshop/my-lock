import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../lock_engine/floating_preview.dart';

class CustomizeRuntimePreviewScreen extends StatefulWidget {
  const CustomizeRuntimePreviewScreen({
    super.key,
    required this.settings,
  });

  final MyLockSettingsController settings;

  @override
  State<CustomizeRuntimePreviewScreen> createState() =>
      _CustomizeRuntimePreviewScreenState();
}

class _CustomizeRuntimePreviewScreenState
    extends State<CustomizeRuntimePreviewScreen> {
  Timer? _hintTimer;
  bool _showHint = true;
  int _shuffleSeed = 0;

  @override
  void initState() {
    super.initState();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _reshuffle() {
    HapticFeedback.selectionClick();
    setState(() => _shuffleSeed++);
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: settings.background.gradient),
              child: KeyedSubtree(
                key: ValueKey(_shuffleSeed),
                child: FloatingPreview(
                  selectedShapes: settings.selectedShapes,
                  selectedTones: settings.selectedTones,
                  movementStyle: settings.movementStyle,
                  popStyle: settings.popStyle,
                  style: settings.style,
                  objectCount: settings.objectCount,
                  speed: settings.speed,
                  movementArea: settings.movementArea,
                  topInset: topPadding + 64,
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 10,
            right: 16,
            child: _GlassIconButton(
              icon: Icons.close_rounded,
              semanticLabel: '미리보기 닫기',
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _showHint
                  ? Container(
                      key: const ValueKey('hint'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Text(
                        '도형을 눌러 반응을 확인해보세요 · × 또는 뒤로가기로 종료',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF4E4A59),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : Align(
                      key: const ValueKey('shuffle'),
                      alignment: Alignment.center,
                      child: FilledButton.tonalIcon(
                        onPressed: _reshuffle,
                        icon: const Icon(Icons.shuffle_rounded, size: 19),
                        label: const Text('다시 섞기'),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.90),
                          foregroundColor: const Color(0xFF7659F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.white.withValues(alpha: 0.90),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: const Color(0xFF4D4659), size: 24),
          ),
        ),
      ),
    );
  }
}
