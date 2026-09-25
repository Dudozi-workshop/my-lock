import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:my_lock/lock_engine/effects.dart';
import 'package:my_lock/lock_engine/floating_preview.dart';
import 'package:my_lock/lock_engine/floating_engine.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';

import 'soft_basic_candidates.dart';

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
  LabTab tab = switch (Uri.base.queryParameters['lab']) {
    'shape' => LabTab.shape,
    'palette' => LabTab.palette,
    'effect' => LabTab.effect,
    'qa' => LabTab.qa,
    _ => LabTab.style,
  };
  bool dark = false;

  void _setTab(LabTab next) {
    setState(() => tab = next);
    final query = Map<String, String>.from(Uri.base.queryParameters)
      ..['lab'] = switch (next) {
        LabTab.shape => 'shape',
        LabTab.style => 'style',
        LabTab.palette => 'palette',
        LabTab.effect => 'effect',
        LabTab.qa => 'qa',
      };
    final nextUri = Uri.base.replace(queryParameters: query);
    SystemNavigator.routeInformationUpdated(uri: nextUri, replace: true);
  }

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
                                  'LAB 015 · Soft Basic Square R1',
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
                              onTap: () => _setTab(LabTab.shape),
                            ),
                            _TabChip(
                              label: 'Style Lab',
                              selected: tab == LabTab.style,
                              onTap: () => _setTab(LabTab.style),
                            ),
                            _TabChip(
                              label: 'Palette Lab',
                              selected: tab == LabTab.palette,
                              onTap: () => _setTab(LabTab.palette),
                            ),
                            _TabChip(
                              label: 'Effect Lab',
                              selected: tab == LabTab.effect,
                              onTap: () => _setTab(LabTab.effect),
                            ),
                            _TabChip(
                              label: 'Runtime QA',
                              selected: tab == LabTab.qa,
                              onTap: () => _setTab(LabTab.qa),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          color: card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'Shape Lab',
                subtitle: '기본 Shape Master와 Drop Shape를 한 화면에서 실제 렌더 기준으로 확인합니다.',
                fg: fg,
                muted: muted,
              ),
              const SizedBox(height: 16),
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
        ),
        const SizedBox(height: 14),
        _SeaTurtleShapePanel(card: card, fg: fg, muted: muted),
      ],
    );
  }
}

