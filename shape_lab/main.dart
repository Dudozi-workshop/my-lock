import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:my_lock/lock_engine/effects.dart';
import 'package:my_lock/lock_engine/floating_preview.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_render_overrides.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_renderer.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';

import 'soft_basic_candidates.dart';
import 'background_asset_registry.dart';
import 'water_refraction_field.dart';
import 'surface_refraction_field.dart';
import 'background_easy_effects.dart';
import 'candy_soft_review.dart';
import 'package:my_lock/lock_engine/shape_spec/candy_soft_runtime.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShapeSpecRegistry.instance.load();
  await CandySoftRuntime.instance.load();
  await BackgroundAssetRegistry.load();
  runApp(const MyLockLabsApp());
}

enum LabTab { background, shape, style, palette, effect, qa }

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
    'background' => LabTab.background,
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
        LabTab.background => 'background',
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
                                  'LABS-2026.10.05-R17 · Background Effects · A Broad Sunbeam',
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
                              label: 'Background Lab',
                              selected: tab == LabTab.background,
                              onTap: () => _setTab(LabTab.background),
                            ),
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
                      LabTab.background => BackgroundLab(card: card, fg: fg, muted: muted),
                      LabTab.shape => Uri.base.queryParameters['review'] == 'candy-soft'
                          ? CandySoftReview(foreground: fg)
                          : ShapeLab(card: card, fg: fg, muted: muted),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          color: card,
          child: _SectionTitle(
            title: 'Shape Production',
            subtitle:
                '신규/진행 중 Shape는 동일 Gate 체계에서 관리합니다. 이전 개별 QA 패널은 기본 화면에서 제거하고 필요 시 Runtime QA 또는 보존 route에서만 확인합니다.',
            fg: fg,
            muted: muted,
          ),
        ),
        const SizedBox(height: 14),
        _StarfishProductionSystemPanel(card: card, fg: fg, muted: muted),
      ],
    );
  }
}


