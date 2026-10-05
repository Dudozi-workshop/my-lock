import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../app/theme.dart';
import '../../../../lock_engine/models.dart';
import '../../../../lock_engine/shape_painter.dart';
import 'choice_card.dart';

class ColorChoiceCard extends StatelessWidget {
  const ColorChoiceCard({
    super.key,
    required this.tone,
    required this.label,
    required this.selected,
    required this.onTap,
    this.wide = false,
  });

  final ShapeTone tone;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final previewSize = wide ? 72.0 : 58.0;
    final preview = tone == ShapeTone.auroraSea
        ? _LiveAuroraRound(size: previewSize)
        : CustomPaint(
            size: Size.square(previewSize),
            painter: LockTokenPainter(
              LockToken(
                shape: ShapeKind.circle,
                tone: tone,
              ),
            ),
          );

    return ChoiceCard(
      selected: selected,
      onTap: onTap,
      badge: tone == ShapeTone.auroraSea
          ? 'REWARD'
          : tone.premium
              ? 'PLUS'
              : null,
      child: wide
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  preview,
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Signature Color',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: secondaryInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: brandPurple,
                    size: 22,
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                preview,
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Mirrors the approved Palette LABS animation contract:
/// a dedicated Ticker advances explicit palette time and rebuilds the painter.
///
/// This avoids platform-specific reliance on indirect CustomPainter repaint
/// notification for the small 58–72 px Signature Color swatch.
class _LiveAuroraRound extends StatefulWidget {
  const _LiveAuroraRound({required this.size});

  final double size;

  @override
  State<_LiveAuroraRound> createState() => _LiveAuroraRoundState();
}

class _LiveAuroraRoundState extends State<_LiveAuroraRound>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _previous = Duration.zero;
  double _seconds = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final delta = _previous == Duration.zero
        ? 0.0
        : (elapsed - _previous).inMicroseconds /
            Duration.microsecondsPerSecond;
    _previous = elapsed;
    if (delta <= 0) return;

    setState(() {
      _seconds += delta.clamp(0.0, 0.05).toDouble();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(widget.size),
      painter: LockTokenPainter(
        const LockToken(
          shape: ShapeKind.circle,
          tone: ShapeTone.auroraSea,
        ),
        paletteTimeSeconds: _seconds,
      ),
    );
  }
}
