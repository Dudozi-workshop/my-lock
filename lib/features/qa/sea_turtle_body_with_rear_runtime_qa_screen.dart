import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../lock_engine/models.dart';
import '../../lock_engine/shape_spec/shape_spec.dart';

class SeaTurtleBodyWithRearRuntimeQaScreen extends StatelessWidget {
  const SeaTurtleBodyWithRearRuntimeQaScreen({super.key});

  static const _tones = <ShapeTone>[
    ShapeTone.pink,
    ShapeTone.blue,
    ShapeTone.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    final neutralBytes = base64Decode(_neutralWebp);
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Turtle · Body + Rear Runtime QA')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'body_with_rear · FULL REMAP v2 runtime check',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Neutral 512×512 runtime source + ShapeTone color remap · '
              'Geometry FINAL_v2 / Outline FINAL_v3 fixed · no ImageGen',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final tone in _tones)
                  _ToneQaCard(tone: tone, neutralBytes: neutralBytes),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Review: 58 px silhouette, major volume separation, outline continuity, '
              'alpha edge, palette dominance, and green-family residual.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToneQaCard extends StatelessWidget {
  const _ToneQaCard({required this.tone, required this.neutralBytes});

  final ShapeTone tone;
  final Uint8List neutralBytes;

  @override
  Widget build(BuildContext context) {
    final color = baseColorForTone(tone);
    return SizedBox(
      width: 260,
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
                  _RuntimeSample(bytes: neutralBytes, color: color, size: 58, dark: false),
                  const SizedBox(width: 10),
                  _RuntimeSample(bytes: neutralBytes, color: color, size: 58, dark: true),
                ],
              ),
              const SizedBox(height: 8),
              const Text('58 px · light / dark'),
              const SizedBox(height: 12),
              Center(
                child: _RuntimeSample(
                  bytes: neutralBytes,
                  color: color,
                  size: 96,
                  dark: false,
                ),
              ),
              const Center(child: Text('96 px inspection')),
              const SizedBox(height: 12),
              Center(
                child: _RuntimeSample(
                  bytes: neutralBytes,
                  color: color,
                  size: 160,
                  dark: true,
                ),
              ),
              const Center(child: Text('160 px reference scale')),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuntimeSample extends StatelessWidget {
  const _RuntimeSample({
    required this.bytes,
    required this.color,
    required this.size,
    required this.dark,
  });

  final Uint8List bytes;
  final Color color;
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
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.color),
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

const _neutralWebp = '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';
