import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

Uint8List seaTurtleFrontFlipperNearRuntimeBytes(String tone) {
  switch (tone) {
    case 'pink':
      return base64Decode(_pinkPng);
    case 'blue':
      return base64Decode(_bluePng);
    case 'yellow':
      return base64Decode(_yellowPng);
    default:
      throw ArgumentError.value(tone, 'tone', 'Unsupported Sea Turtle near flipper tone');
  }
}

class SeaTurtleFrontFlipperRuntimeQaScreen extends StatelessWidget {
  const SeaTurtleFrontFlipperRuntimeQaScreen({super.key});

  static const _items = <_PaletteQaItem>[
    _PaletteQaItem(label: 'Pink', hex: '#FF8FD1', assetBase64: _pinkPng),
    _PaletteQaItem(label: 'Blue', hex: '#79BFFF', assetBase64: _bluePng),
    _PaletteQaItem(label: 'Yellow', hex: '#FFDA72', assetBase64: _yellowPng),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sea Turtle · Front Flipper Runtime QA v2'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Outer front flipper · Geometry v3 / Palette QA v2',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Geometry v3 locked · Material QA v2 locked · Palette QA v2 locked · '
              'runtime58 assets only · no ImageGen',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in _items) _PaletteQaCard(item: item),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Review: 58 px light/dark legibility, exterior outline continuity, '
              'pattern separation, highlight/shadow retention, alpha edge. '
              '96 px is an enlarged inspection of the exact runtime58 bitmap.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteQaCard extends StatelessWidget {
  const _PaletteQaCard({required this.item});

  final _PaletteQaItem item;

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(item.assetBase64);
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.label}  ${item.hex}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _RuntimeSample(bytes: bytes, size: 58, dark: false),
                  const SizedBox(width: 10),
                  _RuntimeSample(bytes: bytes, size: 58, dark: true),
                ],
              ),
              const SizedBox(height: 8),
              const Text('58 px · light / dark'),
              const SizedBox(height: 12),
              Center(
                child: Image.memory(
                  bytes,
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  gaplessPlayback: true,
                ),
              ),
              const Center(child: Text('96 px · runtime bitmap inspection')),
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
    required this.size,
    required this.dark,
  });

  final Uint8List bytes;
  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF171A20) : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
      ),
    );
  }
}

class _PaletteQaItem {
  const _PaletteQaItem({
    required this.label,
    required this.hex,
    required this.assetBase64,
  });

  final String label;
  final String hex;
  final String assetBase64;
}

const _pinkPng = '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';
const _bluePng = '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';
const _yellowPng = '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';
