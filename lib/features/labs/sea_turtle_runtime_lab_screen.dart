import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../lock_engine/floating_engine.dart';
import '../../lock_engine/models.dart';

class SeaTurtleRuntimeLabBootstrap extends StatelessWidget {
  const SeaTurtleRuntimeLabBootstrap({super.key});

  @override
  Widget build(BuildContext context) => const SeaTurtleRuntimeLabScreen();
}

class SeaTurtleRuntimeLabScreen extends StatefulWidget {
  const SeaTurtleRuntimeLabScreen({super.key});

  @override
  State<SeaTurtleRuntimeLabScreen> createState() =>
      _SeaTurtleRuntimeLabScreenState();
}

class _SeaTurtleRuntimeLabScreenState extends State<SeaTurtleRuntimeLabScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final FloatingEngine _engine = FloatingEngine(seed: 240925);

  Duration _previous = Duration.zero;
  Size _lastStageSize = Size.zero;
  int _objectCount = 9;
  MovementStyle _movementStyle = MovementStyle.underwater;
  bool _darkBackground = false;

  @override
  void initState() {
    super.initState();
    _engine
      ..setSelection(
        const {ShapeKind.circle},
        const {ShapeTone.blue, ShapeTone.pink, ShapeTone.yellow},
      )
      ..setObjectCount(_objectCount)
      ..setMovementStyle(_movementStyle)
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
      _engine.step(delta.clamp(0.0, 0.035).toDouble());
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
    final background =
        _darkBackground ? const Color(0xFF08182A) : const Color(0xFFF4FAFF);
    final panel = _darkBackground ? const Color(0xFF10243A) : Colors.white;
    final ink =
        _darkBackground ? const Color(0xFFF5FAFF) : const Color(0xFF18304D);
    final subInk =
        _darkBackground ? const Color(0xFFB9CADB) : const Color(0xFF667C92);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth < 720 ? 16.0 : 28.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sea Turtle Runtime Lab',
                        style: TextStyle(
                          color: ink,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'S02 Long Flipper · dedicated web QA object · production shapes untouched',
                        style: TextStyle(
                          color: subInk,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildControls(panel, ink),
                      const SizedBox(height: 18),
                      _buildSinglePreview(panel, ink, subInk),
                      const SizedBox(height: 18),
                      _buildRuntimeStage(panel, ink, subInk),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControls(Color panel, Color ink) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Count',
              style: TextStyle(color: ink, fontWeight: FontWeight.w800)),
          for (final count in const [6, 9, 12])
            ChoiceChip(
              label: Text('$count'),
              selected: _objectCount == count,
              onSelected: (_) {
                setState(() {
                  _objectCount = count;
                  _engine.setObjectCount(count);
                });
              },
            ),
          const SizedBox(width: 6),
          Text('Motion',
              style: TextStyle(color: ink, fontWeight: FontWeight.w800)),
          for (final entry in const <(MovementStyle, String)>[
            (MovementStyle.floating, 'Floating'),
            (MovementStyle.underwater, 'Underwater'),
            (MovementStyle.zeroGravity, 'Zero G'),
          ])
            ChoiceChip(
              label: Text(entry.$2),
              selected: _movementStyle == entry.$1,
              onSelected: (_) {
                setState(() {
                  _movementStyle = entry.$1;
                  _engine.setMovementStyle(entry.$1);
                });
              },
            ),
          const SizedBox(width: 6),
          FilterChip(
            label: const Text('Dark BG'),
            selected: _darkBackground,
            onSelected: (value) =>
                setState(() => _darkBackground = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePreview(Color panel, Color ink, Color subInk) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '01 · Single asset check',
            style: TextStyle(
              color: ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'One verified Aqua source asset is reused for all three slots; Pink/Sand use a temporary color filter for runtime QA.',
            style: TextStyle(color: subInk, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _SingleTile(tone: ShapeTone.blue, label: 'Aqua Mint'),
              _SingleTile(tone: ShapeTone.pink, label: 'Coral Pink QA tint'),
              _SingleTile(
                  tone: ShapeTone.yellow, label: 'Sand Beige QA tint'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRuntimeStage(Color panel, Color ink, Color subInk) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '02 · Runtime stage',
            style: TextStyle(
              color: ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current FloatingEngine radius, collision and motion are used. The Circle token is physics-only inside this lab.',
            style: TextStyle(color: subInk, fontSize: 12),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = min(640.0, max(460.0, width * 0.62));
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

class _SingleTile extends StatelessWidget {
  const _SingleTile({required this.tone, required this.label});

  final ShapeTone tone;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Column(
        children: [
          const SizedBox(height: 4),
          SizedBox(
            width: 190,
            height: 150,
            child: Center(
              child: _TurtleAsset(tone: tone, size: 132),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SeaTurtleRuntimeObject extends StatelessWidget {
  const _SeaTurtleRuntimeObject({
    super.key,
    required this.object,
  });

  final FloatingObject object;

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
          child: _TurtleAsset(
            tone: object.token.tone,
            size: side,
            compactError: true,
          ),
        ),
      ),
    );
  }
}

class _TurtleAsset extends StatelessWidget {
  const _TurtleAsset({
    required this.tone,
    required this.size,
    this.compactError = false,
  });

  final ShapeTone tone;
  final double size;
  final bool compactError;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/sea_turtle_runtime_v2/sea_turtle_blue.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        if (compactError) {
          return Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0x66FF0000),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.broken_image_outlined,
              size: 18,
              color: Colors.white,
            ),
          );
        }
        return Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFECEC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Asset load failed\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9F2F2F), fontSize: 10),
          ),
        );
      },
    );

    final tint = switch (tone) {
      ShapeTone.blue => null,
      ShapeTone.pink => const Color(0xFFF7A7B5),
      ShapeTone.yellow => const Color(0xFFEFD59A),
    };

    if (tint == null) return image;

    return ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.color),
      child: image,
    );
  }
}
