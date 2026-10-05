import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/effects.dart';
import '../../../lock_engine/floating_preview.dart';
import '../../../lock_engine/models.dart';
import '../background/background_style.dart';

class ShapeStylePreview extends StatelessWidget {
  const ShapeStylePreview({
    super.key,
    required this.shapes,
    required this.tones,
    required this.background,
    required this.movementStyle,
    required this.popStyle,
    required this.style,
    required this.objectCount,
    required this.speed,
    required this.movementArea,
    required this.shuffleSeed,
    required this.onTap,
    required this.onShuffle,
  });

  final Set<ShapeKind> shapes;
  final Set<ShapeTone> tones;
  final LockBackground background;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final ShapeStyle style;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final int shuffleSeed;
  final VoidCallback onTap;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '현재 조합 전체화면으로 보기',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 132,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: background.gradient,
              border: Border.all(color: const Color(0xFFE9E4F3)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: KeyedSubtree(
                      key: ValueKey(shuffleSeed),
                      child: FloatingPreview(
                        selectedShapes: shapes,
                        selectedTones: tones,
                        movementStyle: movementStyle,
                        popStyle: popStyle,
                        style: style,
                        objectCount: objectCount,
                        speed: speed,
                        movementArea: movementArea,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Semantics(
                    button: true,
                    label: '다시 섞기',
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.88),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: onShuffle,
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.shuffle_rounded,
                            color: brandPurple,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShapeStyleRuntimePreviewScreen extends StatelessWidget {
  const ShapeStyleRuntimePreviewScreen({
    super.key,
    required this.shapes,
    required this.tones,
    required this.background,
    required this.movementStyle,
    required this.popStyle,
    required this.style,
    required this.objectCount,
    required this.speed,
    required this.movementArea,
  });

  final Set<ShapeKind> shapes;
  final Set<ShapeTone> tones;
  final LockBackground background;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final ShapeStyle style;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: background.gradient),
              child: FloatingPreview(
                selectedShapes: shapes,
                selectedTones: tones,
                movementStyle: movementStyle,
                popStyle: popStyle,
                style: style,
                objectCount: objectCount,
                speed: speed,
                movementArea: movementArea,
                topInset: topInset + 58,
              ),
            ),
          ),
          Positioned(
            top: topInset + 10,
            right: 16,
            child: Material(
              color: Colors.white.withValues(alpha: 0.90),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF4D4659),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
