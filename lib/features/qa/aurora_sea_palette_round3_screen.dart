import 'package:flutter/material.dart';

import '../../lock_engine/models.dart';
import '../../lock_engine/raster_palette_clock.dart';
import '../../lock_engine/shape_spec/shape_spec_renderer.dart';

class AuroraSeaPaletteRound3Screen extends StatefulWidget {
  const AuroraSeaPaletteRound3Screen({super.key});

  @override
  State<AuroraSeaPaletteRound3Screen> createState() =>
      _AuroraSeaPaletteRound3ScreenState();
}

class _AuroraSeaPaletteRound3ScreenState
    extends State<AuroraSeaPaletteRound3Screen> {
  bool _dark = false;
  double? _frozenTime;

  static const _candidates = <_AuroraSpeedCandidate>[
    _AuroraSpeedCandidate(
      id: 'C01',
      name: 'B08 Base',
      periodSeconds: 8.0,
      note: 'Round 2 B08 그대로. 현재 비교 기준.',
    ),
    _AuroraSpeedCandidate(
      id: 'C02',
      name: 'Quick Signature',
      periodSeconds: 6.5,
      note: '짧게 화면을 지나가도 색 변화가 빨리 읽히도록 약간 가속.',
    ),
    _AuroraSpeedCandidate(
      id: 'C03',
      name: 'Fast Signature',
      periodSeconds: 5.5,
      note: '짧은 노출 시간에서도 오로라 체감을 더 강하게 확보한 안.',
    ),
  ];

  static Map<String, dynamic> _config(double periodSeconds) => {
        'period_seconds': periodSeconds,
        'palette': ['#91D5F4', '#66ADEB', '#8A9BEF', '#B7A9EC'],
        'mode': 'ribbon',
        'travel_x': 1.45,
        'travel_y': 0.86,
        'stops': [0.0, 0.18, 0.50, 0.82, 1.0],
      };

  @override
  Widget build(BuildContext context) {
    final bg = _dark ? const Color(0xFF17151F) : const Color(0xFFF5F6FA);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aurora Sea · Round 3 · Speed Refinement'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Round 2 선택 B08 Full Travel을 고정하고 속도만 비교합니다.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Palette / Ribbon / Travel / Fixed Finish / Geometry는 전부 잠금. 이번 변경 축은 period_seconds 하나뿐입니다.',
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
                        config: _config(candidate.periodSeconds),
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
            '검수 포인트: 화면에 짧게 보일 때 즉시 Aurora Sea로 읽히는지, 동시에 RGB/네온 효과처럼 조급해 보이지 않는지 확인합니다.',
          ),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.config,
    required this.background,
    required this.frozenTime,
  });

  final _AuroraSpeedCandidate candidate;
  final Map<String, dynamic> config;
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
                    '${candidate.periodSeconds.toStringAsFixed(1)}s',
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
              height: 190,
              color: background,
              alignment: Alignment.center,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: const Size(168, 168),
                  painter: _AuroraCandidatePainter(
                    config,
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
                    config,
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

class _AuroraSpeedCandidate {
  const _AuroraSpeedCandidate({
    required this.id,
    required this.name,
    required this.periodSeconds,
    required this.note,
  });

  final String id;
  final String name;
  final double periodSeconds;
  final String note;
}
