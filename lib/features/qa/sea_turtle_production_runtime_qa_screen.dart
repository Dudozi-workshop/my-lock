import 'package:flutter/material.dart';

import '../../lock_engine/models.dart';
import '../../lock_engine/shape_painter.dart';

class SeaTurtleProductionRuntimeQaScreen extends StatelessWidget {
  const SeaTurtleProductionRuntimeQaScreen({super.key});

  static const _tones = <ShapeTone>[
    ShapeTone.pink,
    ShapeTone.blue,
    ShapeTone.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Turtle v3 · Production Runtime')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Shared LockTokenPainter / Raster Shape Registry',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Locked whole runtime58 source · runtime palette only · '
              'no geometry/material edits',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final tone in _tones) _ToneCard(tone: tone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToneCard extends StatelessWidget {
  const _ToneCard({required this.tone});

  final ShapeTone tone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tone.label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Sample(tone: tone, size: 58, dark: false),
                  const SizedBox(width: 10),
                  _Sample(tone: tone, size: 58, dark: true),
                ],
              ),
              const SizedBox(height: 8),
              const Text('58 px · actual shared renderer'),
              const SizedBox(height: 14),
              Center(child: _Sample(tone: tone, size: 116, dark: false)),
              const Center(child: Text('116 px inspection only')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sample extends StatelessWidget {
  const _Sample({
    required this.tone,
    required this.size,
    required this.dark,
  });

  final ShapeTone tone;
  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF171A20) : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        size: Size.square(size),
        painter: LockTokenPainter(
          LockToken(shape: ShapeKind.seaTurtle, tone: tone),
        ),
      ),
    );
  }
}
