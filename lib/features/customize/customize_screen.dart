import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../lock_engine/floating_preview.dart';
import '../../widgets/production_ui.dart';
import 'background/background_screen.dart';
import 'effects/effects_screen.dart';
import 'runtime_preview_screen.dart';
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
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 46,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProductionScreenHeader(
                    icon: Icons.auto_awesome_rounded,
                    title: '꾸미기',
                    subtitle: '나만의 잠금화면을 만들어보세요.',
                  ),
                  const SizedBox(height: 18),
                  _CurrentLockRepresentative(settings: settings),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ProductionShortcutTile(
                          icon: Icons.palette_rounded,
                          title: '모양 & 색상',
                          subtitle: '캐릭터와 컬러를\n꾸며요',
                          backgroundColor: productionPink,
                          iconColor: productionPinkInk,
                          onTap: () => _openShapeStyle(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ProductionShortcutTile(
                          icon: Icons.bubble_chart_rounded,
                          title: '움직임 & 반응',
                          subtitle: '터치와 움직임을\n설정해요',
                          backgroundColor: productionBlue,
                          iconColor: productionBlueInk,
                          onTap: () => _openEffects(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ProductionShortcutTile(
                          icon: Icons.image_rounded,
                          title: '배경',
                          subtitle: '배경화면을\n선택해요',
                          backgroundColor: productionMint,
                          iconColor: productionMintInk,
                          onTap: () => _openBackground(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ProductionPrimaryButton(
                    icon: Icons.open_in_full_rounded,
                    label: '전체화면 보기',
                    onPressed: () => _openRuntimePreview(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openRuntimePreview(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) =>
            CustomizeRuntimePreviewScreen(settings: widget.settings),
      ),
    );
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
          style: settings.style,
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
          style: settings.style,
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
          style: settings.style,
          background: settings.background,
          movementStyle: settings.movementStyle,
          popStyle: settings.popStyle,
          objectCount: settings.objectCount,
          speed: settings.speed,
          movementArea: settings.movementArea,
          onApply: (shapes, tones, style, replacementPassword) {
            if (replacementPassword == null) {
              settings.setShapeStyle(
                shapes,
                tones,
                style: style,
              );
            } else {
              settings.setShapeStyleAndPassword(
                shapes,
                tones,
                replacementPassword,
                style: style,
              );
            }
          },
        ),
      ),
    );
  }
}

class _CurrentLockRepresentative extends StatelessWidget {
  const _CurrentLockRepresentative({
    required this.settings,
  });

  final MyLockSettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ProductionSoftCard(
      padding: EdgeInsets.zero,
      radius: 30,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: AspectRatio(
          aspectRatio: 1.03,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: settings.background.gradient),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: TickerMode(
                      enabled: false,
                      child: FloatingPreview(
                        selectedShapes: settings.selectedShapes,
                        selectedTones: settings.selectedTones,
                        movementStyle: settings.movementStyle,
                        popStyle: settings.popStyle,
                        style: settings.style,
                        objectCount: settings.objectCount,
                        speed: settings.speed,
                        movementArea: settings.movementArea,
                        topInset: 54,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      '현재 잠금화면',
                      style: TextStyle(
                        color: Color(0xFF5C5766),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
