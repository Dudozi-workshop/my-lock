import 'package:flutter/material.dart';

import '../../lock_engine/models.dart';
import '../../lock_engine/raster_palette_clock.dart';
import '../../lock_engine/shape_spec/shape_spec_renderer.dart';

class AuroraSeaPaletteRound2Screen extends StatefulWidget {
  const AuroraSeaPaletteRound2Screen({super.key});

  @override
  State<AuroraSeaPaletteRound2Screen> createState() =>
      _AuroraSeaPaletteRound2ScreenState();
}

class _AuroraSeaPaletteRound2ScreenState
    extends State<AuroraSeaPaletteRound2Screen> {
  bool _dark = false;
  double? _frozenTime;

  static const _candidates = <_AuroraCandidate>[
    _AuroraCandidate(
      id: 'B01',
      name: 'Deep Aurora Base',
      axis: 'CONTROL',
      note: 'Round 1 A08 그대로. 모든 비교의 기준.',
      config: {
        'period_seconds': 8,
        'palette': ['#91D5F4', '#66ADEB', '#8A9BEF', '#B7A9EC'],
        'mode': 'ribbon',
        'travel_x': 1.20,
        'travel_y': 0.72,
        'stops': [0.0, 0.18, 0.50, 0.82, 1.0],
      },
    ),
    _AuroraCandidate(
      id: 'B02',
      name: 'Soft Depth',
      axis: 'COLOR',
      note: 'A08의 깊이는 유지하고 명도 대비만 조금 낮춘 안.',
      config: {
        'period_seconds': 8,
        'palette': ['#9DD9F4', '#74B5EB', '#94A3EE', '#C0AFED'],
        'mode': 'ribbon',
        'travel_x': 1.20,
        'travel_y': 0.72,
        'stops': [0.0, 0.18, 0.50, 0.82, 1.0],
      },
    ),
    _AuroraCandidate(
      id: 'B03',
      name: 'Rich Depth',
      axis: 'COLOR',
      note: 'Blue/Violet 깊이만 한 단계 올려 존재감을 강화한 안.',
      config: {
        'period_seconds': 8,
        'palette': ['#84CFF2', '#56A5E6', '#7C8FEA', '#AA98E7'],
        'mode': 'ribbon',
        'travel_x': 1.20,
        'travel_y': 0.72,
        'stops': [0.0, 0.18, 0.50, 0.82, 1.0],
      },
    ),
    _AuroraCandidate(
      id: 'B04',
      name: 'Wide Ribbon',
      axis: 'BAND',
      note: '색 구간을 더 고르게 벌려 부드러운 넓은 띠로 보이게 한 안.',
      config: {
        'period_seconds': 8,
        'palette': ['#91D5F4', '#66ADEB', '#8A9BEF', '#B7A9EC'],
        'mode': 'ribbon',
        'travel_x': 1.20,
        'travel_y': 0.72,
        'stops': [0.0, 0.25, 0.50, 0.75, 1.0],
      },
    ),
    _AuroraCandidate(
      id: 'B05',
      name: 'Tight Ribbon',
      axis: 'BAND',
      note: '중심 색 전환을 응축해 오로라 띠가 조금 더 또렷한 안.',
      config: {
        'period_seconds': 8,
        'palette': ['#91D5F4', '#66ADEB', '#8A9BEF', '#B7A9EC'],
        'mode': 'ribbon',
        'travel_x': 1.20,
        'travel_y': 0.72,
        'stops': [0.0, 0.12, 0.50, 0.88, 1.0],
      },
    ),
    _AuroraCandidate(
      id: 'B06',
      name: 'Slow Current',
      axis: 'SPEED',
      note: '형태와 색은 그대로 두고 11초로 느려진 고급형 흐름.',
      config: {
        'period_seconds': 11,
        'palette': ['#91D5F4', '#66ADEB', '#8A9BEF', '#B7A9EC'],
        'mode': 'ribbon',
        'travel_x': 1.20,
        'travel_y': 0.72,
        'stops': [0.0, 0.18, 0.50, 0.82, 1.0],
      },
    ),
    _AuroraCandidate(
      id: 'B07',
      name: 'Calm Travel',
      axis: 'TRAVEL',
      note: '이동폭만 줄여 디테일이 더 안정적으로 남는 안.',
      config: {
        'period_seconds': 8,
        'palette': ['#91D5F4', '#66ADEB', '#8A9BEF', '#B7A9EC'],
        'mode': 'ribbon',
        'travel_x': 0.95,
        'travel_y': 0.54,
        'stops': [0.0, 0.18, 0.50, 0.82, 1.0],
      },
    ),
    _AuroraCandidate(
      id: 'B08',
      name: 'Full Travel',
      axis: 'TRAVEL',
      note: '이동폭만 키워 시그니처 색 변화가 가장 확실히 읽히는 안.',
      config: {
        'period_seconds': 8,
        'palette': ['#91D5F4', '#66ADEB', '#8A9BEF', '#B7A9EC'],
        'mode': 'ribbon',
        'travel_x': 1.45,
        'travel_y': 0.86,
        'stops': [0.0, 0.18, 0.50, 0.82, 1.0],
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = _dark ? const Color(0xFF17151F) : const Color(0xFFF5F6FA);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aurora Sea · Round 2 · A08 Refinement'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Round 1 선택 A08 Deep Aurora만 세분화합니다. Production Aurora는 변경하지 않습니다.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Round 2 원칙: 시각 언어는 고정하고 Color / Band / Speed / Travel 축을 하나씩만 조정합니다.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Dark'),
                selected: _dark,
                onSelected: (value) => setState(() => _dark = value),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _frozenTime = _frozenTime == null
                        ? RasterPaletteClock.instance.value
                        : null;
                  });
                },
                icon: Icon(
                  _frozenTime == null
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(
                  _frozenTime == null ? '색 변화 멈춤' : '색 변화 재개',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final candidate in _candidates)
                    SizedBox(
                      width: width,
                      child: _CandidateCard(
                        candidate: candidate,
                        background: bg,
                        frozenTime: _frozenTime,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Text(
            '이번에는 “A08보다 더 좋은지”만 보면 됩니다. 최종 2~3안을 남긴 뒤 Round 3에서 장점을 조합합니다.',
          ),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.background,
    required this.frozenTime,
  });

  final _AuroraCandidate candidate;
  final Color background;
  final double? frozenTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${candidate.id} · ${candidate.name}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    candidate.axis,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              candidate.note,
              style: const TextStyle(fontSize: 11.5, height: 1.25),
            ),
            const SizedBox(height: 8),
            Container(
              height: 170,
              color: background,
              alignment: Alignment.center,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: const Size(150, 150),
                  painter: _AuroraCandidatePainter(
                    candidate.config,
                    frozenTime: frozenTime,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '58px',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                CustomPaint(
                  size: const Size(58, 58),
                  painter: _AuroraCandidatePainter(
                    candidate.config,
                    frozenTime: frozenTime,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuroraCandidatePainter extends CustomPainter {
  _AuroraCandidatePainter(
    this.config, {
    required this.frozenTime,
  }) : super(repaint: RasterPaletteClock.instance);

  final Map<String, dynamic> config;
  final double? frozenTime;

  @override
  void paint(Canvas canvas, Size size) {
    ShapeSpecRenderer.paintToken(
      canvas,
      center: size.center(Offset.zero),
      radius: size.shortestSide * 0.43,
      token: const LockToken(
        shape: ShapeKind.seaTurtle,
        tone: ShapeTone.auroraSea,
      ),
      style: ShapeStyle.softBasic,
      opacity: 1,
      paletteTimeSeconds:
          frozenTime ?? RasterPaletteClock.instance.value,
      swimKey: null,
      auroraConfigOverride: config,
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraCandidatePainter oldDelegate) =>
      oldDelegate.config != config ||
      oldDelegate.frozenTime != frozenTime;
}

class _AuroraCandidate {
  const _AuroraCandidate({
    required this.id,
    required this.name,
    required this.axis,
    required this.note,
    required this.config,
  });

  final String id;
  final String name;
  final String axis;
  final String note;
  final Map<String, dynamic> config;
}