class _StarfishProductionSystemPanel extends StatelessWidget {
  const _StarfishProductionSystemPanel({
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  static const _assetPath =
      'assets/shape_masters/drop01/starfish/master/starfish_appearance_master_final_v1_2048.png';
  static const _sizes = <double>[160, 120, 100, 80, 58];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Starfish · Appearance Master v1 · 58px QA',
            subtitle:
                'FINAL / LOCKED / ACTIVE Master binary를 그대로 사용합니다. Geometry·색·명암·픽셀 내용은 수정하지 않고 리사이즈만 하여 소형 가독성을 검수합니다.',
            fg: fg,
            muted: muted,
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _ValueChip(label: 'Status', value: 'FINAL / LOCKED / ACTIVE'),
              _ValueChip(label: 'Master', value: '2048 RGBA'),
              _ValueChip(label: 'Current Gate', value: '58px QA'),
              _ValueChip(label: 'Geometry', value: 'LOCKED'),
            ],
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _ShapeGateChip('01 Source', true),
              _ShapeGateChip('02 Appearance', true),
              _ShapeGateChip('03 Master Lock', true),
              _ShapeGateChip('04 58px QA', false),
              _ShapeGateChip('05 Color QA', false),
              _ShapeGateChip('06 Runtime / BG', false),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 760;
              final master = _StarfishMasterPreview(
                assetPath: _assetPath,
                fg: fg,
                muted: muted,
              );
              final sizes = _StarfishSizeQaGrid(
                assetPath: _assetPath,
                fg: fg,
                muted: muted,
              );
              if (stacked) {
                return Column(
                  children: [
                    master,
                    const SizedBox(height: 14),
                    sizes,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: master),
                  const SizedBox(width: 14),
                  Expanded(flex: 7, child: sizes),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _StarfishBackgroundQaRow(
            assetPath: _assetPath,
            fg: fg,
            muted: muted,
          ),
          const SizedBox(height: 14),
          Text(
            'Gate 기준: 58px에서 5팔 실루엣과 중심부가 즉시 불가사리로 읽혀야 합니다. 이 화면은 승인 Master의 축소 렌더만 사용하며, 별도 후보 생성·재도색·재조명은 하지 않습니다. 사용자 시각 승인 전 58px QA를 PASS로 기록하지 않습니다.',
            style: TextStyle(color: muted, fontSize: 10.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _StarfishMasterPreview extends StatelessWidget {
  const _StarfishMasterPreview({
    required this.assetPath,
    required this.fg,
    required this.muted,
  });

  final String assetPath;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E2DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Canonical Master', style: TextStyle(color: fg, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text('2048×2048 · transparent RGBA · pixel locked', style: TextStyle(color: muted, fontSize: 10.5)),
          const SizedBox(height: 12),
          Center(
            child: SizedBox.square(
              dimension: 290,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarfishSizeQaGrid extends StatelessWidget {
  const _StarfishSizeQaGrid({
    required this.assetPath,
    required this.fg,
    required this.muted,
  });

  final String assetPath;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E6EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Size Legibility', style: TextStyle(color: fg, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text('160 / 120 / 100 / 80 / 58px 동일 Master 비교', style: TextStyle(color: muted, fontSize: 10.5)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              for (final size in _StarfishProductionSystemPanel._sizes)
                _StarfishSizeTile(
                  assetPath: assetPath,
                  size: size,
                  fg: fg,
                  muted: muted,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarfishSizeTile extends StatelessWidget {
  const _StarfishSizeTile({
    required this.assetPath,
    required this.size,
    required this.fg,
    required this.muted,
  });

  final String assetPath;
  final double size;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final tileSize = max(size + 24, 96.0);
    return Container(
      width: tileSize,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: size == 58 ? const Color(0xFF7257F5) : const Color(0xFFE8E7ED),
          width: size == 58 ? 1.6 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: size,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${size.toInt()}px',
            style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 11),
          ),
          if (size == 58)
            Text(
              'TARGET',
              style: TextStyle(color: muted, fontSize: 8.5, fontWeight: FontWeight.w800),
            ),
        ],
      ),
    );
  }
}

class _StarfishBackgroundQaRow extends StatelessWidget {
  const _StarfishBackgroundQaRow({
    required this.assetPath,
    required this.fg,
    required this.muted,
  });

  final String assetPath;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const samples = [
      ('Light', Color(0xFFF5F3EF)),
      ('Aqua', Color(0xFFBFE8E7)),
      ('Ocean', Color(0xFF3E7893)),
      ('Dark', Color(0xFF14202A)),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E6EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('58px Background Contrast', style: TextStyle(color: fg, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text('배경만 변경 · Master binary는 동일', style: TextStyle(color: muted, fontSize: 10.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final sample in samples)
                Container(
                  width: 112,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  decoration: BoxDecoration(
                    color: sample.$2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 58,
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          gaplessPlayback: true,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sample.$1,
                        style: TextStyle(
                          color: sample.$1 == 'Dark' || sample.$1 == 'Ocean'
                              ? Colors.white
                              : const Color(0xFF242630),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
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

class _ShapeGateChip extends StatelessWidget {
  const _ShapeGateChip(this.label, this.active);
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFECE5FF) : const Color(0xFFF3F1F5),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: active ? const Color(0xFF7655C9) : const Color(0xFFE1DDE5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF5C43A5) : const Color(0xFF8B8492),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ignore: unused_element
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
    badge: 'ORIGINAL',
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

  // 0 Circle / 1 Square / 2 Triangle. Current work starts on Triangle.
  int geometryMode = 2;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    if (geometryMode == 2) {
      return _SharedTriangleMasterLab(
        card: widget.card,
        fg: widget.fg,
        muted: widget.muted,
        onBackToSquare: () => setState(() => geometryMode = 1),
        onBackToCircle: () => setState(() => geometryMode = 0),
      );
    }
    if (geometryMode == 1) {
      return _SoftBasicSquareRound2(
        card: widget.card,
        fg: widget.fg,
        muted: widget.muted,
        onBackToCircle: () => setState(() => geometryMode = 0),
        onOpenTriangle: () => setState(() => geometryMode = 2),
      );
    }
    final selected = softBasicCircleRound9NaturalCandidates[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Soft Basic · Circle · Round 9N · Natural Micro Light',
          subtitle: 'R7-01 상단 하이라이트와 R8-03 Color Shell은 고정. 하단 전체 띠를 버리고 비대칭·소면적·색상 기반 미세광 3안만 비교합니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => geometryMode = 1),
            icon: const Icon(Icons.crop_square_rounded, size: 16),
            label: const Text('Square Master 보기'),
          ),
        ),
        const SizedBox(height: 8),
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
                for (var i = 0; i < softBasicCircleRound9NaturalCandidates.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: _SoftBasicCandidateCard(
                      candidate: softBasicCircleRound9NaturalCandidates[i],
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


class _SoftBasicSquareRound2 extends StatefulWidget {
  const _SoftBasicSquareRound2({
    required this.card,
    required this.fg,
    required this.muted,
    required this.onBackToCircle,
    required this.onOpenTriangle,
  });

  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onBackToCircle;
  final VoidCallback onOpenTriangle;

  @override
  State<_SoftBasicSquareRound2> createState() => _SoftBasicSquareRound2State();
}

class _SoftBasicSquareRound2State extends State<_SoftBasicSquareRound2> {
  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final selected = softBasicSquareRound5Candidates[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Soft Basic · Square · Round 5 · SELECTED 03 · NO CORE',
          subtitle: 'R5-03은 넓은 Soft Spec만 유지하고 Core Spec 및 secondary sparkle을 제거한 클린 버전으로 최종 고정합니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            TextButton.icon(
              onPressed: widget.onBackToCircle,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Circle Master 보기'),
            ),
            TextButton.icon(
              onPressed: widget.onOpenTriangle,
              icon: const Icon(Icons.change_history_rounded, size: 16),
              label: const Text('Triangle Master 보기'),
            ),
          ],
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
                for (var i = 0; i < softBasicSquareRound5Candidates.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: _SoftBasicSquareCandidateCard(
                      candidate: softBasicSquareRound5Candidates[i],
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
        _SoftBasicCircleSquareComparePanel(
          squareCandidate: selected,
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
        ),
      ],
    );
  }
}

class _SharedTriangleMasterLab extends StatefulWidget {
  const _SharedTriangleMasterLab({
    required this.card,
    required this.fg,
    required this.muted,
    required this.onBackToSquare,
    required this.onBackToCircle,
  });

  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onBackToSquare;
  final VoidCallback onBackToCircle;

  @override
  State<_SharedTriangleMasterLab> createState() =>
      _SharedTriangleMasterLabState();
}

class _SharedTriangleMasterLabState extends State<_SharedTriangleMasterLab> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final selected = softBasicTriangleFinalCandidates[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Soft Basic · Triangle · Direction Round 1 · 6 Approaches',
          subtitle:
              'Triangle Geometry는 Canonical Master(R10)로 고정. 기준안 1개와 Gloss Cap · Dual Spec · Bevel · Dome · Bottom Bounce · Hybrid 6개 방향을 비교합니다. 1차에서는 수치 미세조정보다 표현 방식 차이를 크게 봅니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            const _ValueChip(label: 'Geometry', value: 'MASTER LOCKED'),
            const _ValueChip(label: 'Corner', value: 'R10'),
            TextButton.icon(
              onPressed: widget.onBackToSquare,
              icon: const Icon(Icons.crop_square_rounded, size: 16),
              label: const Text('Square 확정본 보기'),
            ),
            TextButton.icon(
              onPressed: widget.onBackToCircle,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Circle 확정본 보기'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980
                ? 3
                : constraints.maxWidth >= 650
                    ? 2
                    : 1;
            final gap = compact ? 8.0 : 12.0;
            final itemWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < softBasicTriangleFinalCandidates.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: _TriangleMaterialCandidateCard(
                      candidate: softBasicTriangleFinalCandidates[i],
                      selected: selectedIndex == i,
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
        _TriangleMaterialDetailPanel(
          candidate: selected,
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
        ),
      ],
    );
  }
}

class _TriangleMaterialCandidateCard extends StatelessWidget {
  const _TriangleMaterialCandidateCard({
    required this.candidate,
    required this.selected,
    required this.card,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  final SoftBasicTriangleMaterialCandidate candidate;
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
          height: 196,
          padding: const EdgeInsets.all(11),
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
                        fontSize: 11,
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
                    _TriangleMaterialToken(
                      tone: tone,
                      candidate: candidate,
                      size: 58,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                candidate.intent,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: muted,
                  fontSize: 9.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TriangleMaterialDetailPanel extends StatelessWidget {
  const _TriangleMaterialDetailPanel({
    required this.candidate,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final SoftBasicTriangleMaterialCandidate candidate;
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
            '${candidate.id} · ${candidate.name}',
            style: TextStyle(
              color: fg,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            candidate.intent,
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Text(
            '96px ENLARGED · CURRENT ↔ CANDIDATE',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          for (final tone in tones) ...[
            _TriangleMaterialCompareRow(
              tone: tone,
              candidate: candidate,
              size: 96,
              fg: fg,
              muted: muted,
            ),
            if (tone != tones.last) const SizedBox(height: 12),
          ],
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE8E5EF), height: 1),
          const SizedBox(height: 14),
          Text(
            '58px APP SCALE · 3 SHAPE BALANCE',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          for (final tone in tones) ...[
            _TriangleThreeShapeBalanceRow(
              tone: tone,
              candidate: candidate,
              fg: fg,
              muted: muted,
            ),
            if (tone != tones.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TriangleMaterialCompareRow extends StatelessWidget {
  const _TriangleMaterialCompareRow({
    required this.tone,
    required this.candidate,
    required this.size,
    required this.fg,
    required this.muted,
  });

  final ShapeTone tone;
  final SoftBasicTriangleMaterialCandidate candidate;
  final double size;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            tone.label,
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: _CompareTokenCell(
            label: 'CURRENT',
            token: _ProductionCoreToken(
              shape: ShapeKind.triangle,
              tone: tone,
              size: size,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _CompareTokenCell(
            label: candidate.id,
            token: _TriangleMaterialToken(
              tone: tone,
              candidate: candidate,
              size: size,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
      ],
    );
  }
}

class _TriangleThreeShapeBalanceRow extends StatelessWidget {
  const _TriangleThreeShapeBalanceRow({
    required this.tone,
    required this.candidate,
    required this.fg,
    required this.muted,
  });

  final ShapeTone tone;
  final SoftBasicTriangleMaterialCandidate candidate;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            tone.label,
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: _CompareTokenCell(
            label: 'CIRCLE',
            token: _ProductionCoreToken(
              shape: ShapeKind.circle,
              tone: tone,
              size: 58,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CompareTokenCell(
            label: 'TRIANGLE',
            token: _TriangleMaterialToken(
              tone: tone,
              candidate: candidate,
              size: 58,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CompareTokenCell(
            label: 'SQUARE',
            token: _ProductionCoreToken(
              shape: ShapeKind.square,
              tone: tone,
              size: 58,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
      ],
    );
  }
}

class _TriangleMaterialToken extends StatelessWidget {
  const _TriangleMaterialToken({
    required this.tone,
    required this.candidate,
    required this.size,
  });

  final ShapeTone tone;
  final SoftBasicTriangleMaterialCandidate candidate;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _TriangleMaterialPainter(
          tone: tone,
          candidate: candidate,
        ),
      ),
    );
  }
}

class _TriangleMaterialPainter extends CustomPainter {
  const _TriangleMaterialPainter({
    required this.tone,
    required this.candidate,
  });

  final ShapeTone tone;
  final SoftBasicTriangleMaterialCandidate candidate;

  @override
  void paint(Canvas canvas, Size size) {
    final baseOverrides = switch (candidate.approach) {
      SoftBasicTriangleApproach.current => const ShapeRenderOverrides(),
      SoftBasicTriangleApproach.glossCap => const ShapeRenderOverrides(
          layerOpacityScaleById: <String, double>{
            'edge_leaf': 0.15,
            'edge_leaf_halo': 0.18,
            'airbrush_light': 1.05,
            'airbrush_shade': 1.12,
            'ambient_bounce': 0.85,
            'ambient_core': 0.55,
          },
        ),
      SoftBasicTriangleApproach.dualSpec => const ShapeRenderOverrides(
          layerOpacityScaleById: <String, double>{
            'edge_leaf': 0.0,
            'edge_leaf_halo': 0.0,
            'airbrush_light': 0.92,
            'airbrush_shade': 1.08,
            'ambient_bounce': 0.88,
            'ambient_core': 0.45,
          },
        ),
      SoftBasicTriangleApproach.edgeSweep => const ShapeRenderOverrides(
          layerOpacityScaleById: <String, double>{
            'edge_leaf': 0.0,
            'edge_leaf_halo': 0.0,
            'airbrush_light': 0.88,
            'airbrush_shade': 1.0,
            'ambient_bounce': 0.90,
          },
        ),
      SoftBasicTriangleApproach.bevelRim => const ShapeRenderOverrides(
          layerOpacityScaleById: <String, double>{
            'edge_leaf': 0.0,
            'edge_leaf_halo': 0.0,
            'airbrush_light': 0.68,
            'airbrush_shade': 0.78,
            'ambient_bounce': 0.55,
            'ambient_core': 0.35,
          },
        ),
      SoftBasicTriangleApproach.domeVolume => const ShapeRenderOverrides(
          layerOpacityScaleById: <String, double>{
            'edge_leaf': 0.22,
            'edge_leaf_halo': 0.26,
            'airbrush_light': 1.25,
            'airbrush_shade': 1.22,
            'ambient_bounce': 1.05,
            'ambient_core': 0.70,
          },
        ),
      SoftBasicTriangleApproach.bottomBounce => const ShapeRenderOverrides(
          layerOpacityScaleById: <String, double>{
            'edge_leaf': 0.30,
            'edge_leaf_halo': 0.34,
            'airbrush_light': 0.78,
            'airbrush_shade': 1.28,
            'ambient_bounce': 1.35,
            'ambient_core': 0.85,
            'ambient_depth': 1.25,
          },
        ),
      SoftBasicTriangleApproach.sculptedHybrid => const ShapeRenderOverrides(
          layerOpacityScaleById: <String, double>{
            'edge_leaf': 0.0,
            'edge_leaf_halo': 0.0,
            'airbrush_light': 1.08,
            'airbrush_shade': 1.20,
            'ambient_bounce': 1.16,
            'ambient_core': 0.62,
            'ambient_depth': 1.08,
          },
        ),
    };

    ShapeSpecRenderer.paintToken(
      canvas,
      center: size.center(Offset.zero),
      radius: size.shortestSide * 0.43,
      token: LockToken(shape: ShapeKind.triangle, tone: tone),
      style: ShapeStyle.softBasic,
      opacity: 1,
      overrides: baseOverrides,
    );

    if (candidate.approach != SoftBasicTriangleApproach.current) {
      _paintDirectionOverlay(canvas, size);
    }
  }

  void _paintDirectionOverlay(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 100;
    final triangle = Path()
      ..moveTo(50 * sx, 4 * sy)
      ..lineTo(96 * sx, 91 * sy)
      ..lineTo(4 * sx, 91 * sy)
      ..close();

    canvas.save();
    canvas.clipPath(triangle);

    final white = Colors.white;
    final deep = _deepTone(tone);

    switch (candidate.approach) {
      case SoftBasicTriangleApproach.current:
        break;

      case SoftBasicTriangleApproach.glossCap:
        _paintGlossEllipse(
          canvas,
          Rect.fromCenter(
            center: Offset(34 * sx, 31 * sy),
            width: 29 * sx,
            height: 48 * sy,
          ),
          white,
          0.74,
          -0.55,
        );
        _paintFormShade(canvas, size, deep, 0.23, 72, 72, 43, 34);
        break;

      case SoftBasicTriangleApproach.dualSpec:
        _paintGlossEllipse(
          canvas,
          Rect.fromCenter(
            center: Offset(33 * sx, 30 * sy),
            width: 26 * sx,
            height: 43 * sy,
          ),
          white,
          0.52,
          -0.58,
        );
        _paintGlossEllipse(
          canvas,
          Rect.fromCenter(
            center: Offset(39 * sx, 43 * sy),
            width: 10 * sx,
            height: 20 * sy,
          ),
          white,
          0.86,
          -0.58,
        );
        _paintFormShade(canvas, size, deep, 0.20, 72, 72, 41, 33);
        break;

      case SoftBasicTriangleApproach.edgeSweep:
        final p = Path()
          ..moveTo(28 * sx, 49 * sy)
          ..cubicTo(
            30 * sx,
            36 * sy,
            36 * sx,
            21 * sy,
            45 * sx,
            13 * sy,
          );
        final paint = Paint()
          ..color = white.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7.5 * sx
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.2 * sx);
        canvas.drawPath(p, paint);
        _paintFormShade(canvas, size, deep, 0.20, 72, 74, 42, 34);
        break;

      case SoftBasicTriangleApproach.bevelRim:
        final lightPath = Path()
          ..moveTo(21 * sx, 65 * sy)
          ..lineTo(47 * sx, 14 * sy);
        final lightPaint = Paint()
          ..color = white.withValues(alpha: 0.50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.2 * sx
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.8 * sx);
        canvas.drawPath(lightPath, lightPaint);

        final shadePath = Path()
          ..moveTo(55 * sx, 17 * sy)
          ..lineTo(88 * sx, 80 * sy)
          ..lineTo(23 * sx, 85 * sy);
        final shadePaint = Paint()
          ..color = deep.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.8 * sx
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.2 * sx);
        canvas.drawPath(shadePath, shadePaint);
        break;

      case SoftBasicTriangleApproach.domeVolume:
        final lightPaint = Paint()
          ..shader = ui.Gradient.radial(
            Offset(39 * sx, 35 * sy),
            42 * sx,
            [
              white.withValues(alpha: 0.44),
              white.withValues(alpha: 0.12),
              white.withValues(alpha: 0.0),
            ],
            const [0.0, 0.56, 1.0],
          );
        canvas.drawRect(Offset.zero & size, lightPaint);
        _paintFormShade(canvas, size, deep, 0.28, 72, 75, 46, 38);
        break;

      case SoftBasicTriangleApproach.bottomBounce:
        _paintFormShade(canvas, size, deep, 0.31, 73, 69, 46, 37);
        final bounce = Paint()
          ..shader = ui.Gradient.radial(
            Offset(49 * sx, 79 * sy),
            35 * sx,
            [
              white.withValues(alpha: 0.32),
              white.withValues(alpha: 0.08),
              white.withValues(alpha: 0.0),
            ],
            const [0.0, 0.62, 1.0],
          );
        canvas.drawRect(Offset.zero & size, bounce);
        break;

      case SoftBasicTriangleApproach.sculptedHybrid:
        _paintGlossEllipse(
          canvas,
          Rect.fromCenter(
            center: Offset(34 * sx, 30 * sy),
            width: 27 * sx,
            height: 46 * sy,
          ),
          white,
          0.64,
          -0.56,
        );
        _paintGlossEllipse(
          canvas,
          Rect.fromCenter(
            center: Offset(38 * sx, 42 * sy),
            width: 8 * sx,
            height: 15 * sy,
          ),
          white,
          0.86,
          -0.56,
        );
        _paintFormShade(canvas, size, deep, 0.29, 72, 72, 45, 36);
        final bounce = Paint()
          ..shader = ui.Gradient.radial(
            Offset(49 * sx, 80 * sy),
            31 * sx,
            [
              white.withValues(alpha: 0.25),
              white.withValues(alpha: 0.06),
              white.withValues(alpha: 0.0),
            ],
            const [0.0, 0.60, 1.0],
          );
        canvas.drawRect(Offset.zero & size, bounce);
        break;
    }

    canvas.restore();
  }

  void _paintGlossEllipse(
    Canvas canvas,
    Rect rect,
    Color color,
    double opacity,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotation);
    canvas.translate(-rect.center.dx, -rect.center.dy);
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomRight,
        [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.40),
          color.withValues(alpha: 0.0),
        ],
        const [0.0, 0.58, 1.0],
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, rect.width * 0.055);
    canvas.drawOval(rect, paint);
    canvas.restore();
  }

  void _paintFormShade(
    Canvas canvas,
    Size size,
    Color color,
    double opacity,
    double cx,
    double cy,
    double rx,
    double ry,
  ) {
    final sx = size.width / 100;
    final sy = size.height / 100;
    final rect = Rect.fromCenter(
      center: Offset(cx * sx, cy * sy),
      width: rx * 2 * sx,
      height: ry * 2 * sy,
    );
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        rect.center,
        rect.width * 0.52,
        [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.30),
          color.withValues(alpha: 0.0),
        ],
        const [0.0, 0.62, 1.0],
      );
    canvas.drawOval(rect, paint);
  }

  Color _deepTone(ShapeTone tone) {
    return switch (tone) {
      ShapeTone.pink => const Color(0xFFB72F86),
      ShapeTone.blue => const Color(0xFF2874BC),
      ShapeTone.yellow => const Color(0xFFC99A18),
    };
  }

  @override
  bool shouldRepaint(covariant _TriangleMaterialPainter oldDelegate) =>
      oldDelegate.tone != tone ||
      oldDelegate.candidate.id != candidate.id;
}

class _ProductionCoreToken extends StatelessWidget {
  const _ProductionCoreToken({
    required this.shape,
    required this.tone,
    required this.size,
  });

  final ShapeKind shape;
  final ShapeTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: LockTokenPainter(
          LockToken(shape: shape, tone: tone),
          style: ShapeStyle.softBasic,
        ),
      ),
    );
  }
}

class _SoftBasicCircleSquareComparePanel extends StatelessWidget {
  const _SoftBasicCircleSquareComparePanel({
    required this.squareCandidate,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final SoftBasicSquareCandidate squareCandidate;
  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final circleMaster = softBasicCircleRound9NaturalCandidates[2];
    const tones = [
      ShapeTone.pink,
      ShapeTone.blue,
      ShapeTone.yellow,
    ];

    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Circle Master R9N-03  ↔  ' +
                squareCandidate.id +
                ' · ' +
                squareCandidate.name,
            style: TextStyle(
              color: fg,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            squareCandidate.intent,
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Text(
            '96px ENLARGED · SAME PALETTE',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          for (final tone in tones) ...[
            _CircleSquareToneRow(
              tone: tone,
              circleMaster: circleMaster,
              squareCandidate: squareCandidate,
              size: 96,
              compact: compact,
              fg: fg,
              muted: muted,
            ),
            if (tone != tones.last) const SizedBox(height: 12),
          ],
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE8E5EF), height: 1),
          const SizedBox(height: 14),
          Text(
            '58px APP EXACT',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          for (final tone in tones) ...[
            _CircleSquareToneRow(
              tone: tone,
              circleMaster: circleMaster,
              squareCandidate: squareCandidate,
              size: 58,
              compact: compact,
              fg: fg,
              muted: muted,
            ),
            if (tone != tones.last) const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _CircleSquareToneRow extends StatelessWidget {
  const _CircleSquareToneRow({
    required this.tone,
    required this.circleMaster,
    required this.squareCandidate,
    required this.size,
    required this.compact,
    required this.fg,
    required this.muted,
  });

  final ShapeTone tone;
  final SoftBasicCandidate circleMaster;
  final SoftBasicSquareCandidate squareCandidate;
  final double size;
  final bool compact;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final gap = compact ? 10.0 : 18.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: compact ? 42 : 58,
          child: Text(
            tone.label,
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: _CompareTokenCell(
            label: 'CIRCLE · R9N-03',
            token: _SoftBasicExactToken(
              shape: ShapeKind.circle,
              tone: tone,
              candidate: circleMaster,
              size: size,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _CompareTokenCell(
            label: 'SQUARE · ' + squareCandidate.id,
            token: _SoftBasicSquareExactToken(
              tone: tone,
              candidate: squareCandidate,
              size: size,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
      ],
    );
  }
}

class _CompareTokenCell extends StatelessWidget {
  const _CompareTokenCell({
    required this.label,
    required this.token,
    required this.fg,
    required this.muted,
  });

  final String label;
  final Widget token;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAE7F0)),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: muted,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Center(child: token),
        ],
      ),
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
    final profile = candidate.materialProfile;

    final shadowAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.075,
      SoftBasicSquareMaterialProfile.highSpec => 0.060,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.060,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.052,
      SoftBasicSquareMaterialProfile.softGloss => 0.050,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.052,
      SoftBasicSquareMaterialProfile.legacy => 0.035,
    };
    final shadowElevation = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.060,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.052,
      _ => 0.035,
    };

    canvas.drawShadow(
      bodyPath,
      Colors.black.withValues(alpha: shadowAlpha),
      size.shortestSide * shadowElevation,
      true,
    );

    final shellAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.42,
      SoftBasicSquareMaterialProfile.highSpec => 0.36,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.38,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.34,
      SoftBasicSquareMaterialProfile.softGloss => 0.32,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.32,
      SoftBasicSquareMaterialProfile.legacy => 0.28,
    };
    canvas.drawRRect(
      rrect,
      Paint()..color = deep.withValues(alpha: shellAlpha),
    );

    final inner = RRect.fromRectAndRadius(
      rect.deflate(rect.width * 0.015),
      Radius.circular(rect.width * radiusFactor * 0.97),
    );
    canvas.drawRRect(inner, Paint()..color = base);

    final upperAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.64,
      SoftBasicSquareMaterialProfile.highSpec => 0.60,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.57,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.54,
      SoftBasicSquareMaterialProfile.softGloss => 0.52,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.50,
      SoftBasicSquareMaterialProfile.legacy => 0.46,
    };
    final deepAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.42,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.38,
      SoftBasicSquareMaterialProfile.highSpec => 0.37,
      _ => profile == SoftBasicSquareMaterialProfile.legacy ? 0.34 : 0.36,
    };
    final baseBounceAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.31,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.34,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.28,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.24,
      SoftBasicSquareMaterialProfile.softGloss => 0.23,
      SoftBasicSquareMaterialProfile.highSpec => 0.20,
      SoftBasicSquareMaterialProfile.legacy =>
        candidate.technique == SoftBasicSquareTechnique.strongerBounce
            ? 0.22
            : 0.16,
    };
    final baseBounceWidth = switch (profile) {
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.96,
      SoftBasicSquareMaterialProfile.mockupGloss => 0.86,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.84,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.82,
      _ => 0.76,
    };
    final baseBounceHeight = switch (profile) {
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.38,
      SoftBasicSquareMaterialProfile.mockupGloss => 0.35,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.33,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.32,
      _ => 0.30,
    };
    final bounceAlpha = baseBounceAlpha * (switch (candidate.glossRefinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 1.05,
      SoftBasicSquareGlossRefinement.highCompactCore => 0.98,
      SoftBasicSquareGlossRefinement.balancedBright => 1.06,
      SoftBasicSquareGlossRefinement.balancedWide => 1.12,
    });
    final bounceWidth = baseBounceWidth * (switch (candidate.glossRefinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 1.03,
      SoftBasicSquareGlossRefinement.highCompactCore => 1.0,
      SoftBasicSquareGlossRefinement.balancedBright => 1.0,
      SoftBasicSquareGlossRefinement.balancedWide => 1.10,
    });
    final bounceHeight = baseBounceHeight * (switch (candidate.glossRefinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 1.03,
      SoftBasicSquareGlossRefinement.highCompactCore => 1.0,
      SoftBasicSquareGlossRefinement.balancedBright => 1.0,
      SoftBasicSquareGlossRefinement.balancedWide => 1.12,
    });

    canvas.save();
    canvas.clipRRect(inner);

    canvas.drawCircle(
      Offset(
        rect.left + rect.width * 0.28,
        rect.top + rect.height * 0.27,
      ),
      rect.width * 0.42,
      Paint()
        ..color = light.withValues(alpha: upperAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.17,
        ),
    );

    canvas.drawCircle(
      Offset(
        rect.right - rect.width * 0.16,
        rect.bottom - rect.height * 0.14,
      ),
      rect.width * 0.43,
      Paint()
        ..color = deep.withValues(alpha: deepAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.21,
        ),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          rect.left + rect.width * 0.56,
          rect.top + rect.height * 0.80,
        ),
        width: rect.width * bounceWidth,
        height: rect.height * bounceHeight,
      ),
      Paint()
        ..color = bounce.withValues(alpha: bounceAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.095,
        ),
    );

    canvas.restore();

    if (profile == SoftBasicSquareMaterialProfile.legacy) {
      _paintSquareReferenceHighlight(
        canvas,
        rect,
        size,
        candidate.highlightTechnique,
      );
    } else {
      _paintSquareGlossProfile(canvas, rect, size, base, light, profile, candidate.glossRefinement);
    }
  }

  void _paintSquareGlossProfile(
    Canvas canvas,
    Rect rect,
    Size size,
    Color base,
    Color light,
    SoftBasicSquareMaterialProfile profile,
    SoftBasicSquareGlossRefinement refinement,
  ) {
    final edgeGlow = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.080 : 0.125,
      saturationDelta: -0.025,
    );

    final basePatchScale = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 1.08,
      SoftBasicSquareMaterialProfile.highSpec => 0.96,
      SoftBasicSquareMaterialProfile.balancedGloss => 1.00,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.92,
      SoftBasicSquareMaterialProfile.softGloss => 1.02,
      SoftBasicSquareMaterialProfile.wideDiffuse => 1.16,
      SoftBasicSquareMaterialProfile.legacy => 0.92,
    };
    final patchScale = basePatchScale * (switch (refinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 1.13,
      SoftBasicSquareGlossRefinement.highCompactCore => 1.02,
      SoftBasicSquareGlossRefinement.balancedBright => 1.02,
      SoftBasicSquareGlossRefinement.balancedWide => 1.15,
    });
    final basePatchAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.72,
      SoftBasicSquareMaterialProfile.highSpec => 0.76,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.64,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.54,
      SoftBasicSquareMaterialProfile.softGloss => 0.52,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.44,
      SoftBasicSquareMaterialProfile.legacy => 0.54,
    };
    final patchAlpha = (basePatchAlpha * (switch (refinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 0.90,
      SoftBasicSquareGlossRefinement.highCompactCore => 0.98,
      SoftBasicSquareGlossRefinement.balancedBright => 1.12,
      SoftBasicSquareGlossRefinement.balancedWide => 0.92,
    })).clamp(0.0, 1.0).toDouble();
    final haloAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.28,
      SoftBasicSquareMaterialProfile.highSpec => 0.22,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.24,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.18,
      SoftBasicSquareMaterialProfile.softGloss => 0.20,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.30,
      SoftBasicSquareMaterialProfile.legacy => 0.18,
    };
    final baseCoreAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.92,
      SoftBasicSquareMaterialProfile.highSpec => 1.00,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.88,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.76,
      SoftBasicSquareMaterialProfile.softGloss => 0.70,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.54,
      SoftBasicSquareMaterialProfile.legacy => 0.76,
    };
    final coreAlpha = (baseCoreAlpha * (switch (refinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 0.92,
      SoftBasicSquareGlossRefinement.highCompactCore => 1.0,
      SoftBasicSquareGlossRefinement.balancedBright => 1.08,
      SoftBasicSquareGlossRefinement.balancedWide => 0.88,
    })).clamp(0.0, 1.0).toDouble();
    final baseCoreScale = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 1.00,
      SoftBasicSquareMaterialProfile.highSpec => 0.90,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.95,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.88,
      SoftBasicSquareMaterialProfile.softGloss => 1.04,
      SoftBasicSquareMaterialProfile.wideDiffuse => 1.08,
      SoftBasicSquareMaterialProfile.legacy => 0.88,
    };
    final coreScale = baseCoreScale * (switch (refinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 0.96,
      SoftBasicSquareGlossRefinement.highCompactCore => 0.74,
      SoftBasicSquareGlossRefinement.balancedBright => 0.94,
      SoftBasicSquareGlossRefinement.balancedWide => 0.88,
    });

    final clip = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * 0.20),
    );

