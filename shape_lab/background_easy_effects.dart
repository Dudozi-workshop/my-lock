import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

class FloorCausticPainter extends CustomPainter {
  FloorCausticPainter({required this.animation}) : super(repaint: animation);
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * pi * 2;
    final region = Rect.fromLTWH(0, size.height * .64, size.width, size.height * .36);
    canvas.save();
    canvas.clipRect(region);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.2, size.width * .004)
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.screen
      ..color = const Color(0xFFFFFFFF).withValues(alpha: .10)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, max(2.0, size.width * .006));

    for (var row = 0; row < 5; row++) {
      final y = size.height * (.70 + row * .055);
      final path = Path();
      for (var x = -1; x <= 13; x++) {
        final px = size.width * (x / 12);
        final py = y +
            sin(x * .92 + row * .67 + t * .42) * size.height * .009 +
            cos(x * .41 - t * .29 + row) * size.height * .005;
        if (x == -1) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FloorCausticPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class VolumetricLightPainter extends CustomPainter {
  VolumetricLightPainter({required this.animation}) : super(repaint: animation);
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * pi * 2;
    final shift = sin(t * .23) * size.width * .035;
    final path = Path()
      ..moveTo(size.width * .20 + shift, 0)
      ..lineTo(size.width * .44 + shift, 0)
      ..lineTo(size.width * .68 + shift, size.height * .72)
      ..lineTo(size.width * .34 + shift, size.height * .72)
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x22FFFFFF),
          Color(0x12E7FFFF),
          Color(0x00FFFFFF),
        ],
        stops: [0, .52, 1],
      ).createShader(Offset.zero & size)
      ..blendMode = BlendMode.screen
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, max(18.0, size.width * .06));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant VolumetricLightPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class AmbientParticlePainter extends CustomPainter {
  AmbientParticlePainter({required this.animation}) : super(repaint: animation);
  final Animation<double> animation;

  static const _particles = <(double, double, double)>[
    (.12,.19,.7),(.28,.31,.5),(.46,.22,.6),(.70,.17,.45),(.84,.34,.55),
    (.18,.48,.45),(.38,.56,.6),(.59,.43,.4),(.76,.59,.55),(.91,.50,.45),
    (.09,.72,.4),(.31,.78,.55),(.52,.69,.45),(.68,.82,.5),(.87,.73,.6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * pi * 2;
    for (var i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final x = (p.$1 + sin(t * .18 + i * .73) * .012) * size.width;
      final y = (p.$2 + cos(t * .13 + i * .51) * .010) * size.height;
      final r = max(.7, size.width * .0024 * p.$3);
      final paint = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: .12 + p.$3 * .08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * .8);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AmbientParticlePainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class BubblePainter extends CustomPainter {
  BubblePainter({required this.animation}) : super(repaint: animation);
  final Animation<double> animation;

  static const _bubbles = <(double, double, double, double)>[
    (.19,.88,.010,.00),(.81,.76,.007,.24),(.63,.94,.005,.51),(.36,.71,.006,.73),
    (.89,.91,.004,.39),(.11,.64,.004,.61),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animation.value;
    for (var i = 0; i < _bubbles.length; i++) {
      final b = _bubbles[i];
      final progress = (phase + b.$4) % 1.0;
      final yNorm = b.$2 - progress * .58;
      if (yNorm < .08) continue;
      final x = (b.$1 + sin(progress * pi * 2 + i) * .012) * size.width;
      final y = yNorm * size.height;
      final r = max(1.2, size.width * b.$3);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(.7, r * .18)
        ..color = const Color(0xFFFFFFFF).withValues(alpha: .20)
        ..blendMode = BlendMode.screen;
      canvas.drawCircle(Offset(x, y), r, paint);
      canvas.drawCircle(
        Offset(x - r * .28, y - r * .28),
        max(.5, r * .16),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: .18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) =>
      oldDelegate.animation != animation;
}
