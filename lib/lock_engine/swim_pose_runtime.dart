import 'dart:math';

class SwimPoseRuntime {
  SwimPoseRuntime._();

  static final SwimPoseRuntime instance = SwimPoseRuntime._();

  final Map<String, _SwimState> _states = <String, _SwimState>{};

  String poseFor({
    required String key,
    required double timeSeconds,
    required Map<String, dynamic> config,
    String profile = 'standard',
  }) {
    if (config.isEmpty) return 's0';

    final sequence =
        (config['sequence'] as List<dynamic>? ?? const ['s0'])
            .map((value) => value as String)
            .toList(growable: false);
    final ratios =
        (config['step_ratios'] as List<dynamic>? ?? const [1.0])
            .map((value) => (value as num).toDouble())
            .toList(growable: false);
    if (sequence.isEmpty || sequence.length != ratios.length) return 's0';

    final profiles = Map<String, dynamic>.from(
      config['profiles'] as Map? ?? const <String, dynamic>{},
    );
    final selectedRange = (profiles[profile] ?? profiles['standard']) as List?;
    if (selectedRange == null || selectedRange.length < 2) return sequence.first;

    final minDuration = (selectedRange[0] as num).toDouble();
    final maxDuration = (selectedRange[1] as num).toDouble();
    if (minDuration <= 0 || maxDuration < minDuration) return sequence.first;

    final holdLoops = (config['hold_loops'] as List<dynamic>? ?? const [2, 4]);
    final minHold = (holdLoops[0] as num).toInt();
    final maxHold = (holdLoops[1] as num).toInt();
    final randomInitialPhase = config['random_initial_phase'] != false;

    final state = _states.putIfAbsent(
      key,
      () => _SwimState.seeded(
        key: key,
        timeSeconds: timeSeconds,
        minDuration: minDuration,
        maxDuration: maxDuration,
        minHold: minHold,
        maxHold: maxHold,
        randomInitialPhase: randomInitialPhase,
        profile: profile,
      ),
    );

    if (timeSeconds < state.lastTimeSeconds) {
      state.reset(
        timeSeconds: timeSeconds,
        minDuration: minDuration,
        maxDuration: maxDuration,
        minHold: minHold,
        maxHold: maxHold,
        randomInitialPhase: randomInitialPhase,
        profile: profile,
      );
    }

    if (state.profile != profile) {
      state.profile = profile;
      state.targetDuration = state.sampleDuration(minDuration, maxDuration);
      state.loopsUntilResample = state.sampleHold(minHold, maxHold);
    }

    final dt = (timeSeconds - state.lastTimeSeconds).clamp(0.0, 0.1);
    state.lastTimeSeconds = timeSeconds;

    final blend = min(1.0, dt * 1.35);
    state.currentDuration +=
        (state.targetDuration - state.currentDuration) * blend;
    state.elapsed += dt;

    while (state.elapsed >= state.currentDuration) {
      state.elapsed -= state.currentDuration;
      state.loopsUntilResample -= 1;
      if (state.loopsUntilResample <= 0) {
        state.targetDuration = state.sampleDuration(minDuration, maxDuration);
        state.loopsUntilResample = state.sampleHold(minHold, maxHold);
      }
    }

    final totalRatio = ratios.fold<double>(0.0, (sum, value) => sum + value);
    if (totalRatio <= 0) return sequence.first;

    final phase = state.elapsed / state.currentDuration;
    var cursor = 0.0;
    for (var i = 0; i < sequence.length; i++) {
      cursor += ratios[i] / totalRatio;
      if (phase < cursor || i == sequence.length - 1) {
        return sequence[i];
      }
    }
    return sequence.first;
  }

  void resetKey(String key) => _states.remove(key);

  void resetAll() => _states.clear();
}

class _SwimState {
  _SwimState({
    required this.random,
    required this.lastTimeSeconds,
    required this.elapsed,
    required this.currentDuration,
    required this.targetDuration,
    required this.loopsUntilResample,
    required this.profile,
  });

  factory _SwimState.seeded({
    required String key,
    required double timeSeconds,
    required double minDuration,
    required double maxDuration,
    required int minHold,
    required int maxHold,
    required bool randomInitialPhase,
    required String profile,
  }) {
    final random = Random(_stableSeed(key));
    final duration = _sampleDuration(random, minDuration, maxDuration);
    return _SwimState(
      random: random,
      lastTimeSeconds: timeSeconds,
      elapsed: randomInitialPhase ? random.nextDouble() * duration : 0.0,
      currentDuration: duration,
      targetDuration: duration,
      loopsUntilResample: _sampleHold(random, minHold, maxHold),
      profile: profile,
    );
  }

  final Random random;
  double lastTimeSeconds;
  double elapsed;
  double currentDuration;
  double targetDuration;
  int loopsUntilResample;
  String profile;

  void reset({
    required double timeSeconds,
    required double minDuration,
    required double maxDuration,
    required int minHold,
    required int maxHold,
    required bool randomInitialPhase,
    required String profile,
  }) {
    final duration = sampleDuration(minDuration, maxDuration);
    lastTimeSeconds = timeSeconds;
    elapsed = randomInitialPhase ? random.nextDouble() * duration : 0.0;
    currentDuration = duration;
    targetDuration = duration;
    loopsUntilResample = sampleHold(minHold, maxHold);
    this.profile = profile;
  }

  double sampleDuration(double minDuration, double maxDuration) =>
      _sampleDuration(random, minDuration, maxDuration);

  int sampleHold(int minHold, int maxHold) =>
      _sampleHold(random, minHold, maxHold);

  static double _sampleDuration(
    Random random,
    double minDuration,
    double maxDuration,
  ) {
    if (maxDuration <= minDuration) return minDuration;
    return minDuration + random.nextDouble() * (maxDuration - minDuration);
  }

  static int _sampleHold(Random random, int minHold, int maxHold) {
    final low = max(1, minHold);
    final high = max(low, maxHold);
    return low + random.nextInt(high - low + 1);
  }

  static int _stableSeed(String value) {
    var hash = 0x811C9DC5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }
}
