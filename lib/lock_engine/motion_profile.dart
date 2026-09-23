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
    spawnSpeedBase: 0.07,
    spawnSpeedRange: 0.025,
    collisionPositionScale: 0.8,
    collisionImpulseScale: 0.55,
    wallBounce: 0.72,
    gravityScale: 0.0,
    dragPerSecond: 0.02,
    wakeUpAfterSeconds: 1.6,
    wakeUpImpulseScale: 0.04,
    minSpeedScale: 0.018,
    maxSpeedScale: 0.20,
    externalForceScale: 0.24,
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
    spawnSpeedBase: 0.055,
    spawnSpeedRange: 0.02,
    collisionPositionScale: 0.72,
    collisionImpulseScale: 0.42,
    wallBounce: 0.60,
    gravityScale: 0.0,
    dragPerSecond: 0.18,
    wakeUpAfterSeconds: 1.4,
    wakeUpImpulseScale: 0.045,
    minSpeedScale: 0.015,
    maxSpeedScale: 0.14,
    externalForceScale: 0.22,
  );
}
