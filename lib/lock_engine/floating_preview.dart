import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'floating_engine.dart';
import 'shape_painter.dart';

class FloatingPreview extends StatefulWidget {
  const FloatingPreview({super.key});

  @override
  State<FloatingPreview> createState() => _FloatingPreviewState();
}

class _FloatingPreviewState extends State<FloatingPreview>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final FloatingEngine _engine = FloatingEngine();
  Duration _previous = Duration.zero;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final delta = _previous == Duration.zero
        ? 0.0
        : (elapsed - _previous).inMicroseconds / Duration.microsecondsPerSecond;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size != _lastSize && size.width > 0 && size.height > 0) {
          _lastSize = size;
          _engine.resize(size);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            if (_engine.tap(details.localPosition)) {
              HapticFeedback.lightImpact();
              setState(() {});
            }
          },
          child: CustomPaint(
            painter: FloatingShapePainter(objects: _engine.objects),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}
