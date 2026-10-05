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
    this.wide = false,
  });

  final ShapeTone tone;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final preview = CustomPaint(
      size: Size.square(wide ? 72 : 58),
      painter: LockTokenPainter(
        LockToken(
          shape: ShapeKind.circle,
          tone: tone,
        ),
      ),
    );

    return ChoiceCard(
      selected: selected,
      onTap: onTap,
      badge: tone == ShapeTone.auroraSea
          ? 'REWARD'
          : tone.premium
              ? 'PLUS'
              : null,
      child: wide
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  preview,
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Signature Color',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: secondaryInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: brandPurple,
                    size: 22,
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                preview,
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
