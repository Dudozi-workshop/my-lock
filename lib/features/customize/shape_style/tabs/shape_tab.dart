import 'package:flutter/material.dart';

import '../../../../lock_engine/models.dart';
import '../widgets/freedom_note.dart';
import '../widgets/shape_choice_card.dart';

class ShapeTab extends StatelessWidget {
  const ShapeTab({
    super.key,
    required this.selectedShapes,
    required this.onToggle,
  });

  final Set<ShapeKind> selectedShapes;
  final ValueChanged<ShapeKind> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          '사용할 도형을 선택하세요.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ShapeChoiceCard(
                kind: ShapeKind.circle,
                label: '원',
                selected: selectedShapes.contains(ShapeKind.circle),
                onTap: () => onToggle(ShapeKind.circle),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ShapeChoiceCard(
                kind: ShapeKind.triangle,
                label: '세모',
                selected: selectedShapes.contains(ShapeKind.triangle),
                onTap: () => onToggle(ShapeKind.triangle),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ShapeChoiceCard(
                kind: ShapeKind.square,
                label: '네모',
                selected: selectedShapes.contains(ShapeKind.square),
                onTap: () => onToggle(ShapeKind.square),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const FreedomNote(
          text: '한 가지 도형만 사용해도 됩니다. 최소 한 가지 도형은 유지됩니다.',
        ),
      ],
    );
  }
}