class _SeaTurtleShapePanel extends StatefulWidget {
  const _SeaTurtleShapePanel({
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<_SeaTurtleShapePanel> createState() => _SeaTurtleShapePanelState();
}

class _SeaTurtleShapePanelState extends State<_SeaTurtleShapePanel>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final FloatingEngine _engine = FloatingEngine(seed: 240925);

  Duration _previous = Duration.zero;
  Size _lastStageSize = Size.zero;
  int _objectCount = 9;
  MovementStyle _movement = MovementStyle.underwater;
  bool _darkBackground = false;

  @override
  void initState() {
    super.initState();
    _engine
      ..setSelection(
        const {ShapeKind.circle},
        const {ShapeTone.blue, ShapeTone.pink, ShapeTone.yellow},
      )
      ..setObjectCount(_objectCount)
      ..setMovementStyle(_movement)
      ..setMovementArea(MovementArea.full)
      ..setSpeed(FloatingSpeed.normal);

    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final delta = _previous == Duration.zero
        ? 0.0
        : (elapsed - _previous).inMicroseconds /
            Duration.microsecondsPerSecond;
    _previous = elapsed;

    if (delta > 0) {
      _engine.step(delta.clamp(0.0, 0.035).toDouble());
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: widget.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Drop 01 · Sea Turtle · Long Flipper',
            subtitle:
                'Static Runtime QA PASS · 투명 Runtime Asset 3색 · Shape 자체 애니메이션 없음 · 이동은 Motion Set이 담당',
            fg: widget.fg,
            muted: widget.muted,
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _SeaTurtlePreview(tone: ShapeTone.blue, label: 'Aqua Mint'),
              _SeaTurtlePreview(tone: ShapeTone.pink, label: 'Coral Pink'),
              _SeaTurtlePreview(tone: ShapeTone.yellow, label: 'Sand Beige'),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Runtime Motion Set QA',
            style: TextStyle(
              color: widget.fg,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '실제 FloatingEngine의 이동·충돌·크기 값을 사용합니다. Circle token은 이 Lab에서 물리 계산용으로만 사용됩니다.',
            style: TextStyle(color: widget.muted, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final value in const [6, 9, 12])
                ChoiceChip(
                  label: Text('$value개'),
                  selected: _objectCount == value,
                  onSelected: (_) {
                    setState(() {
                      _objectCount = value;
                      _engine.setObjectCount(value);
                    });
                  },
                ),
              _EnumDropdown<MovementStyle>(
                label: 'Motion',
                value: _movement,
                values: MovementStyle.values,
                text: (v) => v.label,
                onChanged: (value) {
                  setState(() {
                    _movement = value;
                    _engine.setMovementStyle(value);
                  });
                },
              ),
              FilterChip(
                label: const Text('Dark BG'),
                selected: _darkBackground,
                onSelected: (value) =>
                    setState(() => _darkBackground = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = min(520.0, max(400.0, width * 0.72));
              final stageSize = Size(width, height);

              if (stageSize != _lastStageSize &&
                  stageSize.width > 0 &&
                  stageSize.height > 0) {
                _lastStageSize = stageSize;
                _engine.resize(stageSize);
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: _darkBackground
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF071525),
                              Color(0xFF10345A),
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFEAF8FF),
                              Color(0xFFDFF3F8),
                            ],
                          ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final object in _engine.objects)
                        _SeaTurtleRuntimeObject(
                          key: ValueKey(object.id),
                          object: object,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SeaTurtlePreview extends StatelessWidget {
  const _SeaTurtlePreview({
    required this.tone,
    required this.label,
  });

  final ShapeTone tone;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: Column(
        children: [
          _SeaTurtleAsset(tone: tone, size: 104),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeaTurtleRuntimeObject extends StatelessWidget {
  const _SeaTurtleRuntimeObject({
    super.key,
    required this.object,
  });

  final FloatingObject object;

  @override
  Widget build(BuildContext context) {
    final side = object.radius * 2.34;
    return Positioned(
      left: object.position.dx - side / 2,
      top: object.position.dy - side / 2,
      width: side,
      height: side,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: object.rotation,
          child: _SeaTurtleAsset(
            tone: object.token.tone,
            size: side,
            compactError: true,
          ),
        ),
      ),
    );
  }
}

class _SeaTurtleAsset extends StatelessWidget {
  const _SeaTurtleAsset({
    required this.tone,
    required this.size,
    this.compactError = false,
  });

  final ShapeTone tone;
  final double size;
  final bool compactError;

  @override
  Widget build(BuildContext context) {
    final asset = switch (tone) {
      ShapeTone.blue =>
        'assets/sea_turtle_runtime_v2/sea_turtle_blue.png',
      ShapeTone.pink =>
        'assets/sea_turtle_runtime_v2/sea_turtle_pink.png',
      ShapeTone.yellow =>
        'assets/sea_turtle_runtime_v2/sea_turtle_yellow.png',
    };

    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        if (compactError) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 18,
              color: Color(0xFFB64242),
            ),
          );
        }
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFECEC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Asset error',
            style: TextStyle(color: Color(0xFF9F2F2F), fontSize: 10),
          ),
        );
      },
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
    id: 'C08-A',
    name: 'C08 Baseline',
    intent: '현재 C08 목표안. 다음 후보와 비교하기 위한 기준.',
    badge: 'BASE',
    config: CrayonTextureSpec(
      darkStrokeCount: 44,
      lightStrokeCount: 20,
      grainCount: 34,
      strokeWidth: 1.05,
      angleDeg: -24,
      jitter: 3.2,
      darkOpacity: 0.21,
      lightOpacity: 0.11,
      grainOpacity: 0.18,
      edgeOpacity: 0.13,
    ),
  ),
  _CrayonCandidate(
    id: 'C08-B',
    name: 'Open Fill',
    intent: 'C08 결은 유지하고 바탕 채움을 낮춰 종이색이 은근히 비치게.',
    config: CrayonTextureSpec(
      darkStrokeCount: 42,
      lightStrokeCount: 18,
      grainCount: 30,
      strokeWidth: 1.08,
      angleDeg: -24,
      jitter: 3.1,
      darkOpacity: 0.20,
      lightOpacity: 0.10,
      grainOpacity: 0.15,
      edgeOpacity: 0.12,
      baseStrokeCount: 58,
      underpaintOpacity: 0.62,
      baseStrokeOpacity: 0.48,
      strokeBreakChance: 0.05,
    ),
  ),
  _CrayonCandidate(
    id: 'C08-C',
    name: 'Spaced Fill',
    intent: '채움과 선 밀도를 더 낮춰 크레용 사이 빈틈이 읽히는 안.',
    badge: 'OPEN',
    config: CrayonTextureSpec(
      darkStrokeCount: 37,
      lightStrokeCount: 16,
      grainCount: 26,
      strokeWidth: 1.18,
      angleDeg: -24,
      jitter: 3.35,
      darkOpacity: 0.20,
      lightOpacity: 0.10,
      grainOpacity: 0.13,
      edgeOpacity: 0.11,
      baseStrokeCount: 46,
      underpaintOpacity: 0.50,
      baseStrokeOpacity: 0.52,
      strokeBreakChance: 0.10,
    ),
  ),
  _CrayonCandidate(
    id: 'C08-D',
    name: 'Childlike Gap',
    intent: '중간중간 끊긴 선과 덜 칠한 부분을 가장 적극적으로 남긴 안.',
    badge: 'GAP',
    config: CrayonTextureSpec(
      darkStrokeCount: 34,
      lightStrokeCount: 14,
      grainCount: 24,
      strokeWidth: 1.26,
      angleDeg: -24,
      jitter: 3.8,
      darkOpacity: 0.19,
      lightOpacity: 0.09,
      grainOpacity: 0.12,
      edgeOpacity: 0.10,
      baseStrokeCount: 50,
      underpaintOpacity: 0.40,
      baseStrokeOpacity: 0.55,
      strokeBreakChance: 0.18,
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
  ShapeStyle selectedStyle = Uri.base.queryParameters['style'] == 'soft-basic'
      ? ShapeStyle.softBasic
      : ShapeStyle.crayonSoft;

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
            onChanged: (value) {
              setState(() => selectedStyle = value);
              _syncStyleQuery(value);
            },
          ),
          const SizedBox(height: 12),
          _SoftBasicCandidateLab(
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
          title: 'Crayon Soft · Round 2 · C08 Coverage',
          subtitle: 'C08만 남기고 채움률·선 간격·끊김 정도를 좁혀 비교합니다. Basic은 읽기 전용으로 분리했습니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980 ? 4 : constraints.maxWidth >= 650 ? 2 : 1;
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


void _syncStyleQuery(ShapeStyle style) {
  final query = Map<String, String>.from(Uri.base.queryParameters)
    ..['lab'] = 'style'
    ..['style'] = style == ShapeStyle.softBasic ? 'soft-basic' : 'crayon-soft';
  final next = Uri.base.replace(queryParameters: query);
  // Web build uses browser history through route information updates.
  SystemNavigator.routeInformationUpdated(uri: next, replace: true);
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

class _SoftBasicCandidateLab extends StatefulWidget {
  const _SoftBasicCandidateLab({
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<_SoftBasicCandidateLab> createState() => _SoftBasicCandidateLabState();
}

class _SoftBasicCandidateLabState extends State<_SoftBasicCandidateLab> {
  int selectedIndex = 0;
  bool squareMode = true;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    if (squareMode) {
      return _SoftBasicSquareRound1(
        card: widget.card,
        fg: widget.fg,
        muted: widget.muted,
        onBackToCircle: () => setState(() => squareMode = false),
      );
    }
    final selected = softBasicCircleRound11Candidates[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Soft Basic · Circle · Round 11 · Ambient Bounce Refinement',
          subtitle: 'R10-06 Ambient Bounce를 기준으로 58px 실사용 체감을 강화합니다. 흰색 선은 추가하지 않고 강도·범위·색 대비·비대칭·음영 완화만 비교합니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980 ? 4 : 2;
            final gap = compact ? 8.0 : 12.0;
            final itemWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < softBasicCircleRound11Candidates.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: _SoftBasicCandidateCard(
                      candidate: softBasicCircleRound11Candidates[i],
                      selected: i == selectedIndex,
                      card: widget.card,
                      fg: widget.fg,
                      muted: widget.muted,
                      onTap: () => setState(() => selectedIndex = i),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _SoftBasicDetailPanel(
          candidate: selected,
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
        ),
      ],
    );
  }
}


class _SoftBasicSquareRound1 extends StatefulWidget {
  const _SoftBasicSquareRound1({
    required this.card,
    required this.fg,
    required this.muted,
    required this.onBackToCircle,
  });

  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onBackToCircle;

  @override
  State<_SoftBasicSquareRound1> createState() => _SoftBasicSquareRound1State();
}

class _SoftBasicSquareRound1State extends State<_SoftBasicSquareRound1> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final selected = softBasicSquareRound1Candidates[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Soft Basic · Square · Round 1',
          subtitle: 'Circle Master의 Color Shell · Edge Leaf · Ambient Bounce 디자인 언어를 Square에 맞게 이식합니다. 코너·하이라이트·하단 볼륨만 비교합니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.onBackToCircle,
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Circle Master R11-01 보기'),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980 ? 3 : 2;
            final gap = compact ? 8.0 : 12.0;
            final itemWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < softBasicSquareRound1Candidates.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: _SoftBasicSquareCandidateCard(
                      candidate: softBasicSquareRound1Candidates[i],
                      selected: i == selectedIndex,
                      card: widget.card,
                      fg: widget.fg,
                      muted: widget.muted,
                      onTap: () => setState(() => selectedIndex = i),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _Panel(
          color: widget.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selected.id + ' · ' + selected.name,
                style: TextStyle(
                  color: widget.fg,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                selected.intent,
                style: TextStyle(color: widget.muted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 18,
                runSpacing: 14,
                children: [
                  for (final tone in const [
                    ShapeTone.pink,
                    ShapeTone.blue,
                    ShapeTone.yellow,
                  ])
                    Column(
                      children: [
                        _SoftBasicSquareExactToken(
                          tone: tone,
                          candidate: selected,
                          size: 96,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          tone.label,
                          style: TextStyle(
                            color: widget.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '58px APP EXACT',
                style: TextStyle(
                  color: widget.fg,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  for (final tone in const [
                    ShapeTone.pink,
                    ShapeTone.blue,
                    ShapeTone.yellow,
                  ])
                    _SoftBasicSquareExactToken(
                      tone: tone,
                      candidate: selected,
                      size: 58,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SoftBasicSquareCandidateCard extends StatelessWidget {
  const _SoftBasicSquareCandidateCard({
    required this.candidate,
    required this.selected,
    required this.card,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  final SoftBasicSquareCandidate candidate;
  final bool selected;
  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 176,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7257F5)
                  : const Color(0xFFE6E3EE),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      candidate.id,
                      style: TextStyle(
                        color: fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (candidate.badge != null)
                    Text(
                      candidate.badge!,
                      style: const TextStyle(
                        color: Color(0xFF7257F5),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
              Text(
                candidate.name,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final tone in const [
                    ShapeTone.pink,
                    ShapeTone.blue,
                    ShapeTone.yellow,
                  ])
                    _SoftBasicSquareExactToken(
                      tone: tone,
                      candidate: candidate,
                      size: 58,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                candidate.intent,
                style: TextStyle(
                  color: muted,
                  fontSize: 9.5,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftBasicSquareExactToken extends StatelessWidget {
  const _SoftBasicSquareExactToken({
    required this.tone,
    required this.candidate,
    required this.size,
  });

  final ShapeTone tone;
  final SoftBasicSquareCandidate candidate;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _SoftBasicSquareCandidatePainter(
          tone: tone,
          candidate: candidate,
        ),
      ),
    );
  }
}

class _SoftBasicSquareCandidatePainter extends CustomPainter {
  const _SoftBasicSquareCandidatePainter({
    required this.tone,
    required this.candidate,
  });

  final ShapeTone tone;
  final SoftBasicSquareCandidate candidate;

  @override
  void paint(Canvas canvas, Size size) {
    final base = baseColorForTone(tone);
    final light = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.10 : 0.16,
      saturationDelta: -0.04,
    );
    final deep = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? -0.10 : -0.13,
      saturationDelta: 0.02,
    );
    final bounce = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.075 : 0.11,
      saturationDelta: -0.025,
    );

    final inset = size.shortestSide * 0.07;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    final radiusFactor = switch (candidate.technique) {
      SoftBasicSquareTechnique.softerCorner => 0.31,
      SoftBasicSquareTechnique.tighterCorner => 0.20,
      _ => 0.26,
    };
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * radiusFactor),
    );
    final bodyPath = Path()..addRRect(rrect);

    canvas.drawShadow(
      bodyPath,
      Colors.black.withValues(alpha: 0.035),
      size.shortestSide * 0.035,
      true,
    );

    canvas.drawRRect(
      rrect,
      Paint()..color = deep.withValues(alpha: 0.28),
    );
    final inner = RRect.fromRectAndRadius(
      rect.deflate(rect.width * 0.015),
      Radius.circular(rect.width * radiusFactor * 0.97),
    );
    canvas.drawRRect(inner, Paint()..color = base);

    canvas.save();
    canvas.clipRRect(inner);

    canvas.drawCircle(
      Offset(
        rect.left + rect.width * 0.28,
        rect.top + rect.height * 0.27,
      ),
      rect.width * 0.40,
      Paint()
        ..color = light.withValues(alpha: 0.46)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.18,
        ),
    );

    canvas.drawCircle(
      Offset(
        rect.right - rect.width * 0.17,
        rect.bottom - rect.height * 0.15,
      ),
      rect.width * 0.42,
      Paint()
        ..color = deep.withValues(alpha: 0.34)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.22,
        ),
    );

    final bounceAlpha =
        candidate.technique == SoftBasicSquareTechnique.strongerBounce
            ? 0.22
            : 0.16;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          rect.left + rect.width * 0.56,
          rect.top + rect.height * 0.79,
        ),
        width: rect.width * 0.76,
        height: rect.height * 0.30,
      ),
      Paint()
        ..color = bounce.withValues(alpha: bounceAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.10,
        ),
    );

    canvas.restore();

    final wide =
        candidate.technique == SoftBasicSquareTechnique.wideHighlight;
    final compact =
        candidate.technique == SoftBasicSquareTechnique.compactHighlight;

    final highlight = Path()
      ..moveTo(
        rect.left + rect.width * 0.12,
        rect.top + rect.height * (wide ? 0.39 : 0.36),
      )
      ..cubicTo(
        rect.left + rect.width * 0.12,
        rect.top + rect.height * 0.23,
        rect.left + rect.width * (compact ? 0.20 : 0.18),
        rect.top + rect.height * 0.13,
        rect.left + rect.width * (compact ? 0.27 : 0.30),
        rect.top + rect.height * 0.11,
      )
      ..cubicTo(
        rect.left + rect.width * (compact ? 0.32 : 0.39),
        rect.top + rect.height * 0.10,
        rect.left + rect.width * (compact ? 0.34 : 0.42),
        rect.top + rect.height * 0.16,
        rect.left + rect.width * (compact ? 0.31 : 0.39),
        rect.top + rect.height * 0.22,
      )
      ..cubicTo(
        rect.left + rect.width * (compact ? 0.27 : 0.34),
        rect.top + rect.height * 0.29,
        rect.left + rect.width * 0.18,
        rect.top + rect.height * (wide ? 0.43 : 0.40),
        rect.left + rect.width * 0.12,
        rect.top + rect.height * (wide ? 0.39 : 0.36),
      )
      ..close();

    canvas.drawPath(
      highlight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.08,
        ),
    );
    canvas.drawPath(
      highlight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.74)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.026,
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _SoftBasicSquareCandidatePainter oldDelegate) {
    return oldDelegate.tone != tone ||
        oldDelegate.candidate.id != candidate.id;
  }
}

class _SoftBasicCandidateCard extends StatelessWidget {
  const _SoftBasicCandidateCard({
    required this.candidate,
    required this.selected,
    required this.card,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  final SoftBasicCandidate candidate;
  final bool selected;
  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 166,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7257F5)
                  : const Color(0xFFE6E3EE),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      candidate.id,
                      style: TextStyle(
                        color: fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (candidate.badge != null)
                    Text(
                      candidate.badge!,
                      style: const TextStyle(
                        color: Color(0xFF7257F5),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
              Text(
                candidate.name,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final tone in tones)
                    _SoftBasicExactToken(
                      shape: ShapeKind.circle,
                      tone: tone,
                      candidate: candidate,
                      size: 58,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                candidate.intent,
                style: TextStyle(color: muted, fontSize: 9.5, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftBasicDetailPanel extends StatelessWidget {
  const _SoftBasicDetailPanel({
    required this.candidate,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final SoftBasicCandidate candidate;
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
          Text(
            candidate.id + ' · ' + candidate.name,
            style: TextStyle(
              color: fg,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(candidate.intent, style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 14),
          Text(
            'Circle · Pink / Blue / Yellow · 58px APP EXACT',
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 150,
                child: Column(
                  children: [
                    _SoftBasicExactToken(
                      shape: ShapeKind.circle,
                      tone: ShapeTone.pink,
                      candidate: candidate,
                      size: 132,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pink · enlarged',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final tone in tones)
                      SizedBox(
                        width: 76,
                        child: Column(
                          children: [
                            _SoftBasicExactToken(
                              shape: ShapeKind.circle,
                              tone: tone,
                              candidate: candidate,
                              size: 58,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tone.label,
                              style: TextStyle(color: muted, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftBasicExactToken extends StatelessWidget {
  const _SoftBasicExactToken({
    required this.shape,
    required this.tone,
    required this.candidate,
    required this.size,
  });

  final ShapeKind shape;
  final ShapeTone tone;
  final SoftBasicCandidate candidate;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _SoftBasicCandidatePainter(
          shape: shape,
          tone: tone,
          candidate: candidate,
        ),
      ),
    );
  }
}

class _SoftBasicCandidatePainter extends CustomPainter {
  const _SoftBasicCandidatePainter({
    required this.shape,
    required this.tone,
    required this.candidate,
  });

  final ShapeKind shape;
  final ShapeTone tone;
  final SoftBasicCandidate candidate;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.44;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = baseColorForTone(tone);
    final light = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.10 : 0.16,
      saturationDelta: -0.04,
    );
    final deep = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? -0.13 : -0.16,
      saturationDelta: 0.03,
    );
    final rimLight = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.10 : 0.14,
      saturationDelta: -0.03,
    );
    final rimDeep = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? -0.08 : -0.10,
      saturationDelta: 0.02,
    );

    _paintAirbrushBody(canvas, rect, base, light, deep);

    switch (candidate.finishTechnique) {
      case SoftBasicCircleFinishTechnique.outlineBase:
        break;
      case SoftBasicCircleFinishTechnique.softInnerRim:
        _paintSoftInnerRim(canvas, rect, rimLight, alpha: 0.34, width: 0.040);
      case SoftBasicCircleFinishTechnique.colorShell:
        _paintColorShell(canvas, rect, rimDeep, alpha: 0.28, width: 0.028);
      case SoftBasicCircleFinishTechnique.lowerRim:
        _paintLowerRim(canvas, rect, rimLight, alpha: 0.42, width: 0.050);
      case SoftBasicCircleFinishTechnique.cleanOutline:
        _paintCleanOutline(canvas, rect, rimDeep, alpha: 0.22, width: 0.020);
      case SoftBasicCircleFinishTechnique.premiumRim:
        _paintColorShell(canvas, rect, rimDeep, alpha: 0.20, width: 0.024);
        _paintSoftInnerRim(canvas, rect, rimLight, alpha: 0.36, width: 0.042);
        _paintLowerRim(canvas, rect, rimLight, alpha: 0.24, width: 0.048);
    }

    _paintBottomHighlight(
      canvas,
      rect,
      rimLight,
      candidate.bottomHighlightTechnique,
    );
    _paintLowerVolume(
      canvas,
      rect,
      base,
      light,
      deep,
      candidate.lowerVolumeTechnique,
    );
    _paintEdgeLeafBase(canvas, rect);
  }

  void _paintAirbrushBody(
    Canvas canvas,
    Rect rect,
    Color base,
    Color light,
    Color deep,
  ) {
    _drawSoftShadow(canvas, rect, deep, 0.18, 5.5);
    canvas.drawOval(rect, Paint()..color = base);

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    final r = rect.width;

    canvas.drawCircle(
      Offset(rect.left + r * 0.29, rect.top + r * 0.28),
      r * 0.42,
      Paint()
        ..color = light.withValues(alpha: 0.48)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13),
    );

    canvas.drawCircle(
      Offset(rect.right - r * 0.18, rect.bottom - r * 0.14),
      r * 0.43,
      Paint()
        ..color = deep.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    canvas.restore();
  }

  void _paintEdgeLeafBase(Canvas canvas, Rect rect) {
    final path = _baseEdgeLeafPath(rect);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.76 * 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.9),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.76)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
    );
  }

  void _paintLowerVolume(
    Canvas canvas,
    Rect rect,
    Color base,
    Color light,
    Color deep,
    SoftBasicLowerVolumeTechnique technique,
  ) {
    if (technique == SoftBasicLowerVolumeTechnique.none) return;

    final tintedLight = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.075 : 0.11,
      saturationDelta: -0.025,
    );
    final softBase = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.035 : 0.055,
      saturationDelta: -0.015,
    );
    final strongerTintedLight = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.11 : 0.17,
      saturationDelta: -0.035,
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    switch (technique) {
      case SoftBasicLowerVolumeTechnique.none:
        break;

      case SoftBasicLowerVolumeTechnique.tintedBloom:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.center.dx,
              rect.top + rect.height * 0.77,
            ),
            width: rect.width * 0.68,
            height: rect.height * 0.29,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.center.dx,
              rect.top + rect.height * 0.80,
            ),
            width: rect.width * 0.46,
            height: rect.height * 0.15,
          ),
          Paint()
            ..color = softBase.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.6),
        );

      case SoftBasicLowerVolumeTechnique.embeddedLight:
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.58,
            rect.top + rect.height * 0.72,
          ),
          rect.width * 0.24,
          Paint()
            ..color = tintedLight.withValues(alpha: 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.5),
        );
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.60,
            rect.top + rect.height * 0.73,
          ),
          rect.width * 0.11,
          Paint()
            ..color = light.withValues(alpha: 0.10)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
        );

      case SoftBasicLowerVolumeTechnique.liftGradient:
        final shaderRect = Rect.fromLTWH(
          rect.left,
          rect.top + rect.height * 0.42,
          rect.width,
          rect.height * 0.58,
        );
        canvas.drawRect(
          shaderRect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                base.withValues(alpha: 0.00),
                softBase.withValues(alpha: 0.06),
                tintedLight.withValues(alpha: 0.18),
              ],
              stops: const [0.0, 0.50, 1.0],
            ).createShader(shaderRect),
        );

      case SoftBasicLowerVolumeTechnique.shadowCarve:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.68,
              rect.top + rect.height * 0.72,
            ),
            width: rect.width * 0.54,
            height: rect.height * 0.46,
          ),
          Paint()
            ..color = base.withValues(alpha: 0.17)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.63,
              rect.top + rect.height * 0.76,
            ),
            width: rect.width * 0.34,
            height: rect.height * 0.20,
          ),
          Paint()
            ..color = softBase.withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounce:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.57,
              rect.top + rect.height * 0.79,
            ),
            width: rect.width * 0.78,
            height: rect.height * 0.34,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0),
        );
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.63,
            rect.top + rect.height * 0.72,
          ),
          rect.width * 0.13,
          Paint()
            ..color = light.withValues(alpha: 0.09)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.center.dx,
              rect.top + rect.height * 0.91,
            ),
            width: rect.width * 0.56,
            height: rect.height * 0.12,
          ),
          Paint()
            ..color = deep.withValues(alpha: 0.045)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounceStrong:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.57,
              rect.top + rect.height * 0.79,
            ),
            width: rect.width * 0.78,
            height: rect.height * 0.34,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.21)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9.0),
        );
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.63,
            rect.top + rect.height * 0.72,
          ),
          rect.width * 0.14,
          Paint()
            ..color = light.withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounceWide:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.55,
              rect.top + rect.height * 0.76,
            ),
            width: rect.width * 0.94,
            height: rect.height * 0.47,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.19)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9.5),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.60,
              rect.top + rect.height * 0.73,
            ),
            width: rect.width * 0.48,
            height: rect.height * 0.24,
          ),
          Paint()
            ..color = softBase.withValues(alpha: 0.13)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.5),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounceContrast:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.57,
              rect.top + rect.height * 0.78,
            ),
            width: rect.width * 0.80,
            height: rect.height * 0.36,
          ),
          Paint()
            ..color = strongerTintedLight.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0),
        );
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.62,
            rect.top + rect.height * 0.72,
          ),
          rect.width * 0.15,
          Paint()
            ..color = strongerTintedLight.withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounceAsymmetric:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.45,
              rect.top + rect.height * 0.80,
            ),
            width: rect.width * 0.80,
            height: rect.height * 0.37,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.5),
        );
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.34,
            rect.top + rect.height * 0.73,
          ),
          rect.width * 0.15,
          Paint()
            ..color = light.withValues(alpha: 0.10)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.70,
              rect.top + rect.height * 0.84,
            ),
            width: rect.width * 0.38,
            height: rect.height * 0.20,
          ),
          Paint()
            ..color = base.withValues(alpha: 0.07)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.5),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounceCarved:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.54,
              rect.top + rect.height * 0.77,
            ),
            width: rect.width * 0.90,
            height: rect.height * 0.43,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.21)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.5),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.72,
              rect.top + rect.height * 0.70,
            ),
            width: rect.width * 0.48,
            height: rect.height * 0.43,
          ),
          Paint()
            ..color = base.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.58,
              rect.top + rect.height * 0.76,
            ),
            width: rect.width * 0.46,
            height: rect.height * 0.20,
          ),
          Paint()
            ..color = strongerTintedLight.withValues(alpha: 0.11)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
        );
    }

    canvas.restore();
  }

  void _paintBottomHighlight(
    Canvas canvas,
    Rect rect,
    Color rimLight,
    SoftBasicBottomHighlightTechnique technique,
  ) {
    if (technique == SoftBasicBottomHighlightTechnique.none) return;

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    switch (technique) {
      case SoftBasicBottomHighlightTechnique.none:
        break;
      case SoftBasicBottomHighlightTechnique.softBloom:
        canvas.drawArc(
          rect.deflate(rect.width * 0.085),
          0.47,
          2.20,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.105
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.2),
        );
        canvas.drawArc(
          rect.deflate(rect.width * 0.070),
          0.58,
          1.98,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.050
            ..strokeCap = StrokeCap.round
            ..color = rimLight.withValues(alpha: 0.24)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.1),
        );
      case SoftBasicBottomHighlightTechnique.narrowBloom:
        canvas.drawArc(
          rect.deflate(rect.width * 0.060),
          0.70,
          1.70,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.035
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.52)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.35),
        );
      case SoftBasicBottomHighlightTechnique.crescent:
        final crescent = Path()
          ..moveTo(
            rect.left + rect.width * 0.22,
            rect.top + rect.height * 0.73,
          )
          ..cubicTo(
            rect.left + rect.width * 0.37,
            rect.top + rect.height * 0.88,
            rect.left + rect.width * 0.63,
            rect.top + rect.height * 0.88,
            rect.left + rect.width * 0.79,
            rect.top + rect.height * 0.70,
          );
        canvas.drawPath(
          crescent,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.050
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.42)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.25),
        );
      case SoftBasicBottomHighlightTechnique.liftedGlow:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.center.dx,
              rect.top + rect.height * 0.70,
            ),
            width: rect.width * 0.54,
            height: rect.height * 0.20,
          ),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.24)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.5),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.center.dx,
              rect.top + rect.height * 0.73,
            ),
            width: rect.width * 0.36,
            height: rect.height * 0.085,
          ),
          Paint()
            ..color = rimLight.withValues(alpha: 0.28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.3),
        );
      case SoftBasicBottomHighlightTechnique.premiumBottom:
        canvas.drawArc(
          rect.deflate(rect.width * 0.078),
          0.50,
          2.10,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.090
            ..strokeCap = StrokeCap.round
            ..color = rimLight.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.8),
        );
        canvas.drawArc(
          rect.deflate(rect.width * 0.058),
          0.69,
          1.72,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.025
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.58)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.05),
        );
    }

    canvas.restore();
  }

  void _paintSoftInnerRim(
    Canvas canvas,
    Rect rect,
    Color color, {
    required double alpha,
    required double width,
  }) {
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    canvas.drawOval(
      rect.deflate(rect.width * 0.026),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * width
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
    );
    canvas.restore();
  }

  void _paintColorShell(
    Canvas canvas,
    Rect rect,
    Color color, {
    required double alpha,
    required double width,
  }) {
    canvas.drawOval(
      rect.deflate(rect.width * 0.008),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * width
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
    );
  }

  void _paintLowerRim(
    Canvas canvas,
    Rect rect,
    Color color, {
    required double alpha,
    required double width,
  }) {
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    canvas.drawArc(
      rect.deflate(rect.width * 0.026),
      0.40,
      1.95,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * width
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.restore();
  }

  void _paintCleanOutline(
    Canvas canvas,
    Rect rect,
    Color color, {
    required double alpha,
    required double width,
  }) {
    canvas.drawOval(
      rect.deflate(rect.width * 0.006),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * width
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
    );
  }

  Path _baseEdgeLeafPath(Rect rect) => Path()
    ..moveTo(rect.left + rect.width * 0.13, rect.top + rect.height * 0.40)
    ..cubicTo(
      rect.left + rect.width * 0.13,
      rect.top + rect.height * 0.28,
      rect.left + rect.width * 0.18,
      rect.top + rect.height * 0.17,
      rect.left + rect.width * 0.27,
      rect.top + rect.height * 0.12,
    )
    ..cubicTo(
      rect.left + rect.width * 0.33,
      rect.top + rect.height * 0.09,
      rect.left + rect.width * 0.39,
      rect.top + rect.height * 0.10,
      rect.left + rect.width * 0.40,
      rect.top + rect.height * 0.15,
    )
    ..cubicTo(
      rect.left + rect.width * 0.41,
      rect.top + rect.height * 0.21,
      rect.left + rect.width * 0.35,
      rect.top + rect.height * 0.27,
      rect.left + rect.width * 0.29,
      rect.top + rect.height * 0.33,
    )
    ..cubicTo(
      rect.left + rect.width * 0.23,
      rect.top + rect.height * 0.39,
      rect.left + rect.width * 0.17,
      rect.top + rect.height * 0.45,
      rect.left + rect.width * 0.13,
      rect.top + rect.height * 0.40,
    )
    ..close();

  void _drawSoftShadow(
    Canvas canvas,
    Rect rect,
    Color color,
    double alpha,
    double sigma,
  ) {
    canvas.drawOval(
      rect.shift(Offset(0, rect.height * 0.065)).inflate(rect.width * 0.015),
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
    );
  }

  @override
  bool shouldRepaint(covariant _SoftBasicCandidatePainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.tone != tone ||
        oldDelegate.candidate.id != candidate.id;
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
    final heroScale = compact ? 1.62 : 1.92;

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
                    child: Transform.scale(
                      scale: heroScale,
                      child: _ExactToken(
                        token: const LockToken(
                          shape: ShapeKind.circle,
                          tone: ShapeTone.pink,
                        ),
                        config: candidate.config,
                        size: 58,
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
  return 'W ' +
      config.strokeWidth.toStringAsFixed(2) +
      ' · Fill ' +
      config.underpaintOpacity.toStringAsFixed(2) +
      ' · Base ' +
      config.baseStrokeCount.toString() +
      ' · Break ' +
      config.strokeBreakChance.toStringAsFixed(2);
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
              _ValueChip(label: 'Dark', value: '${candidate.config.darkStrokeCount}'),
              _ValueChip(label: 'Light', value: '${candidate.config.lightStrokeCount}'),
              _ValueChip(label: 'Grain', value: '${candidate.config.grainCount}'),
              _ValueChip(label: 'Width', value: candidate.config.strokeWidth.toStringAsFixed(2)),
              _ValueChip(label: 'Angle', value: '${candidate.config.angleDeg.toStringAsFixed(0)}°'),
              _ValueChip(label: 'Jitter', value: candidate.config.jitter.toStringAsFixed(1)),
              _ValueChip(label: 'Edge', value: candidate.config.edgeOpacity.toStringAsFixed(2)),
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
        initialValue: value,
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
