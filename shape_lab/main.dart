import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:my_lock/lock_engine/effects.dart';
import 'package:my_lock/lock_engine/floating_preview.dart';
import 'package:my_lock/lock_engine/floating_engine.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_render_overrides.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_renderer.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';

import 'soft_basic_candidates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShapeSpecRegistry.instance.load();
  runApp(const MyLockLabsApp());
}

enum LabTab { shape, style, palette, effect, qa }

class MyLockLabsApp extends StatelessWidget {
  const MyLockLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK Labs',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7257F5),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const LabsPage(),
    );
  }
}

class LabsPage extends StatefulWidget {
  const LabsPage({super.key});

  @override
  State<LabsPage> createState() => _LabsPageState();
}

class _LabsPageState extends State<LabsPage> {
  LabTab tab = switch (Uri.base.queryParameters['lab']) {
    'shape' => LabTab.shape,
    'palette' => LabTab.palette,
    'effect' => LabTab.effect,
    'qa' => LabTab.qa,
    _ => LabTab.style,
  };
  bool dark = false;

  void _setTab(LabTab next) {
    setState(() => tab = next);
    final query = Map<String, String>.from(Uri.base.queryParameters)
      ..['lab'] = switch (next) {
        LabTab.shape => 'shape',
        LabTab.style => 'style',
        LabTab.palette => 'palette',
        LabTab.effect => 'effect',
        LabTab.qa => 'qa',
      };
    final nextUri = Uri.base.replace(queryParameters: query);
    SystemNavigator.routeInformationUpdated(uri: nextUri, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF101218) : const Color(0xFFF6F5FA);
    final card = dark ? const Color(0xFF1A1D26) : Colors.white;
    final fg = dark ? Colors.white : const Color(0xFF171923);
    final muted = dark ? const Color(0xFFAEB4C3) : const Color(0xFF6D7382);
    final compact = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: bg,
              padding: EdgeInsets.fromLTRB(
                compact ? 14 : 20,
                12,
                compact ? 14 : 20,
                10,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  compact ? 'MY LOCK Labs' : 'MY LOCK Labs · Design System',
                                  style: TextStyle(
                                    color: fg,
                                    fontSize: compact ? 21 : 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'LAB 032 · Core Basic 3-Shape Master Compare',
                                  style: TextStyle(color: muted, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!compact)
                                Text('Dark', style: TextStyle(color: muted)),
                              Switch(
                                value: dark,
                                onChanged: (value) => setState(() => dark = value),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _TabChip(
                              label: 'Shape Lab',
                              selected: tab == LabTab.shape,
                              onTap: () => _setTab(LabTab.shape),
                            ),
                            _TabChip(
                              label: 'Style Lab',
                              selected: tab == LabTab.style,
                              onTap: () => _setTab(LabTab.style),
                            ),
                            _TabChip(
                              label: 'Palette Lab',
                              selected: tab == LabTab.palette,
                              onTap: () => _setTab(LabTab.palette),
                            ),
                            _TabChip(
                              label: 'Effect Lab',
                              selected: tab == LabTab.effect,
                              onTap: () => _setTab(LabTab.effect),
                            ),
                            _TabChip(
                              label: 'Runtime QA',
                              selected: tab == LabTab.qa,
                              onTap: () => _setTab(LabTab.qa),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: dark ? Colors.white12 : const Color(0xFFE8E5EF)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 12 : 20,
                  14,
                  compact ? 12 : 20,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: switch (tab) {
                      LabTab.shape => ShapeLab(card: card, fg: fg, muted: muted),
                      LabTab.style => CrayonStyleLab(card: card, fg: fg, muted: muted),
                      LabTab.palette => PaletteLab(card: card, fg: fg, muted: muted),
                      LabTab.effect => EffectLab(card: card, fg: fg, muted: muted),
                      LabTab.qa => RuntimeQaLab(card: card, fg: fg, muted: muted),
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class ShapeLab extends StatelessWidget {
  const ShapeLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const shapes = [ShapeKind.circle, ShapeKind.triangle, ShapeKind.square];
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CoreBasicMasterComparePanel(
          card: card,
          fg: fg,
          muted: muted,
        ),
        const SizedBox(height: 14),
        _Panel(
          color: card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'Shape Lab',
                subtitle: '기본 Shape Master와 Drop Shape를 한 화면에서 실제 렌더 기준으로 확인합니다.',
                fg: fg,
                muted: muted,
              ),
              const SizedBox(height: 16),
              for (final shape in shapes) ...[
                Text(
                  shape.label,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  children: [
                    for (final tone in tones)
                      _TokenWithLabel(
                        shape: shape,
                        tone: tone,
                        style: ShapeStyle.softBasic,
                        label: tone.label,
                        muted: muted,
                      ),
                  ],
                ),
                if (shape != shapes.last) const SizedBox(height: 18),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SeaTurtleShapePanel(card: card, fg: fg, muted: muted),
        const SizedBox(height: 14),
        _SeaTurtleRegionCrayonPanel(card: card, fg: fg, muted: muted),
      ],
    );
  }
}


class _CoreBasicMasterComparePanel extends StatelessWidget {
  const _CoreBasicMasterComparePanel({
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const shapes = [
      ShapeKind.circle,
      ShapeKind.triangle,
      ShapeKind.square,
    ];
    const tones = [
      ShapeTone.pink,
      ShapeTone.blue,
      ShapeTone.yellow,
    ];

    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Core Basic · Canonical Master · 3 Shape Compare',
            subtitle:
                'Circle / Triangle / Square의 확정 Geometry를 그대로 사용한 Soft Basic 58px 비교. 모양은 고정하고 Style Layer의 균형만 확인합니다.',
            fg: fg,
            muted: muted,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFF8),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'MASTER LOCKED · 58px APP SCALE',
              style: TextStyle(
                color: Color(0xFF5A4EA3),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const SizedBox(width: 54),
              for (final shape in shapes)
                Expanded(
                  child: Center(
                    child: Text(
                      shape.label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final tone in tones) ...[
            Row(
              children: [
                SizedBox(
                  width: 54,
                  child: Text(
                    tone.label,
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                for (final shape in shapes)
                  Expanded(
                    child: Center(
                      child: SizedBox.square(
                        dimension: 58,
                        child: CustomPaint(
                          painter: LockTokenPainter(
                            LockToken(shape: shape, tone: tone),
                            style: ShapeStyle.softBasic,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (tone != tones.last) const SizedBox(height: 12),
          ],
          const SizedBox(height: 14),
          Text(
            'Check: silhouette 크기 · optical mass · 상단 highlight · 하단 bounce · 색상별 명암 균형',
            style: TextStyle(
              color: muted,
              fontSize: 10.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}


class _SeaTurtleRegionCrayonPanel extends StatelessWidget {
  const _SeaTurtleRegionCrayonPanel({
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Sea Turtle · Region Color × Crayon Soft',
            subtitle:
                '기존 3색 Runtime Asset의 내부 색 구분을 Color Map으로 그대로 보존하고, 전체 silhouette에는 R2-02 계열 contour 1회, 내부에는 R3-04 계열 wax texture를 적용합니다.',
            fg: fg,
            muted: muted,
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _SeaTurtleRegionCrayonCard(
                tone: ShapeTone.blue,
                label: 'Blue · Palette',
              ),
              _SeaTurtleRegionCrayonCard(
                tone: ShapeTone.pink,
                label: 'Pink · Palette',
              ),
              _SeaTurtleRegionCrayonCard(
                tone: ShapeTone.yellow,
                label: 'Yellow · Palette',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeaTurtleRegionCrayonCard extends StatelessWidget {
  const _SeaTurtleRegionCrayonCard({
    required this.tone,
    required this.label,
  });

  final ShapeTone tone;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E1D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 74,
                child: Column(
                  children: [
                    _SeaTurtleStaticAsset(
                      tone: tone,
                      size: 66,
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'SOURCE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7A746B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Center(
                  child: _SeaTurtleRegionCrayonAsset(
                    tone: tone,
                    size: 142,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              _SeaTurtleRegionCrayonAsset(
                tone: tone,
                size: 58,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '58px QA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeaTurtleRegionCrayonAsset extends StatefulWidget {
  const _SeaTurtleRegionCrayonAsset({
    required this.tone,
    required this.size,
  });

  final ShapeTone tone;
  final double size;

  @override
  State<_SeaTurtleRegionCrayonAsset> createState() =>
      _SeaTurtleRegionCrayonAssetState();
}

class _SeaTurtleRegionCrayonAssetState
    extends State<_SeaTurtleRegionCrayonAsset> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ui.Image? _image;

  String get _asset => switch (widget.tone) {
        ShapeTone.blue =>
          'assets/sea_turtle_runtime_v2/sea_turtle_blue.png',
        ShapeTone.pink =>
          'assets/sea_turtle_runtime_v2/sea_turtle_pink.png',
        ShapeTone.yellow =>
          'assets/sea_turtle_runtime_v2/sea_turtle_yellow.png',
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _SeaTurtleRegionCrayonAsset oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tone != widget.tone) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }

    final stream = AssetImage(_asset).resolve(
      createLocalImageConfiguration(context),
    );
    final listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() => _image = info.image);
      },
      onError: (_, __) {
        if (!mounted) return;
        setState(() => _image = null);
      },
    );

    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _image == null
          ? const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : CustomPaint(
              painter: _SeaTurtleRegionCrayonPainter(
                image: _image!,
                tone: widget.tone,
              ),
            ),
    );
  }
}

class _SeaTurtleRegionCrayonPainter extends CustomPainter {
  const _SeaTurtleRegionCrayonPainter({
    required this.image,
    required this.tone,
  });

  final ui.Image image;
  final ShapeTone tone;

  Color get _contourColor => switch (tone) {
        ShapeTone.blue => const Color(0xFF3C7773),
        ShapeTone.pink => const Color(0xFFB95273),
        ShapeTone.yellow => const Color(0xFF9A742F),
      };

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dest = Rect.fromLTWH(0, 0, size.width, size.height);
    final random = Random(271027 + tone.index * 7919);

    // Region color map: retain the authored body / shell / accent colors from
    // the existing three runtime assets instead of flattening to one tone.
    canvas.saveLayer(dest.inflate(side * 0.03), Paint());
    canvas.drawImageRect(
      image,
      src,
      dest,
      Paint()
        ..filterQuality = FilterQuality.high
        ..color = Colors.white.withValues(alpha: 0.96),
    );

    void drawWaxPass({
      required int count,
      required double widthScale,
      required double opacity,
      required double spreadDeg,
      required double minLength,
      required double maxLength,
    }) {
      for (var i = 0; i < count; i++) {
        final angle =
            (-17 + (random.nextDouble() - 0.5) * 2 * spreadDeg) *
                pi /
                180;
        final direction = Offset(cos(angle), sin(angle));
        final normal = Offset(-direction.dy, direction.dx);
        final center = Offset(
          random.nextDouble() * side,
          random.nextDouble() * side,
        );
        final length =
            side * (minLength + random.nextDouble() * (maxLength - minLength));
        final half = direction * (length / 2);
        final wobble =
            normal * ((random.nextDouble() - 0.5) * side * 0.018);
        final start = center - half;
        final end = center + half;
        final control = center + wobble;
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = max(
              0.72,
              side *
                  widthScale *
                  (0.82 + random.nextDouble() * 0.36),
            )
            ..blendMode = BlendMode.multiply
            ..color = Colors.black.withValues(
              alpha: opacity * (0.72 + random.nextDouble() * 0.40),
            ),
        );

        // R3-04 family: sparse dry opening inside otherwise thick wax strokes.
        if (random.nextDouble() < 0.105) {
          final gapCenter = Offset.lerp(
            start,
            end,
            0.28 + random.nextDouble() * 0.44,
          )!;
          final gapHalf =
              direction * side * (0.0085 + random.nextDouble() * 0.012);
          canvas.drawLine(
            gapCenter - gapHalf,
            gapCenter + gapHalf,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = max(0.55, side * widthScale * 0.35)
              ..blendMode = BlendMode.dstOut
              ..color = Colors.white.withValues(alpha: 0.68),
          );
        }
      }
    }

    // Same-brush fill: broad layer first, main wax layer second.
    drawWaxPass(
      count: 19,
      widthScale: 0.0482,
      opacity: 0.105,
      spreadDeg: 6,
      minLength: 0.58,
      maxLength: 0.92,
    );
    drawWaxPass(
      count: 29,
      widthScale: 0.0350,
      opacity: 0.145,
      spreadDeg: 7.5,
      minLength: 0.58,
      maxLength: 0.92,
    );

    // Pigment clumps preserve each underlying region color by multiplying it
    // rather than painting a new global tone over the asset.
    final grainPaint = Paint()
      ..blendMode = BlendMode.multiply
      ..color = Colors.black.withValues(alpha: 0.10);
    for (var i = 0; i < 44; i++) {
      final radius = side * (0.0013 + random.nextDouble() * 0.0083);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * side,
          random.nextDouble() * side,
        ),
        max(0.32, radius),
        grainPaint,
      );
    }

    // Sparse paper tooth: reveal the real Lab background without washing
    // authored region colors with a white texture overlay.
    final toothPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.dstOut
      ..color = Colors.white.withValues(alpha: 0.46);
    for (var i = 0; i < 24; i++) {
      final angle =
          (-17 + (random.nextDouble() - 0.5) * 40) * pi / 180;
      final direction = Offset(cos(angle), sin(angle));
      final center = Offset(
        random.nextDouble() * side,
        random.nextDouble() * side,
      );
      final length = side * (0.0034 + random.nextDouble() * 0.0128);
      final half = direction * (length / 2);
      toothPaint.strokeWidth = max(
        0.42,
        side * (0.0010 + random.nextDouble() * 0.0033),
      );
      canvas.drawLine(center - half, center + half, toothPaint);
    }

    // Clip the full color-map texture with the original transparent silhouette.
    canvas.drawImageRect(
      image,
      src,
      dest,
      Paint()
        ..filterQuality = FilterQuality.high
        ..blendMode = BlendMode.dstIn,
    );
    canvas.restore();

    // R2-02 family global contour: one silhouette outline only.
    final contourWidth = side * 0.0365;
    canvas.saveLayer(dest.inflate(contourWidth * 1.8), Paint());
    final contourPaint = Paint()
      ..filterQuality = FilterQuality.high
      ..colorFilter = ColorFilter.mode(
        _contourColor.withValues(alpha: 0.68),
        BlendMode.srcIn,
      );

    const contourPasses = 16;
    for (var i = 0; i < contourPasses; i++) {
      final angle = pi * 2 * i / contourPasses;
      final offset = Offset(cos(angle), sin(angle)) * contourWidth;
      canvas.drawImageRect(
        image,
        src,
        dest.shift(offset),
        contourPaint,
      );
    }

    // Keep the original silhouette hollow so the contour is not re-applied
    // around the authored internal color regions.
    canvas.drawImageRect(
      image,
      src,
      dest,
      Paint()
        ..filterQuality = FilterQuality.high
        ..blendMode = BlendMode.dstOut,
    );

    final contourGapPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = max(0.72, contourWidth * 0.86)
      ..blendMode = BlendMode.dstOut
      ..color = Colors.white.withValues(alpha: 0.94);
    for (var i = 0; i < 14; i++) {
      final center = Offset(
        random.nextDouble() * side,
        random.nextDouble() * side,
      );
      final angle = random.nextDouble() * pi * 2;
      final length = side * (0.015 + random.nextDouble() * 0.030);
      final delta = Offset(cos(angle), sin(angle)) * length;
      canvas.drawLine(center - delta, center + delta, contourGapPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SeaTurtleRegionCrayonPainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.tone != tone;
}

class _SeaTurtleShapePanel extends StatefulWidget {
  const _SeaTurtleShapePanel({
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<_SeaTurtleShapePanel> createState() => _SeaTurtleShapePanelState();
}

class _SeaTurtleShapePanelState extends State<_SeaTurtleShapePanel>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final FloatingEngine _engine = FloatingEngine(seed: 240925);

  Duration _previous = Duration.zero;
  Size _lastStageSize = Size.zero;
  int _objectCount = 9;
  MovementStyle _movement = MovementStyle.underwater;
  bool _darkBackground = false;

  double _shapeAnimationSeconds = 0;
  int _shapeAnimationVariant = 1;
  bool _shapeAnimationEnabled = true;

  @override
  void initState() {
    super.initState();
    _engine
      ..setSelection(
        const {ShapeKind.circle},
        const {ShapeTone.blue, ShapeTone.pink, ShapeTone.yellow},
      )
      ..setObjectCount(_objectCount)
      ..setMovementStyle(_movement)
      ..setMovementArea(MovementArea.full)
      ..setSpeed(FloatingSpeed.normal);

    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final delta = _previous == Duration.zero
        ? 0.0
        : (elapsed - _previous).inMicroseconds /
            Duration.microsecondsPerSecond;
    _previous = elapsed;

    if (delta > 0) {
      final safeDelta = delta.clamp(0.0, 0.035).toDouble();
      _shapeAnimationSeconds += safeDelta;
      _engine.step(safeDelta);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: widget.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Drop 01 · Sea Turtle · Long Flipper',
            subtitle:
                'Geometry Lock 유지 · 앱 Palette 3색 · Shape Animation 분리 · 전체 이동/충돌/회전은 Motion Set 담당',
            fg: widget.fg,
            muted: widget.muted,
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _SeaTurtlePreview(
                tone: ShapeTone.blue,
                label: 'Blue · Palette',
              ),
              _SeaTurtlePreview(
                tone: ShapeTone.pink,
                label: 'Pink · Palette',
              ),
              _SeaTurtlePreview(
                tone: ShapeTone.yellow,
                label: 'Yellow · Palette',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Shape Animation Comparison · Motion Set OFF',
            style: TextStyle(
              color: widget.fg,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Long Flipper Master의 내부 지느러미 움직임만 비교합니다. Shape 전체 위치·회전 이동은 포함하지 않습니다.',
            style: TextStyle(color: widget.muted, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final cardWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 20) / 3;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _SeaTurtleAnimationCard(
                      animationSeconds: _shapeAnimationSeconds,
                      variant: 0,
                      selected: _shapeAnimationVariant == 0,
                      title: 'A · Long Sweep',
                      subtitle: '긴 앞지느러미를 크게 천천히 쓸어내리는 유영',
                      onTap: () => setState(() => _shapeAnimationVariant = 0),
                      muted: widget.muted,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _SeaTurtleAnimationCard(
                      animationSeconds: _shapeAnimationSeconds,
                      variant: 1,
                      selected: _shapeAnimationVariant == 1,
                      title: 'B · Natural Swim',
                      subtitle: '양쪽 지느러미 위상차로 자연스러운 실제 유영감',
                      onTap: () => setState(() => _shapeAnimationVariant = 1),
                      muted: widget.muted,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _SeaTurtleAnimationCard(
                      animationSeconds: _shapeAnimationSeconds,
                      variant: 2,
                      selected: _shapeAnimationVariant == 2,
                      title: 'C · Soft Flow',
                      subtitle: '작은 진폭과 서로 다른 주기로 잔잔하게 흐르는 움직임',
                      onTap: () => setState(() => _shapeAnimationVariant = 2),
                      muted: widget.muted,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            'Crayon Soft Apply Test',
            style: TextStyle(
              color: widget.fg,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Region/Palette Source v2를 기준으로 스타일을 검증합니다. Geometry는 고정하고 Material 표현만 비교합니다.',
            style: TextStyle(color: widget.muted, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _SeaTurtleCrayonPreview(
                tone: ShapeTone.blue,
                label: 'Blue',
              ),
              _SeaTurtleCrayonPreview(
                tone: ShapeTone.pink,
                label: 'Pink',
              ),
              _SeaTurtleCrayonPreview(
                tone: ShapeTone.yellow,
                label: 'Yellow',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Motion Set × Shape Animation QA',
            style: TextStyle(
              color: widget.fg,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'FloatingEngine은 Shape 전체의 이동·충돌·크기·회전을 담당하고, 선택한 Shape Animation은 거북이 내부 지느러미 움직임만 담당합니다.',
            style: TextStyle(color: widget.muted, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final value in const [6, 9, 12])
                ChoiceChip(
                  label: Text('$value개'),
                  selected: _objectCount == value,
                  onSelected: (_) {
                    setState(() {
                      _objectCount = value;
                      _engine.setObjectCount(value);
                    });
                  },
                ),
              _EnumDropdown<MovementStyle>(
                label: 'Motion Set',
                value: _movement,
                values: MovementStyle.values,
                text: (v) => v.label,
                onChanged: (value) {
                  setState(() {
                    _movement = value;
                    _engine.setMovementStyle(value);
                  });
                },
              ),
              FilterChip(
                label: const Text('Shape Animation'),
                selected: _shapeAnimationEnabled,
                onSelected: (value) =>
                    setState(() => _shapeAnimationEnabled = value),
              ),
              FilterChip(
                label: const Text('Dark BG'),
                selected: _darkBackground,
                onSelected: (value) =>
                    setState(() => _darkBackground = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = min(520.0, max(400.0, width * 0.72));
              final stageSize = Size(width, height);

              if (stageSize != _lastStageSize &&
                  stageSize.width > 0 &&
                  stageSize.height > 0) {
                _lastStageSize = stageSize;
                _engine.resize(stageSize);
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: _darkBackground
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF071525),
                              Color(0xFF10345A),
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFEAF8FF),
                              Color(0xFFDFF3F8),
                            ],
                          ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final object in _engine.objects)
                        _SeaTurtleRuntimeObject(
                          key: ValueKey(object.id),
                          object: object,
                          animationSeconds:
                              _shapeAnimationSeconds + object.id * 0.17,
                          animationVariant: _shapeAnimationVariant,
                          animate: _shapeAnimationEnabled,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SeaTurtleAnimationCard extends StatelessWidget {
  const _SeaTurtleAnimationCard({
    required this.animationSeconds,
    required this.variant,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.muted,
  });

  final double animationSeconds;
  final int variant;
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.34) : const Color(0xFFF8FBFD),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? scheme.primary : const Color(0xFFE5EDF2),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 176,
                child: Center(
                  child: _SeaTurtleAnimatedAsset(
                    tone: ShapeTone.blue,
                    size: 168,
                    animationSeconds: animationSeconds,
                    variant: variant,
                    animate: true,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 10.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeaTurtlePreview extends StatelessWidget {
  const _SeaTurtlePreview({
    required this.tone,
    required this.label,
  });

  final ShapeTone tone;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: Column(
        children: [
          _SeaTurtleStaticAsset(
            tone: tone,
            size: 104,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}



class _SeaTurtleCrayonPreview extends StatelessWidget {
  const _SeaTurtleCrayonPreview({
    required this.tone,
    required this.label,
  });

  final ShapeTone tone;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E1D8)),
      ),
      child: Column(
        children: [
          _SeaTurtleCrayonAsset(tone: tone, size: 132),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SeaTurtleCrayonAsset(tone: tone, size: 58),
              const SizedBox(width: 10),
              Text(
                '58px QA',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeaTurtleCrayonAsset extends StatefulWidget {
  const _SeaTurtleCrayonAsset({
    required this.tone,
    required this.size,
  });

  final ShapeTone tone;
  final double size;

  @override
  State<_SeaTurtleCrayonAsset> createState() => _SeaTurtleCrayonAssetState();
}

class _SeaTurtleCrayonAssetState extends State<_SeaTurtleCrayonAsset> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ui.Image? _image;

  String get _asset => switch (widget.tone) {
        ShapeTone.blue =>
          'assets/sea_turtle_runtime_v2/sea_turtle_blue.png',
        ShapeTone.pink =>
          'assets/sea_turtle_runtime_v2/sea_turtle_pink.png',
        ShapeTone.yellow =>
          'assets/sea_turtle_runtime_v2/sea_turtle_yellow.png',
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _SeaTurtleCrayonAsset oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tone != widget.tone) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }

    final stream = AssetImage(_asset).resolve(
      createLocalImageConfiguration(context),
    );
    final listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() => _image = info.image);
      },
      onError: (_, __) {
        if (!mounted) return;
        setState(() => _image = null);
      },
    );

    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _image == null
          ? const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : CustomPaint(
              painter: _SeaTurtleCrayonPainter(
                image: _image!,
                tone: widget.tone,
              ),
            ),
    );
  }
}

class _SeaTurtleCrayonPainter extends CustomPainter {
  const _SeaTurtleCrayonPainter({
    required this.image,
    required this.tone,
  });

  final ui.Image image;
  final ShapeTone tone;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dest = Rect.fromLTWH(0, 0, size.width, size.height);

    final base = baseColorForTone(tone);
    final dark = adjustTone(
      base,
      lightnessDelta: -0.105,
      saturationDelta: 0.0,
    );
    final slightlyDark = adjustTone(
      base,
      lightnessDelta: -0.055,
      saturationDelta: 0.0,
    );

    final seed = 91261 + tone.index * 104729;
    final random = Random(seed);

    // R2-02 outline: thick dark wax rim with sparse dry breaks.
    final contourWidth = side * 0.0365;
    canvas.saveLayer(dest.inflate(contourWidth * 1.8), Paint());
    final contourPaint = Paint()
      ..filterQuality = FilterQuality.high
      ..colorFilter = ColorFilter.mode(
        dark.withValues(alpha: 0.68),
        BlendMode.srcIn,
      );

    const contourPasses = 16;
    for (var i = 0; i < contourPasses; i++) {
      final angle = pi * 2 * i / contourPasses;
      final offset = Offset(cos(angle), sin(angle)) * contourWidth;
      canvas.drawImageRect(
        image,
        src,
        dest.shift(offset),
        contourPaint,
      );
    }

    final contourGapPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = max(0.75, contourWidth * 0.86)
      ..blendMode = BlendMode.dstOut
      ..color = Colors.white.withValues(alpha: 0.94);

    for (var i = 0; i < 14; i++) {
      final center = Offset(
        random.nextDouble() * side,
        random.nextDouble() * side,
      );
      final angle = random.nextDouble() * pi * 2;
      final length = side * (0.018 + random.nextDouble() * 0.034);
      final delta = Offset(cos(angle), sin(angle)) * length;
      canvas.drawLine(center - delta, center + delta, contourGapPaint);
    }
    canvas.restore();

    // R3-04 fill: high color retention + thick same-family wax strokes.
    canvas.saveLayer(dest, Paint());
    canvas.drawRect(
      dest,
      Paint()..color = base.withValues(alpha: 0.95),
    );

    void drawWaxPass({
      required int count,
      required double width,
      required double opacity,
      required Color color,
      required double baseAngleDeg,
      required double angleSpreadDeg,
      required double minLength,
      required double maxLength,
    }) {
      for (var i = 0; i < count; i++) {
        final angle =
            (baseAngleDeg +
                    (random.nextDouble() - 0.5) * 2 * angleSpreadDeg) *
                pi /
                180;
        final direction = Offset(cos(angle), sin(angle));
        final normal = Offset(-direction.dy, direction.dx);
        final center = Offset(
          random.nextDouble() * side,
          random.nextDouble() * side,
        );
        final length =
            side * (minLength + random.nextDouble() * (maxLength - minLength));
        final half = direction * (length / 2);
        final wobble =
            normal * ((random.nextDouble() - 0.5) * side * 0.018);
        final start = center - half;
        final end = center + half;
        final control = center + wobble;
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

        final pressure = 0.72 + random.nextDouble() * 0.56;
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth =
                max(0.75, width * (0.82 + random.nextDouble() * 0.36))
            ..color = color.withValues(
              alpha: (opacity * pressure).clamp(0.0, 1.0),
            ),
        );

        if (random.nextDouble() < 0.105) {
          final gapCenter = Offset.lerp(start, end, 0.28 + random.nextDouble() * 0.44)!;
          final gapHalf =
              direction * side * (0.0085 + random.nextDouble() * 0.012);
          canvas.drawLine(
            gapCenter - gapHalf,
            gapCenter + gapHalf,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = max(0.62, width * 0.35)
              ..blendMode = BlendMode.dstOut
              ..color = Colors.white.withValues(alpha: 0.88),
          );
        }
      }
    }

    drawWaxPass(
      count: 19,
      width: side * 0.0482,
      opacity: 0.235,
      color: slightlyDark,
      baseAngleDeg: -17,
      angleSpreadDeg: 6,
      minLength: 0.58,
      maxLength: 0.92,
    );
    drawWaxPass(
      count: 29,
      width: side * 0.035,
      opacity: 0.31,
      color: dark,
      baseAngleDeg: -17,
      angleSpreadDeg: 7.5,
      minLength: 0.58,
      maxLength: 0.92,
    );

    final grainPaint = Paint()
      ..color = dark.withValues(alpha: 0.16);
    for (var i = 0; i < 44; i++) {
      final radius = side * (0.0013 + random.nextDouble() * 0.0083);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * side,
          random.nextDouble() * side,
        ),
        max(0.35, radius),
        grainPaint,
      );
    }

    final toothPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.dstOut
      ..color = Colors.white.withValues(alpha: 0.54);

    for (var i = 0; i < 26; i++) {
      final angle =
          (-17 + (random.nextDouble() - 0.5) * 42) * pi / 180;
      final direction = Offset(cos(angle), sin(angle));
      final center = Offset(
        random.nextDouble() * side,
        random.nextDouble() * side,
      );
      final length = side * (0.0036 + random.nextDouble() * 0.0144);
      final half = direction * (length / 2);
      toothPaint.strokeWidth = max(
        0.45,
        side * (0.0010 + random.nextDouble() * 0.0038),
      );
      canvas.drawLine(center - half, center + half, toothPaint);
    }

    // Clip the procedural wax layer by the actual transparent turtle Runtime
    // Asset so the test uses the approved Long Flipper silhouette.
    canvas.drawImageRect(
      image,
      src,
      dest,
      Paint()
        ..filterQuality = FilterQuality.high
        ..blendMode = BlendMode.dstIn,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SeaTurtleCrayonPainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.tone != tone;
}

class _SeaTurtleRuntimeObject extends StatelessWidget {
  const _SeaTurtleRuntimeObject({
    super.key,
    required this.object,
    required this.animationSeconds,
    required this.animationVariant,
    required this.animate,
  });

  final FloatingObject object;
  final double animationSeconds;
  final int animationVariant;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final side = object.radius * 2.34;
    return Positioned(
      left: object.position.dx - side / 2,
      top: object.position.dy - side / 2,
      width: side,
      height: side,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: object.rotation,
          child: _SeaTurtleAnimatedAsset(
            tone: object.token.tone,
            size: side,
            animationSeconds: animationSeconds,
            variant: animationVariant,
            animate: animate,
            compactError: true,
          ),
        ),
      ),
    );
  }
}

class _SeaTurtleAnimatedAsset extends StatelessWidget {
  const _SeaTurtleAnimatedAsset({
    required this.tone,
    required this.size,
    required this.animationSeconds,
    required this.variant,
    required this.animate,
    this.compactError = false,
  });

  final ShapeTone tone;
  final double size;
  final double animationSeconds;
  final int variant;
  final bool animate;
  final bool compactError;

  static const _nearPivot = Offset(204 / 512, 234 / 512);
  static const _farPivot = Offset(124 / 512, 239 / 512);

  @override
  Widget build(BuildContext context) {
    final asset = _assetForTone(tone);
    final (nearDegrees, farDegrees) = _angles();

    Widget image({bool showError = false}) => Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            if (!showError) return const SizedBox.shrink();
            if (compactError) {
              return const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 18,
                  color: Color(0xFFB64242),
                ),
              );
            }
            return Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Asset error',
                style: TextStyle(color: Color(0xFF9F2F2F), fontSize: 10),
              ),
            );
          },
        );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Transform.rotate(
            angle: _degrees(farDegrees),
            alignment: _alignmentFor(_farPivot),
            child: ClipPath(
              clipper: const _SeaTurtlePartClipper(_TurtlePart.far),
              child: image(),
            ),
          ),
          ClipPath(
            clipper: const _SeaTurtleBaseClipper(),
            child: image(showError: true),
          ),
          Transform.rotate(
            angle: _degrees(nearDegrees),
            alignment: _alignmentFor(_nearPivot),
            child: ClipPath(
              clipper: const _SeaTurtlePartClipper(_TurtlePart.near),
              child: image(),
            ),
          ),
        ],
      ),
    );
  }

  (double, double) _angles() {
    if (!animate) return (0, 0);

    switch (variant) {
      case 0:
        final phase = animationSeconds * (2 * pi / 4.2);
        return (
          -0.4 + sin(phase) * 5.0,
          0.2 - sin(phase + 0.18) * 3.4,
        );
      case 2:
        final near =
            sin(animationSeconds * (2 * pi / 4.9)) * 2.8 +
            sin(animationSeconds * (2 * pi / 7.4)) * 0.9;
        final far =
            sin(animationSeconds * (2 * pi / 5.5) + 1.05) * 2.1;
        return (near, far);
      default:
        final phase = animationSeconds * (2 * pi / 3.25);
        return (
          -0.8 + sin(phase) * 6.8,
          0.4 - sin(phase + 0.82) * 4.4,
        );
    }
  }

  static double _degrees(double value) => value * pi / 180;

  static Alignment _alignmentFor(Offset pivot) {
    return Alignment(pivot.dx * 2 - 1, pivot.dy * 2 - 1);
  }
}

class _SeaTurtleStaticAsset extends StatelessWidget {
  const _SeaTurtleStaticAsset({
    required this.tone,
    required this.size,
    this.compactError = false,
  });

  final ShapeTone tone;
  final double size;
  final bool compactError;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetForTone(tone),
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        if (compactError) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 18,
              color: Color(0xFFB64242),
            ),
          );
        }
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFECEC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Asset error',
            style: TextStyle(color: Color(0xFF9F2F2F), fontSize: 10),
          ),
        );
      },
    );
  }
}

String _assetForTone(ShapeTone tone) => switch (tone) {
      ShapeTone.blue => 'assets/sea_turtle_runtime_v2/sea_turtle_blue.png',
      ShapeTone.pink => 'assets/sea_turtle_runtime_v2/sea_turtle_pink.png',
      ShapeTone.yellow => 'assets/sea_turtle_runtime_v2/sea_turtle_yellow.png',
    };

enum _TurtlePart { near, far }

class _SeaTurtlePartClipper extends CustomClipper<Path> {
  const _SeaTurtlePartClipper(this.part);

  final _TurtlePart part;

  static const _near = <Offset>[
    Offset(196 / 512, 224 / 512),
    Offset(218 / 512, 222 / 512),
    Offset(236 / 512, 238 / 512),
    Offset(249 / 512, 263 / 512),
    Offset(265 / 512, 292 / 512),
    Offset(282 / 512, 318 / 512),
    Offset(302 / 512, 340 / 512),
    Offset(323 / 512, 357 / 512),
    Offset(317 / 512, 371 / 512),
    Offset(296 / 512, 373 / 512),
    Offset(276 / 512, 365 / 512),
    Offset(255 / 512, 350 / 512),
    Offset(236 / 512, 329 / 512),
    Offset(220 / 512, 305 / 512),
    Offset(207 / 512, 280 / 512),
    Offset(199 / 512, 255 / 512),
  ];

  static const _far = <Offset>[
    Offset(108 / 512, 231 / 512),
    Offset(132 / 512, 228 / 512),
    Offset(151 / 512, 238 / 512),
    Offset(160 / 512, 255 / 512),
    Offset(155 / 512, 282 / 512),
    Offset(147 / 512, 312 / 512),
    Offset(139 / 512, 340 / 512),
    Offset(128 / 512, 357 / 512),
    Offset(115 / 512, 354 / 512),
    Offset(103 / 512, 342 / 512),
    Offset(96 / 512, 322 / 512),
    Offset(92 / 512, 296 / 512),
    Offset(93 / 512, 269 / 512),
    Offset(101 / 512, 244 / 512),
  ];

  @override
  Path getClip(Size size) {
    final points = part == _TurtlePart.near ? _near : _far;
    return Path()
      ..addPolygon(
        [
          for (final point in points)
            Offset(point.dx * size.width, point.dy * size.height),
        ],
        true,
      );
  }

  @override
  bool shouldReclip(covariant _SeaTurtlePartClipper oldClipper) =>
      oldClipper.part != part;
}

class _SeaTurtleBaseClipper extends CustomClipper<Path> {
  const _SeaTurtleBaseClipper();

  static const _nearCut = <Offset>[
    Offset(201 / 512, 230 / 512),
    Offset(218 / 512, 229 / 512),
    Offset(232 / 512, 241 / 512),
    Offset(245 / 512, 266 / 512),
    Offset(261 / 512, 295 / 512),
    Offset(278 / 512, 319 / 512),
    Offset(300 / 512, 341 / 512),
    Offset(319 / 512, 358 / 512),
    Offset(313 / 512, 367 / 512),
    Offset(298 / 512, 368 / 512),
    Offset(280 / 512, 360 / 512),
    Offset(259 / 512, 346 / 512),
    Offset(240 / 512, 325 / 512),
    Offset(225 / 512, 303 / 512),
    Offset(213 / 512, 278 / 512),
    Offset(205 / 512, 255 / 512),
  ];

  static const _farCut = <Offset>[
    Offset(112 / 512, 236 / 512),
    Offset(132 / 512, 234 / 512),
    Offset(147 / 512, 242 / 512),
    Offset(155 / 512, 257 / 512),
    Offset(151 / 512, 281 / 512),
    Offset(143 / 512, 309 / 512),
    Offset(136 / 512, 336 / 512),
    Offset(127 / 512, 351 / 512),
    Offset(118 / 512, 349 / 512),
    Offset(108 / 512, 338 / 512),
    Offset(101 / 512, 319 / 512),
    Offset(98 / 512, 296 / 512),
    Offset(99 / 512, 271 / 512),
    Offset(105 / 512, 248 / 512),
  ];

  @override
  Path getClip(Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);

    for (final points in [_nearCut, _farCut]) {
      path.addPolygon(
        [
          for (final point in points)
            Offset(point.dx * size.width, point.dy * size.height),
        ],
        true,
      );
    }
    return path;
  }

  @override
  bool shouldReclip(covariant _SeaTurtleBaseClipper oldClipper) => false;
}

class _CrayonCandidate {
  const _CrayonCandidate({
    required this.id,
    required this.name,
    required this.intent,
    required this.config,
    this.badge,
  });

  final String id;
  final String name;
  final String intent;
  final String? badge;
  final CrayonTextureSpec config;
}

const _candidates = <_CrayonCandidate>[
  _CrayonCandidate(
    id: 'C08-A',
    name: 'C08 Baseline',
    intent: '현재 C08 목표안. 다음 후보와 비교하기 위한 기준.',
    badge: 'BASE',
    config: CrayonTextureSpec(
      darkStrokeCount: 44,
      lightStrokeCount: 20,
      grainCount: 34,
      strokeWidth: 1.05,
      angleDeg: -24,
      jitter: 3.2,
      darkOpacity: 0.21,
      lightOpacity: 0.11,
      grainOpacity: 0.18,
      edgeOpacity: 0.13,
    ),
  ),
  _CrayonCandidate(
    id: 'C08-B',
    name: 'Open Fill',
    intent: 'C08 결은 유지하고 바탕 채움을 낮춰 종이색이 은근히 비치게.',
    config: CrayonTextureSpec(
      darkStrokeCount: 42,
      lightStrokeCount: 18,
      grainCount: 30,
      strokeWidth: 1.08,
      angleDeg: -24,
      jitter: 3.1,
      darkOpacity: 0.20,
      lightOpacity: 0.10,
      grainOpacity: 0.15,
      edgeOpacity: 0.12,
      baseStrokeCount: 58,
      underpaintOpacity: 0.62,
      baseStrokeOpacity: 0.48,
      strokeBreakChance: 0.05,
    ),
  ),
  _CrayonCandidate(
    id: 'C08-C',
    name: 'Spaced Fill',
    intent: '채움과 선 밀도를 더 낮춰 크레용 사이 빈틈이 읽히는 안.',
    badge: 'OPEN',
    config: CrayonTextureSpec(
      darkStrokeCount: 37,
      lightStrokeCount: 16,
      grainCount: 26,
      strokeWidth: 1.18,
      angleDeg: -24,
      jitter: 3.35,
      darkOpacity: 0.20,
      lightOpacity: 0.10,
      grainOpacity: 0.13,
      edgeOpacity: 0.11,
      baseStrokeCount: 46,
      underpaintOpacity: 0.50,
      baseStrokeOpacity: 0.52,
      strokeBreakChance: 0.10,
    ),
  ),
  _CrayonCandidate(
    id: 'C08-D',
    name: 'Childlike Gap',
    intent: '중간중간 끊긴 선과 덜 칠한 부분을 가장 적극적으로 남긴 안.',
    badge: 'GAP',
    config: CrayonTextureSpec(
      darkStrokeCount: 34,
      lightStrokeCount: 14,
      grainCount: 24,
      strokeWidth: 1.26,
      angleDeg: -24,
      jitter: 3.8,
      darkOpacity: 0.19,
      lightOpacity: 0.09,
      grainOpacity: 0.12,
      edgeOpacity: 0.10,
      baseStrokeCount: 50,
      underpaintOpacity: 0.40,
      baseStrokeOpacity: 0.55,
      strokeBreakChance: 0.18,
    ),
  ),
];

class CrayonStyleLab extends StatefulWidget {
  const CrayonStyleLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<CrayonStyleLab> createState() => _CrayonStyleLabState();
}

class _CrayonStyleLabState extends State<CrayonStyleLab> {
  int selectedIndex = 0;
  ShapeStyle selectedStyle = Uri.base.queryParameters['style'] == 'soft-basic'
      ? ShapeStyle.softBasic
      : ShapeStyle.crayonSoft;

  @override
  Widget build(BuildContext context) {
    final selected = _candidates[selectedIndex];
    final compact = MediaQuery.sizeOf(context).width < 700;

    if (selectedStyle == ShapeStyle.softBasic) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StyleSelector(
            selected: selectedStyle,
            card: widget.card,
            fg: widget.fg,
            muted: widget.muted,
            onChanged: (value) {
              setState(() => selectedStyle = value);
              _syncStyleQuery(value);
            },
          ),
          const SizedBox(height: 12),
          _SoftBasicCandidateLab(
            card: widget.card,
            fg: widget.fg,
            muted: widget.muted,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StyleSelector(
          selected: selectedStyle,
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
          onChanged: (value) => setState(() => selectedStyle = value),
        ),
        const SizedBox(height: 12),
        _SectionTitle(
          title: 'Crayon Soft · Round 2 · C08 Coverage',
          subtitle: 'C08만 남기고 채움률·선 간격·끊김 정도를 좁혀 비교합니다. Basic은 읽기 전용으로 분리했습니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980 ? 4 : constraints.maxWidth >= 650 ? 2 : 1;
            final gap = compact ? 8.0 : 12.0;
            final itemWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            final cardHeight = compact ? 224.0 : 250.0;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < _candidates.length; i++)
                  SizedBox(
                    width: itemWidth,
                    height: cardHeight,
                    child: _CandidateCard(
                      candidate: _candidates[i],
                      selected: i == selectedIndex,
                      card: widget.card,
                      fg: widget.fg,
                      muted: widget.muted,
                      compact: compact,
                      onTap: () => setState(() => selectedIndex = i),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _SelectedCandidatePanel(
          candidate: selected,
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
        ),
      ],
    );
  }
}


void _syncStyleQuery(ShapeStyle style) {
  final query = Map<String, String>.from(Uri.base.queryParameters)
    ..['lab'] = 'style'
    ..['style'] = style == ShapeStyle.softBasic ? 'soft-basic' : 'crayon-soft';
  final next = Uri.base.replace(queryParameters: query);
  // Web build uses browser history through route information updates.
  SystemNavigator.routeInformationUpdated(uri: next, replace: true);
}

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({
    required this.selected,
    required this.card,
    required this.fg,
    required this.muted,
    required this.onChanged,
  });

  final ShapeStyle selected;
  final Color card;
  final Color fg;
  final Color muted;
  final ValueChanged<ShapeStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: card,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Style Lab',
                  style: TextStyle(
                    color: fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '스타일마다 후보군과 실험값을 분리합니다.',
                  style: TextStyle(color: muted, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<ShapeStyle>(
              initialValue: selected,
              isDense: true,
              decoration: const InputDecoration(
                labelText: '스타일',
                border: OutlineInputBorder(),
              ),
              items: ShapeStyle.values
                  .map(
                    (style) => DropdownMenuItem(
                      value: style,
                      child: Text(style.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftBasicCandidateLab extends StatefulWidget {
  const _SoftBasicCandidateLab({
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<_SoftBasicCandidateLab> createState() => _SoftBasicCandidateLabState();
}

class _SoftBasicCandidateLabState extends State<_SoftBasicCandidateLab> {
  int selectedIndex = 0;

  // 0 Circle / 1 Square / 2 Triangle. Current work starts on Triangle.
  int geometryMode = 2;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    if (geometryMode == 2) {
      return _SharedTriangleMasterLab(
        card: widget.card,
        fg: widget.fg,
        muted: widget.muted,
        onBackToSquare: () => setState(() => geometryMode = 1),
        onBackToCircle: () => setState(() => geometryMode = 0),
      );
    }
    if (geometryMode == 1) {
      return _SoftBasicSquareRound2(
        card: widget.card,
        fg: widget.fg,
        muted: widget.muted,
        onBackToCircle: () => setState(() => geometryMode = 0),
        onOpenTriangle: () => setState(() => geometryMode = 2),
      );
    }
    final selected = softBasicCircleRound9NaturalCandidates[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Soft Basic · Circle · Round 9N · Natural Micro Light',
          subtitle: 'R7-01 상단 하이라이트와 R8-03 Color Shell은 고정. 하단 전체 띠를 버리고 비대칭·소면적·색상 기반 미세광 3안만 비교합니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => geometryMode = 1),
            icon: const Icon(Icons.crop_square_rounded, size: 16),
            label: const Text('Square Master 보기'),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980 ? 4 : 2;
            final gap = compact ? 8.0 : 12.0;
            final itemWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < softBasicCircleRound9NaturalCandidates.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: _SoftBasicCandidateCard(
                      candidate: softBasicCircleRound9NaturalCandidates[i],
                      selected: i == selectedIndex,
                      card: widget.card,
                      fg: widget.fg,
                      muted: widget.muted,
                      onTap: () => setState(() => selectedIndex = i),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _SoftBasicDetailPanel(
          candidate: selected,
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
        ),
      ],
    );
  }
}


class _SoftBasicSquareRound2 extends StatefulWidget {
  const _SoftBasicSquareRound2({
    required this.card,
    required this.fg,
    required this.muted,
    required this.onBackToCircle,
    required this.onOpenTriangle,
  });

  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onBackToCircle;
  final VoidCallback onOpenTriangle;

  @override
  State<_SoftBasicSquareRound2> createState() => _SoftBasicSquareRound2State();
}

class _SoftBasicSquareRound2State extends State<_SoftBasicSquareRound2> {
  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final selected = softBasicSquareRound5Candidates[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Soft Basic · Square · Round 5 · SELECTED 03 · NO CORE',
          subtitle: 'R5-03은 넓은 Soft Spec만 유지하고 Core Spec 및 secondary sparkle을 제거한 클린 버전으로 최종 고정합니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            TextButton.icon(
              onPressed: widget.onBackToCircle,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Circle Master 보기'),
            ),
            TextButton.icon(
              onPressed: widget.onOpenTriangle,
              icon: const Icon(Icons.change_history_rounded, size: 16),
              label: const Text('Triangle Master 보기'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980 ? 3 : 2;
            final gap = compact ? 8.0 : 12.0;
            final itemWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < softBasicSquareRound5Candidates.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: _SoftBasicSquareCandidateCard(
                      candidate: softBasicSquareRound5Candidates[i],
                      selected: i == selectedIndex,
                      card: widget.card,
                      fg: widget.fg,
                      muted: widget.muted,
                      onTap: () => setState(() => selectedIndex = i),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _SoftBasicCircleSquareComparePanel(
          squareCandidate: selected,
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
        ),
      ],
    );
  }
}

class _SharedTriangleMasterLab extends StatefulWidget {
  const _SharedTriangleMasterLab({
    required this.card,
    required this.fg,
    required this.muted,
    required this.onBackToSquare,
    required this.onBackToCircle,
  });

  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onBackToSquare;
  final VoidCallback onBackToCircle;

  @override
  State<_SharedTriangleMasterLab> createState() =>
      _SharedTriangleMasterLabState();
}

class _SharedTriangleMasterLabState extends State<_SharedTriangleMasterLab> {
  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final selected = softBasicTriangleGeometryRound1Candidates[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Soft Basic · Triangle · Geometry Round 1',
          subtitle:
              '정삼각형 비율은 고정하고 꼭짓점 corner round만 2/3/4/5px로 비교합니다. Crayon Soft는 현재 외형을 Frozen Reference로 유지하며 이번 라운드에서 변경하지 않습니다.',
          fg: widget.fg,
          muted: widget.muted,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            TextButton.icon(
              onPressed: widget.onBackToSquare,
              icon: const Icon(Icons.crop_square_rounded, size: 16),
              label: const Text('Square Master 보기'),
            ),
            TextButton.icon(
              onPressed: widget.onBackToCircle,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Circle Master 보기'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980 ? 4 : 2;
            final gap = compact ? 8.0 : 12.0;
            final itemWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0;
                    i < softBasicTriangleGeometryRound1Candidates.length;
                    i++)
                  SizedBox(
                    width: itemWidth,
                    child: _TriangleGeometryCandidateCard(
                      candidate:
                          softBasicTriangleGeometryRound1Candidates[i],
                      selected: selectedIndex == i,
                      card: widget.card,
                      fg: widget.fg,
                      muted: widget.muted,
                      onTap: () => setState(() => selectedIndex = i),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _TriangleGeometryComparePanel(
          candidate: selected,
          card: widget.card,
          fg: widget.fg,
          muted: widget.muted,
        ),
      ],
    );
  }
}

class _TriangleGeometryCandidateCard extends StatelessWidget {
  const _TriangleGeometryCandidateCard({
    required this.candidate,
    required this.selected,
    required this.card,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  final SoftBasicTriangleGeometryCandidate candidate;
  final bool selected;
  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 174,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7257F5)
                  : const Color(0xFFE6E3EE),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      candidate.id,
                      style: TextStyle(
                        color: fg,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (candidate.badge != null)
                    Text(
                      candidate.badge!,
                      style: const TextStyle(
                        color: Color(0xFF7257F5),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
              Text(
                candidate.name,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final tone in const [
                    ShapeTone.pink,
                    ShapeTone.blue,
                    ShapeTone.yellow,
                  ])
                    _TriangleGeometryToken(
                      tone: tone,
                      candidate: candidate,
                      size: 54,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                candidate.intent,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: muted,
                  fontSize: 9.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TriangleGeometryComparePanel extends StatelessWidget {
  const _TriangleGeometryComparePanel({
    required this.candidate,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final SoftBasicTriangleGeometryCandidate candidate;
  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];

    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${candidate.id} · ${candidate.name} · R=${candidate.cornerRadius.toStringAsFixed(0)}px',
            style: TextStyle(
              color: fg,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            candidate.intent,
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Text(
            '96px ENLARGED · BASIC CANDIDATE ↔ CRAYON FROZEN',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          for (final tone in tones) ...[
            _TriangleGeometryToneRow(
              tone: tone,
              candidate: candidate,
              size: 96,
              fg: fg,
              muted: muted,
            ),
            if (tone != tones.last) const SizedBox(height: 12),
          ],
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE8E5EF), height: 1),
          const SizedBox(height: 14),
          Text(
            '58px APP EXACT SCALE',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          for (final tone in tones) ...[
            _TriangleGeometryToneRow(
              tone: tone,
              candidate: candidate,
              size: 58,
              fg: fg,
              muted: muted,
            ),
            if (tone != tones.last) const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _TriangleGeometryToneRow extends StatelessWidget {
  const _TriangleGeometryToneRow({
    required this.tone,
    required this.candidate,
    required this.size,
    required this.fg,
    required this.muted,
  });

  final ShapeTone tone;
  final SoftBasicTriangleGeometryCandidate candidate;
  final double size;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            tone.label,
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: _CompareTokenCell(
            label: 'SOFT BASIC · R=${candidate.cornerRadius.toStringAsFixed(0)}',
            token: _TriangleGeometryToken(
              tone: tone,
              candidate: candidate,
              size: size,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _CompareTokenCell(
            label: 'CRAYON · FROZEN',
            token: _ProductionTriangleToken(
              tone: tone,
              style: ShapeStyle.crayonSoft,
              size: size,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
      ],
    );
  }
}

class _TriangleGeometryToken extends StatelessWidget {
  const _TriangleGeometryToken({
    required this.tone,
    required this.candidate,
    required this.size,
  });

  final ShapeTone tone;
  final SoftBasicTriangleGeometryCandidate candidate;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _TriangleGeometryPainter(
          tone: tone,
          candidate: candidate,
        ),
      ),
    );
  }
}

class _TriangleGeometryPainter extends CustomPainter {
  const _TriangleGeometryPainter({
    required this.tone,
    required this.candidate,
  });

  final ShapeTone tone;
  final SoftBasicTriangleGeometryCandidate candidate;

  @override
  void paint(Canvas canvas, Size size) {
    ShapeSpecRenderer.paintToken(
      canvas,
      center: size.center(Offset.zero),
      radius: size.shortestSide * 0.43,
      token: LockToken(shape: ShapeKind.triangle, tone: tone),
      style: ShapeStyle.softBasic,
      opacity: 1,
      overrides: ShapeRenderOverrides(
        bodyGeometry: ShapeGeometrySpec(
          'roundedPolygon',
          <String, dynamic>{
            'kind': 'roundedPolygon',
            'cornerRadius': candidate.cornerRadius,
            'points': const <dynamic>[
              <dynamic>[50.0, 11.9],
              <dynamic>[94.0, 88.1],
              <dynamic>[6.0, 88.1],
            ],
          },
        ),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _TriangleGeometryPainter oldDelegate) =>
      oldDelegate.tone != tone ||
      oldDelegate.candidate.id != candidate.id;
}

class _ProductionTriangleToken extends StatelessWidget {
  const _ProductionTriangleToken({
    required this.tone,
    required this.style,
    required this.size,
  });

  final ShapeTone tone;
  final ShapeStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: LockTokenPainter(
          LockToken(shape: ShapeKind.triangle, tone: tone),
          style: style,
        ),
      ),
    );
  }
}

class _SoftBasicCircleSquareComparePanel extends StatelessWidget {
  const _SoftBasicCircleSquareComparePanel({
    required this.squareCandidate,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final SoftBasicSquareCandidate squareCandidate;
  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final circleMaster = softBasicCircleRound9NaturalCandidates[2];
    const tones = [
      ShapeTone.pink,
      ShapeTone.blue,
      ShapeTone.yellow,
    ];

    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Circle Master R9N-03  ↔  ' +
                squareCandidate.id +
                ' · ' +
                squareCandidate.name,
            style: TextStyle(
              color: fg,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            squareCandidate.intent,
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Text(
            '96px ENLARGED · SAME PALETTE',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          for (final tone in tones) ...[
            _CircleSquareToneRow(
              tone: tone,
              circleMaster: circleMaster,
              squareCandidate: squareCandidate,
              size: 96,
              compact: compact,
              fg: fg,
              muted: muted,
            ),
            if (tone != tones.last) const SizedBox(height: 12),
          ],
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE8E5EF), height: 1),
          const SizedBox(height: 14),
          Text(
            '58px APP EXACT',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          for (final tone in tones) ...[
            _CircleSquareToneRow(
              tone: tone,
              circleMaster: circleMaster,
              squareCandidate: squareCandidate,
              size: 58,
              compact: compact,
              fg: fg,
              muted: muted,
            ),
            if (tone != tones.last) const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _CircleSquareToneRow extends StatelessWidget {
  const _CircleSquareToneRow({
    required this.tone,
    required this.circleMaster,
    required this.squareCandidate,
    required this.size,
    required this.compact,
    required this.fg,
    required this.muted,
  });

  final ShapeTone tone;
  final SoftBasicCandidate circleMaster;
  final SoftBasicSquareCandidate squareCandidate;
  final double size;
  final bool compact;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final gap = compact ? 10.0 : 18.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: compact ? 42 : 58,
          child: Text(
            tone.label,
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: _CompareTokenCell(
            label: 'CIRCLE · R9N-03',
            token: _SoftBasicExactToken(
              shape: ShapeKind.circle,
              tone: tone,
              candidate: circleMaster,
              size: size,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _CompareTokenCell(
            label: 'SQUARE · ' + squareCandidate.id,
            token: _SoftBasicSquareExactToken(
              tone: tone,
              candidate: squareCandidate,
              size: size,
            ),
            fg: fg,
            muted: muted,
          ),
        ),
      ],
    );
  }
}

class _CompareTokenCell extends StatelessWidget {
  const _CompareTokenCell({
    required this.label,
    required this.token,
    required this.fg,
    required this.muted,
  });

  final String label;
  final Widget token;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAE7F0)),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: muted,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Center(child: token),
        ],
      ),
    );
  }
}

class _SoftBasicSquareCandidateCard extends StatelessWidget {
  const _SoftBasicSquareCandidateCard({
    required this.candidate,
    required this.selected,
    required this.card,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  final SoftBasicSquareCandidate candidate;
  final bool selected;
  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 176,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7257F5)
                  : const Color(0xFFE6E3EE),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      candidate.id,
                      style: TextStyle(
                        color: fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (candidate.badge != null)
                    Text(
                      candidate.badge!,
                      style: const TextStyle(
                        color: Color(0xFF7257F5),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
              Text(
                candidate.name,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final tone in const [
                    ShapeTone.pink,
                    ShapeTone.blue,
                    ShapeTone.yellow,
                  ])
                    _SoftBasicSquareExactToken(
                      tone: tone,
                      candidate: candidate,
                      size: 58,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                candidate.intent,
                style: TextStyle(
                  color: muted,
                  fontSize: 9.5,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftBasicSquareExactToken extends StatelessWidget {
  const _SoftBasicSquareExactToken({
    required this.tone,
    required this.candidate,
    required this.size,
  });

  final ShapeTone tone;
  final SoftBasicSquareCandidate candidate;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _SoftBasicSquareCandidatePainter(
          tone: tone,
          candidate: candidate,
        ),
      ),
    );
  }
}

class _SoftBasicSquareCandidatePainter extends CustomPainter {
  const _SoftBasicSquareCandidatePainter({
    required this.tone,
    required this.candidate,
  });

  final ShapeTone tone;
  final SoftBasicSquareCandidate candidate;

  @override
  void paint(Canvas canvas, Size size) {
    final base = baseColorForTone(tone);
    final light = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.10 : 0.16,
      saturationDelta: -0.04,
    );
    final deep = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? -0.10 : -0.13,
      saturationDelta: 0.02,
    );
    final bounce = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.075 : 0.11,
      saturationDelta: -0.025,
    );

    final inset = size.shortestSide * 0.07;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    final radiusFactor = switch (candidate.technique) {
      SoftBasicSquareTechnique.softerCorner => 0.31,
      SoftBasicSquareTechnique.tighterCorner => 0.20,
      _ => 0.26,
    };
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * radiusFactor),
    );
    final bodyPath = Path()..addRRect(rrect);
    final profile = candidate.materialProfile;

    final shadowAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.075,
      SoftBasicSquareMaterialProfile.highSpec => 0.060,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.060,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.052,
      SoftBasicSquareMaterialProfile.softGloss => 0.050,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.052,
      SoftBasicSquareMaterialProfile.legacy => 0.035,
    };
    final shadowElevation = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.060,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.052,
      _ => 0.035,
    };

    canvas.drawShadow(
      bodyPath,
      Colors.black.withValues(alpha: shadowAlpha),
      size.shortestSide * shadowElevation,
      true,
    );

    final shellAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.42,
      SoftBasicSquareMaterialProfile.highSpec => 0.36,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.38,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.34,
      SoftBasicSquareMaterialProfile.softGloss => 0.32,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.32,
      SoftBasicSquareMaterialProfile.legacy => 0.28,
    };
    canvas.drawRRect(
      rrect,
      Paint()..color = deep.withValues(alpha: shellAlpha),
    );

    final inner = RRect.fromRectAndRadius(
      rect.deflate(rect.width * 0.015),
      Radius.circular(rect.width * radiusFactor * 0.97),
    );
    canvas.drawRRect(inner, Paint()..color = base);

    final upperAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.64,
      SoftBasicSquareMaterialProfile.highSpec => 0.60,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.57,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.54,
      SoftBasicSquareMaterialProfile.softGloss => 0.52,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.50,
      SoftBasicSquareMaterialProfile.legacy => 0.46,
    };
    final deepAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.42,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.38,
      SoftBasicSquareMaterialProfile.highSpec => 0.37,
      _ => profile == SoftBasicSquareMaterialProfile.legacy ? 0.34 : 0.36,
    };
    final baseBounceAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.31,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.34,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.28,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.24,
      SoftBasicSquareMaterialProfile.softGloss => 0.23,
      SoftBasicSquareMaterialProfile.highSpec => 0.20,
      SoftBasicSquareMaterialProfile.legacy =>
        candidate.technique == SoftBasicSquareTechnique.strongerBounce
            ? 0.22
            : 0.16,
    };
    final baseBounceWidth = switch (profile) {
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.96,
      SoftBasicSquareMaterialProfile.mockupGloss => 0.86,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.84,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.82,
      _ => 0.76,
    };
    final baseBounceHeight = switch (profile) {
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.38,
      SoftBasicSquareMaterialProfile.mockupGloss => 0.35,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.33,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.32,
      _ => 0.30,
    };
    final bounceAlpha = baseBounceAlpha * (switch (candidate.glossRefinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 1.05,
      SoftBasicSquareGlossRefinement.highCompactCore => 0.98,
      SoftBasicSquareGlossRefinement.balancedBright => 1.06,
      SoftBasicSquareGlossRefinement.balancedWide => 1.12,
    });
    final bounceWidth = baseBounceWidth * (switch (candidate.glossRefinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 1.03,
      SoftBasicSquareGlossRefinement.highCompactCore => 1.0,
      SoftBasicSquareGlossRefinement.balancedBright => 1.0,
      SoftBasicSquareGlossRefinement.balancedWide => 1.10,
    });
    final bounceHeight = baseBounceHeight * (switch (candidate.glossRefinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 1.03,
      SoftBasicSquareGlossRefinement.highCompactCore => 1.0,
      SoftBasicSquareGlossRefinement.balancedBright => 1.0,
      SoftBasicSquareGlossRefinement.balancedWide => 1.12,
    });

    canvas.save();
    canvas.clipRRect(inner);

    canvas.drawCircle(
      Offset(
        rect.left + rect.width * 0.28,
        rect.top + rect.height * 0.27,
      ),
      rect.width * 0.42,
      Paint()
        ..color = light.withValues(alpha: upperAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.17,
        ),
    );

    canvas.drawCircle(
      Offset(
        rect.right - rect.width * 0.16,
        rect.bottom - rect.height * 0.14,
      ),
      rect.width * 0.43,
      Paint()
        ..color = deep.withValues(alpha: deepAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.21,
        ),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          rect.left + rect.width * 0.56,
          rect.top + rect.height * 0.80,
        ),
        width: rect.width * bounceWidth,
        height: rect.height * bounceHeight,
      ),
      Paint()
        ..color = bounce.withValues(alpha: bounceAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.095,
        ),
    );

    canvas.restore();

    if (profile == SoftBasicSquareMaterialProfile.legacy) {
      _paintSquareReferenceHighlight(
        canvas,
        rect,
        size,
        candidate.highlightTechnique,
      );
    } else {
      _paintSquareGlossProfile(canvas, rect, size, base, light, profile, candidate.glossRefinement);
    }
  }

  void _paintSquareGlossProfile(
    Canvas canvas,
    Rect rect,
    Size size,
    Color base,
    Color light,
    SoftBasicSquareMaterialProfile profile,
    SoftBasicSquareGlossRefinement refinement,
  ) {
    final edgeGlow = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.080 : 0.125,
      saturationDelta: -0.025,
    );

    final basePatchScale = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 1.08,
      SoftBasicSquareMaterialProfile.highSpec => 0.96,
      SoftBasicSquareMaterialProfile.balancedGloss => 1.00,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.92,
      SoftBasicSquareMaterialProfile.softGloss => 1.02,
      SoftBasicSquareMaterialProfile.wideDiffuse => 1.16,
      SoftBasicSquareMaterialProfile.legacy => 0.92,
    };
    final patchScale = basePatchScale * (switch (refinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 1.13,
      SoftBasicSquareGlossRefinement.highCompactCore => 1.02,
      SoftBasicSquareGlossRefinement.balancedBright => 1.02,
      SoftBasicSquareGlossRefinement.balancedWide => 1.15,
    });
    final basePatchAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.72,
      SoftBasicSquareMaterialProfile.highSpec => 0.76,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.64,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.54,
      SoftBasicSquareMaterialProfile.softGloss => 0.52,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.44,
      SoftBasicSquareMaterialProfile.legacy => 0.54,
    };
    final patchAlpha = (basePatchAlpha * (switch (refinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 0.90,
      SoftBasicSquareGlossRefinement.highCompactCore => 0.98,
      SoftBasicSquareGlossRefinement.balancedBright => 1.12,
      SoftBasicSquareGlossRefinement.balancedWide => 0.92,
    })).clamp(0.0, 1.0).toDouble();
    final haloAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.28,
      SoftBasicSquareMaterialProfile.highSpec => 0.22,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.24,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.18,
      SoftBasicSquareMaterialProfile.softGloss => 0.20,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.30,
      SoftBasicSquareMaterialProfile.legacy => 0.18,
    };
    final baseCoreAlpha = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 0.92,
      SoftBasicSquareMaterialProfile.highSpec => 1.00,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.88,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.76,
      SoftBasicSquareMaterialProfile.softGloss => 0.70,
      SoftBasicSquareMaterialProfile.wideDiffuse => 0.54,
      SoftBasicSquareMaterialProfile.legacy => 0.76,
    };
    final coreAlpha = (baseCoreAlpha * (switch (refinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 0.92,
      SoftBasicSquareGlossRefinement.highCompactCore => 1.0,
      SoftBasicSquareGlossRefinement.balancedBright => 1.08,
      SoftBasicSquareGlossRefinement.balancedWide => 0.88,
    })).clamp(0.0, 1.0).toDouble();
    final baseCoreScale = switch (profile) {
      SoftBasicSquareMaterialProfile.mockupGloss => 1.00,
      SoftBasicSquareMaterialProfile.highSpec => 0.90,
      SoftBasicSquareMaterialProfile.balancedGloss => 0.95,
      SoftBasicSquareMaterialProfile.circleTransfer => 0.88,
      SoftBasicSquareMaterialProfile.softGloss => 1.04,
      SoftBasicSquareMaterialProfile.wideDiffuse => 1.08,
      SoftBasicSquareMaterialProfile.legacy => 0.88,
    };
    final coreScale = baseCoreScale * (switch (refinement) {
      SoftBasicSquareGlossRefinement.base => 1.0,
      SoftBasicSquareGlossRefinement.highSoftPatch => 0.96,
      SoftBasicSquareGlossRefinement.highCompactCore => 0.74,
      SoftBasicSquareGlossRefinement.balancedBright => 0.94,
      SoftBasicSquareGlossRefinement.balancedWide => 0.88,
    });

    final clip = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * 0.20),
    );

    Path buildPatch(double scale) {
      final p = Path()
        ..moveTo(
          rect.left + rect.width * (0.105),
          rect.top + rect.height * (0.390 * scale),
        )
        ..cubicTo(
          rect.left + rect.width * 0.085,
          rect.top + rect.height * 0.285,
          rect.left + rect.width * 0.090,
          rect.top + rect.height * 0.165,
          rect.left + rect.width * 0.205,
          rect.top + rect.height * 0.105,
        )
        ..cubicTo(
          rect.left + rect.width * 0.275,
          rect.top + rect.height * 0.070,
          rect.left + rect.width * (0.405 * scale),
          rect.top + rect.height * 0.085,
          rect.left + rect.width * (0.430 * scale),
          rect.top + rect.height * 0.150,
        )
        ..cubicTo(
          rect.left + rect.width * (0.445 * scale),
          rect.top + rect.height * 0.205,
          rect.left + rect.width * (0.365 * scale),
          rect.top + rect.height * 0.245,
          rect.left + rect.width * 0.305,
          rect.top + rect.height * 0.285,
        )
        ..cubicTo(
          rect.left + rect.width * 0.245,
          rect.top + rect.height * 0.325,
          rect.left + rect.width * 0.165,
          rect.top + rect.height * (0.420 * scale),
          rect.left + rect.width * 0.105,
          rect.top + rect.height * (0.390 * scale),
        )
        ..close();
      return p;
    }

    final patch = buildPatch(patchScale);

    canvas.save();
    canvas.clipRRect(clip);

    // Wide face light: the mockup reads as a lit corner surface, not a line.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          rect.left + rect.width * 0.235,
          rect.top + rect.height * 0.235,
        ),
        width: rect.width * 0.50 * patchScale,
        height: rect.height * 0.47 * patchScale,
      ),
      Paint()
        ..color = edgeGlow.withValues(alpha: haloAlpha * 0.72)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.090,
        ),
    );

    // Soft Spec: broad filled patch that wraps the upper-left corner.
    canvas.drawPath(
      patch,
      Paint()
        ..color = Colors.white.withValues(alpha: haloAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.052,
        ),
    );
    canvas.drawPath(
      patch,
      Paint()
        ..color = Colors.white.withValues(alpha: patchAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.017,
        ),
    );

    final hideCore =
        refinement == SoftBasicSquareGlossRefinement.highCompactCore;

    if (!hideCore) {
      // Core Spec: optional compact interior glint for non-master variants.
      final coreRect = Rect.fromCenter(
      center: Offset(
        rect.left + rect.width * 0.235,
        rect.top + rect.height * 0.205,
      ),
      width: rect.width * 0.105 * coreScale,
      height: rect.height * 0.165 * coreScale,
    );
    final core = RRect.fromRectAndRadius(
      coreRect,
      Radius.circular(coreRect.width * 0.50),
    );
    canvas.save();
    canvas.translate(coreRect.center.dx, coreRect.center.dy);
    canvas.rotate(0.34);
    canvas.translate(-coreRect.center.dx, -coreRect.center.dy);
    canvas.drawRRect(
      core,
      Paint()
        ..color = Colors.white.withValues(alpha: coreAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.007,
        ),
    );
    canvas.restore();

    // Small secondary sparkle only for the glossier profiles.
      if (profile == SoftBasicSquareMaterialProfile.mockupGloss ||
          profile == SoftBasicSquareMaterialProfile.highSpec ||
          profile == SoftBasicSquareMaterialProfile.balancedGloss) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.320,
              rect.top + rect.height * 0.145,
            ),
            width: rect.width * 0.030,
            height: rect.height * 0.046,
          ),
          Paint()
            ..color = Colors.white.withValues(alpha: coreAlpha * 0.82)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.004,
            ),
        );
      }
    }
    canvas.restore();
  }

  void _paintSquareReferenceHighlight(
    Canvas canvas,
    Rect rect,
    Size size,
    SoftBasicSquareHighlightTechnique technique,
  ) {
    switch (technique) {
      case SoftBasicSquareHighlightTechnique.flatInset:
        _paintGlossPill(
          canvas,
          center: Offset(
            rect.left + rect.width * 0.245,
            rect.top + rect.height * 0.255,
          ),
          width: rect.width * 0.145,
          height: rect.height * 0.285,
          rotation: 0.30,
          softAlpha: 0.20,
          faceAlpha: 0.76,
          blur: size.shortestSide * 0.020,
        );
      case SoftBasicSquareHighlightTechnique.shortCompact:
        _paintGlossPill(
          canvas,
          center: Offset(
            rect.left + rect.width * 0.235,
            rect.top + rect.height * 0.245,
          ),
          width: rect.width * 0.170,
          height: rect.height * 0.245,
          rotation: 0.26,
          softAlpha: 0.22,
          faceAlpha: 0.70,
          blur: size.shortestSide * 0.024,
        );
      case SoftBasicSquareHighlightTechnique.taperedEdge:
        final path = Path()
          ..moveTo(
            rect.left + rect.width * 0.185,
            rect.top + rect.height * 0.365,
          )
          ..cubicTo(
            rect.left + rect.width * 0.150,
            rect.top + rect.height * 0.305,
            rect.left + rect.width * 0.165,
            rect.top + rect.height * 0.205,
            rect.left + rect.width * 0.235,
            rect.top + rect.height * 0.135,
          )
          ..cubicTo(
            rect.left + rect.width * 0.275,
            rect.top + rect.height * 0.095,
            rect.left + rect.width * 0.330,
            rect.top + rect.height * 0.105,
            rect.left + rect.width * 0.342,
            rect.top + rect.height * 0.145,
          )
          ..cubicTo(
            rect.left + rect.width * 0.350,
            rect.top + rect.height * 0.175,
            rect.left + rect.width * 0.325,
            rect.top + rect.height * 0.205,
            rect.left + rect.width * 0.300,
            rect.top + rect.height * 0.235,
          )
          ..cubicTo(
            rect.left + rect.width * 0.260,
            rect.top + rect.height * 0.285,
            rect.left + rect.width * 0.220,
            rect.top + rect.height * 0.350,
            rect.left + rect.width * 0.185,
            rect.top + rect.height * 0.365,
          )
          ..close();

        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.18)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.055,
            ),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.72)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.018,
            ),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.280,
              rect.top + rect.height * 0.145,
            ),
            width: rect.width * 0.040,
            height: rect.height * 0.065,
          ),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.92)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.009,
            ),
        );
      case SoftBasicSquareHighlightTechnique.cornerKiss:
        final cornerGlow = adjustTone(
          baseColorForTone(tone),
          lightnessDelta: tone == ShapeTone.yellow ? 0.08 : 0.12,
          saturationDelta: -0.02,
        );
        final kissRect = Rect.fromCenter(
          center: Offset(
            rect.left + rect.width * 0.205,
            rect.top + rect.height * 0.205,
          ),
          width: rect.width * 0.23,
          height: rect.height * 0.12,
        );
        canvas.save();
        canvas.clipRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(rect.width * 0.20),
          ),
        );
        canvas.drawArc(
          kissRect,
          3.55,
          1.45,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.030
            ..strokeCap = StrokeCap.round
            ..color = cornerGlow.withValues(alpha: 0.34)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.018,
            ),
        );
        canvas.restore();

      case SoftBasicSquareHighlightTechnique.softFacet:
        final facetGlow = adjustTone(
          baseColorForTone(tone),
          lightnessDelta: tone == ShapeTone.yellow ? 0.07 : 0.105,
          saturationDelta: -0.018,
        );
        final facet = Path()
          ..moveTo(
            rect.left + rect.width * 0.08,
            rect.top + rect.height * 0.31,
          )
          ..quadraticBezierTo(
            rect.left + rect.width * 0.10,
            rect.top + rect.height * 0.11,
            rect.left + rect.width * 0.30,
            rect.top + rect.height * 0.08,
          )
          ..quadraticBezierTo(
            rect.left + rect.width * 0.40,
            rect.top + rect.height * 0.09,
            rect.left + rect.width * 0.34,
            rect.top + rect.height * 0.20,
          )
          ..quadraticBezierTo(
            rect.left + rect.width * 0.23,
            rect.top + rect.height * 0.29,
            rect.left + rect.width * 0.08,
            rect.top + rect.height * 0.31,
          )
          ..close();
        canvas.save();
        canvas.clipRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(rect.width * 0.20),
          ),
        );
        canvas.drawPath(
          facet,
          Paint()
            ..color = facetGlow.withValues(alpha: 0.18)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.050,
            ),
        );
        canvas.drawPath(
          facet,
          Paint()
            ..color = facetGlow.withValues(alpha: 0.10)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.018,
            ),
        );
        canvas.restore();

      case SoftBasicSquareHighlightTechnique.edgeFade:
        final edgeGlow = adjustTone(
          baseColorForTone(tone),
          lightnessDelta: tone == ShapeTone.yellow ? 0.075 : 0.115,
          saturationDelta: -0.02,
        );
        final rounded = RRect.fromRectAndRadius(
          rect.deflate(rect.width * 0.022),
          Radius.circular(rect.width * 0.20 * 0.97),
        );
        final edgeBounds = Rect.fromLTWH(
          rect.left,
          rect.top,
          rect.width * 0.52,
          rect.height * 0.48,
        );
        canvas.save();
        canvas.clipRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(rect.width * 0.20),
          ),
        );
        canvas.drawRRect(
          rounded,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.025
            ..shader = LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                edgeGlow.withValues(alpha: 0.00),
                edgeGlow.withValues(alpha: 0.28),
                edgeGlow.withValues(alpha: 0.08),
                edgeGlow.withValues(alpha: 0.00),
              ],
              stops: const [0.0, 0.42, 0.70, 1.0],
            ).createShader(edgeBounds)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.shortestSide * 0.016,
            ),
        );
        canvas.restore();

      case SoftBasicSquareHighlightTechnique.round1Base:
        _paintGlossPill(
          canvas,
          center: Offset(
            rect.left + rect.width * 0.225,
            rect.top + rect.height * 0.245,
          ),
          width: rect.width * 0.130,
          height: rect.height * 0.225,
          rotation: 0.22,
          softAlpha: 0.16,
          faceAlpha: 0.68,
          blur: size.shortestSide * 0.023,
        );
    }
  }

  void _paintGlossPill(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required double rotation,
    required double softAlpha,
    required double faceAlpha,
    required double blur,
    double coreAlpha = 0.94,
  }) {
    final pillRect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );
    final pill = RRect.fromRectAndRadius(
      pillRect,
      Radius.circular(width * 0.52),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawRRect(
      pill.inflate(width * 0.12),
      Paint()
        ..color = Colors.white.withValues(alpha: softAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          blur * 2.6,
        ),
    );

    canvas.drawRRect(
      pill,
      Paint()
        ..color = Colors.white.withValues(alpha: faceAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          blur,
        ),
    );

    final coreCenter = Offset(
      center.dx + width * 0.05,
      center.dy - height * 0.29,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: coreCenter,
        width: width * 0.30,
        height: height * 0.16,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: coreAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          blur * 0.45,
        ),
    );

    canvas.restore();
  }



  @override
  bool shouldRepaint(covariant _SoftBasicSquareCandidatePainter oldDelegate) {
    return oldDelegate.tone != tone ||
        oldDelegate.candidate.id != candidate.id;
  }
}

