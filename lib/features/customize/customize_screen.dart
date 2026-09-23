import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../app/theme.dart';
import '../../lock_engine/floating_preview.dart';
import '../../widgets/customization_card.dart';
import 'background/background_screen.dart';
import 'effects/effects_screen.dart';
import 'shape_style_screen.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({
    super.key,
    required this.settings,
  });

  final MyLockSettingsController settings;

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant CustomizeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings == widget.settings) return;
    oldWidget.settings.removeListener(_refresh);
    widget.settings.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.settings.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final previewHeight =
              (constraints.maxHeight * 0.48).clamp(300.0, 440.0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY LOCK',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '나만의 잠금화면을 꾸며보세요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Container(
                  height: previewHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: settings.background.gradient,
                    border: Border.all(color: const Color(0xFFE9E4F3)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x173F2E83),
                        blurRadius: 28,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
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
                        ),
                      ),
                      Positioned(
                        top: 18,
                        right: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: brandPurple,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        bottom: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            '도형을 눌러보세요',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF615D6A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomizationCard(
                  icon: Icons.wallpaper_rounded,
                  title: '배경',
                  subtitle: settings.background.label,
                  onTap: () => _openBackground(context),
                ),
                const SizedBox(height: 10),
                CustomizationCard(
                  icon: Icons.category_rounded,
                  title: '도형 & 스타일',
                  subtitle: _styleSummary,
                  onTap: () => _openShapeStyle(context),
                ),
                const SizedBox(height: 10),
                CustomizationCard(
                  icon: Icons.auto_fix_high_rounded,
                  title: '효과',
                  subtitle:
                      '${settings.movementStyle.label} · ${settings.popStyle.label}',
                  onTap: () => _openEffects(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String get _styleSummary {
    final settings = widget.settings;
    return '도형 ${settings.selectedShapes.length}개 · 색상 ${settings.selectedTones.length}개 · Basic Glossy';
  }

  Future<void> _openEffects(BuildContext context) async {
    final settings = widget.settings;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => EffectsScreen(
          background: settings.background,
          selectedShapes: settings.selectedShapes,
          selectedTones: settings.selectedTones,
          movementStyle: settings.movementStyle,
          popStyle: settings.popStyle,
          objectCount: settings.objectCount,
          speed: settings.speed,
          movementArea: settings.movementArea,
          onChanged: settings.setEffects,
        ),
      ),
    );
  }

  Future<void> _openBackground(BuildContext context) async {
    final settings = widget.settings;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => BackgroundScreen(
          selectedBackground: settings.background,
          selectedShapes: settings.selectedShapes,
          selectedTones: settings.selectedTones,
          movementStyle: settings.movementStyle,
          popStyle: settings.popStyle,
          objectCount: settings.objectCount,
          speed: settings.speed,
          movementArea: settings.movementArea,
          onChanged: settings.setBackground,
        ),
      ),
    );
  }

  Future<void> _openShapeStyle(BuildContext context) async {
    final settings = widget.settings;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => ShapeStyleScreen(
          selectedShapes: settings.selectedShapes,
          selectedTones: settings.selectedTones,
          currentPassword: settings.password,
          background: settings.background,
          movementStyle: settings.movementStyle,
          popStyle: settings.popStyle,
          objectCount: settings.objectCount,
          speed: settings.speed,
          movementArea: settings.movementArea,
          onApply: (shapes, tones, replacementPassword) {
            if (replacementPassword == null) {
              settings.setShapeStyle(shapes, tones);
            } else {
              settings.setShapeStyleAndPassword(
                shapes,
                tones,
                replacementPassword,
              );
            }
          },
        ),
      ),
    );
  }
}
