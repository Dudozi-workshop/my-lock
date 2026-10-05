import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

/// LABS candidates; approved Base and Flow motion are independent inputs.
class LivingParticlePainter extends CustomPainter {
  LivingParticlePainter({required this.animation}) : super(repaint: animation);
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animation.value * math.pi * 2;
    for (var i = 0; i < 42; i++) {
      final seed = (i * .61803398875 + .17) % 1;
      final progress = (animation.value * (i % 4 == 0 ? 2 : 1) + seed) % 1;
      final fade = (progress / .09).clamp(0.0, 1.0) *
          ((1 - progress) / .12).clamp(0.0, 1.0);
      final baseX = .035 + ((i * .38196601125 + .13) % 1) * .93;
      final x = (baseX + .022 * math.sin(phase * 2 + i * 1.7) +
          .008 * math.sin(phase * 3 - i * .9)) * size.width;
      final y = (.94 - progress * .85) * size.height;
      final foreground = i % 6 == 0;
      final radius = size.width * (foreground ? .0048 : .0023 + (i % 3) * .0005);
      final centerQuiet = baseX > .34 && baseX < .7 ? .65 : 1.0;
      final shimmer = .72 + .28 * math.sin(phase * (2 + i % 3) + i * 2.1);
      final alpha = fade * centerQuiet * shimmer * (foreground ? .8 : .55);
      final color = i % 5 == 0 ? const ui.Color(0xFFFFF3D7) : const ui.Color(0xFFE2FAFF);
      final paint = Paint()..color = color.withValues(alpha: alpha);
      if (foreground) {
        canvas.drawCircle(Offset(x, y), radius * 2.3,
          Paint()..color = color.withValues(alpha: alpha * .12)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 1.4));
      }
      canvas.drawCircle(Offset(x, y), radius, paint);
      if (i % 11 == 0) {
        canvas.drawOval(Rect.fromCenter(center: Offset(x, y),
          width: radius * .85, height: radius * 3),
          Paint()..color = color.withValues(alpha: alpha * .6));
      }
    }
  }

  @override
  bool shouldRepaint(LivingParticlePainter oldDelegate) => oldDelegate.animation != animation;
}

class LivingBubblePainter extends CustomPainter {
  LivingBubblePainter({required this.animation}) : super(repaint: animation);
  final Animation<double> animation;
  static const _bubbles = <(double, double, double)>[
    (.08, .021, .12), (.16, .010, .55), (.24, .006, .31),
    (.09, .007, .79), (.88, .020, .45), (.94, .010, .08),
    (.82, .006, .71), (.91, .007, .93), (.38, .008, .38),
    (.66, .011, .65), (.76, .006, .23), (.19, .012, .87),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animation.value * math.pi * 2;
    for (var i = 0; i < _bubbles.length; i++) {
      final b = _bubbles[i];
      final progress = (animation.value * (i % 4 == 0 ? 2 : 1) + b.$3) % 1;
      final fade = (progress / .08).clamp(0.0, 1.0) *
          ((1 - progress) / .13).clamp(0.0, 1.0);
      final x = (b.$1 + .018 * math.sin(phase * 2 + i * 1.3) +
          .006 * math.sin(phase * 5 - i * .7)) * size.width;
      final y = (.97 - progress * .86) * size.height;
      final radius = size.width * b.$2;
      final aspect = 1 + .065 * math.sin(phase * 3 + i * .8);
      final rect = Rect.fromCenter(center: Offset(x, y),
          width: radius * 2 / aspect, height: radius * 2 * aspect);
      canvas.drawOval(rect, Paint()..shader = ui.Gradient.radial(
        Offset(x - radius * .3, y - radius * .3), radius * 1.5,
        [const ui.Color(0xFFEDFDFF).withValues(alpha: fade * .14),
         const ui.Color(0xFF70C9F0).withValues(alpha: fade * .035)],
      ));
      canvas.drawOval(rect, Paint()..style = PaintingStyle.stroke
        ..strokeWidth = math.max(.65, radius * .09)
        ..color = const ui.Color(0xFFD9F5FF).withValues(alpha: fade * .42));
      canvas.drawArc(rect, math.pi * 1.05, math.pi * .65, false,
        Paint()..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(.8, radius * .13)
          ..color = const ui.Color(0xFFF4FEFF).withValues(alpha: fade * .9));
      canvas.drawArc(rect, .1, math.pi * .48, false,
        Paint()..style = PaintingStyle.stroke
          ..strokeWidth = math.max(.6, radius * .08)
          ..color = const ui.Color(0xFFFFEAD7).withValues(alpha: fade * .35));
      canvas.drawOval(Rect.fromCenter(center: Offset(x - radius * .32, y - radius * .42),
        width: radius * .32, height: radius * .2),
        Paint()..color = const ui.Color(0xFFFFFFFF).withValues(alpha: fade * .8));
    }
  }

  @override
  bool shouldRepaint(LivingBubblePainter oldDelegate) => oldDelegate.animation != animation;
}
