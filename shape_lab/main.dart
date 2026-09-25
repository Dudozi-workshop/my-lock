import 'package:flutter/material.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShapeSpecRegistry.instance.load();
  runApp(const CrayonStyleLabApp());
}

class CrayonStyleLabApp extends StatelessWidget {
  const CrayonStyleLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK Shape Lab · Crayon Soft',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7A5AF8),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const CrayonStyleLabPage(),
    );
  }
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
    id: 'C01',
    name: 'Current 008',
    intent: '현재 앱 기준. 비교의 출발점.',
    badge: 'CURRENT',
    config: CrayonTextureSpec(
      darkStrokeCount: 34,
      lightStrokeCount: 18,
      grainCount: 30,
      strokeWidth: 1.35,
      angleDeg: -18,
      jitter: 2.6,
      darkOpacity: 0.17,
      lightOpacity: 0.16,
      grainOpacity: 0.18,
      edgeOpacity: 0.16,
    ),
  ),
  _CrayonCandidate(
    id: 'C02',
    name: 'Fine Dense',
    intent: '얇고 촘촘한 결. 작은 크기 가독성 우선.',
    config: CrayonTextureSpec(
      darkStrokeCount: 52,
      lightStrokeCount: 26,
      grainCount: 22,
      strokeWidth: 0.86,
      angleDeg: -18,
      jitter: 1.5,
      darkOpacity: 0.14,
      lightOpacity: 0.14,
      grainOpacity: 0.11,
      edgeOpacity: 0.12,
    ),
  ),
  _CrayonCandidate(
    id: 'C03',
    name: 'Bold Hand',
    intent: '굵고 손그림다운 터치. 질감 존재감 강화.',
    config: CrayonTextureSpec(
      darkStrokeCount: 24,
      lightStrokeCount: 12,
      grainCount: 24,
      strokeWidth: 2.05,
      angleDeg: -16,
      jitter: 3.3,
      darkOpacity: 0.19,
      lightOpacity: 0.14,
      grainOpacity: 0.16,
      edgeOpacity: 0.20,
    ),
  ),
  _CrayonCandidate(
    id: 'C04',
    name: 'Loose Grain',
    intent: '불규칙성 증가. 더 자연스러운 손칠 느낌.',
    config: CrayonTextureSpec(
      darkStrokeCount: 38,
      lightStrokeCount: 19,
      grainCount: 48,
      strokeWidth: 1.14,
      angleDeg: -24,
      jitter: 4.6,
      darkOpacity: 0.16,
      lightOpacity: 0.13,
      grainOpacity: 0.21,
      edgeOpacity: 0.13,
    ),
  ),
  _CrayonCandidate(
    id: 'C05',
    name: 'Clean Edge',
    intent: '내부는 크레용, 외곽 실루엣은 또렷하게.',
    config: CrayonTextureSpec(
      darkStrokeCount: 36,
      lightStrokeCount: 16,
      grainCount: 18,
      strokeWidth: 1.16,
      angleDeg: -18,
      jitter: 1.9,
      darkOpacity: 0.16,
      lightOpacity: 0.12,
      grainOpacity: 0.09,
      edgeOpacity: 0.30,
    ),
  ),
  _CrayonCandidate(
    id: 'C06',
    name: 'Soft Pastel',
    intent: '밝고 포근한 결. 어두운 선을 약하게.',
    config: CrayonTextureSpec(
      darkStrokeCount: 30,
      lightStrokeCount: 24,
      grainCount: 42,
      strokeWidth: 1.42,
      angleDeg: -12,
      jitter: 3.0,
      darkOpacity: 0.09,
      lightOpacity: 0.23,
      grainOpacity: 0.13,
      edgeOpacity: 0.09,
    ),
  ),
  _CrayonCandidate(
    id: 'C07',
    name: 'High Contrast',
    intent: '색과 결을 선명하게. 축소 시 질감 유지.',
    config: CrayonTextureSpec(
      darkStrokeCount: 31,
      lightStrokeCount: 14,
      grainCount: 20,
      strokeWidth: 1.56,
      angleDeg: -22,
      jitter: 2.4,
      darkOpacity: 0.27,
      lightOpacity: 0.12,
      grainOpacity: 0.11,
      edgeOpacity: 0.23,
    ),
  ),
  _CrayonCandidate(
    id: 'C08',
    name: 'Mockup Aim',
    intent: '목업의 따뜻한 사선 크레용 결을 목표로 한 균형안.',
    badge: 'TARGET',
    config: CrayonTextureSpec(
      darkStrokeCount: 42,
      lightStrokeCount: 20,
      grainCount: 28,
      strokeWidth: 1.08,
      angleDeg: -22,
      jitter: 2.7,
      darkOpacity: 0.20,
      lightOpacity: 0.13,
      grainOpacity: 0.15,
      edgeOpacity: 0.15,
    ),
  ),
];

