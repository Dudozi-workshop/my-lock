import 'package:flutter/material.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_renderer.dart';
import 'package:my_lock/dev/style_lab/style_lab_route.dart';
import 'package:my_lock/dev/style_lab/style_lab_shell.dart';

import 'soft_basic_candidates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShapeSpecRegistry.instance.load();
  runApp(const SoftBasicStyleLabApp());
}

class SoftBasicStyleLabApp extends StatelessWidget {
  const SoftBasicStyleLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK · Style Lab',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF7257F5),
      ),
      home: StyleLabShell(
        domains: const [
          StyleLabDomain(
            id: 'soft-basic',
            label: 'Soft Basic',
            builder: _buildSoftBasicDomain,
          ),
        ],
        initialStyleId: resolveStyleLabInitialStyle(
          fallbackStyleId: 'soft-basic',
        ),
        onStyleChanged: syncStyleLabUrl,
        labMarker: 'LAB 001 · Round 1 Direction · 8 Candidates · APP EXACT',
      ),
    );
  }
}

Widget _buildSoftBasicDomain(
  BuildContext context,
  StyleLabTheme theme,
) {
  return _SoftBasicDomain(
    theme: theme,
  );
}

class _SoftBasicDomain extends StatefulWidget {
  const _SoftBasicDomain({required this.theme});

  final StyleLabTheme theme;

  @override
  State<_SoftBasicDomain> createState() => _SoftBasicDomainState();
}

class _SoftBasicDomainState extends State<_SoftBasicDomain> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selected = softBasicRound1Candidates[selectedIndex];
    final card = widget.theme.card;
    final fg = widget.theme.foreground;
    final muted = widget.theme.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980 ? 4 : 2;
            const gap = 8.0;
            final itemWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0;
                    i < softBasicRound1Candidates.length;
                    i++)
                  SizedBox(
                    width: itemWidth,
                    child: _CandidateCard(
                      candidate: softBasicRound1Candidates[i],
                      selected: i == selectedIndex,
                      card: card,
                      fg: fg,
                      muted: muted,
                      onTap: () => setState(() => selectedIndex = i),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _DetailPanel(
          candidate: selected,
          card: card,
          fg: fg,
          muted: muted,
        ),
      ],
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.candidate, required this.selected, required this.card, required this.fg, required this.muted, required this.onTap});
  final SoftBasicCandidate candidate;
  final bool selected;
  final Color card, fg, muted;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    const shapes = [ShapeKind.circle, ShapeKind.square, ShapeKind.triangle];
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 132, padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: card, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? const Color(0xFF7257F5) : const Color(0xFFE8E5EF), width: selected ? 1.6 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(candidate.id, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w900))),
            if (candidate.badge != null) Text(candidate.badge!, style: const TextStyle(color: Color(0xFF7257F5), fontSize: 9, fontWeight: FontWeight.w900)),
          ]),
          Text(candidate.name, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w900)),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            for (final shape in shapes) _ExactToken(shape: shape, tone: ShapeTone.blue, candidate: candidate, size: 48),
          ]),
          const Spacer(),
          Text(candidate.intent, style: TextStyle(color: muted, fontSize: 9.5, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.candidate, required this.card, required this.fg, required this.muted});
  final SoftBasicCandidate candidate;
  final Color card, fg, muted;
  @override
  Widget build(BuildContext context) {
    const shapes = [ShapeKind.circle, ShapeKind.square, ShapeKind.triangle];
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE8E5EF))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(candidate.id + ' · ' + candidate.name, style: TextStyle(color: fg, fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(candidate.intent, style: TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 14),
        Text('3 Shapes × 3 Colors · 58px APP EXACT', style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(spacing: 12, runSpacing: 12, children: [
          for (final shape in shapes)
            for (final tone in tones)
              SizedBox(width: 72, child: Column(children: [
                _ExactToken(shape: shape, tone: tone, candidate: candidate, size: 58),
                const SizedBox(height: 4),
                Text(shape.label + '·' + tone.label, style: TextStyle(color: muted, fontSize: 9)),
              ])),
        ]),
        const SizedBox(height: 16),
        Text('평가 순서 · Color 명확성 → 58px 가독성 → 실루엣 안정성 → 감성/목업 근접도 → 과도한 Gloss 여부', style: TextStyle(color: muted, fontSize: 11, height: 1.45)),
      ]),
    );
  }
}

class _ExactToken extends StatelessWidget {
  const _ExactToken({required this.shape, required this.tone, required this.candidate, required this.size});
  final ShapeKind shape;
  final ShapeTone tone;
  final SoftBasicCandidate candidate;
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _SoftBasicCandidatePainter(shape: shape, tone: tone, candidate: candidate)),
  );
}

class _SoftBasicCandidatePainter extends CustomPainter {
  const _SoftBasicCandidatePainter({required this.shape, required this.tone, required this.candidate});
  final ShapeKind shape;
  final ShapeTone tone;
  final SoftBasicCandidate candidate;
  @override
  void paint(Canvas canvas, Size size) {
    ShapeSpecRenderer.paintToken(
      canvas,
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2,
      token: LockToken(shape: shape, tone: tone),
      style: ShapeStyle.softBasic,
      opacity: 1,
      overrides: candidate.forShape(shape),
    );
  }
  @override
  bool shouldRepaint(covariant _SoftBasicCandidatePainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.tone != tone || oldDelegate.candidate.id != candidate.id;
}