class _SoftBasicCandidateCard extends StatelessWidget {
  const _SoftBasicCandidateCard({
    required this.candidate,
    required this.selected,
    required this.card,
    required this.fg,
    required this.muted,
    required this.onTap,
  });

  final SoftBasicCandidate candidate;
  final bool selected;
  final Color card;
  final Color fg;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 166,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7257F5)
                  : const Color(0xFFE6E3EE),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      candidate.id,
                      style: TextStyle(
                        color: fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (candidate.badge != null)
                    Text(
                      candidate.badge!,
                      style: const TextStyle(
                        color: Color(0xFF7257F5),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
              Text(
                candidate.name,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final tone in tones)
                    _SoftBasicExactToken(
                      shape: ShapeKind.circle,
                      tone: tone,
                      candidate: candidate,
                      size: 58,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                candidate.intent,
                style: TextStyle(color: muted, fontSize: 9.5, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftBasicDetailPanel extends StatelessWidget {
  const _SoftBasicDetailPanel({
    required this.candidate,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final SoftBasicCandidate candidate;
  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];
    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            candidate.id + ' · ' + candidate.name,
            style: TextStyle(
              color: fg,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(candidate.intent, style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 14),
          Text(
            'Circle · Pink / Blue / Yellow · 58px APP EXACT',
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 150,
                child: Column(
                  children: [
                    _SoftBasicExactToken(
                      shape: ShapeKind.circle,
                      tone: ShapeTone.pink,
                      candidate: candidate,
                      size: 132,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pink · enlarged',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final tone in tones)
                      SizedBox(
                        width: 76,
                        child: Column(
                          children: [
                            _SoftBasicExactToken(
                              shape: ShapeKind.circle,
                              tone: tone,
                              candidate: candidate,
                              size: 58,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tone.label,
                              style: TextStyle(color: muted, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftBasicExactToken extends StatelessWidget {
  const _SoftBasicExactToken({
    required this.shape,
    required this.tone,
    required this.candidate,
    required this.size,
  });

  final ShapeKind shape;
  final ShapeTone tone;
  final SoftBasicCandidate candidate;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _SoftBasicCandidatePainter(
          shape: shape,
          tone: tone,
          candidate: candidate,
        ),
      ),
    );
  }
}

class _SoftBasicCandidatePainter extends CustomPainter {
  const _SoftBasicCandidatePainter({
    required this.shape,
    required this.tone,
    required this.candidate,
  });

  final ShapeKind shape;
  final ShapeTone tone;
  final SoftBasicCandidate candidate;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.44;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = baseColorForTone(tone);
    final light = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.10 : 0.16,
      saturationDelta: -0.04,
    );
    final deep = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? -0.13 : -0.16,
      saturationDelta: 0.03,
    );
    final rimLight = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.10 : 0.14,
      saturationDelta: -0.03,
    );
    final rimDeep = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? -0.08 : -0.10,
      saturationDelta: 0.02,
    );

    _paintAirbrushBody(canvas, rect, base, light, deep);

    switch (candidate.finishTechnique) {
      case SoftBasicCircleFinishTechnique.outlineBase:
        break;
      case SoftBasicCircleFinishTechnique.softInnerRim:
        _paintSoftInnerRim(canvas, rect, rimLight, alpha: 0.34, width: 0.040);
      case SoftBasicCircleFinishTechnique.colorShell:
        _paintColorShell(canvas, rect, rimDeep, alpha: 0.28, width: 0.028);
      case SoftBasicCircleFinishTechnique.lowerRim:
        _paintLowerRim(canvas, rect, rimLight, alpha: 0.42, width: 0.050);
      case SoftBasicCircleFinishTechnique.cleanOutline:
        _paintCleanOutline(canvas, rect, rimDeep, alpha: 0.22, width: 0.020);
      case SoftBasicCircleFinishTechnique.premiumRim:
        _paintColorShell(canvas, rect, rimDeep, alpha: 0.20, width: 0.024);
        _paintSoftInnerRim(canvas, rect, rimLight, alpha: 0.36, width: 0.042);
        _paintLowerRim(canvas, rect, rimLight, alpha: 0.24, width: 0.048);
    }

    _paintBottomHighlight(
      canvas,
      rect,
      rimLight,
      candidate.bottomHighlightTechnique,
    );
    _paintLowerVolume(
      canvas,
      rect,
      base,
      light,
      deep,
      candidate.lowerVolumeTechnique,
    );
    _paintEdgeLeafBase(canvas, rect);
  }

  void _paintAirbrushBody(
    Canvas canvas,
    Rect rect,
    Color base,
    Color light,
    Color deep,
  ) {
    _drawSoftShadow(canvas, rect, deep, 0.18, 5.5);
    canvas.drawOval(rect, Paint()..color = base);

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    final r = rect.width;

    canvas.drawCircle(
      Offset(rect.left + r * 0.29, rect.top + r * 0.28),
      r * 0.42,
      Paint()
        ..color = light.withValues(alpha: 0.48)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13),
    );

    canvas.drawCircle(
      Offset(rect.right - r * 0.18, rect.bottom - r * 0.14),
      r * 0.43,
      Paint()
        ..color = deep.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    canvas.restore();
  }

  void _paintEdgeLeafBase(Canvas canvas, Rect rect) {
    final path = _baseEdgeLeafPath(rect);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.76 * 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.9),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.76)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
    );
  }

  void _paintLowerVolume(
    Canvas canvas,
    Rect rect,
    Color base,
    Color light,
    Color deep,
    SoftBasicLowerVolumeTechnique technique,
  ) {
    if (technique == SoftBasicLowerVolumeTechnique.none) return;

    final tintedLight = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.075 : 0.11,
      saturationDelta: -0.025,
    );
    final softBase = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.035 : 0.055,
      saturationDelta: -0.015,
    );
    final strongerTintedLight = adjustTone(
      base,
      lightnessDelta: tone == ShapeTone.yellow ? 0.11 : 0.17,
      saturationDelta: -0.035,
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    switch (technique) {
      case SoftBasicLowerVolumeTechnique.none:
        break;

      case SoftBasicLowerVolumeTechnique.tintedBloom:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.center.dx,
              rect.top + rect.height * 0.77,
            ),
            width: rect.width * 0.68,
            height: rect.height * 0.29,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.center.dx,
              rect.top + rect.height * 0.80,
            ),
            width: rect.width * 0.46,
            height: rect.height * 0.15,
          ),
          Paint()
            ..color = softBase.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.6),
        );

      case SoftBasicLowerVolumeTechnique.embeddedLight:
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.58,
            rect.top + rect.height * 0.72,
          ),
          rect.width * 0.24,
          Paint()
            ..color = tintedLight.withValues(alpha: 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.5),
        );
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.60,
            rect.top + rect.height * 0.73,
          ),
          rect.width * 0.11,
          Paint()
            ..color = light.withValues(alpha: 0.10)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
        );

      case SoftBasicLowerVolumeTechnique.liftGradient:
        final shaderRect = Rect.fromLTWH(
          rect.left,
          rect.top + rect.height * 0.42,
          rect.width,
          rect.height * 0.58,
        );
        canvas.drawRect(
          shaderRect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                base.withValues(alpha: 0.00),
                softBase.withValues(alpha: 0.06),
                tintedLight.withValues(alpha: 0.18),
              ],
              stops: const [0.0, 0.50, 1.0],
            ).createShader(shaderRect),
        );

      case SoftBasicLowerVolumeTechnique.shadowCarve:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.68,
              rect.top + rect.height * 0.72,
            ),
            width: rect.width * 0.54,
            height: rect.height * 0.46,
          ),
          Paint()
            ..color = base.withValues(alpha: 0.17)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.63,
              rect.top + rect.height * 0.76,
            ),
            width: rect.width * 0.34,
            height: rect.height * 0.20,
          ),
          Paint()
            ..color = softBase.withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounce:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.57,
              rect.top + rect.height * 0.79,
            ),
            width: rect.width * 0.78,
            height: rect.height * 0.34,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0),
        );
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.63,
            rect.top + rect.height * 0.72,
          ),
          rect.width * 0.13,
          Paint()
            ..color = light.withValues(alpha: 0.09)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.center.dx,
              rect.top + rect.height * 0.91,
            ),
            width: rect.width * 0.56,
            height: rect.height * 0.12,
          ),
          Paint()
            ..color = deep.withValues(alpha: 0.045)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounceStrong:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.57,
              rect.top + rect.height * 0.79,
            ),
            width: rect.width * 0.78,
            height: rect.height * 0.34,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.21)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9.0),
        );
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.63,
            rect.top + rect.height * 0.72,
          ),
          rect.width * 0.14,
          Paint()
            ..color = light.withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounceWide:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.55,
              rect.top + rect.height * 0.76,
            ),
            width: rect.width * 0.94,
            height: rect.height * 0.47,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.19)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9.5),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.60,
              rect.top + rect.height * 0.73,
            ),
            width: rect.width * 0.48,
            height: rect.height * 0.24,
          ),
          Paint()
            ..color = softBase.withValues(alpha: 0.13)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.5),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounceContrast:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.57,
              rect.top + rect.height * 0.78,
            ),
            width: rect.width * 0.80,
            height: rect.height * 0.36,
          ),
          Paint()
            ..color = strongerTintedLight.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0),
        );
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.62,
            rect.top + rect.height * 0.72,
          ),
          rect.width * 0.15,
          Paint()
            ..color = strongerTintedLight.withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounceAsymmetric:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.45,
              rect.top + rect.height * 0.80,
            ),
            width: rect.width * 0.80,
            height: rect.height * 0.37,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.5),
        );
        canvas.drawCircle(
          Offset(
            rect.left + rect.width * 0.34,
            rect.top + rect.height * 0.73,
          ),
          rect.width * 0.15,
          Paint()
            ..color = light.withValues(alpha: 0.10)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.70,
              rect.top + rect.height * 0.84,
            ),
            width: rect.width * 0.38,
            height: rect.height * 0.20,
          ),
          Paint()
            ..color = base.withValues(alpha: 0.07)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.5),
        );

      case SoftBasicLowerVolumeTechnique.ambientBounceCarved:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.54,
              rect.top + rect.height * 0.77,
            ),
            width: rect.width * 0.90,
            height: rect.height * 0.43,
          ),
          Paint()
            ..color = tintedLight.withValues(alpha: 0.21)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.5),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.72,
              rect.top + rect.height * 0.70,
            ),
            width: rect.width * 0.48,
            height: rect.height * 0.43,
          ),
          Paint()
            ..color = base.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.left + rect.width * 0.58,
              rect.top + rect.height * 0.76,
            ),
            width: rect.width * 0.46,
            height: rect.height * 0.20,
          ),
          Paint()
            ..color = strongerTintedLight.withValues(alpha: 0.11)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
        );
    }

    canvas.restore();
  }

  void _paintBottomHighlight(
    Canvas canvas,
    Rect rect,
    Color rimLight,
    SoftBasicBottomHighlightTechnique technique,
  ) {
    if (technique == SoftBasicBottomHighlightTechnique.none) return;

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    switch (technique) {
      case SoftBasicBottomHighlightTechnique.none:
        break;
      case SoftBasicBottomHighlightTechnique.softBloom:
        canvas.drawArc(
          rect.deflate(rect.width * 0.085),
          0.47,
          2.20,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.105
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.2),
        );
        canvas.drawArc(
          rect.deflate(rect.width * 0.070),
          0.58,
          1.98,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.050
            ..strokeCap = StrokeCap.round
            ..color = rimLight.withValues(alpha: 0.24)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.1),
        );
      case SoftBasicBottomHighlightTechnique.narrowBloom:
        canvas.drawArc(
          rect.deflate(rect.width * 0.060),
          0.70,
          1.70,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.035
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.52)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.35),
        );
      case SoftBasicBottomHighlightTechnique.crescent:
        final crescent = Path()
          ..moveTo(
            rect.left + rect.width * 0.22,
            rect.top + rect.height * 0.73,
          )
          ..cubicTo(
            rect.left + rect.width * 0.37,
            rect.top + rect.height * 0.88,
            rect.left + rect.width * 0.63,
            rect.top + rect.height * 0.88,
            rect.left + rect.width * 0.79,
            rect.top + rect.height * 0.70,
          );
        canvas.drawPath(
          crescent,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.050
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.42)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.25),
        );
      case SoftBasicBottomHighlightTechnique.liftedGlow:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.center.dx,
              rect.top + rect.height * 0.70,
            ),
            width: rect.width * 0.54,
            height: rect.height * 0.20,
          ),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.24)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.5),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              rect.center.dx,
              rect.top + rect.height * 0.73,
            ),
            width: rect.width * 0.36,
            height: rect.height * 0.085,
          ),
          Paint()
            ..color = rimLight.withValues(alpha: 0.28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.3),
        );
      case SoftBasicBottomHighlightTechnique.premiumBottom:
        canvas.drawArc(
          rect.deflate(rect.width * 0.078),
          0.50,
          2.10,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.090
            ..strokeCap = StrokeCap.round
            ..color = rimLight.withValues(alpha: 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.8),
        );
        canvas.drawArc(
          rect.deflate(rect.width * 0.058),
          0.69,
          1.72,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.025
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.58)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.05),
        );

      case SoftBasicBottomHighlightTechnique.sideKiss:
        final sideRect = Rect.fromCenter(
          center: Offset(
            rect.left + rect.width * 0.68,
            rect.top + rect.height * 0.72,
          ),
          width: rect.width * 0.34,
          height: rect.height * 0.22,
        );
        canvas.drawArc(
          sideRect,
          0.42,
          1.08,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.036
            ..strokeCap = StrokeCap.round
            ..color = rimLight.withValues(alpha: 0.26)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4),
        );
        canvas.drawArc(
          sideRect.deflate(rect.width * 0.014),
          0.50,
          0.72,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.015
            ..strokeCap = StrokeCap.round
            ..color = rimLight.withValues(alpha: 0.34)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9),
        );

      case SoftBasicBottomHighlightTechnique.softSpot:
        final spotRect = Rect.fromCenter(
          center: Offset(
            rect.left + rect.width * 0.61,
            rect.top + rect.height * 0.73,
          ),
          width: rect.width * 0.24,
          height: rect.height * 0.105,
        );
        canvas.drawOval(
          spotRect,
          Paint()
            ..color = rimLight.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.6),
        );
        canvas.drawOval(
          spotRect.deflate(rect.width * 0.032),
          Paint()
            ..color = rimLight.withValues(alpha: 0.14)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
        );

      case SoftBasicBottomHighlightTechnique.edgeFade:
        final fadeRect = rect.deflate(rect.width * 0.028);
        final fadeBounds = Rect.fromLTWH(
          rect.left + rect.width * 0.46,
          rect.top + rect.height * 0.55,
          rect.width * 0.46,
          rect.height * 0.40,
        );
        canvas.drawArc(
          fadeRect,
          0.34,
          1.20,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.024
            ..strokeCap = StrokeCap.round
            ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x00FFFFFF),
                Color(0x33FFFFFF),
                Color(0x00FFFFFF),
              ],
              stops: [0.0, 0.58, 1.0],
            ).createShader(fadeBounds)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
        );
        canvas.drawArc(
          fadeRect.deflate(rect.width * 0.010),
          0.50,
          0.72,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = rect.width * 0.012
            ..strokeCap = StrokeCap.round
            ..color = rimLight.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7),
        );
    }

    canvas.restore();
  }

  void _paintSoftInnerRim(
    Canvas canvas,
    Rect rect,
    Color color, {
    required double alpha,
    required double width,
  }) {
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    canvas.drawOval(
      rect.deflate(rect.width * 0.026),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * width
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
    );
    canvas.restore();
  }

  void _paintColorShell(
    Canvas canvas,
    Rect rect,
    Color color, {
    required double alpha,
    required double width,
  }) {
    canvas.drawOval(
      rect.deflate(rect.width * 0.008),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * width
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
    );
  }

  void _paintLowerRim(
    Canvas canvas,
    Rect rect,
    Color color, {
    required double alpha,
    required double width,
  }) {
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    canvas.drawArc(
      rect.deflate(rect.width * 0.026),
      0.40,
      1.95,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * width
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.restore();
  }

  void _paintCleanOutline(
    Canvas canvas,
    Rect rect,
    Color color, {
    required double alpha,
    required double width,
  }) {
    canvas.drawOval(
      rect.deflate(rect.width * 0.006),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * width
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
    );
  }

  Path _baseEdgeLeafPath(Rect rect) => Path()
    ..moveTo(rect.left + rect.width * 0.13, rect.top + rect.height * 0.40)
    ..cubicTo(
      rect.left + rect.width * 0.13,
      rect.top + rect.height * 0.28,
      rect.left + rect.width * 0.18,
      rect.top + rect.height * 0.17,
      rect.left + rect.width * 0.27,
      rect.top + rect.height * 0.12,
    )
    ..cubicTo(
      rect.left + rect.width * 0.33,
      rect.top + rect.height * 0.09,
      rect.left + rect.width * 0.39,
      rect.top + rect.height * 0.10,
      rect.left + rect.width * 0.40,
      rect.top + rect.height * 0.15,
    )
    ..cubicTo(
      rect.left + rect.width * 0.41,
      rect.top + rect.height * 0.21,
      rect.left + rect.width * 0.35,
      rect.top + rect.height * 0.27,
      rect.left + rect.width * 0.29,
      rect.top + rect.height * 0.33,
    )
    ..cubicTo(
      rect.left + rect.width * 0.23,
      rect.top + rect.height * 0.39,
      rect.left + rect.width * 0.17,
      rect.top + rect.height * 0.45,
      rect.left + rect.width * 0.13,
      rect.top + rect.height * 0.40,
    )
    ..close();

  void _drawSoftShadow(
    Canvas canvas,
    Rect rect,
    Color color,
    double alpha,
    double sigma,
  ) {
    canvas.drawOval(
      rect.shift(Offset(0, rect.height * 0.065)).inflate(rect.width * 0.015),
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
    );
  }

  @override
  bool shouldRepaint(covariant _SoftBasicCandidatePainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.tone != tone ||
        oldDelegate.candidate.id != candidate.id;
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.selected,
    required this.card,
    required this.fg,
    required this.muted,
    required this.compact,
    required this.onTap,
  });

  final _CrayonCandidate candidate;
  final bool selected;
  final Color card;
  final Color fg;
  final Color muted;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7257F5);
    final heroScale = compact ? 1.62 : 1.92;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.all(compact ? 9 : 11),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? accent : const Color(0xFFE6E3EE),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: selected ? 0.07 : 0.025),
                blurRadius: selected ? 12 : 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    candidate.id,
                    style: TextStyle(
                      color: fg,
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (candidate.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        candidate.badge!,
                        style: const TextStyle(
                          color: accent,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check_circle, color: accent, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F5FB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEEE9F3)),
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: heroScale,
                      child: _ExactToken(
                        token: const LockToken(
                          shape: ShapeKind.circle,
                          tone: ShapeTone.pink,
                        ),
                        config: candidate.config,
                        size: 58,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                candidate.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                candidate.intent,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: muted,
                  fontSize: compact ? 9.5 : 10.5,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _shortCrayonConfig(candidate.config),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: muted,
                  fontSize: compact ? 8.5 : 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _shortCrayonConfig(CrayonTextureSpec config) {
  return 'W ' +
      config.strokeWidth.toStringAsFixed(2) +
      ' · Fill ' +
      config.underpaintOpacity.toStringAsFixed(2) +
      ' · Base ' +
      config.baseStrokeCount.toString() +
      ' · Break ' +
      config.strokeBreakChance.toStringAsFixed(2);
}

class _SelectedCandidatePanel extends StatelessWidget {
  const _SelectedCandidatePanel({
    required this.candidate,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final _CrayonCandidate candidate;
  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const shapes = [ShapeKind.circle, ShapeKind.triangle, ShapeKind.square];
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];
    final compact = MediaQuery.sizeOf(context).width < 700;

    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${candidate.id} · ${candidate.name}',
            style: TextStyle(
              color: fg,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(candidate.intent, style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 14),
          Wrap(
            spacing: compact ? 8 : 12,
            runSpacing: 10,
            children: [
              for (final shape in shapes)
                for (final tone in tones)
                  SizedBox(
                    width: compact ? 66 : 78,
                    child: Column(
                      children: [
                        _ExactToken(
                          token: LockToken(shape: shape, tone: tone),
                          config: candidate.config,
                          size: 58,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${shape.label}·${tone.label}',
                          style: TextStyle(color: muted, fontSize: 9),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _ValueChip(label: 'Dark', value: '${candidate.config.darkStrokeCount}'),
              _ValueChip(label: 'Light', value: '${candidate.config.lightStrokeCount}'),
              _ValueChip(label: 'Grain', value: '${candidate.config.grainCount}'),
              _ValueChip(label: 'Width', value: candidate.config.strokeWidth.toStringAsFixed(2)),
              _ValueChip(label: 'Angle', value: '${candidate.config.angleDeg.toStringAsFixed(0)}°'),
              _ValueChip(label: 'Jitter', value: candidate.config.jitter.toStringAsFixed(1)),
              _ValueChip(label: 'Edge', value: candidate.config.edgeOpacity.toStringAsFixed(2)),
            ],
          ),
        ],
      ),
    );
  }
}

class PaletteLab extends StatelessWidget {
  const PaletteLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];

    return _Panel(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Palette Lab',
            subtitle: '기본 3색을 Soft Basic / Crayon Soft에 동일 적용해 색 구분을 확인합니다.',
            fg: fg,
            muted: muted,
          ),
          const SizedBox(height: 16),
          for (final tone in tones) ...[
            Text(
              tone.label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                _TokenWithLabel(
                  shape: ShapeKind.circle,
                  tone: tone,
                  style: ShapeStyle.softBasic,
                  label: 'Soft',
                  muted: muted,
                ),
                _TokenWithLabel(
                  shape: ShapeKind.circle,
                  tone: tone,
                  style: ShapeStyle.crayonSoft,
                  label: 'Crayon',
                  muted: muted,
                ),
                _TokenWithLabel(
                  shape: ShapeKind.triangle,
                  tone: tone,
                  style: ShapeStyle.crayonSoft,
                  label: 'Triangle',
                  muted: muted,
                ),
                _TokenWithLabel(
                  shape: ShapeKind.square,
                  tone: tone,
                  style: ShapeStyle.crayonSoft,
                  label: 'Square',
                  muted: muted,
                ),
              ],
            ),
            if (tone != tones.last) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class EffectLab extends StatefulWidget {
  const EffectLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<EffectLab> createState() => _EffectLabState();
}

class _EffectLabState extends State<EffectLab> {
  MovementStyle movement = MovementStyle.floating;
  PopStyle pop = PopStyle.basicPop;
  ShapeStyle style = ShapeStyle.crayonSoft;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: widget.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Effect Lab',
            subtitle: '실제 FloatingPreview에서 Motion / POP 조합을 바로 확인합니다.',
            fg: widget.fg,
            muted: widget.muted,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _EnumDropdown<MovementStyle>(
                label: 'Motion',
                value: movement,
                values: MovementStyle.values,
                text: (v) => v.label,
                onChanged: (v) => setState(() => movement = v),
              ),
              _EnumDropdown<PopStyle>(
                label: 'POP',
                value: pop,
                values: PopStyle.values,
                text: (v) => v.label,
                onChanged: (v) => setState(() => pop = v),
              ),
              _EnumDropdown<ShapeStyle>(
                label: 'Style',
                value: style,
                values: ShapeStyle.values,
                text: (v) => v.label,
                onChanged: (v) => setState(() => style = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0FA),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: FloatingPreview(
              selectedShapes: ShapeKind.defaults,
              selectedTones: ShapeTone.defaults,
              movementStyle: movement,
              popStyle: pop,
              style: style,
              objectCount: 9,
              movementArea: MovementArea.full,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '도형을 탭하면 선택한 POP 반응을 확인할 수 있습니다.',
            style: TextStyle(color: widget.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class RuntimeQaLab extends StatefulWidget {
  const RuntimeQaLab({
    super.key,
    required this.card,
    required this.fg,
    required this.muted,
  });

  final Color card;
  final Color fg;
  final Color muted;

  @override
  State<RuntimeQaLab> createState() => _RuntimeQaLabState();
}

class _RuntimeQaLabState extends State<RuntimeQaLab> {
  int count = 12;
  MovementStyle movement = MovementStyle.floating;
  ShapeStyle style = ShapeStyle.crayonSoft;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: widget.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Runtime QA',
            subtitle: '6 / 9 / 12개 동시 렌더에서 가독성과 움직임을 확인합니다.',
            fg: widget.fg,
            muted: widget.muted,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final value in const [6, 9, 12])
                ChoiceChip(
                  label: Text('$value개'),
                  selected: count == value,
                  onSelected: (_) => setState(() => count = value),
                ),
              _EnumDropdown<MovementStyle>(
                label: 'Motion',
                value: movement,
                values: MovementStyle.values,
                text: (v) => v.label,
                onChanged: (v) => setState(() => movement = v),
              ),
              _EnumDropdown<ShapeStyle>(
                label: 'Style',
                value: style,
                values: ShapeStyle.values,
                text: (v) => v.label,
                onChanged: (v) => setState(() => style = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 430,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF5FA), Color(0xFFF0F3FF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: FloatingPreview(
              selectedShapes: ShapeKind.defaults,
              selectedTones: ShapeTone.defaults,
              movementStyle: movement,
              popStyle: PopStyle.basicPop,
              style: style,
              objectCount: count,
              movementArea: MovementArea.full,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExactToken extends StatelessWidget {
  const _ExactToken({
    required this.token,
    required this.config,
    this.size = 58,
  });

  final LockToken token;
  final CrayonTextureSpec config;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: LockTokenPainter(
          token,
          style: ShapeStyle.crayonSoft,
          crayonOverride: config,
        ),
      ),
    );
  }
}

class _TokenWithLabel extends StatelessWidget {
  const _TokenWithLabel({
    required this.shape,
    required this.tone,
    required this.style,
    required this.label,
    required this.muted,
  });

  final ShapeKind shape;
  final ShapeTone tone;
  final ShapeStyle style;
  final String label;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          SizedBox.square(
            dimension: 58,
            child: CustomPaint(
              painter: LockTokenPainter(
                LockToken(shape: shape, tone: tone),
                style: style,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: muted, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.text,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) text;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isDense: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        items: [
          for (final item in values)
            DropdownMenuItem<T>(
              value: item,
              child: Text(text(item), overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.fg,
    required this.muted,
  });

  final String title;
  final String subtitle;
  final Color fg;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: fg,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(color: muted, fontSize: 12, height: 1.35),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E5EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFF8),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Color(0xFF4D4568),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
