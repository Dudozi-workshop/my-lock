import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../lock_engine/models.dart';
import '../../lock_engine/shape_spec/shape_spec.dart';
import '../../lock_engine/shape_spec/shape_spec_registry.dart';
import '../../lock_engine/shape_spec/shape_spec_renderer.dart';

class StarfishRound1LabScreen extends StatelessWidget {
  const StarfishRound1LabScreen({super.key});

  static const _candidates = <_StarfishCandidate>[
    _StarfishCandidate('S01', 'Balanced Soft', 0.43, 0.22, 10.0, 0.0),
    _StarfishCandidate('S02', 'Baby Wide', 0.40, 0.27, 12.0, -5.0),
    _StarfishCandidate('S03', 'Slim Natural', 0.45, 0.18, 9.0, 3.0),
    _StarfishCandidate('S04', 'Round Chubby', 0.39, 0.30, 13.0, 0.0),
    _StarfishCandidate('S05', 'Organic Lean', 0.44, 0.21, 10.5, 8.0, asymmetry: 0.055),
    _StarfishCandidate('S06', 'Compact Icon', 0.38, 0.25, 11.5, -2.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
      appBar: AppBar(title: const Text('Starfish · Round 1 · Candidate')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Drop 01 · 불가사리', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Silhouette Gate · Production 미반영 · 같은 Soft Basic renderer 비교'),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250, mainAxisExtent: 286, crossAxisSpacing: 14, mainAxisSpacing: 14),
            itemCount: _candidates.length,
            itemBuilder: (context, index) => _CandidateCard(candidate: _candidates[index]),
          ),
          const SizedBox(height: 20),
          const Text('확인 포인트 · 58 px 식별성 / 팔 길이·두께 / 중심부 비율 / MY LOCK Soft 톤 적합성',
            style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.candidate});
  final _StarfishCandidate candidate;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${candidate.code} · ${candidate.label}', style: const TextStyle(fontWeight: FontWeight.w900)),
          const Spacer(),
          Center(child: CustomPaint(size: const Size.square(170), painter: _StarfishPainter(candidate, 58Mode: false))),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('58 px  ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            CustomPaint(size: const Size.square(58), painter: _StarfishPainter(candidate, 58Mode: true)),
          ]),
        ]),
      ),
    );
  }
}

class _StarfishPainter extends CustomPainter {
  _StarfishPainter(this.candidate, {required this.58Mode});
  final _StarfishCandidate candidate;
  final bool 58Mode;

  @override
  void paint(Canvas canvas, Size size) {
    final base = ShapeSpecRegistry.instance.resolve(ShapeStyle.softBasic, ShapeKind.triangle);
    final spec = ShapeSpec(
      styleId: base.shape.styleId,
      shapeId: 'starfish_${candidate.code.toLowerCase()}',
      version: 1,
      body: ShapeGeometrySpec('roundedPolygon', {
        'kind': 'roundedPolygon',
        'cornerRadius': candidate.corner,
        'points': candidate.points,
      }),
      surface: const ShapeSurfaceSpec(kind: 'radial', centerX: -0.34, centerY: -0.42, radius: 1.2, stops: [0.0, 0.34, 0.76, 1.0]),
      rotationMode: ShapeRotationMode.rotateWithObject,
      layers: [
        const ShapeLayerSpec(
          id: 'light', role: ShapeLayerRole.light, blend: ShapeLayerBlend.softLight,
          opacity: 0.20, blur: 4.2, rotationDeg: -38,
          geometry: ShapeGeometrySpec('ellipse', {'kind':'ellipse','cx':35,'cy':34,'rx':25,'ry':12}),
        ),
        const ShapeLayerSpec(
          id: 'shade', role: ShapeLayerRole.shade, blend: ShapeLayerBlend.multiply,
          opacity: 0.10, blur: 5.2, rotationDeg: 28,
          geometry: ShapeGeometrySpec('ellipse', {'kind':'ellipse','cx':65,'cy':67,'rx':28,'ry':17}),
        ),
      ],
      shadow: const ShapeShadowSpec(opacity: 0.035, elevation: 1.7, offsetX: 0, offsetY: 0.8),
    );
    ShapeSpecRenderer.paintToken(
      canvas,
      center: size.center(Offset.zero),
      radius: size.shortestSide * 0.43,
      token: const LockToken(shape: ShapeKind.triangle, tone: ShapeTone.coralPink),
      style: ShapeStyle.softBasic,
      opacity: 1,
      useCandySoft: false,
      bundleOverride: ShapeSpecBundle(style: base.style, shape: spec),
    );
  }

  @override
  bool shouldRepaint(covariant _StarfishPainter oldDelegate) => oldDelegate.candidate != candidate || oldDelegate.58Mode != 58Mode;
}

class _StarfishCandidate {
  const _StarfishCandidate(this.code, this.label, this.outer, this.inner, this.corner, this.rotationDeg, {this.asymmetry = 0});
  final String code;
  final String label;
  final double outer;
  final double inner;
  final double corner;
  final double rotationDeg;
  final double asymmetry;

  List<List<double>> get points {
    final result = <List<double>>[];
    for (var i = 0; i < 10; i++) {
      final arm = i ~/ 2;
      final isOuter = i.isEven;
      final angle = (-90 + rotationDeg + i * 36) * math.pi / 180;
      var radius = isOuter ? outer : inner;
      if (isOuter && asymmetry != 0) {
        radius *= 1 + asymmetry * math.sin(arm * 2.17 + 0.7);
      }
      result.add([50 + math.cos(angle) * radius * 100, 50 + math.sin(angle) * radius * 100]);
    }
    return result;
  }
}
