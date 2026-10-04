import 'dart:math';
import 'dart:ui';

class WholeShapeIdleTransform {
  const WholeShapeIdleTransform({this.offset = Offset.zero, this.rotationRadians = 0, this.scaleX = 1, this.scaleY = 1});
  final Offset offset;
  final double rotationRadians;
  final double scaleX;
  final double scaleY;
}

class WholeShapeIdleRuntime {
  WholeShapeIdleRuntime._();
  static final WholeShapeIdleRuntime instance = WholeShapeIdleRuntime._();

  WholeShapeIdleTransform transformFor({required String key, required double timeSeconds, required Map<String, dynamic> config, required double radius}) {
    if (config['enabled'] != true) return const WholeShapeIdleTransform();
    final period = (config['period_seconds'] as num?)?.toDouble() ?? 3.6;
    if (period <= 0) return const WholeShapeIdleTransform();
    final phaseOffset = config['random_initial_phase'] == false ? 0.0 : (_stableSeed(key) % 10000) / 10000.0 * pi * 2;
    final phase = timeSeconds / period * pi * 2 + phaseOffset;
    final swayDeg = (config['sway_degrees'] as num?)?.toDouble() ?? 0.0;
    final floatRatio = (config['vertical_float_radius_ratio'] as num?)?.toDouble() ?? 0.0;
    final driftRatio = (config['horizontal_drift_radius_ratio'] as num?)?.toDouble() ?? 0.0;
    final breathe = (config['breathing_scale'] as num?)?.toDouble() ?? 0.0;
    final pulse = breathe * sin(phase * 2 - 0.4);
    return WholeShapeIdleTransform(
      offset: Offset(radius * driftRatio * sin(phase * 2 + 0.6), radius * floatRatio * sin(phase - pi / 3)),
      rotationRadians: swayDeg * pi / 180 * sin(phase),
      scaleX: 1 + pulse,
      scaleY: 1 - pulse,
    );
  }

  static int _stableSeed(String value) {
    var hash = 0x811C9DC5;
    for (final unit in value.codeUnits) { hash ^= unit; hash = (hash * 0x01000193) & 0x7FFFFFFF; }
    return hash;
  }
}
