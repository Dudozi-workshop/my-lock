import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/floating_preview.dart';
import '../../../lock_engine/models.dart';

class ShapeStylePreview extends StatelessWidget {
  const ShapeStylePreview({
    super.key,
    required this.shapes,
    required this.tones,
  });

  final Set<ShapeKind> shapes;
  final Set<ShapeTone> tones;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 238,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF4FB),
            Color(0xFFF1EEFF),
            Color(0xFFECF7FF),
          ],
        ),
        border: Border.all(color: const Color(0xFFE9E4F3)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FloatingPreview(
              selectedShapes: shapes,
              selectedTones: tones,
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: brandPurple,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
