import 'package:flutter/material.dart';

import '../../lock_engine/effects.dart';
import '../../lock_engine/floating_preview.dart';
import '../../lock_engine/models.dart';
import '../../lock_engine/shape_spec/shape_spec_registry.dart';

class SeaTurtleSwimRuntimeQaScreen extends StatefulWidget {
  const SeaTurtleSwimRuntimeQaScreen({super.key});

  @override
  State<SeaTurtleSwimRuntimeQaScreen> createState() =>
      _SeaTurtleSwimRuntimeQaScreenState();
}

class _SeaTurtleSwimRuntimeQaScreenState
    extends State<SeaTurtleSwimRuntimeQaScreen> {
  FloatingSpeed _speed = FloatingSpeed.normal;
  ShapeTone _tone = ShapeTone.auroraSea;
  int _respawn = 0;

  @override
  Widget build(BuildContext context) {
    final metadata = ShapeSpecRegistry.instance
        .resolveRasterSpec(ShapeKind.seaTurtle)
        .metadata;

    return Scaffold(
      appBar: AppBar(title: const Text('Sea Turtle v3 · Swim Motion Master v1')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Final / Locked · S0 → S1 → S2 → S1 → S0',
            ),
            const SizedBox(height: 4),
            Text(
              'Random initial phase · 2–4 loop hold · ${metadata.swim['transition']} tempo transition',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final speed in FloatingSpeed.values)
                  ChoiceChip(
                    label: Text(
                      switch (speed) {
                        FloatingSpeed.slow => 'Calm · 1.10–1.30 s',
                        FloatingSpeed.normal => 'Standard · 0.90–1.10 s',
                        FloatingSpeed.fast => 'Lively · 0.78–0.92 s',
                      },
                    ),
                    selected: _speed == speed,
                    onSelected: (_) => setState(() => _speed = speed),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final tone in ShapeTone.values)
                  ChoiceChip(
                    label: Text(tone.label),
                    selected: _tone == tone,
                    onSelected: (_) => setState(() => _tone = tone),
                  ),
                OutlinedButton(
                  onPressed: () => setState(() => _respawn++),
                  child: const Text('Respawn'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 520,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: FloatingPreview(
                  key: ValueKey('swim-$_respawn'),
                  selectedShapes: const {ShapeKind.seaTurtle},
                  selectedTones: {_tone},
                  objectCount: 6,
                  speed: _speed,
                  movementArea: MovementArea.full,
                  movementStyle: MovementStyle.floating,
                  popStyle: PopStyle.basicPop,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Check: shoulder/root continuity · Near/Far rhythm · no synchronized flap · 58px readability · palette detail retention.',
            ),
          ],
        ),
      ),
    );
  }
}