class CrayonStyleLabPage extends StatefulWidget {
  const CrayonStyleLabPage({super.key});

  @override
  State<CrayonStyleLabPage> createState() => _CrayonStyleLabPageState();
}

class _CrayonStyleLabPageState extends State<CrayonStyleLabPage> {
  int selectedIndex = 0;
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF101218) : const Color(0xFFF6F5FA);
    final card = dark ? const Color(0xFF1A1D26) : Colors.white;
    final fg = dark ? Colors.white : const Color(0xFF171923);
    final muted = dark ? const Color(0xFFAEB4C3) : const Color(0xFF6D7382);
    final selected = _candidates[selectedIndex];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MY LOCK Shape Lab',
                              style: TextStyle(
                                color: fg,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Crayon Soft · 실제 ShapeSpecRenderer 후보 비교',
                              style: TextStyle(color: muted, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Dark', style: TextStyle(color: muted)),
                          Switch(
                            value: dark,
                            onChanged: (value) => setState(() => dark = value),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Panel(
                    color: card,
                    child: Text(
                      'C01~C08은 이미지 시안이 아니라 앱과 동일한 LockTokenPainter + '
                      'Crayon Soft 렌더러를 서로 다른 파라미터로 즉시 그립니다. '
                      '좋은 후보를 고른 뒤 다음 라운드에서 요소를 조합합니다.',
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'ROUND 1 · 방향 탐색',
                    style: TextStyle(
                      color: fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 1040
                          ? 4
                          : width >= 700
                              ? 2
                              : 1;
                      final itemWidth =
                          (width - (columns - 1) * 12) / columns;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (var i = 0; i < _candidates.length; i++)
                            SizedBox(
                              width: itemWidth,
                              child: _CandidateCard(
                                candidate: _candidates[i],
                                selected: i == selectedIndex,
                                card: card,
                                fg: fg,
                                muted: muted,
                                onTap: () => setState(() => selectedIndex = i),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _SelectedCandidatePanel(
                    candidate: selected,
                    card: card,
                    fg: fg,
                    muted: muted,
                  ),
                ],
              ),
            ),
          ),
        ),
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
    required this.onTap,
  });

  final _CrayonCandidate candidate;
  final bool selected;
  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7257F5);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? accent : const Color(0xFFE6E3EE),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: selected ? 0.08 : 0.035),
                blurRadius: selected ? 18 : 10,
                offset: const Offset(0, 5),
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
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (candidate.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        candidate.badge!,
                        style: const TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check_circle, color: accent, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(
                height: 66,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -66),
                child: SizedBox(
                  height: 66,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ExactToken(
                        token: LockToken(
                          shape: ShapeKind.circle,
                          tone: ShapeTone.pink,
                        ),
                        config: candidate.config,
                      ),
                      _ExactToken(
                        token: LockToken(
                          shape: ShapeKind.triangle,
                          tone: ShapeTone.blue,
                        ),
                        config: candidate.config,
                      ),
                      _ExactToken(
                        token: LockToken(
                          shape: ShapeKind.square,
                          tone: ShapeTone.yellow,
                        ),
                        config: candidate.config,
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -58),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: TextStyle(
                        color: fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.intent,
                      style: TextStyle(color: muted, fontSize: 12, height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _shortConfig(candidate.config),
                      style: TextStyle(
                        color: muted,
                        fontSize: 10.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${candidate.id} · ${candidate.name}',
                  style: TextStyle(
                    color: fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7257F5).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '58×58 APP EXACT',
                  style: TextStyle(
                    color: Color(0xFF7257F5),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(candidate.intent, style: TextStyle(color: muted)),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              final large = _LargePreview(candidate: candidate, fg: fg, muted: muted);
              final matrix = _ExactMatrix(candidate: candidate, fg: fg, muted: muted);
              if (narrow) {
                return Column(
                  children: [
                    large,
                    const SizedBox(height: 18),
                    matrix,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: large),
                  const SizedBox(width: 22),
                  Expanded(flex: 2, child: matrix),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            '파라미터',
            style: TextStyle(color: fg, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: 'Dark strokes', value: '${candidate.config.darkStrokeCount}'),
              _Chip(label: 'Light strokes', value: '${candidate.config.lightStrokeCount}'),
              _Chip(label: 'Grain', value: '${candidate.config.grainCount}'),
              _Chip(label: 'Width', value: candidate.config.strokeWidth.toStringAsFixed(2)),
              _Chip(label: 'Angle', value: '${candidate.config.angleDeg.toStringAsFixed(0)}°'),
              _Chip(label: 'Jitter', value: candidate.config.jitter.toStringAsFixed(1)),
              _Chip(label: 'Dark α', value: candidate.config.darkOpacity.toStringAsFixed(2)),
              _Chip(label: 'Light α', value: candidate.config.lightOpacity.toStringAsFixed(2)),
              _Chip(label: 'Grain α', value: candidate.config.grainOpacity.toStringAsFixed(2)),
              _Chip(label: 'Edge α', value: candidate.config.edgeOpacity.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '평가 포인트: ① 목업과의 감성 거리 ② 58px에서 질감 유지 '
            '③ Pink / Blue / Yellow 구분 ④ 실루엣 선명도. '
            '마음에 드는 후보를 기준으로 다음 Round에서 폭·밀도·거칠기만 좁혀갑니다.',
            style: TextStyle(color: muted, fontSize: 12.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _LargePreview extends StatelessWidget {
  const _LargePreview({
    required this.candidate,
    required this.fg,
    required this.muted,
  });

  final _CrayonCandidate candidate;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '4× 확대',
          style: TextStyle(color: fg, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: Transform.scale(
              scale: 3.7,
              child: _ExactToken(
                token: const LockToken(
                  shape: ShapeKind.circle,
                  tone: ShapeTone.pink,
                ),
                config: candidate.config,
              ),
            ),
          ),
        ),
        Text(
          '58px 결과 자체를 확대 · 재렌더 아님',
          style: TextStyle(color: muted, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ExactMatrix extends StatelessWidget {
  const _ExactMatrix({
    required this.candidate,
    required this.fg,
    required this.muted,
  });

  final _CrayonCandidate candidate;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const shapes = [ShapeKind.circle, ShapeKind.triangle, ShapeKind.square];
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3 Shapes × 3 Colors',
          style: TextStyle(color: fg, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final shape in shapes)
              for (final tone in tones)
                SizedBox(
                  width: 78,
                  child: Column(
                    children: [
                      _ExactToken(
                        token: LockToken(shape: shape, tone: tone),
                        config: candidate.config,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${shape.label} · ${tone.label}',
                        style: TextStyle(color: muted, fontSize: 9.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ],
    );
  }
}

class _ExactToken extends StatelessWidget {
  const _ExactToken({
    required this.token,
    required this.config,
  });

  final LockToken token;
  final CrayonTextureSpec config;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 58,
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

class _Panel extends StatelessWidget {
  const _Panel({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E5EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFF8),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Color(0xFF4D4568),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _shortConfig(CrayonTextureSpec c) {
  return 'W ${c.strokeWidth.toStringAsFixed(2)} · D ${c.darkStrokeCount} · '
      'J ${c.jitter.toStringAsFixed(1)} · E ${c.edgeOpacity.toStringAsFixed(2)}';
}
