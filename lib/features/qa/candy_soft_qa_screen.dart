import 'package:flutter/material.dart';
import '../shell/root_shell.dart';
import '../../lock_engine/models.dart';
import '../../lock_engine/effects.dart';
import '../../lock_engine/floating_preview.dart';
import '../../lock_engine/shape_painter.dart';
import '../customize/shape_style/widgets/shape_choice_card.dart';

class CandySoftQaScreen extends StatelessWidget {
  const CandySoftQaScreen({super.key});
  static const pairs = [
    LockToken(shape: ShapeKind.circle, tone: ShapeTone.pink),
    LockToken(shape: ShapeKind.triangle, tone: ShapeTone.yellow),
    LockToken(shape: ShapeKind.square, tone: ShapeTone.blue),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Candy Soft · Runtime Candidate')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('승인 시안 원본 · 실제 LockTokenPainter\n'
        '분홍 원 / 노란 세모 / 파란 네모만 새 시안. 다른 색은 기존 표현.\n'
        '색 변경·알파 정리·256 Master·Android 실기기 검증 전.'),
      TextButton(onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const RootShell())),
        child: const Text('앱으로 확인하기')),
      Wrap(spacing: 8, children: [for (final token in pairs)
        SizedBox(width: 110, height: 130, child: ShapeChoiceCard(
          kind: token.shape, previewTone: token.tone,
          label: token.shape.label, selected: true, onTap: () {},
        )),
      ]),
      for (final dark in [false, true]) ...[
        Container(color: dark ? const Color(0xff171929) : const Color(0xfffaf9ff),
          padding: const EdgeInsets.all(12), child: Column(children: [
            for (final size in [58.0, 72.0, 96.0, 160.0])
              Padding(padding: const EdgeInsets.symmetric(vertical: 12),
                child: Wrap(spacing: 8, children: [for (final token in pairs)
                  CustomPaint(size: Size.square(size), painter: LockTokenPainter(token)),
                ])),
          ])),
        for (final token in pairs)
          Container(height: 280, color: dark ? const Color(0xff171929) : const Color(0xfffaf9ff),
            child: FloatingPreview(selectedShapes: {token.shape},
              selectedTones: {token.tone}, objectCount: 6,
              movementStyle: MovementStyle.floating, popStyle: PopStyle.basicPop)),
      ],
    ]),
  );
}
