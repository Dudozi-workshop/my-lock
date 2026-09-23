import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../lock_engine/models.dart';
import '../../../../lock_engine/shape_painter.dart';
import 'choice_card.dart';

class ColorChoiceCard extends StatelessWidget {
  const ColorChoiceCard({
    super.key,
    required this.tone,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ShapeTone tone;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceCard(
      selected: selected,
      onTap: onTap,
      badge: tone.premium ? 'PLUS' : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(58, 58),
            painter: LockTokenPainter(
              LockToken(shape: ShapeKind.circle, tone: tone),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}
