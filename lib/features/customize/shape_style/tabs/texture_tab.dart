import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../lock_engine/models.dart';
import '../../../../lock_engine/shape_painter.dart';
import '../widgets/choice_card.dart';
import '../widgets/freedom_note.dart';

class TextureTab extends StatelessWidget {
  const TextureTab({
    super.key,
    required this.selectedTexture,
    required this.onSelect,
  });

  final ShapeTexture selectedTexture;
  final ValueChanged<ShapeTexture> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          '도형 전체에 적용할 질감을 선택하세요.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        GridView.builder(
          itemCount: ShapeTexture.values.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, index) {
            final texture = ShapeTexture.values[index];
            return ChoiceCard(
              selected: selectedTexture == texture,
              onTap: () => onSelect(texture),
              badge: texture.premium ? 'PLUS' : null,
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
                      texture: texture,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    texture.label,
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
          text: '질감은 현재 개발 버전에서 모두 직접 적용해 확인할 수 있습니다. 키샤드 구매/소유권은 상점 경제 시스템 단계에서 연결됩니다.',
        ),
      ],
    );
  }
}
