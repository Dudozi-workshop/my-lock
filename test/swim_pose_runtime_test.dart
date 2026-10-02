import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/swim_pose_runtime.dart';

void main() {
  const config = <String, dynamic>{
    'sequence': <String>['s0', 's1', 's2', 's1', 's0'],
    'step_ratios': <double>[0.23, 0.16, 0.22, 0.16, 0.23],
    'profiles': <String, dynamic>{
      'calm': <double>[1.10, 1.30],
      'standard': <double>[0.90, 1.10],
      'lively': <double>[0.78, 0.92],
    },
    'hold_loops': <int>[2, 4],
    'random_initial_phase': true,
  };

  setUp(() {
    SwimPoseRuntime.instance.resetAll();
  });

  test('swim runtime only returns approved S0/S1/S2 poses', () {
    final poses = <String>{};
    for (var frame = 0; frame < 600; frame++) {
      poses.add(
        SwimPoseRuntime.instance.poseFor(
          key: 'turtle-a',
          timeSeconds: frame / 60,
          config: config,
        ),
      );
    }

    expect(poses.difference(const {'s0', 's1', 's2'}), isEmpty);
    expect(poses, containsAll(const ['s0', 's1', 's2']));
  });

  test('same key and timeline replay deterministically after reset', () {
    List<String> sample() => [
      for (var frame = 0; frame < 240; frame++)
        SwimPoseRuntime.instance.poseFor(
          key: 'turtle-deterministic',
          timeSeconds: frame / 60,
          config: config,
        ),
    ];

    final first = sample();
    SwimPoseRuntime.instance.resetAll();
    final second = sample();

    expect(second, first);
  });

  test('different object keys can start at different phases', () {
    final first = [
      for (var frame = 0; frame < 120; frame++)
        SwimPoseRuntime.instance.poseFor(
          key: 'floating:101',
          timeSeconds: frame / 60,
          config: config,
        ),
    ];

    final second = [
      for (var frame = 0; frame < 120; frame++)
        SwimPoseRuntime.instance.poseFor(
          key: 'floating:202',
          timeSeconds: frame / 60,
          config: config,
        ),
    ];

    expect(second, isNot(first));
  });

  test('time rewind safely resets a pose state', () {
    for (var frame = 0; frame < 120; frame++) {
      SwimPoseRuntime.instance.poseFor(
        key: 'rewind',
        timeSeconds: frame / 60,
        config: config,
      );
    }

    final pose = SwimPoseRuntime.instance.poseFor(
      key: 'rewind',
      timeSeconds: 0,
      config: config,
    );

    expect(const {'s0', 's1', 's2'}, contains(pose));
  });

  test('speed profile switch remains inside the approved pose set', () {
    for (var frame = 0; frame < 90; frame++) {
      SwimPoseRuntime.instance.poseFor(
        key: 'profile-switch',
        timeSeconds: frame / 60,
        config: config,
        profile: 'calm',
      );
    }

    final pose = SwimPoseRuntime.instance.poseFor(
      key: 'profile-switch',
      timeSeconds: 1.6,
      config: config,
      profile: 'lively',
    );

    expect(const {'s0', 's1', 's2'}, contains(pose));
  });
}
