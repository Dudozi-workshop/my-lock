import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:my_lock/lock_engine/effects.dart';
import 'package:my_lock/lock_engine/floating_preview.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShapeSpecRegistry.instance.load();
  runApp(const MyLockLabsApp());
}

enum LabTab { shape, style, palette, effect, qa }

class MyLockLabsApp extends StatelessWidget {
  const MyLockLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK Labs',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7257F5),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const LabsPage(),
    );
  }
}

class LabsPage extends StatefulWidget {
  const LabsPage({super.key});

  @override
  State<LabsPage> createState() => _LabsPageState();
}

class _LabsPageState extends State<LabsPage> {
  LabTab tab = LabTab.shape;
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF101218) : const Color(0xFFF6F5FA);
    final card = dark ? const Color(0xFF1A1D26) : Colors.white;
    final fg = dark ? Colors.white : const Color(0xFF171923);
    final muted = dark ? const Color(0xFFAEB4C3) : const Color(0xFF6D7382);
    final compact = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: bg,
              padding: EdgeInsets.fromLTRB(
                compact ? 14 : 20,
                12,
                compact ? 14 : 20,
                10,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  compact ? 'MY LOCK Labs' : 'MY LOCK Labs · Design System',
                                  style: TextStyle(
                                    color: fg,
                                    fontSize: compact ? 21 : 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'LAB 027 · Lily Bubble HQ · 58px Runtime',
                                  style: TextStyle(color: muted, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!compact)
                                Text('Dark', style: TextStyle(color: muted)),
                              Switch(
                                value: dark,
                                onChanged: (value) => setState(() => dark = value),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _TabChip(
                              label: 'Shape Lab',
                              selected: tab == LabTab.shape,
                              onTap: () => setState(() => tab = LabTab.shape),
                            ),
                            _TabChip(
                              label: 'Style Lab',
                              selected: tab == LabTab.style,
                              onTap: () => setState(() => tab = LabTab.style),
                            ),
                            _TabChip(
                              label: 'Palette Lab',
                              selected: tab == LabTab.palette,
                              onTap: () => setState(() => tab = LabTab.palette),
                            ),
                            _TabChip(
                              label: 'Effect Lab',
                              selected: tab == LabTab.effect,
                              onTap: () => setState(() => tab = LabTab.effect),
                            ),
                            _TabChip(
                              label: 'Runtime QA',
                              selected: tab == LabTab.qa,
                              onTap: () => setState(() => tab = LabTab.qa),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: dark ? Colors.white12 : const Color(0xFFE8E5EF)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 12 : 20,
                  14,
                  compact ? 12 : 20,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: switch (tab) {
                      LabTab.shape => ShapeLab(card: card, fg: fg, muted: muted),
                      LabTab.style => CrayonStyleLab(card: card, fg: fg, muted: muted),
                      LabTab.palette => PaletteLab(card: card, fg: fg, muted: muted),
                      LabTab.effect => EffectLab(card: card, fg: fg, muted: muted),
                      LabTab.qa => RuntimeQaLab(card: card, fg: fg, muted: muted),
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class ShapeLab extends StatelessWidget {
  const ShapeLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const shapes = [ShapeKind.circle, ShapeKind.triangle, ShapeKind.square];
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];

    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Shape Lab',
            subtitle: '현재 기본 Shape Master를 실제 58×58 renderer로 확인합니다.',
            fg: fg,
            muted: muted,
          ),
          const SizedBox(height: 16),
          _HighResRuntimeDemo(fg: fg, muted: muted),
          const SizedBox(height: 22),
          for (final shape in shapes) ...[
            Text(
              shape.label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              children: [
                for (final tone in tones)
                  _TokenWithLabel(
                    shape: shape,
                    tone: tone,
                    style: ShapeStyle.softBasic,
                    label: tone.label,
                    muted: muted,
                  ),
              ],
            ),
            if (shape != shapes.last) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}



class _HighResRuntimeDemo extends StatelessWidget {
  const _HighResRuntimeDemo({required this.fg, required this.muted});

  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF07120D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF234534)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 230,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lily Bubble · HQ Runtime',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '레퍼런스의 짙은 숲색 유리구슬, 좌상단 백색 반사광, 우하단 금빛 글로우, 은방울꽃과 내부 반딧불 움직임을 8× Master에서 구성합니다.',
                  style: TextStyle(
                    color: muted.withValues(alpha: 0.98),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'MASTER 464px  ·  DISPLAY 58px  ·  SCALE 12.5%  ·  FIREFLY LIVE',
                  style: TextStyle(
                    color: Color(0xFFC4E98B),
                    fontSize: 9.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF030A07),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const _LilyBubbleAsset(displaySize: 58),
              ),
              const SizedBox(height: 5),
              const Text(
                'ACTUAL 58×58',
                style: TextStyle(
                  color: Color(0xFFE7F7D1),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                width: 140,
                height: 140,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF030A07),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const _LilyBubbleAsset(displaySize: 116),
              ),
              const SizedBox(height: 5),
              const Text(
                '2× INSPECTION',
                style: TextStyle(
                  color: Color(0xFF9BB9A1),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LilyBubbleAsset extends StatefulWidget {
  const _LilyBubbleAsset({required this.displaySize});

  final double displaySize;

  @override
  State<_LilyBubbleAsset> createState() => _LilyBubbleAssetState();
}

class _LilyBubbleAssetState extends State<_LilyBubbleAsset>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 9200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.displaySize,
      child: FittedBox(
        fit: BoxFit.contain,
        child: RepaintBoundary(
          child: SizedBox.square(
            dimension: 464,
            child: CustomPaint(
              painter: _LilyBubblePainter(_controller),
            ),
          ),
        ),
      ),
    );
  }
}

class _LilyBubblePainter extends CustomPainter {
  _LilyBubblePainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  static const _master = 464.0;
  static const _center = Offset(232, 229);
  static const _radius = 194.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _master;
    canvas.save();
    canvas.scale(scale, scale);

    final t = animation.value * math.pi * 2;
    final orbRect = Rect.fromCircle(center: _center, radius: _radius);

    _drawOuterShadow(canvas);
    _drawGlassBase(canvas, orbRect);

    canvas.save();
    canvas.clipPath(Path()..addOval(orbRect));

    _drawForestDepth(canvas, orbRect);
    _drawMossFloor(canvas);
    _drawGoldenBloom(canvas);
    _drawStaticLightDust(canvas);
    _drawFlower(canvas);
    _drawAnimatedFireflies(canvas, t);
    _drawInnerRefractions(canvas);

    canvas.restore();

    _drawGlassRim(canvas, orbRect);
    _drawPrimaryReflection(canvas);
    _drawLowerGoldReflection(canvas);
    _drawMicroHighlights(canvas);

    canvas.restore();
  }

  static void _drawOuterShadow(Canvas canvas) {
    canvas.drawOval(
      const Rect.fromLTWH(72, 404, 320, 38),
      Paint()
        ..color = const Color(0x62000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    canvas.drawCircle(
      _center + const Offset(0, 8),
      _radius + 5,
      Paint()
        ..color = const Color(0x42000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  static void _drawGlassBase(Canvas canvas, Rect orbRect) {
    canvas.drawCircle(
      _center,
      _radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.32, -0.40),
          radius: 1.10,
          colors: [
            Color(0xFF124A38),
            Color(0xFF0A3022),
            Color(0xFF071C15),
            Color(0xFF030B08),
          ],
          stops: [0.0, 0.38, 0.72, 1.0],
        ).createShader(orbRect),
    );
  }

  static void _drawForestDepth(Canvas canvas, Rect orbRect) {
    final vignette = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.18, -0.10),
        radius: 1.05,
        colors: [
          Color(0x00182C1F),
          Color(0x22030906),
          Color(0xA8000000),
        ],
        stops: [0.0, 0.64, 1.0],
      ).createShader(orbRect);
    canvas.drawCircle(_center, _radius, vignette);

    _softBlob(canvas, const Offset(104, 96), 76, const Color(0x442D8168), 30);
    _softBlob(canvas, const Offset(142, 62), 46, const Color(0x1E83B5A0), 22);
    _softBlob(canvas, const Offset(330, 86), 72, const Color(0x24598437), 30);
    _softBlob(canvas, const Offset(362, 150), 38, const Color(0x3C6B6E29), 24);
    _softBlob(canvas, const Offset(80, 250), 54, const Color(0x1E244F33), 24);

    for (final spot in const [
      (Offset(74, 86), 16.0, Color(0x33579F81)),
      (Offset(99, 142), 13.0, Color(0x24307454)),
      (Offset(306, 62), 13.0, Color(0x244D7831)),
      (Offset(344, 113), 18.0, Color(0x315A6B2F)),
      (Offset(371, 220), 14.0, Color(0x28496E28)),
      (Offset(127, 215), 11.0, Color(0x263F6B49)),
    ]) {
      _softBlob(canvas, spot.$1, spot.$2, spot.$3, 10);
    }
  }

  static void _drawMossFloor(Canvas canvas) {
    final moss = Path()
      ..moveTo(62, 350)
      ..cubicTo(106, 324, 143, 336, 175, 328)
      ..cubicTo(217, 316, 251, 340, 287, 324)
      ..cubicTo(322, 309, 356, 321, 404, 344)
      ..lineTo(420, 430)
      ..lineTo(44, 430)
      ..close();

    canvas.drawPath(
      moss,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF426F28),
            Color(0xFF173A19),
            Color(0xFF07150C),
          ],
        ).createShader(const Rect.fromLTWH(45, 315, 380, 120)),
    );

    for (var i = 0; i < 24; i++) {
      final x = 64.0 + ((i * 37) % 330);
      final y = 347.0 + ((i * 17) % 50);
      final r = 2.0 + (i % 4) * 1.2;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Color.lerp(
          const Color(0xFF87A934),
          const Color(0xFF22421B),
          (i % 5) / 4,
        )!,
      );
    }
  }

  static void _drawGoldenBloom(Canvas canvas) {
    final bloomRect = Rect.fromCircle(
      center: const Offset(341, 320),
      radius: 154,
    );
    canvas.drawCircle(
      const Offset(341, 320),
      154,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xE8FFF65D),
            Color(0xB8EAC72C),
            Color(0x557F8B1D),
            Color(0x001C2E10),
          ],
          stops: [0.0, 0.20, 0.48, 1.0],
        ).createShader(bloomRect),
    );

    _softBlob(canvas, const Offset(368, 340), 50, const Color(0x9EFFF879), 18);
    _softBlob(canvas, const Offset(329, 368), 38, const Color(0x6AF3E14B), 14);
  }

  static void _drawStaticLightDust(Canvas canvas) {
    const lights = [
      (Offset(73, 117), 9.0),
      (Offset(121, 205), 5.5),
      (Offset(160, 100), 5.0),
      (Offset(184, 310), 5.4),
      (Offset(263, 95), 4.4),
      (Offset(316, 128), 6.0),
      (Offset(372, 182), 7.0),
      (Offset(339, 258), 5.2),
      (Offset(286, 331), 5.5),
      (Offset(117, 329), 4.5),
    ];

    for (var i = 0; i < lights.length; i++) {
      final light = lights[i];
      _drawGlow(
        canvas,
        light.$1,
        light.$2,
        i.isEven ? const Color(0xFFFFF36D) : const Color(0xFFCFFF90),
        coreOpacity: 0.90,
      );
    }
  }

  static void _drawFlower(Canvas canvas) {
    final stemGlow = Paint()
      ..color = const Color(0x454EAF34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final stem = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8ED53), Color(0xFF8FB32F), Color(0xFF4F7B24)],
      ).createShader(const Rect.fromLTWH(170, 106, 150, 260))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    final mainStem = Path()
      ..moveTo(231, 362)
      ..cubicTo(230, 316, 229, 274, 233, 229)
      ..cubicTo(238, 182, 249, 151, 269, 134)
      ..cubicTo(280, 124, 289, 122, 299, 127);
    canvas.drawPath(mainStem, stemGlow);
    canvas.drawPath(mainStem, stem);

    final branches = <Path>[
      Path()
        ..moveTo(237, 250)
        ..cubicTo(216, 235, 197, 226, 177, 210),
      Path()
        ..moveTo(240, 218)
        ..cubicTo(263, 207, 281, 193, 293, 176),
      Path()
        ..moveTo(245, 190)
        ..cubicTo(266, 177, 277, 161, 282, 145),
      Path()
        ..moveTo(232, 285)
        ..cubicTo(252, 271, 271, 260, 293, 250),
    ];
    for (final branch in branches) {
      canvas.drawPath(branch, stemGlow..strokeWidth = 9);
      canvas.drawPath(branch, stem..strokeWidth = 5.2);
    }

    _drawLeaf(
      canvas,
      Path()
        ..moveTo(230, 319)
        ..cubicTo(190, 282, 154, 281, 128, 302)
        ..cubicTo(153, 340, 192, 347, 230, 331)
        ..close(),
      const Rect.fromLTWH(125, 278, 112, 72),
    );
    _drawLeaf(
      canvas,
      Path()
        ..moveTo(236, 333)
        ..cubicTo(272, 292, 312, 287, 341, 303)
        ..cubicTo(320, 345, 278, 360, 236, 344)
        ..close(),
      const Rect.fromLTWH(232, 286, 112, 78),
    );
    _drawLeaf(
      canvas,
      Path()
        ..moveTo(234, 274)
        ..cubicTo(208, 252, 187, 252, 171, 266)
        ..cubicTo(188, 288, 210, 294, 234, 284)
        ..close(),
      const Rect.fromLTWH(168, 248, 72, 50),
      small: true,
    );

    _drawBell(canvas, const Offset(174, 205), 1.02, -0.16);
    _drawBell(canvas, const Offset(292, 170), 1.12, 0.10);
    _drawBell(canvas, const Offset(283, 141), 1.18, 0.09);
    _drawBell(canvas, const Offset(301, 246), 0.96, 0.10);
    _drawBell(canvas, const Offset(211, 234), 1.08, -0.08);
  }

  static void _drawAnimatedFireflies(Canvas canvas, double t) {
    final particles = <(Offset, double, double, double)>[
      (const Offset(122, 142), 12, 1.0, 0.0),
      (const Offset(314, 112), 9, 0.8, 1.4),
      (const Offset(348, 224), 10, 1.1, 2.2),
      (const Offset(154, 292), 8, 0.9, 3.3),
      (const Offset(288, 308), 7, 1.3, 4.1),
      (const Offset(95, 258), 6, 1.2, 5.0),
    ];

    for (var i = 0; i < particles.length; i++) {
      final item = particles[i];
      final base = item.$1;
      final radius = item.$2;
      final speed = item.$3;
      final phase = item.$4;
      final dx = math.sin(t * speed + phase) * (4.5 + (i % 3) * 2.0);
      final dy = math.cos(t * (speed * 0.73) + phase * 1.2) *
          (5.5 + (i % 2) * 2.5);
      final pulse = 0.62 + 0.38 * (0.5 + 0.5 * math.sin(t * 2.1 + phase));
      _drawGlow(
        canvas,
        base + Offset(dx, dy),
        radius * (0.74 + pulse * 0.26),
        i.isEven ? const Color(0xFFFFEE57) : const Color(0xFFD6FF79),
        coreOpacity: pulse,
      );
    }
  }

  static void _drawInnerRefractions(Canvas canvas) {
    final leftRefraction = Path()
      ..moveTo(78, 174)
      ..cubicTo(99, 126, 135, 91, 187, 73);
    canvas.drawPath(
      leftRefraction,
      Paint()
        ..color = const Color(0x2E9BE8C0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    final goldRefraction = Path()
      ..moveTo(334, 351)
      ..cubicTo(367, 329, 386, 291, 399, 249);
    canvas.drawPath(
      goldRefraction,
      Paint()
        ..color = const Color(0x7AFFF672)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  static void _drawGlassRim(Canvas canvas, Rect orbRect) {
    canvas.drawCircle(
      _center,
      _radius,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFE7FFF1),
            Color(0xFF80F0B3),
            Color(0xFF245F47),
            Color(0xFFECFFF0),
            Color(0xFFF6F45A),
            Color(0xFF3A815C),
            Color(0xFFE7FFF1),
          ],
          stops: [0.0, 0.14, 0.34, 0.51, 0.67, 0.85, 1.0],
        ).createShader(orbRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0,
    );
    canvas.drawCircle(
      _center,
      _radius - 7,
      Paint()
        ..color = const Color(0x6AB8F5D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.1,
    );
  }

  static void _drawPrimaryReflection(Canvas canvas) {
    final reflection = Path()
      ..moveTo(86, 184)
      ..cubicTo(103, 125, 145, 83, 202, 64)
      ..cubicTo(226, 56, 250, 55, 274, 59);

    canvas.drawPath(
      reflection,
      Paint()
        ..color = const Color(0x62C8FFE5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 27
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawPath(
      reflection,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFDFFFEF),
            Color(0x66FFFFFF),
          ],
        ).createShader(const Rect.fromLTWH(80, 54, 200, 135))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      reflection,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );
  }

  static void _drawLowerGoldReflection(Canvas canvas) {
    final lower = Path()
      ..moveTo(334, 366)
      ..cubicTo(374, 343, 401, 307, 414, 260);
    canvas.drawPath(
      lower,
      Paint()
        ..color = const Color(0xB6FFF36A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      lower,
      Paint()
        ..color = const Color(0xEFFFF7AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  static void _drawMicroHighlights(Canvas canvas) {
    for (final item in const [
      (Offset(318, 77), 4.5),
      (Offset(352, 101), 3.0),
      (Offset(385, 164), 5.0),
      (Offset(82, 240), 3.5),
      (Offset(115, 322), 4.0),
    ]) {
      canvas.drawCircle(
        item.$1,
        item.$2,
        Paint()..color = const Color(0xEFFFFFFF),
      );
    }
  }

  static void _drawGlow(
    Canvas canvas,
    Offset center,
    double radius,
    Color color, {
    double coreOpacity = 1.0,
  }) {
    canvas.drawCircle(
      center,
      radius * 2.4,
      Paint()
        ..color = color.withValues(alpha: 0.20 * coreOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 1.4),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.98 * coreOpacity),
            color.withValues(alpha: 0.95 * coreOpacity),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.38, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  static void _softBlob(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double blur,
  ) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  static void _drawLeaf(
    Canvas canvas,
    Path path,
    Rect bounds, {
    bool small = false,
  }) {
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD6E74D),
            Color(0xFF60912B),
            Color(0xFF255421),
            Color(0xFF102E18),
          ],
          stops: [0.0, 0.35, 0.72, 1.0],
        ).createShader(bounds),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xA9EAF466)
        ..style = PaintingStyle.stroke
        ..strokeWidth = small ? 3.0 : 4.2,
    );

    final vein = Path()
      ..moveTo(bounds.left + bounds.width * 0.18, bounds.bottom - bounds.height * 0.20)
      ..lineTo(bounds.right - bounds.width * 0.12, bounds.top + bounds.height * 0.26);
    canvas.drawPath(
      vein,
      Paint()
        ..color = const Color(0x7294C644)
        ..style = PaintingStyle.stroke
        ..strokeWidth = small ? 1.5 : 2.0,
    );
  }

  static void _drawBell(
    Canvas canvas,
    Offset center,
    double scale,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(scale, scale);

    final bell = Path()
      ..moveTo(0, -24)
      ..cubicTo(-15, -22, -22, -7, -20, 9)
      ..cubicTo(-18, 15, -12, 18, -7, 13)
      ..cubicTo(-4, 21, 3, 21, 7, 13)
      ..cubicTo(12, 18, 19, 15, 22, 9)
      ..cubicTo(21, -8, 14, -22, 0, -24)
      ..close();

    final bounds = bell.getBounds();

    canvas.drawPath(
      bell,
      Paint()
        ..color = const Color(0x66FFF46A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawPath(
      bell,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF2FFF1),
            Color(0xFFFFFFD1),
            Color(0xFFF0D95D),
          ],
          stops: [0.0, 0.42, 0.76, 1.0],
        ).createShader(bounds),
    );

    canvas.drawPath(
      bell,
      Paint()
        ..color = const Color(0xFFCBDD63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    canvas.drawOval(
      const Rect.fromLTWH(-11, -17, 7, 19),
      Paint()..color = const Color(0xB8FFFFFF),
    );
    canvas.drawOval(
      const Rect.fromLTWH(5, -12, 5, 13),
      Paint()..color = const Color(0x72F7FFEE),
    );

    canvas.drawCircle(
      const Offset(0, 10),
      3.1,
      Paint()..color = const Color(0xFFE8C347),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LilyBubblePainter oldDelegate) => false;
}

class _CrayonCandidate {
  const _CrayonCandidate({
    required this.id,
    required this.name,
    required this.intent,
    required this.config,
    this.badge,
  });

  final String id;
  final String name;
  final String intent;
  final String? badge;
  final CrayonTextureSpec config;
}

const _candidates = <_CrayonCandidate>[
  _CrayonCandidate(
    id: 'CR-R3-01',
    name: 'Dense Same Brush',
    intent: 'R2-02 외곽 브러시와 비슷한 굵기의 내부 획. 가장 촘촘하고 연속적인 wax fill 기준안.',
    badge: 'DENSE',
    config: CrayonTextureSpec(
      darkStrokeCount: 27,
      lightStrokeCount: 0,
      grainCount: 36,
      strokeWidth: 3.45,
      angleDeg: -17,
      jitter: 4.4,
      darkOpacity: 0.31,
      lightOpacity: 0.0,
      grainOpacity: 0.14,
      edgeOpacity: 0.18,
      underpaintOpacity: 0.96,
      strokeBreakChance: 0.055,
      strokeBuiltSurface: true,
      broadStrokeCount: 17,
      broadStrokeWidth: 4.75,
      broadStrokeOpacity: 0.23,
      angleJitterDeg: 6.0,
      strokeWidthJitter: 0.24,
      strokeLengthMin: 0.72,
      strokeLengthMax: 1.0,
      gapChance: 0.025,
      toneVariation: 0.065,
      edgeWidth: 1.90,
      edgeMode: CrayonEdgeMode.hybrid,
      edgeSegmentLength: 8.8,
      edgeSegmentGap: 5.8,
      edgeOffsetJitter: 1.05,
      edgeWidthJitter: 0.34,
      edgeOpacityJitter: 0.38,
      edgeBandWidth: 1.8,
      overflowAmount: 1.15,
      internalGapChance: 0.060,
      internalGapWidthRatio: 0.28,
      internalGapLengthMin: 1.6,
      internalGapLengthMax: 3.4,
      internalGapStrength: 0.78,
      internalStrandCount: 1,
      internalGapOffsetJitter: 0.06,
      directionPassCount: 1,
      directionSpreadDeg: 0.0,
      laneScatter: 0.46,
      pressureVariation: 0.38,
      paperToothCount: 20,
      paperToothWidthMin: 0.10,
      paperToothWidthMax: 0.44,
      paperToothLengthMin: 0.35,
      paperToothLengthMax: 1.55,
      paperToothStrength: 0.48,
      grainRadiusMin: 0.12,
      grainRadiusMax: 0.76,
      contourBaseWidth: 3.65,
      contourBaseOpacity: 0.68,
      contourGapCount: 14,
      contourGapLengthMin: 1.5,
      contourGapLengthMax: 4.1,
      contourGapWidthScale: 0.86,
      contourGapStrength: 0.94,
    ),
  ),
  _CrayonCandidate(
    id: 'CR-R3-02',
    name: 'Broken Same Brush',
    intent: '메인 후보. R2-02 테두리처럼 굵은 내부 획도 군데군데 끊기고 wax가 덜 묻은 손칠 느낌.',
    badge: 'MAIN',
    config: CrayonTextureSpec(
      darkStrokeCount: 28,
      lightStrokeCount: 0,
      grainCount: 42,
      strokeWidth: 3.60,
      angleDeg: -17,
      jitter: 5.0,
      darkOpacity: 0.32,
      lightOpacity: 0.0,
      grainOpacity: 0.16,
      edgeOpacity: 0.18,
      underpaintOpacity: 0.93,
      strokeBreakChance: 0.135,
      strokeBuiltSurface: true,
      broadStrokeCount: 19,
      broadStrokeWidth: 4.90,
      broadStrokeOpacity: 0.24,
      angleJitterDeg: 7.5,
      strokeWidthJitter: 0.31,
      strokeLengthMin: 0.56,
      strokeLengthMax: 0.94,
      gapChance: 0.045,
      toneVariation: 0.070,
      edgeWidth: 1.90,
      edgeMode: CrayonEdgeMode.hybrid,
      edgeSegmentLength: 8.8,
      edgeSegmentGap: 5.8,
      edgeOffsetJitter: 1.05,
      edgeWidthJitter: 0.34,
      edgeOpacityJitter: 0.38,
      edgeBandWidth: 1.8,
      overflowAmount: 1.15,
      internalGapChance: 0.125,
      internalGapWidthRatio: 0.38,
      internalGapLengthMin: 1.8,
      internalGapLengthMax: 4.4,
      internalGapStrength: 0.90,
      internalStrandCount: 1,
      internalGapOffsetJitter: 0.09,
      directionPassCount: 1,
      directionSpreadDeg: 0.0,
      laneScatter: 0.55,
      pressureVariation: 0.54,
      paperToothCount: 28,
      paperToothWidthMin: 0.10,
      paperToothWidthMax: 0.50,
      paperToothLengthMin: 0.38,
      paperToothLengthMax: 1.85,
      paperToothStrength: 0.56,
      grainRadiusMin: 0.13,
      grainRadiusMax: 0.92,
      contourBaseWidth: 3.65,
      contourBaseOpacity: 0.68,
      contourGapCount: 14,
      contourGapLengthMin: 1.5,
      contourGapLengthMax: 4.1,
      contourGapWidthScale: 0.86,
      contourGapStrength: 0.94,
    ),
  ),
  _CrayonCandidate(
    id: 'CR-R3-03',
    name: 'Layered Same Brush',
    intent: '굵은 wax 획을 두 방향으로 여러 번 덧칠해, 같은 브러시지만 겹쳐 칠한 손동작을 더 강하게 표현.',
    badge: 'LAYERED',
    config: CrayonTextureSpec(
      darkStrokeCount: 30,
      lightStrokeCount: 0,
      grainCount: 48,
      strokeWidth: 3.30,
      angleDeg: -17,
      jitter: 5.4,
      darkOpacity: 0.29,
      lightOpacity: 0.0,
      grainOpacity: 0.18,
      edgeOpacity: 0.18,
      underpaintOpacity: 0.94,
      strokeBreakChance: 0.095,
      strokeBuiltSurface: true,
      broadStrokeCount: 18,
      broadStrokeWidth: 4.65,
      broadStrokeOpacity: 0.22,
      angleJitterDeg: 8.5,
      strokeWidthJitter: 0.33,
      strokeLengthMin: 0.50,
      strokeLengthMax: 0.88,
      gapChance: 0.038,
      toneVariation: 0.075,
      edgeWidth: 1.90,
      edgeMode: CrayonEdgeMode.hybrid,
      edgeSegmentLength: 8.8,
      edgeSegmentGap: 5.8,
      edgeOffsetJitter: 1.05,
      edgeWidthJitter: 0.34,
      edgeOpacityJitter: 0.38,
      edgeBandWidth: 1.8,
      overflowAmount: 1.15,
      internalGapChance: 0.095,
      internalGapWidthRatio: 0.33,
      internalGapLengthMin: 1.6,
      internalGapLengthMax: 4.0,
      internalGapStrength: 0.86,
      internalStrandCount: 1,
      internalGapOffsetJitter: 0.08,
      directionPassCount: 2,
      directionSpreadDeg: 11.0,
      laneScatter: 0.60,
      pressureVariation: 0.62,
      paperToothCount: 25,
      paperToothWidthMin: 0.10,
      paperToothWidthMax: 0.48,
      paperToothLengthMin: 0.35,
      paperToothLengthMax: 1.75,
      paperToothStrength: 0.52,
      grainRadiusMin: 0.14,
      grainRadiusMax: 1.02,
      contourBaseWidth: 3.65,
      contourBaseOpacity: 0.68,
      contourGapCount: 14,
      contourGapLengthMin: 1.5,
      contourGapLengthMax: 4.1,
      contourGapWidthScale: 0.86,
      contourGapStrength: 0.94,
    ),
  ),
  _CrayonCandidate(
    id: 'CR-R3-04',
    name: 'Balanced Same Brush',
    intent: 'R3-02의 끊김과 R3-03의 겹침을 절제해 조합한 실사용 밸런스안.',
    badge: 'BALANCED',
    config: CrayonTextureSpec(
      darkStrokeCount: 29,
      lightStrokeCount: 0,
      grainCount: 44,
      strokeWidth: 3.50,
      angleDeg: -17,
      jitter: 4.9,
      darkOpacity: 0.31,
      lightOpacity: 0.0,
      grainOpacity: 0.16,
      edgeOpacity: 0.18,
      underpaintOpacity: 0.95,
      strokeBreakChance: 0.105,
      strokeBuiltSurface: true,
      broadStrokeCount: 19,
      broadStrokeWidth: 4.82,
      broadStrokeOpacity: 0.235,
      angleJitterDeg: 7.5,
      strokeWidthJitter: 0.30,
      strokeLengthMin: 0.58,
      strokeLengthMax: 0.92,
      gapChance: 0.038,
      toneVariation: 0.070,
      edgeWidth: 1.90,
      edgeMode: CrayonEdgeMode.hybrid,
      edgeSegmentLength: 8.8,
      edgeSegmentGap: 5.8,
      edgeOffsetJitter: 1.05,
      edgeWidthJitter: 0.34,
      edgeOpacityJitter: 0.38,
      edgeBandWidth: 1.8,
      overflowAmount: 1.15,
      internalGapChance: 0.105,
      internalGapWidthRatio: 0.35,
      internalGapLengthMin: 1.7,
      internalGapLengthMax: 4.1,
      internalGapStrength: 0.88,
      internalStrandCount: 1,
      internalGapOffsetJitter: 0.08,
      directionPassCount: 2,
      directionSpreadDeg: 6.0,
      laneScatter: 0.55,
      pressureVariation: 0.55,
      paperToothCount: 26,
      paperToothWidthMin: 0.10,
      paperToothWidthMax: 0.48,
      paperToothLengthMin: 0.36,
      paperToothLengthMax: 1.80,
      paperToothStrength: 0.54,
      grainRadiusMin: 0.13,
      grainRadiusMax: 0.96,
      contourBaseWidth: 3.65,
      contourBaseOpacity: 0.68,
      contourGapCount: 14,
      contourGapLengthMin: 1.5,
      contourGapLengthMax: 4.1,
      contourGapWidthScale: 0.86,
      contourGapStrength: 0.94,
    ),
  ),
];

class CrayonStyleLab extends StatefulWidget {
  const CrayonStyleLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<CrayonStyleLab> createState() => _CrayonStyleLabState();
}

class _CrayonStyleLabState extends State<CrayonStyleLab> {
  int selectedIndex = 0;
  ShapeStyle selectedStyle = ShapeStyle.crayonSoft;

  @override
  Widget build(BuildContext context) {
    final selected = _candidates[selectedIndex];
    final compact = MediaQuery.sizeOf(context).width < 700;

    if (selectedStyle == ShapeStyle.softBasic) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StyleSelector(
            selected: selectedStyle,
            card: widget.card,
            fg: widget.fg,
            muted: widget.muted,
            onChanged: (value) => setState(() => selectedStyle = value),
          ),
          const SizedBox(height: 12),
          _SoftBasicLockedReference(
            card: widget.card,
            fg: widget.fg,
            muted: widget.muted,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StyleSelector(
          selected: selectedStyle,
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
          onChanged: (value) => setState(() => selectedStyle = value),
        ),
        const SizedBox(height: 12),
        _SectionTitle(
          title: 'Crayon Soft · Approved Master · R3-04',
          subtitle: 'CR-R3-04 Balanced Same Brush를 1차 승인 Master로 승격했습니다. 외곽은 CR-R2-02의 Broken Thick Outline 구조를 유지하고, 내부는 같은 굵은 wax stroke 문법으로 통일합니다. R3-02는 보조 레퍼런스로 보존합니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const columns = 2;
            final gap = compact ? 8.0 : 12.0;
            final itemWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            final cardHeight = compact ? 224.0 : 250.0;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < _candidates.length; i++)
                  SizedBox(
                    width: itemWidth,
                    height: cardHeight,
                    child: _CandidateCard(
                      candidate: _candidates[i],
                      selected: i == selectedIndex,
                      card: widget.card,
                      fg: widget.fg,
                      muted: widget.muted,
                      compact: compact,
                      onTap: () => setState(() => selectedIndex = i),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _SelectedCandidatePanel(
          candidate: selected,
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
        ),
      ],
    );
  }
}


class _StyleSelector extends StatelessWidget {
  const _StyleSelector({
    required this.selected,
    required this.card,
    required this.fg,
    required this.muted,
    required this.onChanged,
  });

  final ShapeStyle selected;
  final Color card;
  final Color fg;
  final Color muted;
  final ValueChanged<ShapeStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: card,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Style Lab',
                  style: TextStyle(
                    color: fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '스타일마다 후보군과 실험값을 분리합니다.',
                  style: TextStyle(color: muted, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<ShapeStyle>(
              initialValue: selected,
              isDense: true,
              decoration: const InputDecoration(
                labelText: '스타일',
                border: OutlineInputBorder(),
              ),
              items: ShapeStyle.values
                  .map(
                    (style) => DropdownMenuItem(
                      value: style,
                      child: Text(style.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftBasicLockedReference extends StatelessWidget {
  const _SoftBasicLockedReference({
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const shapes = [ShapeKind.circle, ShapeKind.triangle, ShapeKind.square];
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];
    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soft Basic · LOCKED REFERENCE',
            style: TextStyle(
              color: fg,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '이번 Crayon 최적화에서는 수정하지 않습니다. 현재 앱 렌더만 확인합니다.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final shape in shapes)
                for (final tone in tones)
                  _TokenWithLabel(
                    shape: shape,
                    tone: tone,
                    style: ShapeStyle.softBasic,
                    label: '${shape.label}·${tone.label}',
                    muted: muted,
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.selected,
    required this.card,
    required this.fg,
    required this.muted,
    required this.compact,
    required this.onTap,
  });

  final _CrayonCandidate candidate;
  final bool selected;
  final Color card;
  final Color fg;
  final Color muted;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7257F5);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.all(compact ? 9 : 11),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? accent : const Color(0xFFE6E3EE),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: selected ? 0.07 : 0.025),
                blurRadius: selected ? 12 : 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    candidate.id,
                    style: TextStyle(
                      color: fg,
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (candidate.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        candidate.badge!,
                        style: const TextStyle(
                          color: accent,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check_circle, color: accent, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F5FB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEEE9F3)),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: compact ? 126 : 144,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: compact ? 3 : 5,
                        runSpacing: compact ? 1 : 3,
                        children: [
                          for (final shape in const [
                            ShapeKind.circle,
                            ShapeKind.triangle,
                            ShapeKind.square,
                          ])
                            for (final tone in const [
                              ShapeTone.pink,
                              ShapeTone.blue,
                              ShapeTone.yellow,
                            ])
                              _ExactToken(
                                token: LockToken(shape: shape, tone: tone),
                                config: candidate.config,
                                size: compact ? 35 : 39,
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                candidate.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                candidate.intent,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: muted,
                  fontSize: compact ? 9.5 : 10.5,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _shortCrayonConfig(candidate.config),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: muted,
                  fontSize: compact ? 8.5 : 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _shortCrayonConfig(CrayonTextureSpec config) {
  return 'Stroke ' +
      config.strokeWidth.toStringAsFixed(2) +
      ' · Break ' +
      config.strokeBreakChance.toStringAsFixed(2) +
      ' · InGap ' +
      config.internalGapChance.toStringAsFixed(2) +
      ' · Fill ' +
      config.underpaintOpacity.toStringAsFixed(2);
}

class _SelectedCandidatePanel extends StatelessWidget {
  const _SelectedCandidatePanel({
    required this.candidate,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final _CrayonCandidate candidate;
  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const shapes = [ShapeKind.circle, ShapeKind.triangle, ShapeKind.square];
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];
    final compact = MediaQuery.sizeOf(context).width < 700;

    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${candidate.id} · ${candidate.name}',
            style: TextStyle(
              color: fg,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(candidate.intent, style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 14),
          Wrap(
            spacing: compact ? 8 : 12,
            runSpacing: 10,
            children: [
              for (final shape in shapes)
                for (final tone in tones)
                  SizedBox(
                    width: compact ? 66 : 78,
                    child: Column(
                      children: [
                        _ExactToken(
                          token: LockToken(shape: shape, tone: tone),
                          config: candidate.config,
                          size: 58,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${shape.label}·${tone.label}',
                          style: TextStyle(color: muted, fontSize: 9),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _ValueChip(label: 'Contour', value: '${candidate.config.contourBaseWidth.toStringAsFixed(2)} / ${candidate.config.contourBaseOpacity.toStringAsFixed(2)}'),
              _ValueChip(label: 'Contour Gaps', value: '${candidate.config.contourGapCount} / ${candidate.config.contourGapLengthMin.toStringAsFixed(1)}–${candidate.config.contourGapLengthMax.toStringAsFixed(1)}'),
              _ValueChip(label: 'Underpaint', value: candidate.config.underpaintOpacity.toStringAsFixed(2)),
              _ValueChip(label: 'Broad', value: '${candidate.config.broadStrokeCount}×${candidate.config.broadStrokeWidth.toStringAsFixed(1)}'),
              _ValueChip(label: 'Main', value: '${candidate.config.darkStrokeCount}×${candidate.config.strokeWidth.toStringAsFixed(2)}'),
              _ValueChip(label: 'Passes', value: '${candidate.config.directionPassCount} / ${candidate.config.directionSpreadDeg.toStringAsFixed(0)}°'),
              _ValueChip(label: 'Lane Scatter', value: candidate.config.laneScatter.toStringAsFixed(2)),
              _ValueChip(label: 'Pressure', value: candidate.config.pressureVariation.toStringAsFixed(2)),
              _ValueChip(label: 'Break', value: candidate.config.strokeBreakChance.toStringAsFixed(2)),
              _ValueChip(label: 'Fill Gap', value: candidate.config.gapChance.toStringAsFixed(2)),
              _ValueChip(label: 'Paper Tooth', value: '${candidate.config.paperToothCount}'),
              _ValueChip(label: 'Tooth W', value: '${candidate.config.paperToothWidthMin.toStringAsFixed(2)}–${candidate.config.paperToothWidthMax.toStringAsFixed(2)}'),
              _ValueChip(label: 'Tooth L', value: '${candidate.config.paperToothLengthMin.toStringAsFixed(1)}–${candidate.config.paperToothLengthMax.toStringAsFixed(1)}'),
              _ValueChip(label: 'Grain', value: '${candidate.config.grainCount} / ${candidate.config.grainRadiusMax.toStringAsFixed(2)}'),
              _ValueChip(label: 'Edge', value: candidate.config.edgeMode.name),
            ],
          ),
        ],
      ),
    );
  }
}

class PaletteLab extends StatelessWidget {
  const PaletteLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];

    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Palette Lab',
            subtitle: '기본 3색을 Soft Basic / Crayon Soft에 동일 적용해 색 구분을 확인합니다.',
            fg: fg,
            muted: muted,
          ),
          const SizedBox(height: 16),
          for (final tone in tones) ...[
            Text(
              tone.label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                _TokenWithLabel(
                  shape: ShapeKind.circle,
                  tone: tone,
                  style: ShapeStyle.softBasic,
                  label: 'Soft',
                  muted: muted,
                ),
                _TokenWithLabel(
                  shape: ShapeKind.circle,
                  tone: tone,
                  style: ShapeStyle.crayonSoft,
                  label: 'Crayon',
                  muted: muted,
                ),
                _TokenWithLabel(
                  shape: ShapeKind.triangle,
                  tone: tone,
                  style: ShapeStyle.crayonSoft,
                  label: 'Triangle',
                  muted: muted,
                ),
                _TokenWithLabel(
                  shape: ShapeKind.square,
                  tone: tone,
                  style: ShapeStyle.crayonSoft,
                  label: 'Square',
                  muted: muted,
                ),
              ],
            ),
            if (tone != tones.last) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class EffectLab extends StatefulWidget {
  const EffectLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<EffectLab> createState() => _EffectLabState();
}

class _EffectLabState extends State<EffectLab> {
  MovementStyle movement = MovementStyle.floating;
  PopStyle pop = PopStyle.basicPop;
  ShapeStyle style = ShapeStyle.crayonSoft;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: widget.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Effect Lab',
            subtitle: '실제 FloatingPreview에서 Motion / POP 조합을 바로 확인합니다.',
            fg: widget.fg,
            muted: widget.muted,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _EnumDropdown<MovementStyle>(
                label: 'Motion',
                value: movement,
                values: MovementStyle.values,
                text: (v) => v.label,
                onChanged: (v) => setState(() => movement = v),
              ),
              _EnumDropdown<PopStyle>(
                label: 'POP',
                value: pop,
                values: PopStyle.values,
                text: (v) => v.label,
                onChanged: (v) => setState(() => pop = v),
              ),
              _EnumDropdown<ShapeStyle>(
                label: 'Style',
                value: style,
                values: ShapeStyle.values,
                text: (v) => v.label,
                onChanged: (v) => setState(() => style = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0FA),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: FloatingPreview(
              selectedShapes: ShapeKind.defaults,
              selectedTones: ShapeTone.defaults,
              movementStyle: movement,
              popStyle: pop,
              style: style,
              objectCount: 9,
              movementArea: MovementArea.full,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '도형을 탭하면 선택한 POP 반응을 확인할 수 있습니다.',
            style: TextStyle(color: widget.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class RuntimeQaLab extends StatefulWidget {
  const RuntimeQaLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<RuntimeQaLab> createState() => _RuntimeQaLabState();
}

class _RuntimeQaLabState extends State<RuntimeQaLab> {
  int count = 12;
  MovementStyle movement = MovementStyle.floating;
  ShapeStyle style = ShapeStyle.crayonSoft;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: widget.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Runtime QA',
            subtitle: '6 / 9 / 12개 동시 렌더에서 가독성과 움직임을 확인합니다.',
            fg: widget.fg,
            muted: widget.muted,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final value in const [6, 9, 12])
                ChoiceChip(
                  label: Text('$value개'),
                  selected: count == value,
                  onSelected: (_) => setState(() => count = value),
                ),
              _EnumDropdown<MovementStyle>(
                label: 'Motion',
                value: movement,
                values: MovementStyle.values,
                text: (v) => v.label,
                onChanged: (v) => setState(() => movement = v),
              ),
              _EnumDropdown<ShapeStyle>(
                label: 'Style',
                value: style,
                values: ShapeStyle.values,
                text: (v) => v.label,
                onChanged: (v) => setState(() => style = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 430,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF5FA), Color(0xFFF0F3FF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: FloatingPreview(
              selectedShapes: ShapeKind.defaults,
              selectedTones: ShapeTone.defaults,
              movementStyle: movement,
              popStyle: PopStyle.basicPop,
              style: style,
              objectCount: count,
              movementArea: MovementArea.full,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExactToken extends StatelessWidget {
  const _ExactToken({
    required this.token,
    required this.config,
    this.size = 58,
  });

  final LockToken token;
  final CrayonTextureSpec config;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: LockTokenPainter(
          token,
          style: ShapeStyle.crayonSoft,
          crayonOverride: config,
        ),
      ),
    );
  }
}

class _TokenWithLabel extends StatelessWidget {
  const _TokenWithLabel({
    required this.shape,
    required this.tone,
    required this.style,
    required this.label,
    required this.muted,
  });

  final ShapeKind shape;
  final ShapeTone tone;
  final ShapeStyle style;
  final String label;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          SizedBox.square(
            dimension: 58,
            child: CustomPaint(
              painter: LockTokenPainter(
                LockToken(shape: shape, tone: tone),
                style: style,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: muted, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.text,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) text;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<T>(
        value: value,
        isDense: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        items: [
          for (final item in values)
            DropdownMenuItem<T>(
              value: item,
              child: Text(text(item), overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.fg,
    required this.muted,
  });

  final String title;
  final String subtitle;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: fg,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(color: muted, fontSize: 12, height: 1.35),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E5EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFF8),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Color(0xFF4D4568),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
