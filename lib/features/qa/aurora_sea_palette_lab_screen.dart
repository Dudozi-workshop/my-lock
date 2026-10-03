import 'package:flutter/material.dart';

import '../../lock_engine/models.dart';
import '../../lock_engine/raster_palette_clock.dart';
import '../../lock_engine/shape_spec/shape_spec_registry.dart';
import '../../lock_engine/shape_spec/shape_spec_renderer.dart';

class AuroraSeaPaletteLabScreen extends StatefulWidget {
  const AuroraSeaPaletteLabScreen({super.key});

  @override
  State<AuroraSeaPaletteLabScreen> createState() =>
      _AuroraSeaPaletteLabScreenState();
}

class _AuroraSeaPaletteLabScreenState
    extends State<AuroraSeaPaletteLabScreen> {
  bool _dark = false;

  static const _candidates = <_AuroraCandidate>[
    _AuroraCandidate(
      id: 'A01',
      name: 'Current v2',
      note: '현재 기준. 넓은 대각선 드리프트.',
      config: {
        'period_seconds': 8,
        'palette': ['#A7D8F7', '#7FB8FF', '#9FA8F2', '#C7B6F3'],
        'mode': 'drift',
        'travel_x': 0.70,
        'travel_y': 0.42,
      },
    ),
    _AuroraCandidate(
      id: 'A02',
      name: 'Wide Drift',
      note: '이동폭을 키워 색 변화가 더 또렷함.',
      config: {
        'period_seconds': 8,
        'palette': ['#A7D8F7', '#7FB8FF', '#9FA8F2', '#C7B6F3'],
        'mode': 'drift',
        'travel_x': 1.10,
        'travel_y': 0.62,
      },
    ),
    _AuroraCandidate(
      id: 'A03',
      name: 'Slow Silk',
      note: '12초. 고급스럽고 잔잔한 실크 흐름.',
      config: {
        'period_seconds': 12,
        'palette': ['#B5E3F8', '#7FB8FF', '#9FA8F2', '#D1C2F5'],
        'mode': 'drift',
        'travel_x': 0.95,
        'travel_y': 0.50,
      },
    ),
    _AuroraCandidate(
      id: 'A04',
      name: 'Ocean Ribbon',
      note: '색 띠가 사선으로 지나가는 체감 강화.',
      config: {
        'period_seconds': 9,
        'palette': ['#A9E4F5', '#73BFF0', '#8FAAF4', '#C5B7F3'],
        'mode': 'ribbon',
        'travel_x': 1.05,
        'travel_y': 0.68,
        'stops': [0.0, 0.22, 0.52, 0.78, 1.0],
      },
    ),
    _AuroraCandidate(
      id: 'A05',
      name: 'Moon Tide',
      note: '보라 비중을 줄이고 청량한 바닷빛 중심.',
      config: {
        'period_seconds': 10,
        'palette': ['#B7E7F7', '#78C6F1', '#7EAEEF', '#B7B8F0'],
        'mode': 'horizontal',
        'travel_x': 1.00,
        'travel_y': 0.0,
      },
    ),
    _AuroraCandidate(
      id: 'A06',
      name: 'Pearl Veil',
      note: '아주 밝은 펄 베일 느낌. 저채도 고급형.',
      config: {
        'period_seconds': 11,
        'palette': ['#C6EBF8', '#9CCAF3', '#ADB7F1', '#D7CBF4'],
        'mode': 'vertical',
        'travel_x': 0.0,
        'travel_y': 0.95,
      },
    ),
    _AuroraCandidate(
      id: 'A07',
      name: 'Aurora Pulse',
      note: '전체 Hue가 천천히 호흡. 변화 인지가 가장 쉬움.',
      config: {
        'period_seconds': 9,
        'palette': ['#A7D8F7', '#7FB8FF', '#9FA8F2', '#C7B6F3'],
        'mode': 'breath',
      },
    ),
    _AuroraCandidate(
      id: 'A08',
      name: 'Deep Aurora',
      note: '명도 차를 조금 키워 시그니처 존재감 강화.',
      config: {
        'period_seconds': 8,
        'palette': ['#91D5F4', '#66ADEB', '#8A9BEF', '#B7A9EC'],
        'mode': 'ribbon',
        'travel_x': 1.20,
        'travel_y': 0.72,
        'stops': [0.0, 0.18, 0.50, 0.82, 1.0],
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = _dark ? const Color(0xFF17151F) : const Color(0xFFF5F6FA);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aurora Sea · Palette Lab · Round 1'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Production Aurora v2는 잠금 상태입니다. 아래 8안은 Lab override만 사용합니다.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Dark'),
                selected: _dark,
                onSelected: (value) => setState(() => _dark = value),
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
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Text(
            '1차 선택 기준: 색 변화 체감 → 디테일 보존 → 58px 가독성 → 시그니처 존재감.',
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
  });

  final _AuroraCandidate candidate;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${candidate.id} · ${candidate.name}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              candidate.note,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Container(
              height: 170,
              color: background,
              alignment: Alignment.center,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: const Size(150, 150),
                  painter: _AuroraCandidatePainter(candidate.config),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('58px'),
                const Spacer(),
                CustomPaint(
                  size: const Size(58, 58),
                  painter: _AuroraCandidatePainter(candidate.config),
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
  _AuroraCandidatePainter(this.config)
      : super(repaint: RasterPaletteClock.instance);

  final Map<String, dynamic> config;

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
      paletteTimeSeconds: RasterPaletteClock.instance.value,
      swimKey: null,
      auroraConfigOverride: config,
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraCandidatePainter oldDelegate) =>
      oldDelegate.config != config;
}

class _AuroraCandidate {
  const _AuroraCandidate({
    required this.id,
    required this.name,
    required this.note,
    required this.config,
  });

  final String id;
  final String name;
  final String note;
  final Map<String, dynamic> config;
}