    Path buildPatch(double scale) {
      final p = Path()
        ..moveTo(
          rect.left + rect.width * (0.105),
          rect.top + rect.height * (0.390 * scale),
        )
        ..cubicTo(
          rect.left + rect.width * 0.085,
          rect.top + rect.height * 0.285,
          rect.left + rect.width * 0.090,
          rect.top + rect.height * 0.165,
          rect.left + rect.width * 0.205,
          rect.top + rect.height * 0.105,
        )
        ..cubicTo(
          rect.left + rect.width * 0.275,
          rect.top + rect.height * 0.070,
          rect.left + rect.width * (0.405 * scale),
          rect.top + rect.height * 0.085,
          rect.left + rect.width * (0.430 * scale),
          rect.top + rect.height * 0.150,
        )
        ..cubicTo(
          rect.left + rect.width * (0.445 * scale),
          rect.top + rect.height * 0.205,
          rect.left + rect.width * (0.365 * scale),
          rect.top + rect.height * 0.245,
          rect.left + rect.width * 0.305,
          rect.top + rect.height * 0.285,
        )
        ..cubicTo(
          rect.left + rect.width * 0.245,
          rect.top + rect.height * 0.325,
          rect.left + rect.width * 0.165,
          rect.top + rect.height * (0.420 * scale),
          rect.left + rect.width * 0.105,
          rect.top + rect.height * (0.390 * scale),
        )
        ..close();
      return p;
    }

