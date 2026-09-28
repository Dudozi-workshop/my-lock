import 'package:flutter/material.dart';

class SeaTurtleShellRuntimeQaScreen extends StatelessWidget {
  const SeaTurtleShellRuntimeQaScreen({super.key});

  static const _items = <_ShellRuntimeItem>[
    _ShellRuntimeItem(
      label: 'Pink',
      hex: '#FF8FD1',
      assetPath:
          'assets/shape_masters/drop01/sea_turtle_v3/shell/runtime/'
          'sea_turtle_v3_shell_palette_pink_runtime_v1_512.webp',
    ),
    _ShellRuntimeItem(
      label: 'Blue',
      hex: '#79BFFF',
      assetPath:
          'assets/shape_masters/drop01/sea_turtle_v3/shell/runtime/'
          'sea_turtle_v3_shell_palette_blue_runtime_v1_512.webp',
    ),
    _ShellRuntimeItem(
      label: 'Yellow',
      hex: '#FFDA72',
      assetPath:
          'assets/shape_masters/drop01/sea_turtle_v3/shell/runtime/'
          'sea_turtle_v3_shell_palette_yellow_runtime_v1_512.webp',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Turtle · Shell Runtime QA')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Shell · approved 512×512 runtime asset',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Canonical source: 2048×2048 · runtime export: lossless WebP · '
              'palette only · no ImageGen',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in _items) _ShellRuntimeCard(item: item),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Review: 58 px legibility, 96 px detail retention, 160 px '
              'reference scale, alpha edge, outline continuity, and no '
              'non-shell pixels.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellRuntimeCard extends StatelessWidget {
  const _ShellRuntimeCard({required this.item});

  final _ShellRuntimeItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
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
                  _RuntimeSample(item: item, size: 58, dark: false),
                  const SizedBox(width: 10),
                  _RuntimeSample(item: item, size: 58, dark: true),
                ],
              ),
              const SizedBox(height: 8),
              const Text('58 px · light / dark'),
              const SizedBox(height: 12),
              Center(child: _RuntimeSample(item: item, size: 96, dark: false)),
              const Center(child: Text('96 px inspection')),
              const SizedBox(height: 12),
              Center(child: _RuntimeSample(item: item, size: 160, dark: true)),
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
    required this.item,
    required this.size,
    required this.dark,
  });

  final _ShellRuntimeItem item;
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
      child: Image.asset(
        item.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      ),
    );
  }
}

class _ShellRuntimeItem {
  const _ShellRuntimeItem({
    required this.label,
    required this.hex,
    required this.assetPath,
  });

  final String label;
  final String hex;
  final String assetPath;
}
