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
    spawnSpeedBase: 0.10,
    spawnSpeedRange: 0.06,
    collisionPositionScale: 1.0,
    collisionImpulseScale: 0.95,
    wallBounce: 0.92,
    gravityScale: 0.0,
    dragPerSecond: 0.045,
    wakeUpAfterSeconds: 0.75,
    wakeUpImpulseScale: 0.14,
    minSpeedScale: 0.04,
    maxSpeedScale: 0.34,
    externalForceScale: 0.48,
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
    spawnSpeedBase: 0.055,
    spawnSpeedRange: 0.018,
    collisionPositionScale: 0.62,
    collisionImpulseScale: 0.38,
    wallBounce: 0.66,
    gravityScale: 0.0,
    dragPerSecond: 0.012,
    wakeUpAfterSeconds: 2.0,
    wakeUpImpulseScale: 0.025,
    minSpeedScale: 0.012,
    maxSpeedScale: 0.26,
    externalForceScale: 0.18,
  );

  static const zeroGravity = MotionProfile(
    spawnSpeedBase: 0.045,
    spawnSpeedRange: 0.018,
    collisionPositionScale: 0.68,
    collisionImpulseScale: 0.36,
    wallBounce: 0.94,
    gravityScale: 0.0,
    dragPerSecond: 0.0015,
    wakeUpAfterSeconds: 2.4,
    wakeUpImpulseScale: 0.025,
    minSpeedScale: 0.008,
    maxSpeedScale: 0.12,
    externalForceScale: 0.18,
  );

  static const underwater = MotionProfile(
    spawnSpeedBase: 0.05,
    spawnSpeedRange: 0.018,
    collisionPositionScale: 0.70,
    collisionImpulseScale: 0.38,
    wallBounce: 0.52,
    gravityScale: 0.0,
    dragPerSecond: 0.22,
    wakeUpAfterSeconds: 1.5,
    wakeUpImpulseScale: 0.035,
    minSpeedScale: 0.012,
    maxSpeedScale: 0.18,
    externalForceScale: 0.20,
  );
}