    final patch = buildPatch(patchScale);

    canvas.save();
    canvas.clipRRect(clip);

    // Wide face light: the mockup reads as a lit corner surface, not a line.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          rect.left + rect.width * 0.235,
          rect.top + rect.height * 0.235,
        ),
        width: rect.width * 0.50 * patchScale,
        height: rect.height * 0.47 * patchScale,
      ),
      Paint()
        ..color = edgeGlow.withValues(alpha: haloAlpha * 0.72)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.090,
        ),
    );

    // Soft Spec: broad filled patch that wraps the upper-left corner.
    canvas.drawPath(
      patch,
      Paint()
        ..color = Colors.white.withValues(alpha: haloAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.052,
        ),
    );
    canvas.drawPath(
      patch,
      Paint()
        ..color = Colors.white.withValues(alpha: patchAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.017,
        ),
    );

    final hideCore =
        refinement == SoftBasicSquareGlossRefinement.highCompactCore;

    if (!hideCore) {
      // Core Spec: optional compact interior glint for non-master variants.
      final coreRect = Rect.fromCenter(
      center: Offset(
        rect.left + rect.width * 0.235,
        rect.top + rect.height * 0.205,
      ),
      width: rect.width * 0.105 * coreScale,
      height: rect.height * 0.165 * coreScale,
    );
    final core = RRect.fromRectAndRadius(
      coreRect,
      Radius.circular(coreRect.width * 0.50),
    );
    canvas.save();
    canvas.translate(coreRect.center.dx, coreRect.center.dy);
    canvas.rotate(0.34);
    canvas.translate(-coreRect.center.dx, -coreRect.center.dy);
    canvas.drawRRect(
      core,
      Paint()
        ..color = Colors.white.withValues(alpha: coreAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.007,
        ),
    );
    canvas.restore();

    // Small secondary sparkle only for the glossier profiles.
      if (profile == SoftBasicSquareMaterialProfile.mockupGloss ||
          profile == SoftBasicSquareMaterialProfile.highSpec ||
          profile == SoftBasicSquareMaterialProfile.balancedGloss) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.320,
              rect.top + rect.height * 0.145,
            ),
            width: rect.width * 0.030,
            height: rect.height * 0.046,
          ),
          Paint()
            ..color = Colors.white.withValues(alpha: coreAlpha * 0.82)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.004,
            ),
        );
      }
    }
    canvas.restore();
  }

  void _paintSquareReferenceHighlight(
    Canvas canvas,
    Rect rect,
    Size size,
    SoftBasicSquareHighlightTechnique technique,
  ) {
    switch (technique) {
      case SoftBasicSquareHighlightTechnique.flatInset:
        _paintGlossPill(
          canvas,
          center: Offset(
            rect.left + rect.width * 0.245,
            rect.top + rect.height * 0.255,
          ),
          width: rect.width * 0.145,
          height: rect.height * 0.285,
          rotation: 0.30,
          softAlpha: 0.20,
          faceAlpha: 0.76,
          blur: size.shortestSide * 0.020,
        );
      case SoftBasicSquareHighlightTechnique.shortCompact:
        _paintGlossPill(
          canvas,
          center: Offset(
            rect.left + rect.width * 0.235,
            rect.top + rect.height * 0.245,
          ),
          width: rect.width * 0.170,
          height: rect.height * 0.245,
          rotation: 0.26,
          softAlpha: 0.22,
          faceAlpha: 0.70,
          blur: size.shortestSide * 0.024,
        );
      case SoftBasicSquareHighlightTechnique.taperedEdge:
        final path = Path()
          ..moveTo(
            rect.left + rect.width * 0.185,
            rect.top + rect.height * 0.365,
          )
          ..cubicTo(
            rect.left + rect.width * 0.150,
            rect.top + rect.height * 0.305,
            rect.left + rect.width * 0.165,
            rect.top + rect.height * 0.205,
            rect.left + rect.width * 0.235,
            rect.top + rect.height * 0.135,
          )
          ..cubicTo(
            rect.left + rect.width * 0.275,
            rect.top + rect.height * 0.095,
            rect.left + rect.width * 0.330,
            rect.top + rect.height * 0.105,
            rect.left + rect.width * 0.342,
            rect.top + rect.height * 0.145,
          )
          ..cubicTo(
            rect.left + rect.width * 0.350,
            rect.top + rect.height * 0.175,
            rect.left + rect.width * 0.325,
            rect.top + rect.height * 0.205,
            rect.left + rect.width * 0.300,
            rect.top + rect.height * 0.235,
          )
          ..cubicTo(
            rect.left + rect.width * 0.260,
            rect.top + rect.height * 0.285,
            rect.left + rect.width * 0.220,
            rect.top + rect.height * 0.350,
            rect.left + rect.width * 0.185,
            rect.top + rect.height * 0.365,
          )
          ..close();

        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.18)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.055,
            ),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.72)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.018,
            ),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.280,
              rect.top + rect.height * 0.145,
            ),
            width: rect.width * 0.040,
            height: rect.height * 0.065,
          ),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.92)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.009,
            ),
        );
      case SoftBasicSquareHighlightTechnique.cornerKiss:
        final cornerGlow = adjustTone(
          baseColorForTone(tone),
          lightnessDelta: tone == ShapeTone.yellow ? 0.08 : 0.12,
          saturationDelta: -0.02,
        );
        final kissRect = Rect.fromCenter(
          center: Offset(
            rect.left + rect.width * 0.205,
            rect.top + rect.height * 0.205,
          ),
          width: rect.width * 0.23,
          height: rect.height * 0.12,
        );
        canvas.save();
        canvas.clipRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(rect.width * 0.20),
          ),
        );
        canvas.drawArc(
          kissRect,
          3.55,
          1.45,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.030
            ..strokeCap = StrokeCap.round
            ..color = cornerGlow.withValues(alpha: 0.34)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.018,
            ),
        );
        canvas.restore();

      case SoftBasicSquareHighlightTechnique.softFacet:
        final facetGlow = adjustTone(
          baseColorForTone(tone),
          lightnessDelta: tone == ShapeTone.yellow ? 0.07 : 0.105,
          saturationDelta: -0.018,
        );
        final facet = Path()
          ..moveTo(
            rect.left + rect.width * 0.08,
            rect.top + rect.height * 0.31,
          )
          ..quadraticBezierTo(
            rect.left + rect.width * 0.10,
            rect.top + rect.height * 0.11,
            rect.left + rect.width * 0.30,
            rect.top + rect.height * 0.08,
          )
          ..quadraticBezierTo(
            rect.left + rect.width * 0.40,
            rect.top + rect.height * 0.09,
            rect.left + rect.width * 0.34,
            rect.top + rect.height * 0.20,
          )
          ..quadraticBezierTo(
            rect.left + rect.width * 0.23,
            rect.top + rect.height * 0.29,
            rect.left + rect.width * 0.08,
            rect.top + rect.height * 0.31,
          )
          ..close();
        canvas.save();
        canvas.clipRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(rect.width * 0.20),
          ),
        );
        canvas.drawPath(
          facet,
          Paint()
            ..color = facetGlow.withValues(alpha: 0.18)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.050,
            ),
        );
        canvas.drawPath(
          facet,
          Paint()
            ..color = facetGlow.withValues(alpha: 0.10)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.018,
            ),
        );
        canvas.restore();

      case SoftBasicSquareHighlightTechnique.edgeFade:
        final edgeGlow = adjustTone(
          baseColorForTone(tone),
          lightnessDelta: tone == ShapeTone.yellow ? 0.075 : 0.115,
          saturationDelta: -0.02,
        );
        final rounded = RRect.fromRectAndRadius(
          rect.deflate(rect.width * 0.022),
          Radius.circular(rect.width * 0.20 * 0.97),
        );
        final edgeBounds = Rect.fromLTWH(
          rect.left,
          rect.top,
          rect.width * 0.52,
          rect.height * 0.48,
        );
        canvas.save();
        canvas.clipRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(rect.width * 0.20),
          ),
        );
        canvas.drawRRect(
          rounded,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.025
            ..shader = LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                edgeGlow.withValues(alpha: 0.00),
                edgeGlow.withValues(alpha: 0.28),
                edgeGlow.withValues(alpha: 0.08),
                edgeGlow.withValues(alpha: 0.00),
              ],
              stops: const [0.0, 0.42, 0.70, 1.0],
            ).createShader(edgeBounds)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.016,
            ),
        );
        canvas.restore();

      case SoftBasicSquareHighlightTechnique.round1Base:
        _paintGlossPill(
          canvas,
          center: Offset(
            rect.left + rect.width * 0.225,
            rect.top + rect.height * 0.245,
          ),
          width: rect.width * 0.130,
          height: rect.height * 0.225,
          rotation: 0.22,
          softAlpha: 0.16,
          faceAlpha: 0.68,
          blur: size.shortestSide * 0.023,
        );
    }
  }

  void _paintGlossPill(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required double rotation,
    required double softAlpha,
    required double faceAlpha,
    required double blur,
    double coreAlpha = 0.94,
  }) {
    final pillRect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );
    final pill = RRect.fromRectAndRadius(
      pillRect,
      Radius.circular(width * 0.52),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawRRect(
      pill.inflate(width * 0.12),
      Paint()
        ..color = Colors.white.withValues(alpha: softAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          blur * 2.6,
        ),
    );

    canvas.drawRRect(
      pill,
      Paint()
        ..color = Colors.white.withValues(alpha: faceAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          blur,
        ),
    );

    final coreCenter = Offset(
      center.dx + width * 0.05,
      center.dy - height * 0.29,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: coreCenter,
        width: width * 0.30,
        height: height * 0.16,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: coreAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          blur * 0.45,
        ),
    );

    canvas.restore();
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

      case SoftBasicBottomHighlightTechnique.sideKiss:
        final sideRect = Rect.fromCenter(
          center: Offset(
            rect.left + rect.width * 0.68,
            rect.top + rect.height * 0.72,
          ),
          width: rect.width * 0.34,
          height: rect.height * 0.22,
        );
        canvas.drawArc(
          sideRect,
          0.42,
          1.08,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.036
            ..strokeCap = StrokeCap.round
            ..color = rimLight.withValues(alpha: 0.26)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4),
        );
        canvas.drawArc(
          sideRect.deflate(rect.width * 0.014),
          0.50,
          0.72,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.015
            ..strokeCap = StrokeCap.round
            ..color = rimLight.withValues(alpha: 0.34)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9),
        );

      case SoftBasicBottomHighlightTechnique.softSpot:
        final spotRect = Rect.fromCenter(
          center: Offset(
            rect.left + rect.width * 0.61,
            rect.top + rect.height * 0.73,
          ),
          width: rect.width * 0.24,
          height: rect.height * 0.105,
        );
        canvas.drawOval(
          spotRect,
          Paint()
            ..color = rimLight.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.6),
        );
        canvas.drawOval(
          spotRect.deflate(rect.width * 0.032),
          Paint()
            ..color = rimLight.withValues(alpha: 0.14)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
        );

      case SoftBasicBottomHighlightTechnique.edgeFade:
        final fadeRect = rect.deflate(rect.width * 0.028);
        final fadeBounds = Rect.fromLTWH(
          rect.left + rect.width * 0.46,
          rect.top + rect.height * 0.55,
          rect.width * 0.46,
          rect.height * 0.40,
        );
        canvas.drawArc(
          fadeRect,
          0.34,
          1.20,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.024
            ..strokeCap = StrokeCap.round
            ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x00FFFFFF),
                Color(0x33FFFFFF),
                Color(0x00FFFFFF),
              ],
              stops: [0.0, 0.58, 1.0],
            ).createShader(fadeBounds)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
        );
        canvas.drawArc(
          fadeRect.deflate(rect.width * 0.010),
          0.50,
          0.72,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.012
            ..strokeCap = StrokeCap.round
            ..color = rimLight.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7),
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

