import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../lock_engine/effects.dart';
import '../../lock_engine/floating_preview.dart';
import '../../lock_engine/models.dart';
import '../../widgets/customization_card.dart';
import 'background/background_screen.dart';
import 'background/background_style.dart';
import 'effects/effects_screen.dart';
import 'shape_style_screen.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  Set<ShapeKind> _selectedShapes = ShapeKind.values.toSet();
  Set<ShapeTone> _selectedTones = ShapeTone.values.toSet();
  LockBackground _selectedBackground = LockBackground.softGradient;
  MovementStyle _movementStyle = MovementStyle.floating;
  PopStyle _popStyle = PopStyle.basicPop;

  @override
  Widget build(BuildContext context) {
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
                    gradient: _selectedBackground.gradient,
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
                          selectedShapes: _selectedShapes,
                          selectedTones: _selectedTones,
                          movementStyle: _movementStyle,
                          popStyle: _popStyle,
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
                          child: Text(
                            _selectedShapes.isEmpty || _selectedTones.isEmpty
                                ? '도형 또는 색상을 선택해보세요'
                                : '도형을 눌러보세요',
                            style: const TextStyle(
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
                  subtitle: _selectedBackground.label,
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
                  subtitle: '${_movementStyle.label} · ${_popStyle.label}',
                  onTap: () => _openEffects(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openEffects(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => EffectsScreen(
          background: _selectedBackground,
          selectedShapes: _selectedShapes,
          selectedTones: _selectedTones,
          movementStyle: _movementStyle,
          popStyle: _popStyle,
          onChanged: (movement, popStyle) {
            setState(() {
              _movementStyle = movement;
              _popStyle = popStyle;
            });
          },
        ),
      ),
    );
  }

  Future<void> _openBackground(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => BackgroundScreen(
          selectedBackground: _selectedBackground,
          selectedShapes: _selectedShapes,
          selectedTones: _selectedTones,
          onChanged: (background) {
            setState(() => _selectedBackground = background);
          },
        ),
      ),
    );
  }

  String get _styleSummary {
    final shapeCount = _selectedShapes.length;
    final toneCount = _selectedTones.length;
    return '도형 $shapeCount개 · 색상 $toneCount개 · Basic Glossy';
  }

  Future<void> _openShapeStyle(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => ShapeStyleScreen(
          selectedShapes: _selectedShapes,
          selectedTones: _selectedTones,
          onChanged: (shapes, tones) {
            setState(() {
              _selectedShapes = Set<ShapeKind>.from(shapes);
              _selectedTones = Set<ShapeTone>.from(tones);
            });
          },
        ),
      ),
    );
  }

}
