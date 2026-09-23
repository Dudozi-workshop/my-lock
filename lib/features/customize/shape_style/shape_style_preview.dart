import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/effects.dart';
import '../../../lock_engine/floating_preview.dart';
import '../background/background_style.dart';
import '../../../lock_engine/models.dart';

class ShapeStylePreview extends StatelessWidget {
  const ShapeStylePreview({
    super.key,
    required this.shapes,
    required this.tones,
    required this.background,
    required this.movementStyle,
    required this.popStyle,
    required this.texture,
    required this.objectCount,
    required this.speed,
    required this.movementArea,
  });

  final Set<ShapeKind> shapes;
  final Set<ShapeTone> tones;
  final LockBackground background;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final ShapeTexture texture;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 238,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: background.gradient,
        border: Border.all(color: const Color(0xFFE9E4F3)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FloatingPreview(
              selectedShapes: shapes,
              selectedTones: tones,
              movementStyle: movementStyle,
              popStyle: popStyle,
              texture: texture,
              objectCount: objectCount,
              speed: speed,
              movementArea: movementArea,
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
