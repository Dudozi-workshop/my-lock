import 'effects.dart';

class MotionProfile {
  const MotionProfile({
    required this.spawnSpeedBase,
    required this.spawnSpeedRange,
    required this.collisionPositionScale,
    required this.collisionImpulseScale,
    required this.wallBounce,
    required this.gravityScale,
    required this.dragPerSecond,
    required this.wakeUpAfterSeconds,
    required this.wakeUpImpulseScale,
    required this.minSpeedScale,
    required this.maxSpeedScale,
    required this.externalForceScale,
  });

  final double spawnSpeedBase;
  final double spawnSpeedRange;
  final double collisionPositionScale;
  final double collisionImpulseScale;
  final double wallBounce;
  final double gravityScale;
  final double dragPerSecond;
  final double wakeUpAfterSeconds;
  final double wakeUpImpulseScale;
  final double minSpeedScale;
  final double maxSpeedScale;

  /// Strength applied to normalized external input such as tilt/gyro forces.
  ///
  /// The engine accepts this input now, while sensor wiring can be added later
  /// without changing the core motion API.
  final double externalForceScale;

  static MotionProfile forStyle(MovementStyle style) {
    switch (style) {
      case MovementStyle.floating:
        return floating;
      case MovementStyle.bounce:
        return bounce;
      case MovementStyle.orbit:
        return orbit;
      case MovementStyle.zeroGravity:
        return zeroGravity;
      case MovementStyle.underwater:
        return underwater;
    }
  }

  static const floating = MotionProfile(
    spawnSpeedBase: 0.085,
    spawnSpeedRange: 0.055,
    collisionPositionScale: 1.0,
    collisionImpulseScale: 0.95,
    wallBounce: 0.94,
    gravityScale: 0.0,
    dragPerSecond: 0.015,
    wakeUpAfterSeconds: 0.85,
    wakeUpImpulseScale: 0.12,
    minSpeedScale: 0.035,
    maxSpeedScale: 0.22,
    externalForceScale: 0.42,
  );

  static const bounce = MotionProfile(
    spawnSpeedBase: 0.13,
    spawnSpeedRange: 0.06,
    collisionPositionScale: 1.2,
    collisionImpulseScale: 1.75,
    wallBounce: 0.98,
    gravityScale: 0.22,
    dragPerSecond: 0.005,
    wakeUpAfterSeconds: 0.65,
    wakeUpImpulseScale: 0.16,
    minSpeedScale: 0.05,
    maxSpeedScale: 0.34,
    externalForceScale: 0.52,
  );

  // Reserved profiles. Their dedicated trajectories can be layered on top of
  // these shared physics values when the store items are enabled.
  static const orbit = MotionProfile(
    spawnSpeedBase: 0.075,
    spawnSpeedRange: 0.035,
    collisionPositionScale: 0.9,
    collisionImpulseScale: 0.75,
    wallBounce: 0.82,
    gravityScale: 0.0,
    dragPerSecond: 0.035,
    wakeUpAfterSeconds: 1.0,
    wakeUpImpulseScale: 0.08,
    minSpeedScale: 0.025,
    maxSpeedScale: 0.18,
    externalForceScale: 0.30,
  );

  static const zeroGravity = MotionProfile(
    spawnSpeedBase: 0.055,
    spawnSpeedRange: 0.025,
    collisionPositionScale: 0.75,
    collisionImpulseScale: 0.45,
    wallBounce: 0.88,
    gravityScale: 0.0,
    dragPerSecond: 0.004,
    wakeUpAfterSeconds: 1.2,
    wakeUpImpulseScale: 0.055,
    minSpeedScale: 0.018,
    maxSpeedScale: 0.14,
    externalForceScale: 0.22,
  );

  static const underwater = MotionProfile(
    spawnSpeedBase: 0.06,
    spawnSpeedRange: 0.03,
    collisionPositionScale: 0.8,
    collisionImpulseScale: 0.55,
    wallBounce: 0.78,
    gravityScale: 0.0,
    dragPerSecond: 0.12,
    wakeUpAfterSeconds: 0.95,
    wakeUpImpulseScale: 0.075,
    minSpeedScale: 0.02,
    maxSpeedScale: 0.15,
    externalForceScale: 0.26,
  );
}
