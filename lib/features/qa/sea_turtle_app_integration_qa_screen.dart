import 'package:flutter/material.dart';

import '../../lock_engine/effects.dart';
import '../../lock_engine/floating_preview.dart';
import '../../lock_engine/models.dart';
import '../customize/shape_style/widgets/shape_choice_card.dart';

class SeaTurtleAppIntegrationQaScreen extends StatelessWidget {
  const SeaTurtleAppIntegrationQaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Turtle v3 · App Integration')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Production components only',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Customize ShapeChoiceCard + lock FloatingPreview. '
            'Both use the shared RasterShapeBootstrap and LockTokenPainter path.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 190,
            height: 170,
            child: ShapeChoiceCard(
              kind: ShapeKind.seaTurtle,
              label: ShapeKind.seaTurtle.label,
              selected: true,
              onTap: _noop,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Lock field · Sea Turtle only · Pink / Blue / Yellow',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Container(
            height: 520,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF6F2FF),
                  Color(0xFFEAF5FF),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE2DFF0)),
            ),
            clipBehavior: Clip.antiAlias,
            child: const FloatingPreview(
              selectedShapes: {ShapeKind.seaTurtle},
              selectedTones: {
                ShapeTone.pink,
                ShapeTone.blue,
                ShapeTone.yellow,
              },
              movementStyle: MovementStyle.floating,
              popStyle: PopStyle.basicPop,
              style: ShapeStyle.softBasic,
              objectCount: 9,
              speed: FloatingSpeed.normal,
              movementArea: MovementArea.full,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'QA focus: shape-only palette, transparent background, '
            '58 px readability, token motion, rotation, and repeated spawn.',
          ),
        ],
      ),
    );
  }

  static void _noop() {}
}
