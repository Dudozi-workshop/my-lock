import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../lock_engine/models.dart';
import '../../lock_engine/shape_spec/shape_spec.dart';

class SeaTurtleFrontFlipperFarRuntimeQaScreen extends StatelessWidget {
  const SeaTurtleFrontFlipperFarRuntimeQaScreen({super.key});

  static const _tones = <ShapeTone>[
    ShapeTone.pink,
    ShapeTone.blue,
    ShapeTone.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(_neutralWebp);
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Turtle · Front Flipper Far Runtime QA')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'front_flipper_far · FINAL v1 runtime check',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Geometry FINAL_v4 · Outline Final v1 · deterministic material decomposition · no ImageGen',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final tone in _tones)
                  _ToneQaCard(tone: tone, neutralBytes: bytes),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Review: 58 px silhouette, pattern separation, shadow/highlight retention, '
              'outline contrast, alpha edge, and light/dark background legibility.',
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
    final hex = color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();

    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${tone.name}  #$hex', style: Theme.of(context).textTheme.titleMedium),
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
              Center(child: _RuntimeSample(bytes: neutralBytes, color: color, size: 96, dark: false)),
              const Center(child: Text('96 px inspection')),
              const SizedBox(height: 12),
              Center(child: _RuntimeSample(bytes: neutralBytes, color: color, size: 160, dark: true)),
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
