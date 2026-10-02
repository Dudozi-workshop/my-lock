import 'package:flutter/foundation.dart';

/// One monotonic palette phase per Flutter engine (including lockMain).
/// The bootstrap owns the ticker; static cards repaint without widget rebuilds.
class RasterPaletteClock extends ValueNotifier<double> {
  RasterPaletteClock._() : super(0);
  static final instance = RasterPaletteClock._();
  final Stopwatch _elapsed = Stopwatch()..start();
  void tick() =>
      value = _elapsed.elapsedMicroseconds / Duration.microsecondsPerSecond;
}
