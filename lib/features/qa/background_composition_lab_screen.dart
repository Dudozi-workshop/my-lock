import 'package:flutter/material.dart';

import '../../lock_engine/effects.dart';
import '../../lock_engine/floating_preview.dart';
import '../../lock_engine/models.dart';

enum CompositionCandidate {
  openWater('A', 'Open Water', '넓은 중앙 Play Field · 해저 낮음'),
  lowHorizon('B', 'Low Horizon', '해저를 더 낮춰 수중 여백 확대'),
  softFrame('C', 'Soft Frame', '가장자리만 약하게 감싸는 구조');

  const CompositionCandidate(this.code, this.label, this.note);
  final String code;
  final String label;
  final String note;
}

class BackgroundCompositionLabScreen extends StatefulWidget {
  const BackgroundCompositionLabScreen({super.key});

  @override
  State<BackgroundCompositionLabScreen> createState() => _BackgroundCompositionLabScreenState();
}

class _BackgroundCompositionLabScreenState extends State<BackgroundCompositionLabScreen> {
  CompositionCandidate selected = CompositionCandidate.openWater;
  bool showRuntime = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
      appBar: AppBar(title: const Text('Background Lab · Gate 01')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 32),
        children: [
          const Text('Common · 투명바다 / Composition',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('A/B/C를 같은 Runtime Shape 조건에서 한 화면으로 비교합니다. 지금은 공간 구조만 평가합니다.'),
          const SizedBox(height: 14),
          _gateStrip(),
          const SizedBox(height: 18),
          _comparisonBoard(),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: Text('실제 Runtime Shape', style: TextStyle(fontWeight: FontWeight.w700))),
            Switch(value: showRuntime, onChanged: (value) => setState(() => showRuntime = value)),
          ]),
          const SizedBox(height: 14),
          const Text('Composition Candidates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final candidate in CompositionCandidate.values)
            Padding(padding: const EdgeInsets.only(bottom: 10), child: _candidateTile(candidate)),
          const SizedBox(height: 8),
          const Text('선택은 Candidate 전환만 수행합니다. 사용자 승인 전 LOCK 또는 Production 승격하지 않습니다.',
              style: TextStyle(fontSize: 12, color: Color(0xFF77717F))),
        ],
      ),
    );
  }

  Widget _gateStrip() {
    const gates = [
      ('01', 'Composition', true), ('02', 'Color', false), ('03', 'Light', false),
      ('04', 'Depth', false), ('05', 'Ambient', false), ('06', 'Environment', false),
      ('07', 'Motion', false), ('08', 'Final QA', false),
    ];
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: gates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = gates[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: item.$3 ? const Color(0xFFECE5FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: item.$3 ? const Color(0xFF7655C9) : const Color(0xFFE4E0E8)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('GATE '+item.$1, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
              Text(item.$2, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
          );
        },
      ),
    );
  }


  Widget _comparisonBoard() {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 760 ? 3 : 1;
      final width = columns == 3 ? (constraints.maxWidth - 20) / 3 : constraints.maxWidth;
      return Wrap(
        spacing: 10,
        runSpacing: 12,
        children: [
          for (final candidate in CompositionCandidate.values)
            SizedBox(width: width, child: _preview(candidate)),
        ],
      );
    });
  }

  Widget _preview(CompositionCandidate candidate) {
    final active = selected == candidate;
    return GestureDetector(
      onTap: () => setState(() => selected = candidate),
      child: AspectRatio(
        aspectRatio: 0.72,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: CompositionPainter(candidate))),
            if (showRuntime)
              const Positioned.fill(
                child: FloatingPreview(
                  selectedShapes: {ShapeKind.seaTurtle},
                  selectedTones: {ShapeTone.blue},
                  movementStyle: MovementStyle.floating,
                  popStyle: PopStyle.basicPop,
                  style: ShapeStyle.softBasic,
                  objectCount: 6,
                  speed: FloatingSpeed.normal,
                  movementArea: MovementArea.full,
                ),
              ),
            Positioned(top: 12, left: 12, child: _badge(candidate.code+' · '+candidate.label)),
            if (active)
              const Positioned(top: 12, right: 12, child: Icon(Icons.check_circle_rounded, color: Color(0xFF7655C9))),
          ]),
        ),
      ),
    );
  }

  Widget _candidateTile(CompositionCandidate candidate) {
    final active = selected == candidate;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => selected = candidate),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: active ? const Color(0xFF7655C9) : const Color(0xFFE4E0E8), width: active ? 2 : 1),
          ),
          child: Row(children: [
            SizedBox(
              width: 70, height: 92,
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: CustomPaint(painter: CompositionPainter(candidate))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(candidate.code+' · '+candidate.label, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(candidate.note, style: const TextStyle(fontSize: 12, color: Color(0xFF77717F))),
            ])),
            if (active) const Icon(Icons.check_circle_rounded, color: Color(0xFF7655C9)),
          ]),
        ),
      ),
    );
  }

  Widget _badge(String text) => DecoratedBox(
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.86), borderRadius: BorderRadius.circular(99)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
    ),
  );
}

class CompositionPainter extends CustomPainter {
  const CompositionPainter(this.candidate);
  final CompositionCandidate candidate;

  @override
  void paint(Canvas canvas, Size size) {
    final water = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFCFF4F2), Color(0xFFAEDFE3), Color(0xFF8CC8D2)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, water);

    final surface = Paint()..color = Colors.white.withValues(alpha: 0.34);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .5, -size.height * .01), width: size.width * 1.3, height: size.height * .16), surface);

    final sand = Paint()..color = const Color(0xFFEADFCB).withValues(alpha: .72);
    final horizon = switch (candidate) {
      CompositionCandidate.openWater => .84,
      CompositionCandidate.lowHorizon => .91,
      CompositionCandidate.softFrame => .87,
    };
    final path = Path()
      ..moveTo(0, size.height * horizon)
      ..quadraticBezierTo(size.width * .45, size.height * (horizon - .025), size.width, size.height * (horizon + .01))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, sand);

    if (candidate == CompositionCandidate.softFrame) {
      final edge = Paint()..color = const Color(0xFF83BFC4).withValues(alpha: .22);
      canvas.drawOval(Rect.fromLTWH(-size.width * .2, size.height * .58, size.width * .38, size.height * .35), edge);
      canvas.drawOval(Rect.fromLTWH(size.width * .82, size.height * .62, size.width * .35, size.height * .31), edge);
    }
  }

  @override
  bool shouldRepaint(covariant CompositionPainter oldDelegate) => oldDelegate.candidate != candidate;
}
