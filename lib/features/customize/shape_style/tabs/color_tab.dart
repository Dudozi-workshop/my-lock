import 'package:flutter/material.dart';

import '../../../../lock_engine/models.dart';
import '../widgets/color_choice_card.dart';
import '../widgets/freedom_note.dart';

class ColorTab extends StatelessWidget {
  const ColorTab({
    super.key,
    required this.selectedTones,
    required this.onToggle,
  });

  final Set<ShapeTone> selectedTones;
  final ValueChanged<ShapeTone> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          '사용할 색상을 선택하세요.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ColorChoiceCard(
                tone: ShapeTone.pink,
                label: '핑크',
                color: const Color(0xFFFF79C6),
                selected: selectedTones.contains(ShapeTone.pink),
                onTap: () => onToggle(ShapeTone.pink),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ColorChoiceCard(
                tone: ShapeTone.blue,
                label: '블루',
                color: const Color(0xFF65A7FF),
                selected: selectedTones.contains(ShapeTone.blue),
                onTap: () => onToggle(ShapeTone.blue),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ColorChoiceCard(
                tone: ShapeTone.yellow,
                label: '옐로우',
                color: const Color(0xFFFFCD58),
                selected: selectedTones.contains(ShapeTone.yellow),
                onTap: () => onToggle(ShapeTone.yellow),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const FreedomNote(
          text: '색상도 자유롭게 조합할 수 있습니다. 최소 한 가지 색상은 유지됩니다.',
        ),
      ],
    );
  }
}
