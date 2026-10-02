import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../lock_engine/models.dart';
import '../../lock_engine/shape_spec/shape_spec.dart';
import 'sea_turtle_body_with_rear_runtime_qa_screen.dart';
import 'sea_turtle_front_flipper_far_runtime_qa_screen.dart';
import 'sea_turtle_front_flipper_runtime_qa_screen.dart';
import 'sea_turtle_shell_runtime_qa_screen.dart';
import 'sea_turtle_underbelly_runtime_qa_screen.dart';

class SeaTurtleWholeRuntimeQaScreen extends StatelessWidget {
  const SeaTurtleWholeRuntimeQaScreen({super.key});

  static const _tones = <ShapeTone>[
    ShapeTone.pink,
    ShapeTone.blue,
    ShapeTone.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Turtle v3 · Whole-turtle QA')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Static F0 · Final / Locked / Active parts only',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'QA only: seam · double outline · attachment continuity · '
              'palette/material continuity · 58 px readability · alpha edge. '
              'No geometry or material ownership edits.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final tone in _tones) _WholeToneCard(tone: tone),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Render order: Far flipper → Body/Rear → Shell → Underbelly → Near flipper. '
              '58 px is the target runtime read; 116/232 px are inspection-only enlargements '
              'of the same assembled F0 composition.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WholeToneCard extends StatelessWidget {
  const _WholeToneCard({required this.tone});

  final ShapeTone tone;

  @override
  Widget build(BuildContext context) {
    final color = baseColorForTone(tone);
    return SizedBox(
      width: 330,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tone.name}  #${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _QaTile(tone: tone, size: 58, dark: false),
                  const SizedBox(width: 10),
                  _QaTile(tone: tone, size: 58, dark: true),
                ],
              ),
              const SizedBox(height: 8),
              const Text('58 px · light / dark'),
              const SizedBox(height: 12),
              Center(child: _QaTile(tone: tone, size: 116, dark: false)),
              const Center(child: Text('116 px · seam inspection')),
              const SizedBox(height: 12),
              Center(child: _QaTile(tone: tone, size: 232, dark: true)),
              const Center(child: Text('232 px · outline / alpha inspection')),
            ],
          ),
        ),
      ),
    );
  }
}

class _QaTile extends StatelessWidget {
  const _QaTile({
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
      child: _WholeTurtleF0(tone: tone, size: size),
    );
  }
}

class _WholeTurtleF0 extends StatelessWidget {
  const _WholeTurtleF0({required this.tone, required this.size});

  final ShapeTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final toneName = tone.name;
    final color = baseColorForTone(tone);
    final far = seaTurtleFrontFlipperFarNeutralRuntimeBytes();
    final body = seaTurtleBodyWithRearNeutralRuntimeBytes();
    final shell = seaTurtleShellRuntimeBytes(toneName);
    final belly = seaTurtleUnderbellyNeutralRuntimeBytes();
    final near = seaTurtleFrontFlipperNearRuntimeBytes(toneName);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          _NeutralLayer(bytes: far, color: color),
          _NeutralLayer(bytes: body, color: color),
          _BakedLayer(bytes: shell),
          _NeutralLayer(bytes: belly, color: color),
          _BakedLayer(bytes: near, pixelated: true),
        ],
      ),
    );
  }
}

class _NeutralLayer extends StatelessWidget {
  const _NeutralLayer({required this.bytes, required this.color});

  final Uint8List bytes;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.color),
      child: Image.memory(
        bytes,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      ),
    );
  }
}

class _BakedLayer extends StatelessWidget {
  const _BakedLayer({required this.bytes, this.pixelated = false});

  final Uint8List bytes;
  final bool pixelated;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      fit: BoxFit.contain,
      filterQuality: pixelated ? FilterQuality.none : FilterQuality.high,
      gaplessPlayback: true,
    );
  }
}
