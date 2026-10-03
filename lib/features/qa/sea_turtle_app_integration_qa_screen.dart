import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../../app/my_lock_settings_store.dart';
import '../../lock_engine/effects.dart';
import '../../lock_engine/floating_preview.dart';
import '../../lock_engine/models.dart';
import '../../lock_engine/relock_policy.dart';
import '../../lock_engine/shape_painter.dart';
import '../../lock_engine/shape_spec/shape_spec_registry.dart';
import '../customize/background/background_style.dart';
import '../customize/shape_style/widgets/shape_choice_card.dart';
import '../lock_mode/lock_mode_screen.dart';

class SeaTurtleAppIntegrationQaScreen extends StatefulWidget {
  const SeaTurtleAppIntegrationQaScreen({super.key});
  @override
  State<SeaTurtleAppIntegrationQaScreen> createState() => _QaState();
}

class _QaState extends State<SeaTurtleAppIntegrationQaScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();
  ShapeTone _tone = ShapeTone.auroraSea;
  bool _dark = false;
  bool _rotationPaused = false;
  int _count = 9;
  int _spawn = 0;

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  Future<void> _openLock() async {
    final settings = MyLockSettingsController(store: _QaStore());
    await settings.load();
    settings.setShapeStyleAndPassword({ShapeKind.seaTurtle}, {_tone}, [
      LockToken(shape: ShapeKind.seaTurtle, tone: _tone),
      LockToken(shape: ShapeKind.seaTurtle, tone: _tone),
    ]);
    settings.setBackground(
      _dark ? LockBackground.basicDark : LockBackground.basicLight,
    );
    if (!mounted) {
      settings.dispose();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LockModeScreen(settings: settings, demoMode: true),
      ),
    );
    settings.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = ShapeSpecRegistry.instance
        .resolveRasterSpec(ShapeKind.seaTurtle)
        .metadata;
    final bg = _dark ? const Color(0xFF17151F) : const Color(0xFFF5F6FA);
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Turtle · Runtime v3 · Candidate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '256px source · 58px display · Palette Base + Fixed Finish',
          ),
          Text(
            'Content ${meta.contentBbox} · padding ${(meta.safetyPaddingRatio * 100).toStringAsFixed(1)}%',
          ),
          Wrap(
            spacing: 6,
            children: [
              for (final tone in ShapeTone.values)
                ChoiceChip(
                  label: Text(tone.label),
                  selected: _tone == tone,
                  onSelected: (_) => setState(() => _tone = tone),
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark'),
                  value: _dark,
                  onChanged: (value) => setState(() => _dark = value),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _rotationPaused = !_rotationPaused;
                    if (_rotationPaused) {
                      _rotation.stop();
                    } else {
                      _rotation.repeat();
                    }
                  });
                },
                icon: Icon(
                  _rotationPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                ),
                label: Text(
                  _rotationPaused ? '회전 재개' : '회전 멈춤',
                ),
              ),
            ],
          ),
          Container(
            color: bg,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text('Actual LockTokenPainter · rotating / enlarged'),
                AnimatedBuilder(
                  animation: _rotation,
                  builder: (_, child) => Transform.rotate(
                    angle: _rotation.value * math.pi * 2,
                    child: child,
                  ),
                  child: CustomPaint(
                    size: const Size(256, 256),
                    painter: LockTokenPainter(
                      LockToken(shape: ShapeKind.seaTurtle, tone: _tone),
                    ),
                  ),
                ),
                Wrap(
                  spacing: 16,
                  children: [
                    for (final tone in ShapeTone.values)
                      Column(
                        children: [
                          CustomPaint(
                            size: const Size(58, 58),
                            painter: LockTokenPainter(
                              LockToken(shape: ShapeKind.seaTurtle, tone: tone),
                            ),
                          ),
                          Text(tone.label),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Customize · actual ShapeChoiceCard'),
          SizedBox(
            height: 155,
            child: ShapeChoiceCard(
              kind: ShapeKind.seaTurtle,
              label: ShapeKind.seaTurtle.label,
              selected: true,
              onTap: () {},
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final n in [6, 9, 12])
                ChoiceChip(
                  label: Text('$n objects'),
                  selected: _count == n,
                  onSelected: (_) => setState(() => _count = n),
                ),
              OutlinedButton(
                onPressed: () => setState(() => _spawn++),
                child: const Text('Respawn'),
              ),
            ],
          ),
          const Text('FloatingPreview · tap turtle to POP and respawn'),
          Container(
            height: 430,
            color: bg,
            child: FloatingPreview(
              key: ValueKey('$_spawn/$_count'),
              selectedShapes: const {ShapeKind.seaTurtle},
              selectedTones: {_tone},
              objectCount: _count,
              movementArea: MovementArea.full,
              movementStyle: MovementStyle.floating,
              popStyle: PopStyle.basicPop,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _openLock,
            child: const Text('Open actual LockModeScreen · tap two turtles'),
          ),
          const Text(
            'Candidate · user visual approval pending. Android LockActivity device QA is separate.',
          ),
        ],
      ),
    );
  }
}

/// Isolated QA settings; never overwrite the user's password/preferences.
class _QaStore implements MyLockSettingsPersistence {
  @override
  Future<MyLockStoredSettings> load() async => const MyLockStoredSettings(
    selectedShapes: {ShapeKind.seaTurtle},
    selectedTones: {ShapeTone.auroraSea},
    background: LockBackground.basicLight,
    movementStyle: MovementStyle.floating,
    popStyle: PopStyle.basicPop,
    password: null,
    selectedAppIds: {},
    objectCount: 9,
    speed: FloatingSpeed.normal,
    movementArea: MovementArea.full,
    relockPolicy: RelockPolicy.immediate,
  );
  @override
  Future<void> savePreferences(MyLockStoredSettings settings) async {}
  @override
  Future<void> savePassword(List<LockToken> password) async {}
  @override
  Future<void> saveRecoveryPin(String pin) async {}
}
