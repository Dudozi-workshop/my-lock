import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../lock_engine/models.dart';
import '../../../../lock_engine/shape_painter.dart';
import 'choice_card.dart';

class ShapeChoiceCard extends StatelessWidget {
  const ShapeChoiceCard({
    super.key,
    required this.kind,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ShapeKind kind;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceCard(
      selected: selected,
      onTap: onTap,
      badge: kind.premium ? 'PLUS' : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(58, 58),
            painter: LockTokenPainter(
              LockToken(shape: kind, tone: ShapeTone.purple),
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
