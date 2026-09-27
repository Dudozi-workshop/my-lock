import 'dart:convert';

import 'package:flutter/material.dart';

class SeaTurtleFrontFlipperRuntimeQaScreen extends StatelessWidget {
  const SeaTurtleFrontFlipperRuntimeQaScreen({super.key});

  static const _items = <_PaletteQaItem>[
    _PaletteQaItem(label: 'Pink', hex: '#FF8FD1', assetBase64: _pinkWebp),
    _PaletteQaItem(label: 'Blue', hex: '#79BFFF', assetBase64: _blueWebp),
    _PaletteQaItem(label: 'Yellow', hex: '#FFDA72', assetBase64: _yellowWebp),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Turtle · Front Flipper Runtime QA')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Outer front flipper · app palette runtime check',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Fixed geometry / pattern / shadow / highlight / outline · '
              'palette only · no ImageGen',
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
              'Review: 58 px legibility, outline continuity, pattern separation, '
              'highlight/shadow retention, alpha edge.',
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
                item.label + '  ' + item.hex,
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
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),
              ),
              const Center(child: Text('96 px inspection')),
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

  final List<int> bytes;
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
        filterQuality: FilterQuality.high,
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

const _pinkWebp =
    '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';

const _blueWebp =
    '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';

const _yellowWebp =
    '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';

