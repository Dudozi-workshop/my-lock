import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../lock_engine/models.dart';
import 'choice_card.dart';

class ColorChoiceCard extends StatelessWidget {
  const ColorChoiceCard({
    super.key,
    required this.tone,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final ShapeTone tone;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceCard(
      selected: selected,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
