import 'package:flutter/material.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';

void main() {
  runApp(const MyLockLabsApp());
}

enum LabTab { shape, palette, effect, qa }

class MyLockLabsApp extends StatelessWidget {
  const MyLockLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK Labs',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF5C6CF2),
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

class _LabsPageState extends State<LabsPage>
    with SingleTickerProviderStateMixin {
  LabTab tab = LabTab.shape;
  bool dark = false;
  late final AnimationController effectController;

  @override
  void initState() {
    super.initState();
    effectController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    effectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF101218) : const Color(0xFFF4F5F8);
    final card = dark ? const Color(0xFF1A1D26) : Colors.white;
    final fg = dark ? Colors.white : const Color(0xFF171923);
    final muted =
        dark ? const Color(0xFFAEB4C3) : const Color(0xFF6D7382);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
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
                              'MY LOCK Labs',
                              style: TextStyle(
                                color: fg,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Shape Master · Palette · Effect · Runtime QA',
                              style: TextStyle(color: muted),
                            ),
                          ],
                        ),
                      ),
                      Row(
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
                  const SizedBox(height: 16),
                  SegmentedButton<LabTab>(
                    segments: const [
                      ButtonSegment(
                        value: LabTab.shape,
                        label: Text('Shape Lab'),
                      ),
                      ButtonSegment(
                        value: LabTab.palette,
                        label: Text('Palette Lab'),
                      ),
                      ButtonSegment(
                        value: LabTab.effect,
                        label: Text('Effect Lab'),
                      ),
                      ButtonSegment(
                        value: LabTab.qa,
                        label: Text('Runtime QA'),
                      ),
                    ],
                    selected: {tab},
                    onSelectionChanged: (value) {
                      setState(() => tab = value.first);
                    },
                  ),
                  const SizedBox(height: 18),
                  if (tab == LabTab.shape)
                    ShapeLab(card: card, fg: fg, muted: muted),
                  if (tab == LabTab.palette)
                    PaletteLab(
                      card: card,
                      fg: fg,
                      muted: muted,
                      effectController: effectController,
                    ),
                  if (tab == LabTab.effect)
                    EffectLab(
                      card: card,
                      fg: fg,
                      muted: muted,
                      effectController: effectController,
                    ),
                  if (tab == LabTab.qa)
                    RuntimeQa(card: card, fg: fg, muted: muted),
                ],
              ),
            ),
          ),
        ),
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
    return Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shape Lab',
            style: TextStyle(
              color: fg,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '확정된 Shape Master만 보관합니다. 후보안은 확정 전 별도 작업으로 관리합니다.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 18),
          Text(
            'Drop 01 · Dolphin · MASTER LOCKED',
            style: TextStyle(color: fg, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TokenPreview(
                shape: ShapeKind.dolphin,
                color: const Color(0xFF4F8EDB),
                size: 190,
              ),
              SizedBox(
                width: 380,
                child: Text(
                  '02 날렵형 · Geometry Lock\n'
                  'Color / Accent / Animation / Motion / Effect는 '
                  '이 Master geometry에서만 파생합니다.',
                  style: TextStyle(color: muted, height: 1.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaletteEntry {
  const PaletteEntry({
    required this.en,
    required this.ko,
    required this.color,
    required this.hex,
    this.gradient,
    this.effectLabel,
  });

  final String en;
  final String ko;
  final Color color;
  final String hex;
  final List<Color>? gradient;
  final String? effectLabel;

  bool get hasGradient => gradient != null && gradient!.length >= 2;
  bool get hasColorEffect => effectLabel != null;
}

const drop01Palette = [
  PaletteEntry(
    en: 'Deep Ocean',
    ko: '딥 오션 블루',
    color: Color(0xFF4F8EDB),
    hex: '#4F8EDB',
  ),
  PaletteEntry(
    en: 'Aqua Mint',
    ko: '아쿠아 민트',
    color: Color(0xFF7CCFC4),
    hex: '#7CCFC4',
  ),
  PaletteEntry(
    en: 'Coral Red',
    ko: '코랄 레드',
    color: Color(0xFFF7A7B5),
    hex: '#F7A7B5',
  ),
  PaletteEntry(
    en: 'Sand Gold',
    ko: '샌드 골드',
    color: Color(0xFFEFD59A),
    hex: '#EFD59A',
  ),
  PaletteEntry(
    en: 'Jelly Violet',
    ko: '젤리 바이올렛',
    color: Color(0xFFB9A7E8),
    hex: '#B9A7E8',
  ),
  PaletteEntry(
    en: 'Sea Orange',
    ko: '씨 오렌지',
    color: Color(0xFFF7B385),
    hex: '#F7B385',
  ),
  PaletteEntry(
    en: 'Aurora Sea',
    ko: '오로라 씨',
    color: Color(0xFF7FB8FF),
    hex: '#A7D8F7 → #7FB8FF → #C7B6F3',
    gradient: [
      Color(0xFFA7D8F7),
      Color(0xFF7FB8FF),
      Color(0xFFC7B6F3),
    ],
    effectLabel: 'Slow Gradient Flow',
  ),
];

const drop02Palette = [
  PaletteEntry(
    en: 'Sunlit Acorn',
    ko: '볕든도토리',
    color: Color(0xFFC97A3D),
    hex: '#C97A3D',
  ),
  PaletteEntry(
    en: 'Leaf Green',
    ko: '잎새초록',
    color: Color(0xFF79D34D),
    hex: '#79D34D',
  ),
  PaletteEntry(
    en: 'Mushroom Cream',
    ko: '버섯크림',
    color: Color(0xFFFFD98A),
    hex: '#FFD98A',
  ),
  PaletteEntry(
    en: 'Maple Orange',
    ko: '단풍주황',
    color: Color(0xFFFF8A3D),
    hex: '#FF8A3D',
  ),
  PaletteEntry(
    en: 'Forest Berry',
    ko: '숲속딸기',
    color: Color(0xFFF05A82),
    hex: '#F05A82',
  ),
  PaletteEntry(
    en: 'Forest Teal',
    ko: '숲청록',
    color: Color(0xFF27B8A6),
    hex: '#27B8A6',
  ),
  PaletteEntry(
    en: 'Forest Light',
    ko: '숲빛',
    color: Color(0xFFE5E94F),
    hex: '#8BDD55 → #E5E94F → #FFD45A',
    gradient: [
      Color(0xFF8BDD55),
      Color(0xFFE5E94F),
      Color(0xFFFFD45A),
    ],
    effectLabel: 'Slow Forest Gradient',
  ),
];

class PaletteLab extends StatefulWidget {
  const PaletteLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
    required this.effectController,
  });

  final Color card;
  final Color fg;
  final Color muted;
  final AnimationController effectController;

  @override
  State<PaletteLab> createState() => _PaletteLabState();
}

class _PaletteLabState extends State<PaletteLab> {
  int selectedIndex = 0;
  int paletteGroup = 0;
  ShapeKind previewShape = ShapeKind.dolphin;

  List<PaletteEntry> get activePalette =>
      paletteGroup == 0 ? drop01Palette : drop02Palette;

  @override
  Widget build(BuildContext context) {
    final palette = activePalette;
    final selected = palette[selectedIndex.clamp(0, palette.length - 1)];

    return Column(
      children: [
        Panel(
          color: widget.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Palette Lab',
                style: TextStyle(
                  color: widget.fg,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '확정 HEX/Gradient를 실제 Shape에 직접 적용해 비교합니다.',
                style: TextStyle(color: widget.muted),
              ),
              const SizedBox(height: 12),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Drop 01 · 작은 바닷속')),
                  ButtonSegment(value: 1, label: Text('Drop 02 · 도토리숲')),
                ],
                selected: {paletteGroup},
                onSelectionChanged: (value) {
                  setState(() {
                    paletteGroup = value.first;
                    selectedIndex = 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth < 760
                      ? (constraints.maxWidth - 10) / 2
                      : (constraints.maxWidth - 20) / 3;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < palette.length; i++)
                        SizedBox(
                          width: width,
                          child: PaletteSwatch(
                            entry: palette[i],
                            selected: i == selectedIndex,
                            onTap: () {
                              setState(() => selectedIndex = i);
                            },
                            fg: widget.fg,
                            muted: widget.muted,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Signature Color도 동일 목록에서 선택해 실제 Shape 적용을 확인합니다.',
                style: TextStyle(color: widget.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          color: widget.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${selected.en} 실제 적용 Preview',
                      style: TextStyle(
                        color: widget.fg,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  DropdownButton<ShapeKind>(
                    value: previewShape,
                    items: const [
                      ShapeKind.circle,
                      ShapeKind.triangle,
                      ShapeKind.square,
                      ShapeKind.dolphin,
                    ]
                        .map(
                          (shape) => DropdownMenuItem(
                            value: shape,
                            child: Text(shape.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => previewShape = value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AnimatedBuilder(
                animation: widget.effectController,
                builder: (context, _) {
                  return Wrap(
                    spacing: 22,
                    runSpacing: 18,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      LabeledPreview(
                        label: 'Large',
                        child: PaletteTokenPreview(
                          shape: previewShape,
                          entry: selected,
                          size: 180,
                          phase: widget.effectController.value,
                        ),
                      ),
                      LabeledPreview(
                        label: '100 px',
                        child: PaletteTokenPreview(
                          shape: previewShape,
                          entry: selected,
                          size: 100,
                          phase: widget.effectController.value,
                        ),
                      ),
                      LabeledPreview(
                        label: '58 px · APP',
                        child: PaletteTokenPreview(
                          shape: previewShape,
                          entry: selected,
                          size: 58,
                          phase: widget.effectController.value,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    selected.hasColorEffect ? Icons.auto_awesome : Icons.circle_outlined,
                    size: 18,
                    color: widget.muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selected.hasColorEffect
                          ? 'Color Effect 자동 재생 · ${selected.effectLabel}'
                          : 'Static Color · 별도 Color Effect 없음',
                      style: TextStyle(color: widget.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Shape 밖 Particle은 Effect Lab에서 분리 검수',
                style: TextStyle(color: widget.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PaletteSwatch extends StatelessWidget {
  const PaletteSwatch({
    super.key,
    required this.entry,
    required this.selected,
    required this.onTap,
    required this.fg,
    required this.muted,
  });

  final PaletteEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? fg : muted.withValues(alpha: 0.25),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 78,
              decoration: BoxDecoration(
                color: entry.hasGradient ? null : entry.color,
                gradient: entry.hasGradient
                    ? LinearGradient(colors: entry.gradient!)
                    : null,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.en,
              style: TextStyle(color: fg, fontWeight: FontWeight.w800),
            ),
            Text(
              entry.ko,
              style: TextStyle(color: muted, fontSize: 12),
            ),
            Text(
              entry.hex,
              style: TextStyle(color: muted, fontSize: 12),
            ),
            if (entry.hasColorEffect) ...[
              const SizedBox(height: 4),
              Text(
                'EFFECT · ${entry.effectLabel}',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
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
    required this.effectController,
  });

  final Color card;
  final Color fg;
  final Color muted;
  final AnimationController effectController;

  @override
  State<EffectLab> createState() => _EffectLabState();
}

class _EffectLabState extends State<EffectLab> {
  ShapeKind previewShape = ShapeKind.dolphin;
  ShapeTone effectTone = ShapeTone.fireflyLight;

  @override
  Widget build(BuildContext context) {
    return Panel(
      color: widget.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Effect Lab',
            style: TextStyle(
              color: widget.fg,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shape 밖 Bubble / Sparkle / Firefly / Trail을 Color와 분리해 검수합니다.',
            style: TextStyle(color: widget.muted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DropdownButton<ShapeKind>(
                value: previewShape,
                items: const [
                  ShapeKind.circle,
                  ShapeKind.triangle,
                  ShapeKind.square,
                  ShapeKind.dolphin,
                ]
                    .map(
                      (shape) => DropdownMenuItem(
                        value: shape,
                        child: Text(shape.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => previewShape = value);
                  }
                },
              ),
              DropdownButton<ShapeTone>(
                value: effectTone,
                items: const [
                  ShapeTone.dawnDew,
                  ShapeTone.fireflyLight,
                ]
                    .map(
                      (tone) => DropdownMenuItem(
                        value: tone,
                        child: Text(tone.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => effectTone = value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: widget.effectController,
            builder: (context, _) {
              return Center(
                child: SizedBox.square(
                  dimension: 260,
                  child: CustomPaint(
                    painter: LockTokenPainter(
                      LockToken(
                        shape: previewShape,
                        tone: effectTone,
                      ),
                      texture: ShapeTexture.glossy,
                      effectPhase: widget.effectController.value,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            effectTone == ShapeTone.fireflyLight
                ? 'Firefly · 8초 cycle · 불규칙 waypoint 이동'
                : 'Dawn Dew · 내부 광 이동',
            style: TextStyle(color: widget.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class RuntimeQa extends StatelessWidget {
  const RuntimeQa({
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
    return Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Runtime QA',
            style: TextStyle(
              color: fg,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '검수 기준',
            style: TextStyle(color: fg, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '• 58×58 실제 크기 식별성\n'
            '• Light / Dark 배경 가독성\n'
            '• Basic Palette와 Drop Palette 구분\n'
            '• Color 내부 표현과 Runtime Effect 분리\n'
            '• 확정 Shape의 Geometry Lock 유지\n'
            '• 향후 6 / 9 / 12개 동시 표시 성능 QA',
            style: TextStyle(color: muted, height: 1.75),
          ),
        ],
      ),
    );
  }
}

class TokenPreview extends StatelessWidget {
  const TokenPreview({
    super.key,
    required this.shape,
    required this.color,
    required this.size,
    this.effectPhase,
  });

  final ShapeKind shape;
  final Color color;
  final double size;
  final double? effectPhase;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: LockTokenPainter(
          LockToken(shape: shape, tone: ShapeTone.blue),
          texture: ShapeTexture.glossy,
          colorOverride: color,
          effectPhase: effectPhase,
        ),
      ),
    );
  }
}


class PaletteTokenPreview extends StatelessWidget {
  const PaletteTokenPreview({
    super.key,
    required this.shape,
    required this.entry,
    required this.size,
    required this.phase,
  });

  final ShapeKind shape;
  final PaletteEntry entry;
  final double size;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final base = TokenPreview(
      shape: shape,
      color: entry.color,
      size: size,
    );

    if (!entry.hasGradient) return base;

    final shifted = (phase + 0.18) % 1.0;
    return ShaderMask(
      blendMode: BlendMode.modulate,
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment(-1.2 + phase * 0.8, -0.9),
          end: Alignment(1.0 + phase * 0.8, 0.9),
          colors: [
            entry.gradient![0],
            entry.gradient![1],
            entry.gradient![2],
            entry.gradient![0],
          ],
          stops: [
            0.0,
            (0.30 + shifted * 0.12).clamp(0.0, 1.0),
            (0.68 + shifted * 0.10).clamp(0.0, 1.0),
            1.0,
          ],
        ).createShader(rect);
      },
      child: base,
    );
  }
}

class LabeledPreview extends StatelessWidget {
  const LabeledPreview({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        child,
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
