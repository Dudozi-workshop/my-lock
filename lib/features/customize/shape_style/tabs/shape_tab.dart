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
        GridView.builder(
          itemCount: ShapeKind.values.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, index) {
            final kind = ShapeKind.values[index];
            return ShapeChoiceCard(
              kind: kind,
              label: kind.label,
              selected: selectedShapes.contains(kind),
              onTap: () => onToggle(kind),
            );
          },
        ),
        const SizedBox(height: 20),
        const FreedomNote(
          text: '도형은 자유롭게 조합할 수 있습니다. 확장 도형도 현재 개발 버전에서는 직접 적용해 테스트할 수 있습니다.',
        ),
      ],
    );
  }
}
