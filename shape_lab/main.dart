import 'dart:convert';
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
                                  'LAB 028 · Lily Bubble Illustrated Asset · 58px',
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
                  'Lily Bubble · Illustrated Runtime',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '코드 드로잉 대신 일러스트 원본을 직접 런타임 베이스로 사용하고, 반딧불만 실시간 오버레이 애니메이션으로 움직입니다.',
                  style: TextStyle(
                    color: muted.withValues(alpha: 0.98),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ILLUSTRATED ASSET 128px  ·  DISPLAY 58px  ·  FIREFLY LIVE',
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


const _lilyBubbleIllustrationBase64 = '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';

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
    duration: const Duration(milliseconds: 9800),
  )..repeat();

  late final imageBytes = base64Decode(_lilyBubbleIllustrationBase64);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.displaySize,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _LilyFireflyOverlayPainter(_controller.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LilyFireflyOverlayPainter extends CustomPainter {
  const _LilyFireflyOverlayPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    final particles = <(Offset, double, double, double)>[
      (const Offset(0.24, 0.30), 1.0, 0.0, 0.85),
      (const Offset(0.76, 0.25), 0.85, 1.3, 0.72),
      (const Offset(0.82, 0.52), 1.1, 2.4, 0.92),
      (const Offset(0.31, 0.69), 0.9, 3.3, 0.76),
      (const Offset(0.66, 0.73), 1.2, 4.2, 0.82),
    ];

    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final base = Offset(p.$1.dx * size.width, p.$1.dy * size.height);
      final amp = size.width * (0.018 + (i % 3) * 0.005);
      final dx = math.sin(t * p.$2 + p.$3) * amp;
      final dy = math.cos(t * (p.$2 * 0.73) + p.$3) * amp;
      final pulse = 0.58 + 0.42 * (0.5 + 0.5 * math.sin(t * 2.1 + p.$3));
      final radius = size.width * (0.018 + 0.006 * (i % 2));

      _paintGlow(
        canvas,
        base + Offset(dx, dy),
        radius,
        pulse * p.$4,
      );
    }
  }

  static void _paintGlow(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    canvas.drawCircle(
      center,
      radius * 3.2,
      Paint()
        ..color = const Color(0xFFFFF06A).withValues(alpha: 0.16 * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 2.0),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.98 * opacity),
            const Color(0xFFFFEE58).withValues(alpha: 0.92 * opacity),
            const Color(0x00FFEE58),
          ],
          stops: const [0.0, 0.35, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _LilyFireflyOverlayPainter oldDelegate) =>
      oldDelegate.progress != progress;
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