class _StarfishPaletteQaPanel extends StatelessWidget {
  const _StarfishPaletteQaPanel({
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  static const _asset =
      'assets/shape_masters/drop01/starfish/master/starfish_appearance_master_final_v1_2048.png';

  static const _palettes = <(String, Color)>[
    ('Deep Ocean', Color(0xFF4F8EDB)),
    ('Aqua Mint', Color(0xFF7CCFC4)),
    ('Coral Pink', Color(0xFFF7A7B5)),
    ('Sand Beige', Color(0xFFEFD59A)),
    ('Lavender', Color(0xFFB9A7E8)),
    ('Peach Orange', Color(0xFFF7B385)),
  ];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Starfish · Drop 01 Color QA',
            subtitle:
                '58px QA PASS된 FINAL / LOCKED Appearance Master에 확정 6색을 적용해 색상 식별성과 명암 보존을 검수합니다. Geometry와 alpha는 변경하지 않습니다.',
            fg: fg,
            muted: muted,
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _ValueChip(label: 'Source', value: 'Starfish Master v1'),
              _ValueChip(label: '58px', value: 'PASS'),
              _ValueChip(label: 'Current Gate', value: 'Static 6 Color QA'),
              _ValueChip(label: 'Geometry', value: 'LOCKED'),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 980
                  ? 3
                  : constraints.maxWidth >= 620
                      ? 2
                      : 1;
              const gap = 12.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final palette in _palettes)
                    SizedBox(
                      width: width,
                      child: _StarfishPaletteCard(
                        assetPath: _asset,
                        name: palette.$1,
                        color: palette.$2,
                        fg: fg,
                        muted: muted,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE3E7F0)),
            ),
            child: Text(
              'Aurora Sea는 정적 색상 근사본을 만들지 않습니다. 현재 Final / Locked / Active H02B Living Water Brighter는 동적 refraction renderer이므로 Starfish Runtime palette binding이 연결된 뒤 Runtime QA에서 exact renderer로 검수합니다.',
              style: TextStyle(color: muted, fontSize: 10.5, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarfishPaletteCard extends StatelessWidget {
  const _StarfishPaletteCard({
    required this.assetPath,
    required this.name,
    required this.color,
    required this.fg,
    required this.muted,
  });

  final String assetPath;
  final String name;
  final Color color;
  final Color fg;
  final Color muted;

  Widget _coloredStar(double size) {
    return SizedBox.square(
      dimension: size,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.color),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E7ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(color: muted, fontSize: 9.5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _coloredStar(118),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _coloredStar(58),
                  const SizedBox(height: 4),
                  Text(
                    '58px',
                    style: TextStyle(
                      color: muted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaletteLab extends StatefulWidget {
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
  State<PaletteLab> createState() => _PaletteLabState();
}

class _PaletteLabState extends State<PaletteLab>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _previous = Duration.zero;
  double _seconds = 0;
  bool _paused = false;
  double? _peekEnd;
  ui.Image? _paletteBase;
  ui.Image? _fixedFinish;
  Object? _loadError;

  final _candidates = <_WaterWaveCandidate>[
    _WaterWaveCandidate(
      id: 'H02', name: 'Living Water · Original',
      note: '선택된 원본 기준안. 자연스러운 흐름과 눈에 띄는 물빛 유지.',
      field: WaterRefractionField(
        colors: const [Color(0xFF0754A3), Color(0xFF138BD3), Color(0xFF20CCD7), Color(0xFF9AF0F3)],
        speed: 1.28, refraction: .92, cellScale: 3.7, light: 0.72, seed: 29,
      ),
    ),
    _WaterWaveCandidate(
      id: 'H02B', name: 'Living Water · Brighter',
      note: '원본과 같은 흐름. 집광 밝기만 높여 58px에서 물빛을 더 또렷하게.',
      field: WaterRefractionField(
        colors: const [Color(0xFF0754A3), Color(0xFF138BD3), Color(0xFF20CCD7), Color(0xFF9AF0F3)],
        speed: 1.28, refraction: .92, cellScale: 3.7, light: 0.84, seed: 29,
      ),
    ),
    _WaterWaveCandidate(
      id: 'H02C', name: 'Living Water · Broad',
      note: '원본과 같은 밝기. 굴절 면광을 넓혀 작은 크기에서도 면의 변화를 읽기 쉽게.',
      field: WaterRefractionField(
        colors: const [Color(0xFF0754A3), Color(0xFF138BD3), Color(0xFF20CCD7), Color(0xFF9AF0F3)],
        speed: 1.28, refraction: .92, cellScale: 3.1, light: 0.72, seed: 29,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadProductionLayers();
    _ticker = createTicker(_onTick)..start();
  }

  Future<ui.Image> _loadImage(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  Future<void> _loadProductionLayers() async {
    try {
      final results = await Future.wait([
        _loadImage(
          'assets/raster_shapes/sea_turtle_v3_palette_base_256_v3.webp',
        ),
        _loadImage(
          'assets/raster_shapes/sea_turtle_v3_fixed_finish_256_v3.webp',
        ),
      ]);
      if (!mounted) {
        for (final image in results) {
          image.dispose();
        }
        return;
      }
      setState(() {
        _paletteBase = results[0];
        _fixedFinish = results[1];
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error);
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final delta = _previous == Duration.zero
        ? 0.0
        : (elapsed - _previous).inMicroseconds /
            Duration.microsecondsPerSecond;
    _previous = elapsed;
    if (!_paused && delta > 0) {
      _seconds += delta.clamp(0.0, 0.05).toDouble();
      if (_peekEnd != null && _seconds >= _peekEnd!) {
        _seconds = _peekEnd!;
        _peekEnd = null;
        _paused = true;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _paletteBase?.dispose();
    _fixedFinish?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final experiment = Uri.base.queryParameters['experiment'];
    if (experiment == 'jellyfish-multicolor') {
      return JellyfishMultiColorExperiment(
        card: widget.card,
        fg: widget.fg,
        muted: widget.muted,
      );
    }

    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StarfishPaletteQaPanel(
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 14),
        _Panel(
          color: widget.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'Experimental · Jellyfish Multi-Color',
                subtitle:
                    'Production Palette와 분리된 별도 실험. 선정된 Jellyfish R4 Static Master를 잠근 뒤 Color Weight Map 기반 정적 Multi-Color 가능성을 검증합니다.',
                fg: widget.fg,
                muted: widget.muted,
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _ValueChip(label: 'Class', value: 'Palette Lab / Experimental'),
                  _ValueChip(label: 'Experiment', value: 'jellyfish-multicolor'),
                  _ValueChip(label: 'State', value: 'POC / NOT PRODUCTION'),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: () {
                    final next = Uri.base.replace(
                      queryParameters: {
                        ...Uri.base.queryParameters,
                        'lab': 'palette',
                        'experiment': 'jellyfish-multicolor',
                      },
                    );
                    SystemNavigator.routeInformationUpdated(uri: next, replace: true);
                  },
                  child: const Text('Multi-Color 실험 열기'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          color: widget.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'Water Wave R2 · H02B Final',
                subtitle:
                    'H02B는 Signature Color v3 Final / Locked / Active. C02 원본은 복구 이력으로 보존합니다. 동일 Palette Base + Fixed Finish 기준이며 W01~W03은 Reject / Archived.',
                fg: widget.fg,
                muted: widget.muted,
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _ValueChip(label: 'Version', value: 'LABS-2026.10.04-R02'),
                  _ValueChip(label: 'State', value: 'FINAL / LOCKED'),
                  _ValueChip(label: 'Source', value: 'Runtime v4 source'),
                  _ValueChip(label: 'Production', value: 'LOCKED'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '평가 기준: 1~2초 노출에서도 바다로 즉시 읽힘 · 색 변화 체감 큼 · 물결/수면광이 눈에 띔 · Fixed Finish 디테일 유지.',
                style: TextStyle(
                  color: widget.muted,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: widget.fg),
                onPressed: () => setState(() { _peekEnd = null; _paused = !_paused; }),
                icon: Icon(
                  _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                ),
                label: Text(_paused ? '효과 재개' : '효과 멈춤'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: widget.fg),
                onPressed: () => setState(() {
                  _peekEnd = _seconds + 2;
                  _paused = false;
                }),
                icon: const Icon(Icons.timer_outlined),
                label: const Text('2초 노출 비교 · 자동 정지'),
              ),
              const SizedBox(height: 14),
              if (_loadError != null)
                Text(
                  'Production raster load error: $_loadError',
                  style: const TextStyle(color: Colors.red),
                )
              else if (_paletteBase == null || _fixedFinish == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 12.0;
                    final columns = constraints.maxWidth >= 850 ? 3 : 1;
                    final width =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final candidate in _candidates)
                          SizedBox(
                            width: width,
                            child: _WaterWaveCandidateCard(
                              candidate: candidate,
                              paletteBase: _paletteBase!,
                              fixedFinish: _fixedFinish!,
                              timeSeconds: _seconds,
                              fg: widget.fg,
                              muted: widget.muted,
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          color: widget.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'Core Palette Reference',
                subtitle: '기존 기본 3색 Soft Basic / Crayon Soft 비교는 그대로 유지합니다.',
                fg: widget.fg,
                muted: widget.muted,
              ),
              const SizedBox(height: 16),
              for (final tone in tones) ...[
                Text(
                  tone.label,
                  style: TextStyle(
                    color: widget.fg,
                    fontWeight: FontWeight.w900,
                  ),
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
                      muted: widget.muted,
                    ),
                    _TokenWithLabel(
                      shape: ShapeKind.circle,
                      tone: tone,
                      style: ShapeStyle.crayonSoft,
                      label: 'Crayon',
                      muted: widget.muted,
                    ),
                    _TokenWithLabel(
                      shape: ShapeKind.triangle,
                      tone: tone,
                      style: ShapeStyle.crayonSoft,
                      label: 'Triangle',
                      muted: widget.muted,
                    ),
                    _TokenWithLabel(
                      shape: ShapeKind.square,
                      tone: tone,
                      style: ShapeStyle.crayonSoft,
                      label: 'Square',
                      muted: widget.muted,
                    ),
                  ],
                ),
                if (tone != tones.last) const SizedBox(height: 18),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WaterWaveCandidateCard extends StatelessWidget {
  const _WaterWaveCandidateCard({
    required this.candidate,
    required this.paletteBase,
    required this.fixedFinish,
    required this.timeSeconds,
    required this.fg,
    required this.muted,
  });

  final _WaterWaveCandidate candidate;
  final ui.Image paletteBase;
  final ui.Image fixedFinish;
  final double timeSeconds;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    Widget preview(double size, Color background) {
      return Container(
        width: size,
        height: size,
        color: background,
        child: CustomPaint(
          painter: _WaterWaveSeaTurtlePainter(
            paletteBase: paletteBase,
            fixedFinish: fixedFinish,
            candidate: candidate,
            timeSeconds: timeSeconds,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: candidate.id == 'H02B'
            ? (fg.computeLuminance() > .5 ? const Color(0xFF123743) : const Color(0xFFEAF8FF))
            : (fg.computeLuminance() > .5 ? const Color(0xFF16232D) : const Color(0xFFF8F8FB)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: candidate.id == 'H02B'
              ? const Color(0xFF38AEE8)
              : const Color(0xFFE4E5EB),
          width: candidate.id == 'H02B' ? 2 : 1,
        ),
      ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (candidate.id == 'H02B')
                const Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    'FINAL',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            candidate.note,
            style: TextStyle(color: muted, fontSize: 10.5, height: 1.3),
          ),
          const SizedBox(height: 9),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: preview(190, const Color(0xFFF4FBFF)),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: preview(58, const Color(0xFFF5FBFF)),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: preview(58, const Color(0xFF071A2D)),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Center(
            child: Text(
              '58px · Light / Dark',
              style: TextStyle(
                color: muted,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterWaveSeaTurtlePainter extends CustomPainter {
  const _WaterWaveSeaTurtlePainter({
    required this.paletteBase,
    required this.fixedFinish,
    required this.candidate,
    required this.timeSeconds,
  });

  final ui.Image paletteBase;
  final ui.Image fixedFinish;
  final _WaterWaveCandidate candidate;
  final double timeSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      0,
      0,
      paletteBase.width.toDouble(),
      paletteBase.height.toDouble(),
    );
    final dest = Offset.zero & size;
    // Hard clip removes subpixel mesh coverage outside the alpha-mask rectangle.
    canvas.save();
    canvas.clipRect(dest, doAntiAlias: false);
    // Alpha-first compositing prevents filtered dstIn edge coverage from
    // leaving a rectangular fringe. The optical field is srcIn of exact alpha.
    canvas.saveLayer(dest, Paint());
    canvas.drawImageRect(
      paletteBase, src, dest,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.save();
    canvas.scale(size.width, size.height);
    canvas.drawVertices(
      candidate.field.mesh(timeSeconds),
      BlendMode.src,
      Paint()..blendMode = BlendMode.srcIn,
    );
    canvas.restore();
    canvas.restore();

    canvas.drawImageRect(
      fixedFinish,
      Rect.fromLTWH(
        0,
        0,
        fixedFinish.width.toDouble(),
        fixedFinish.height.toDouble(),
      ),
      dest,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WaterWaveSeaTurtlePainter oldDelegate) =>
      oldDelegate.timeSeconds != timeSeconds ||
      oldDelegate.candidate != candidate ||
      oldDelegate.paletteBase != paletteBase ||
      oldDelegate.fixedFinish != fixedFinish;
}

class _WaterWaveCandidate {
  const _WaterWaveCandidate({
    required this.id, required this.name, required this.note, required this.field,
  });
  final String id, name, note;
  final WaterRefractionField field;
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


enum _SurfaceRefractionCandidate { calmBroad, softPrism, livingSurface }

extension on _SurfaceRefractionCandidate {
  SurfaceRefractionProfile get profile => switch (this) {
    _SurfaceRefractionCandidate.calmBroad => const SurfaceRefractionProfile(
        mode: SurfaceRefractionMode.broadField,
        seed: 101,
        speed: .34,
        scale: 1.55,
        warp: .28,
        energy: .34,
        softness: .86,
        warmth: .06,
        topFraction: .42,
      ),
    _SurfaceRefractionCandidate.softPrism => const SurfaceRefractionProfile(
        mode: SurfaceRefractionMode.surfaceSweep,
        seed: 211,
        speed: .42,
        scale: 1.82,
        warp: .36,
        energy: .38,
        softness: .78,
        warmth: .18,
        topFraction: .46,
      ),
    _SurfaceRefractionCandidate.livingSurface => const SurfaceRefractionProfile(
        mode: SurfaceRefractionMode.organicCaustic,
        seed: 307,
        speed: .50,
        scale: 2.20,
        warp: .44,
        energy: .42,
        softness: .70,
        warmth: .04,
        topFraction: .48,
      ),
  };
}

enum _BackgroundWorkbenchStep { image, effects, composite, finalState }

extension on _BackgroundWorkbenchStep {
  String get code => switch (this) {
    _BackgroundWorkbenchStep.image => '01',
    _BackgroundWorkbenchStep.effects => '02',
    _BackgroundWorkbenchStep.composite => '03',
    _BackgroundWorkbenchStep.finalState => '04',
  };

  String get label => switch (this) {
    _BackgroundWorkbenchStep.image => '배경 이미지',
    _BackgroundWorkbenchStep.effects => '레이어 효과',
    _BackgroundWorkbenchStep.composite => '합성 QA',
    _BackgroundWorkbenchStep.finalState => 'Final',
  };
}

class BackgroundLab extends StatefulWidget {
  const BackgroundLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<BackgroundLab> createState() => _BackgroundLabState();
}

class _BackgroundLabState extends State<BackgroundLab>
    with TickerProviderStateMixin {
  late final AnimationController _surfaceClock;
  late final AnimationController _broadSunbeamClock;

  int selectedBackground = 0;
  int selectedRatio = 2;
  bool showSafeZone = true;
  late final BackgroundAssetRecord _shallowClearBase;
  _BackgroundWorkbenchStep step = _BackgroundWorkbenchStep.image;
  _SurfaceRefractionCandidate selected = _SurfaceRefractionCandidate.calmBroad;
  bool showSurface = false;
  bool showFloorCaustic = true;
  bool showVolumetricLight = true;
  bool showAmbientParticle = true;
  bool showBubble = true;
  double intensity = 1.0;
  int? soloEffectIndex;
  bool volumetricExpanded = true;
  int selectedVolumetric = 0;

  static const backgrounds = [
    ('01', '투명한 얕은 바다', 'Image Selected · Effects In Progress'),
    ('02', '바닷속 하루', 'Not Started'),
    ('03', '고요한 심해', 'Not Started'),
  ];

  static const deviceRatios = [
    ('16:9', 9 / 16, 'Legacy / short'),
    ('18:9', 9 / 18, 'Tall'),
    ('19.5:9', 9 / 19.5, 'Common'),
    ('20:9', 9 / 20, 'Common tall'),
    ('21:9', 9 / 21, 'Extreme tall'),
  ];

  @override
  void initState() {
    super.initState();
    _shallowClearBase = BackgroundAssetRegistry.instance.resolve(
      'background.drop01.shallow_clear.base_only_v2',
    );
    _surfaceClock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _broadSunbeamClock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _surfaceClock.dispose();
    _broadSunbeamClock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(),
        const SizedBox(height: 16),
        _dropSelector(),
        const SizedBox(height: 14),
        _backgroundSelector(),
        const SizedBox(height: 14),
        _stepSelector(),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: selectedBackground == 0
              ? _activeBackgroundBody()
              : _notStartedBody(),
        ),
      ],
    );
  }

  Widget _title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Lab',
          style: TextStyle(
            color: widget.fg,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Drop → Background → Production Step',
          style: TextStyle(
            color: widget.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _dropSelector() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('DROP'),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _navChip(
                label: 'Drop 01 · 작은 바닷속',
                selected: true,
                onTap: () {},
              ),
              _navChip(
                label: 'Drop 02 · 준비중',
                selected: false,
                enabled: false,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backgroundSelector() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('BACKGROUND'),
          const SizedBox(height: 9),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < backgrounds.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _backgroundTab(i),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundTab(int index) {
    final item = backgrounds[index];
    final active = selectedBackground == index;
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => setState(() {
        selectedBackground = index;
        step = _BackgroundWorkbenchStep.image;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minWidth: 184),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFECE5FF) : widget.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: active ? const Color(0xFF7655C9) : const Color(0xFFE1DDE8),
            width: active ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.$1 + ' · ' + item.$2,
              style: TextStyle(
                color: widget.fg,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.$3,
              style: TextStyle(
                color: active ? const Color(0xFF6A4FC0) : widget.muted,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepSelector() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('PRODUCTION STEP'),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in _BackgroundWorkbenchStep.values)
                _navChip(
                  label: item.code + ' · ' + item.label,
                  selected: step == item,
                  enabled: selectedBackground == 0 ||
                      item == _BackgroundWorkbenchStep.image,
                  onTap: () => setState(() => step = item),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activeBackgroundBody() {
    return switch (step) {
      _BackgroundWorkbenchStep.image => _imageStep(),
      _BackgroundWorkbenchStep.effects => _effectsStep(),
      _BackgroundWorkbenchStep.composite => _compositeStep(),
      _BackgroundWorkbenchStep.finalState => _finalStep(),
    };
  }

  Widget _imageStep() {
    return _sectionCard(
      key: const ValueKey('background-image-step'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
            '01 · 배경 이미지',
            'Planning Visual → 선택 → Clean Background Base',
            'Selected / Base Candidate',
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 720;
              final preview = _approvedBasePreview(showBadge: true);
              final info = _imageInfo();
              if (!wide) {
                return Column(
                  children: [
                    preview,
                    const SizedBox(height: 14),
                    info,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: preview),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: info),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Divider(color: widget.muted.withValues(alpha: .18)),
          const SizedBox(height: 12),
          _deviceRatioQa(),
        ],
      ),
    );
  }

  Widget _imageInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('현재 기준', 'A Open Water · Base Only v2 · Approved'),
        _infoRow('Base Asset ID', _shallowClearBase.assetId),
        _infoRow('구도', '중앙 Play Field 확보 · 좌하단 환경 요소 집중'),
        _infoRow('잠금', '구도 · 오브젝트 밀도 · 색감 계열 · 세계관'),
        _infoRow('동적 요소', 'Base에 Bake하지 않음'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7EF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            '배경 이미지 선정 완료. 다음 수정은 새 Candidate/Version으로만 진행.',
            style: TextStyle(
              color: Color(0xFF356C49),
              fontSize: 11,
              height: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _deviceRatioQa() {
    final ratio = deviceRatios[selectedRatio];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Ratio QA',
                    style: TextStyle(
                      color: widget.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '승인 Base를 Asset ID → Registry → Runtime Path로 불러와 기기 비율별 BoxFit.cover로 확인합니다. Production 목표는 20:9 Master입니다.',
                    style: TextStyle(
                      color: widget.muted,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilterChip(
              label: const Text('Safe Zone'),
              selected: showSafeZone,
              onSelected: (v) => setState(() => showSafeZone = v),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < deviceRatios.length; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                ChoiceChip(
                  label: Text(deviceRatios[i].$1),
                  selected: selectedRatio == i,
                  onSelected: (_) => setState(() => selectedRatio = i),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: AspectRatio(
              aspectRatio: ratio.$2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _shallowClearBase.runtimePath!,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      gaplessPlayback: true,
                    ),
                    if (showSafeZone)
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _BackgroundSafeZonePainter(),
                        ),
                      ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _previewBadge(ratio.$1 + ' · ' + ratio.$3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'QA 원칙: 배경은 늘리거나 찌그러뜨리지 않습니다. 기존 1024×1536 Core Composition은 별도 Reference로 보존하고, '
          '현재 LABS는 승인된 Base Only v2를 immutable input으로 사용합니다. Production Master는 1440×3200(20:9) 기준이며 16:9에서는 상·하 약 10%씩만 bleed, '
          '21:9에서는 좌·우 약 2.4%씩만 bleed가 발생하도록 설계합니다. 산호·주요 암석과 Play Field는 공통 Safe Zone 안에 유지합니다.',
          style: TextStyle(
            color: widget.muted,
            fontSize: 11,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _effectsStep() {
    return _sectionCard(
      key: const ValueKey('background-effects-step'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
            '02 · 레이어 효과',
            '승인 Base는 그대로 유지하고 Effect만 독립 제작',
            'Full Live First',
          ),
          const SizedBox(height: 14),
          _fullLivePanel(),
          const SizedBox(height: 16),
          Divider(color: widget.muted.withValues(alpha: .18)),
          const SizedBox(height: 12),
          Text(
            'Effect Queue',
            style: TextStyle(
              color: widget.fg,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '아래 Effect를 조작하면 상단 Full Live Preview에 즉시 반영됩니다.',
            style: TextStyle(color: widget.muted, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          _layerStatusList(),

        ],
      ),
    );
  }

  static const _volumetricProfiles = <VolumetricLightProfile>[
    VolumetricLightProfile(
      mode: VolumetricLightMode.broadCalm,
      energy: 1.0,
      drift: .045,
      width: .24,
      depth: .64,
    ),
    VolumetricLightProfile(
      mode: VolumetricLightMode.livingRays,
      energy: 1.0,
      drift: .035,
      width: .20,
      depth: .70,
    ),
    VolumetricLightProfile(
      mode: VolumetricLightMode.softDrift,
      energy: .92,
      drift: .050,
      width: .22,
      depth: .62,
    ),
  ];

  static const _volumetricLabels = <String>[
    'A · Broad Sunbeam · R17',
    'B · Living Rays',
    'C · Soft Drift',
  ];

  Widget _volumetricCandidatePanel() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 160),
      crossFadeState: volumetricExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(),
      secondChild: Padding(
        padding: const EdgeInsets.fromLTRB(42, 8, 8, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A · Broad Sunbeam 검수 중 · B/C는 R14 보존본',
              style: TextStyle(
                color: widget.muted,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (var i = 0; i < _volumetricLabels.length; i++)
                  ChoiceChip(
                    label: Text(_volumetricLabels[i]),
                    selected: selectedVolumetric == i,
                    onSelected: (_) {
                      setState(() => selectedVolumetric = i);
                      _soloEffect(2);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _layerStatusList() {
    final layers = [
      ('01', 'Surface Refraction', 'Deferred', showSurface, (bool v) => setState(() => showSurface = v), () => _soloEffect(0)),
      ('02', 'Floor Caustic', 'Candidate', showFloorCaustic, (bool v) => setState(() => showFloorCaustic = v), () => _soloEffect(1)),
      ('03', 'Volumetric Light', 'Candidate', showVolumetricLight, (bool v) => setState(() => showVolumetricLight = v), () => _soloEffect(2)),
      ('04', 'Ambient Particle', 'Candidate', showAmbientParticle, (bool v) => setState(() => showAmbientParticle = v), () => _soloEffect(3)),
      ('05', 'Bubble', 'Candidate', showBubble, (bool v) => setState(() => showBubble = v), () => _soloEffect(4)),
    ];
    return Column(
      children: [
        for (var i = 0; i < layers.length; i++) ...[
          if (i > 0) const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: layers[i].$4 ? const Color(0xFFF3EFFF) : widget.muted.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: layers[i].$4 ? const Color(0xFFD9CDF9) : widget.muted.withValues(alpha: .12),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(layers[i].$1, style: TextStyle(color: widget.muted, fontSize: 10, fontWeight: FontWeight.w900)),
                ),
                Expanded(
                  child: Text(layers[i].$2, style: TextStyle(color: widget.fg, fontSize: 12, fontWeight: FontWeight.w800)),
                ),
                _statusBadge(layers[i].$3, layers[i].$3 != 'Deferred'),
                const SizedBox(width: 4),
                if (i == 2)
                  IconButton(
                    tooltip: volumetricExpanded ? '접기' : 'A-C 후보 열기',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(
                      () => volumetricExpanded = !volumetricExpanded,
                    ),
                    icon: Icon(
                      volumetricExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                  ),
                TextButton(onPressed: layers[i].$6, child: const Text('Solo')),
                Switch(value: layers[i].$4, onChanged: layers[i].$5),
              ],
            ),
          ),
          if (i == 2) _volumetricCandidatePanel(),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() {
              showSurface = false;
              showFloorCaustic = true;
              showVolumetricLight = true;
              showAmbientParticle = true;
              showBubble = true;
              soloEffectIndex = null;
            }),
            child: const Text('Easy Stack Reset'),
          ),
        ),
      ],
    );
  }

  void _soloEffect(int index) {
    setState(() {
      soloEffectIndex = index;
      showSurface = index == 0;
      showFloorCaustic = index == 1;
      showVolumetricLight = index == 2;
      showAmbientParticle = index == 3;
      showBubble = index == 4;
    });
  }

  String get _soloEffectName => switch (soloEffectIndex) {
    0 => 'Surface Refraction · Deferred',
    1 => 'Floor Caustic',
    2 => 'Volumetric Light',
    3 => 'Ambient Particle',
    4 => 'Bubble',
    _ => 'Easy Stack · Composite',
  };

  Widget _fullLivePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9CDF9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Full Live Preview' + (soloEffectIndex == null ? '' : ' · SOLO $_soloEffectName'),
            style: TextStyle(color: widget.fg, fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            soloEffectIndex == null
                ? 'Approved Base + 현재 ON Effect 전체 합성'
                : '현재는 Approved Base + $_soloEffectName 단독 표시 중',
            style: TextStyle(color: widget.muted, fontSize: 10.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _runtimeEffectPreview(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _runtimeEffectPreview() {
    return AspectRatio(
      aspectRatio: .67,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(_shallowClearBase.runtimePath!, fit: BoxFit.cover, gaplessPlayback: true),
            if (showSurface)
              CustomPaint(
                painter: SurfaceRefractionFieldPainter(
                  profile: selected.profile,
                  animation: _surfaceClock,
                  intensity: intensity,
                ),
              ),
            if (showVolumetricLight)
              CustomPaint(
                painter: VolumetricLightPainter(
                  animation: selectedVolumetric == 0
                      ? _broadSunbeamClock : _surfaceClock,
                  profile: _volumetricProfiles[selectedVolumetric],
                ),
              ),
            if (showFloorCaustic)
              CustomPaint(painter: FloorCausticPainter(animation: _surfaceClock)),
            if (showAmbientParticle)
              CustomPaint(painter: AmbientParticlePainter(animation: _surfaceClock)),
            if (showBubble)
              CustomPaint(painter: BubblePainter(animation: _surfaceClock)),
          ],
        ),
      ),
    );
  }

  Widget _compositeStep() {
    return _sectionCard(
      key: const ValueKey('background-composite-step'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
            '03 · 합성 QA',
            'Base Only ↔ Full Composite · 승인 Effect 전체 검수',
            'Waiting',
          ),
          const SizedBox(height: 16),
          _lockedStage(
            '레이어 효과 승인 후 활성화',
            'Surface / Floor Caustic / Light / Ambient / Bubble을 하나씩 승인한 뒤 '
                '전체 합성과 실제 Locked Shape 6·9·12개 조건을 검수합니다.',
          ),
        ],
      ),
    );
  }

  Widget _finalStep() {
    return _sectionCard(
      key: const ValueKey('background-final-step'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
            '04 · Final',
            'Production Master · Runtime Asset · Manifest · QA',
            'Waiting',
          ),
          const SizedBox(height: 16),
          _lockedStage(
            '합성 QA 통과 후 활성화',
            '사용자 승인 전에는 Final / Locked / Active로 승격하지 않습니다. '
                '승격 후 수정은 기존 파일 덮어쓰기가 아니라 새 Version으로 진행합니다.',
          ),
        ],
      ),
    );
  }

  Widget _notStartedBody() {
    final item = backgrounds[selectedBackground];
    return _sectionCard(
      key: ValueKey('background-not-started-' + selectedBackground.toString()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
            item.$1 + ' · ' + item.$2,
            '동일 Production Step 구조 적용',
            'Not Started',
          ),
          const SizedBox(height: 14),
          _lockedStage(
            '아직 제작 시작 전',
            '01 배경 이미지 선정부터 시작하며, 투명한 얕은 바다 파일럿에서 '
                '검증된 공정을 그대로 적용합니다.',
          ),
        ],
      ),
    );
  }

  Widget _approvedBasePreview({bool showBadge = false}) {
    return AspectRatio(
      aspectRatio: .67,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _shallowClearBase.runtimePath!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
            if (showBadge)
              Positioned(
                left: 10,
                top: 10,
                child: _previewBadge('APPROVED BASE'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stepHeader(String title, String subtitle, String status) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: widget.fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: widget.muted,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _statusBadge(status, status != 'Waiting' && status != 'Not Started'),
      ],
    );
  }

  Widget _lockedStage(String title, String detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.muted.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.muted.withValues(alpha: .12)),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline_rounded, color: widget.muted),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.fg,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.muted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({Key? key, required Widget child}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E0E8)),
      ),
      child: child,
    );
  }

  Widget _navChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFECE5FF)
              : enabled
                  ? widget.card
                  : widget.muted.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected
                ? const Color(0xFF7655C9)
                : widget.muted.withValues(alpha: .20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? widget.fg : widget.muted,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFEAF7EF)
            : widget.muted.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF356C49) : widget.muted,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: widget.muted,
        fontSize: 9.5,
        letterSpacing: .7,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: TextStyle(
                color: widget.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: widget.fg,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewBadge(String text) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .90),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF34313B),
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _BackgroundSafeZonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final safe = Rect.fromLTWH(
      size.width * .02381,
      size.height * .10,
      size.width * .95238,
      size.height * .80,
    );

    final shade = Paint()..color = Colors.black.withValues(alpha: .12);
    final outer = Path()..addRect(Offset.zero & size);
    final inner = Path()..addRRect(RRect.fromRectAndRadius(safe, const Radius.circular(18)));
    final cut = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(cut, shade);

    final line = Paint()
      ..color = Colors.white.withValues(alpha: .88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(safe, const Radius.circular(18)),
      line,
    );

    final centerLine = Paint()
      ..color = Colors.white.withValues(alpha: .36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * .5, safe.top),
      Offset(size.width * .5, safe.bottom),
      centerLine,
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundSafeZonePainter oldDelegate) => false;
}

class JellyfishMultiColorExperiment extends StatelessWidget {
  const JellyfishMultiColorExperiment({
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
    const palettes = <({String name, List<Color> colors})>[
      (
        name: 'Original',
        colors: [Color(0xFF8FCBFF), Color(0xFFB7A8F2), Color(0xFFF2B7DD), Color(0xFFFFE8C8)],
      ),
      (
        name: 'Ocean Dream',
        colors: [Color(0xFF7FC8FF), Color(0xFFB8A7F2), Color(0xFFFFE7C7), Color(0xFF7098E8)],
      ),
      (
        name: 'Coral Dawn',
        colors: [Color(0xFFFF9FBA), Color(0xFFFFC5A8), Color(0xFFFFF0D2), Color(0xFFC88BE8)],
      ),
      (
        name: 'Moon Jelly',
        colors: [Color(0xFFA9D5FF), Color(0xFFC5B2F4), Color(0xFFF8ECFF), Color(0xFF7F91D8)],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          color: card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'Jellyfish Multi-Color · Experimental',
                subtitle:
                    'Palette Lab 하위의 독립 실험 기능입니다. Production Color / Signature Color와 분리하며, Master Geometry·Alpha·Motion은 변경하지 않습니다.',
                fg: fg,
                muted: muted,
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _ValueChip(label: 'Route', value: '?lab=palette&experiment=jellyfish-multicolor'),
                  _ValueChip(label: 'Scope', value: 'Jellyfish R4 only'),
                  _ValueChip(label: 'Status', value: 'POC / Candidate'),
                  _ValueChip(label: 'Production', value: 'NO'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Gate: Static Master LOCK → Color/Light decomposition → 4-region soft Weight Map → Multi-Color render → 58px QA → 별도 승인 후에만 공통 Color System 후보로 승격',
                style: TextStyle(color: muted, height: 1.45),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: () {
                    final query = Map<String, String>.from(Uri.base.queryParameters)
                      ..['lab'] = 'palette'
                      ..remove('experiment');
                    final next = Uri.base.replace(queryParameters: query);
                    SystemNavigator.routeInformationUpdated(uri: next, replace: true);
                  },
                  child: const Text('Palette Lab으로 돌아가기'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          color: card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'PoC Palette Set',
                subtitle:
                    '현재는 색 조합과 분류만 보존합니다. 실제 Jellyfish Master 파생 렌더는 Master LOCK 이후 durable asset으로 연결합니다.',
                fg: fg,
                muted: muted,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final palette in palettes)
                    Container(
                      width: 220,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: muted.withValues(alpha: 0.22)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            palette.name,
                            style: TextStyle(
                              color: fg,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (final color in palette.colors)
                                Padding(
                                  padding: const EdgeInsets.only(right: 7),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: fg.withValues(alpha: 0.08),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          color: card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'Separation Rule',
                subtitle: '이 실험이 Production Palette를 오염시키지 않도록 명시적으로 분리합니다.',
                fg: fg,
                muted: muted,
              ),
              const SizedBox(height: 10),
              Text(
                '• 일반 6색 / Aurora Sea Final에는 영향 없음\n'
                '• Jellyfish Authoritative Master 승격과 별개\n'
                '• Weight Map은 파생 실험 산출물이며 Geometry/Alpha Source가 아님\n'
                '• 사용자 승인 전 상품 Color 목록 / 비밀번호 identity에 등록 금지\n'
                '• 성공 시에만 Solid / Multi / Dynamic Signature 통합 Color System 후보로 별도 승격',
                style: TextStyle(color: muted, height: 1.55),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
