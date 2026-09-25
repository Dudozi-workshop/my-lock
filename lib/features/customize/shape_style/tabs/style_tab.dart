import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../lock_engine/models.dart';
import '../../../../lock_engine/shape_painter.dart';
import '../widgets/choice_card.dart';
import '../widgets/freedom_note.dart';

class StyleTab extends StatelessWidget {
  const StyleTab({
    super.key,
    required this.selectedStyle,
    required this.onSelect,
  });

  final ShapeStyle selectedStyle;
  final ValueChanged<ShapeStyle> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          '도형 전체에 적용할 스타일을 선택하세요.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        GridView.builder(
          itemCount: ShapeStyle.values.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, index) {
            final style = ShapeStyle.values[index];
            return ChoiceCard(
              selected: selectedStyle == style,
              onTap: () => onSelect(style),
              badge: style.premium ? 'PLUS' : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    size: const Size(62, 62),
                    painter: LockTokenPainter(
                      const LockToken(
                        shape: ShapeKind.circle,
                        tone: ShapeTone.pink,
                      ),
                      style: style,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    style.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const FreedomNote(
          text: 'Soft Basic은 정교한 마스크 레이어를 사용하고, Crayon Soft는 하나의 절차형 재질을 모든 도형에 재사용합니다.',
        ),
      ],
    );
  }
}
