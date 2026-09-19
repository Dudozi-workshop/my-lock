import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../lock_engine/models.dart';
import 'choice_card.dart';

class ShapeChoiceCard extends StatelessWidget {
  const ShapeChoiceCard({
    super.key,
    required this.kind,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ShapeKind kind;
  final String label;
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
          CustomPaint(
            size: const Size(54, 54),
            painter: _ShapeIconPainter(kind: kind),
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

class _ShapeIconPainter extends CustomPainter {
  const _ShapeIconPainter({required this.kind});

  final ShapeKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9B8CFF), Color(0xFF7659F6)],
      ).createShader(Offset.zero & size);

    switch (kind) {
      case ShapeKind.circle:
        canvas.drawCircle(center, size.width * 0.43, paint);
      case ShapeKind.triangle:
        final path = Path()
          ..moveTo(center.dx, size.height * 0.08)
          ..lineTo(size.width * 0.92, size.height * 0.86)
          ..lineTo(size.width * 0.08, size.height * 0.86)
          ..close();
        canvas.drawPath(path, paint);
      case ShapeKind.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center,
              width: size.width * 0.78,
              height: size.height * 0.78,
            ),
            const Radius.circular(12),
          ),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _ShapeIconPainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}
