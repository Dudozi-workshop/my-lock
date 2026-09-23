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
        GridView.builder(
          itemCount: ShapeTone.values.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, index) {
            final tone = ShapeTone.values[index];
            return ColorChoiceCard(
              tone: tone,
              label: tone.label,
              selected: selectedTones.contains(tone),
              onTap: () => onToggle(tone),
            );
          },
        ),
        const SizedBox(height: 20),
        const FreedomNote(
          text: '색상도 자유롭게 조합할 수 있습니다. 확장 색상은 현재 개발 버전에서 직접 적용해 테스트할 수 있습니다.',
        ),
      ],
    );
  }
}
