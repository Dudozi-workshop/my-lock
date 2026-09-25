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
  LabTab tab = LabTab.style;
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
                                  'LAB 020 · R03 Stroke + Edge',
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
    id: 'R03',
    name: 'True Paper Gap · Baseline',
    intent: '선호 기준형. 공백 구조와 종이 비침은 그대로 두고 이후 안의 기준점으로 사용.',
    badge: 'BASE',
    config: CrayonTextureSpec(
      darkStrokeCount: 31,
      lightStrokeCount: 5,
      grainCount: 10,
      strokeWidth: 2.30,
      angleDeg: -20,
      jitter: 2.4,
      darkOpacity: 0.34,
      lightOpacity: 0.04,
      grainOpacity: 0.05,
      edgeOpacity: 0.31,
      edgeWidth: 3.45,
      edgeMode: CrayonEdgeMode.hybrid,
      edgeSegmentLength: 11.2,
      edgeSegmentGap: 5.8,
      edgeOffsetJitter: 0.82,
      edgeWidthJitter: 0.25,
      edgeOpacityJitter: 0.22,
      edgeBandWidth: 2.8,
      overflowAmount: 1.8,
      underpaintOpacity: 0.82,
      strokeBreakChance: 0.07,
      strokeBuiltSurface: true,
      broadStrokeCount: 13,
      broadStrokeWidth: 4.1,
      broadStrokeOpacity: 0.20,
      angleJitterDeg: 5.0,
      strokeWidthJitter: 0.20,
      strokeLengthMin: 0.74,
      strokeLengthMax: 0.98,
      gapChance: 0.045,
      toneVariation: 0.11,
      negativeGapCount: 9,
      negativeGapWidth: 0.72,
    ),
  ),
  _CrayonCandidate(
    id: 'W01',
    name: 'Stroke +15%',
    intent: 'R03의 공백은 그대로 유지하고 주 획과 broad pass만 한 단계 굵게.',
    badge: 'STROKE',
    config: CrayonTextureSpec(
      darkStrokeCount: 31,
      lightStrokeCount: 5,
      grainCount: 10,
      strokeWidth: 2.65,
      angleDeg: -20,
      jitter: 2.4,
      darkOpacity: 0.34,
      lightOpacity: 0.04,
      grainOpacity: 0.05,
      edgeOpacity: 0.31,
      edgeWidth: 3.45,
      edgeMode: CrayonEdgeMode.hybrid,
      edgeSegmentLength: 11.2,
      edgeSegmentGap: 5.8,
      edgeOffsetJitter: 0.82,
      edgeWidthJitter: 0.25,
      edgeOpacityJitter: 0.22,
      edgeBandWidth: 2.8,
      overflowAmount: 1.8,
      underpaintOpacity: 0.82,
      strokeBreakChance: 0.07,
      strokeBuiltSurface: true,
      broadStrokeCount: 13,
      broadStrokeWidth: 4.45,
      broadStrokeOpacity: 0.21,
      angleJitterDeg: 5.0,
      strokeWidthJitter: 0.20,
      strokeLengthMin: 0.74,
      strokeLengthMax: 0.98,
      gapChance: 0.045,
      toneVariation: 0.11,
      negativeGapCount: 9,
      negativeGapWidth: 0.72,
    ),
  ),
  _CrayonCandidate(
    id: 'W02',
    name: 'Stroke +30%',
    intent: '58px에서도 내부 획이 확실히 읽히도록 굵기와 pressure pass를 중간 강도로 강화.',
    badge: 'STROKE',
    config: CrayonTextureSpec(
      darkStrokeCount: 30,
      lightStrokeCount: 5,
      grainCount: 10,
      strokeWidth: 2.95,
      angleDeg: -20,
      jitter: 2.4,
      darkOpacity: 0.35,
      lightOpacity: 0.04,
      grainOpacity: 0.05,
      edgeOpacity: 0.31,
      edgeWidth: 3.45,
      edgeMode: CrayonEdgeMode.hybrid,
      edgeSegmentLength: 11.2,
      edgeSegmentGap: 5.8,
      edgeOffsetJitter: 0.82,
      edgeWidthJitter: 0.25,
      edgeOpacityJitter: 0.22,
      edgeBandWidth: 2.8,
      overflowAmount: 1.8,
      underpaintOpacity: 0.82,
      strokeBreakChance: 0.07,
      strokeBuiltSurface: true,
      broadStrokeCount: 13,
      broadStrokeWidth: 4.75,
      broadStrokeOpacity: 0.22,
      angleJitterDeg: 5.0,
      strokeWidthJitter: 0.24,
      strokeLengthMin: 0.74,
      strokeLengthMax: 0.98,
      gapChance: 0.045,
      toneVariation: 0.11,
      negativeGapCount: 9,
      negativeGapWidth: 0.72,
    ),
  ),
  _CrayonCandidate(
    id: 'W03',
    name: 'Pressure Mix',
    intent: '선 수를 늘리지 않고 더 굵은 압력차와 폭 편차로 크레용 획의 존재감을 가장 강하게.',
    badge: 'STROKE',
    config: CrayonTextureSpec(
      darkStrokeCount: 29,
      lightStrokeCount: 5,
      grainCount: 10,
      strokeWidth: 3.15,
      angleDeg: -20,
      jitter: 2.55,
      darkOpacity: 0.36,
      lightOpacity: 0.04,
      grainOpacity: 0.05,
      edgeOpacity: 0.31,
      edgeWidth: 3.45,
      edgeMode: CrayonEdgeMode.hybrid,
      edgeSegmentLength: 11.2,
      edgeSegmentGap: 5.8,
      edgeOffsetJitter: 0.82,
      edgeWidthJitter: 0.25,
      edgeOpacityJitter: 0.22,
      edgeBandWidth: 2.8,
      overflowAmount: 1.8,
      underpaintOpacity: 0.80,
      strokeBreakChance: 0.07,
      strokeBuiltSurface: true,
      broadStrokeCount: 12,
      broadStrokeWidth: 5.05,
      broadStrokeOpacity: 0.24,
      angleJitterDeg: 5.4,
      strokeWidthJitter: 0.32,
      strokeLengthMin: 0.72,
      strokeLengthMax: 0.98,
      gapChance: 0.045,
      toneVariation: 0.12,
      negativeGapCount: 9,
      negativeGapWidth: 0.72,
    ),
  ),
  _CrayonCandidate(
    id: 'E01',
    name: 'Clean Contour',
    intent: 'W02 내부 획 고정. 테두리만 매끈한 단일 contour로 두어 실루엣 가독성을 기준 비교.',
    badge: 'EDGE',
    config: CrayonTextureSpec(
      darkStrokeCount: 30,
      lightStrokeCount: 5,
      grainCount: 10,
      strokeWidth: 2.95,
      angleDeg: -20,
      jitter: 2.4,
      darkOpacity: 0.35,
      lightOpacity: 0.04,
      grainOpacity: 0.05,
      edgeOpacity: 0.26,
      edgeWidth: 1.65,
      edgeMode: CrayonEdgeMode.vector,
      edgeSegmentLength: 11.2,
      edgeSegmentGap: 5.8,
      edgeOffsetJitter: 0.82,
      edgeWidthJitter: 0.10,
      edgeOpacityJitter: 0.08,
      edgeBandWidth: 2.2,
      overflowAmount: 1.2,
      underpaintOpacity: 0.82,
      strokeBreakChance: 0.07,
      strokeBuiltSurface: true,
      broadStrokeCount: 13,
      broadStrokeWidth: 4.75,
      broadStrokeOpacity: 0.22,
      angleJitterDeg: 5.0,
      strokeWidthJitter: 0.24,
      strokeLengthMin: 0.74,
      strokeLengthMax: 0.98,
      gapChance: 0.045,
      toneVariation: 0.11,
      negativeGapCount: 9,
      negativeGapWidth: 0.72,
    ),
  ),
  _CrayonCandidate(
    id: 'E02',
    name: 'Hybrid Wax Edge',
    intent: 'W02 내부 획 고정. 끊긴 외곽 + 약한 overfill을 얹어 실루엣을 유지하면서 크레용 감성을 추가.',
    badge: 'EDGE',
    config: CrayonTextureSpec(
      darkStrokeCount: 30,
      lightStrokeCount: 5,
      grainCount: 10,
      strokeWidth: 2.95,
      angleDeg: -20,
      jitter: 2.4,
      darkOpacity: 0.35,
      lightOpacity: 0.04,
      grainOpacity: 0.05,
      edgeOpacity: 0.27,
      edgeWidth: 2.65,
      edgeMode: CrayonEdgeMode.hybrid,
      edgeSegmentLength: 12.8,
      edgeSegmentGap: 6.3,
      edgeOffsetJitter: 0.75,
      edgeWidthJitter: 0.20,
      edgeOpacityJitter: 0.18,
      edgeBandWidth: 2.4,
      overflowAmount: 1.6,
      underpaintOpacity: 0.82,
      strokeBreakChance: 0.07,
      strokeBuiltSurface: true,
      broadStrokeCount: 13,
      broadStrokeWidth: 4.75,
      broadStrokeOpacity: 0.22,
      angleJitterDeg: 5.0,
      strokeWidthJitter: 0.24,
      strokeLengthMin: 0.74,
      strokeLengthMax: 0.98,
      gapChance: 0.045,
      toneVariation: 0.11,
      negativeGapCount: 9,
      negativeGapWidth: 0.72,
    ),
  ),
  _CrayonCandidate(
    id: 'E03',
    name: 'Strong Wax Edge',
    intent: 'W02 내부 획 고정. 외곽의 끊김·번짐·폭 편차를 더 키워 손으로 그린 윤곽의 상한을 확인.',
    badge: 'EDGE',
    config: CrayonTextureSpec(
      darkStrokeCount: 30,
      lightStrokeCount: 5,
      grainCount: 10,
      strokeWidth: 2.95,
      angleDeg: -20,
      jitter: 2.4,
      darkOpacity: 0.35,
      lightOpacity: 0.04,
      grainOpacity: 0.05,
      edgeOpacity: 0.33,
      edgeWidth: 3.50,
      edgeMode: CrayonEdgeMode.hybrid,
      edgeSegmentLength: 9.6,
      edgeSegmentGap: 4.4,
      edgeOffsetJitter: 1.15,
      edgeWidthJitter: 0.35,
      edgeOpacityJitter: 0.30,
      edgeBandWidth: 3.4,
      overflowAmount: 2.4,
      underpaintOpacity: 0.82,
      strokeBreakChance: 0.07,
      strokeBuiltSurface: true,
      broadStrokeCount: 13,
      broadStrokeWidth: 4.75,
      broadStrokeOpacity: 0.22,
      angleJitterDeg: 5.0,
      strokeWidthJitter: 0.24,
      strokeLengthMin: 0.74,
      strokeLengthMax: 0.98,
      gapChance: 0.045,
      toneVariation: 0.11,
      negativeGapCount: 9,
      negativeGapWidth: 0.72,
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
          title: 'Crayon Soft · Round 15 · Stroke Weight + Edge',
          subtitle: 'R03의 true paper gap은 유지합니다. W01~W03은 내부 획의 체감 두께만 올리고, E01~E03은 W02 내부 획을 고정한 채 외곽선 방식만 비교합니다.',
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
                    child: Transform.scale(
                      scale: compact ? 0.92 : 1.02,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ExactToken(
                            token: const LockToken(
                              shape: ShapeKind.circle,
                              tone: ShapeTone.pink,
                            ),
                            config: candidate.config,
                            size: 58,
                          ),
                          SizedBox(width: compact ? 2 : 5),
                          _ExactToken(
                            token: const LockToken(
                              shape: ShapeKind.triangle,
                              tone: ShapeTone.blue,
                            ),
                            config: candidate.config,
                            size: 58,
                          ),
                          SizedBox(width: compact ? 2 : 5),
                          _ExactToken(
                            token: const LockToken(
                              shape: ShapeKind.square,
                              tone: ShapeTone.yellow,
                            ),
                            config: candidate.config,
                            size: 58,
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
  return config.strokePattern.name.toUpperCase() +
      ' · Broad ' +
      config.broadStrokeCount.toString() +
      ' · Main ' +
      config.darkStrokeCount.toString() +
      ' · Cut ' +
      config.negativeGapCount.toString() +
      ' · Lightα ' +
      config.lightOpacity.toStringAsFixed(2);
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
              _ValueChip(label: 'Broad', value: '${candidate.config.broadStrokeCount}'),
              _ValueChip(label: 'Main', value: '${candidate.config.darkStrokeCount}'),
              _ValueChip(label: 'Broad W', value: candidate.config.broadStrokeWidth.toStringAsFixed(1)),
              _ValueChip(label: 'Main W', value: candidate.config.strokeWidth.toStringAsFixed(2)),
              _ValueChip(label: 'Gap', value: candidate.config.gapChance.toStringAsFixed(2)),
              _ValueChip(label: 'Break', value: candidate.config.strokeBreakChance.toStringAsFixed(2)),
              _ValueChip(label: 'Angle±', value: '${candidate.config.angleJitterDeg.toStringAsFixed(0)}°'),
              _ValueChip(label: 'Tone', value: candidate.config.toneVariation.toStringAsFixed(2)),
              _ValueChip(label: 'Edge W', value: candidate.config.edgeWidth.toStringAsFixed(2)),
              _ValueChip(label: 'Edge Tex', value: candidate.config.edgeTexture.toStringAsFixed(2)),
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
