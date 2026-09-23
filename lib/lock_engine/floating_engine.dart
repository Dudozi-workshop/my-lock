import 'dart:math';
import 'dart:ui';

import 'effects.dart';
import 'models.dart';
import 'motion_profile.dart';

class FloatingEngine {
  FloatingEngine({int seed = 4921}) : _random = Random(seed);

  static const int defaultObjectCount = 9;
  static const Set<int> supportedObjectCounts = {6, 9, 12};
  static const double popDuration = 0.18;

  final Random _random;
  final List<FloatingObject> objects = [];
  final Map<int, double> _idleSeconds = <int, double>{};

  Size _area = Size.zero;
  int _nextId = 0;
  MovementStyle _movementStyle = MovementStyle.floating;
  MovementArea _movementArea = MovementArea.lower;
  FloatingSpeed _speed = FloatingSpeed.normal;
  double _topInset = 0;
  int _objectCount = defaultObjectCount;
  Offset _externalForce = Offset.zero;
  double _elapsedSeconds = 0;
  List<LockToken> _allowedTokens = List<LockToken>.from(defaultTokens);
  List<LockToken> _requiredTokens = <LockToken>[];

  static const List<LockToken> defaultTokens = [
    LockToken(shape: ShapeKind.circle, tone: ShapeTone.pink),
    LockToken(shape: ShapeKind.triangle, tone: ShapeTone.pink),
    LockToken(shape: ShapeKind.square, tone: ShapeTone.pink),
    LockToken(shape: ShapeKind.circle, tone: ShapeTone.blue),
    LockToken(shape: ShapeKind.triangle, tone: ShapeTone.blue),
    LockToken(shape: ShapeKind.square, tone: ShapeTone.blue),
    LockToken(shape: ShapeKind.circle, tone: ShapeTone.yellow),
    LockToken(shape: ShapeKind.triangle, tone: ShapeTone.yellow),
    LockToken(shape: ShapeKind.square, tone: ShapeTone.yellow),
  ];

  void setSelection(Set<ShapeKind> shapes, Set<ShapeTone> tones) {
    if (shapes.isEmpty || tones.isEmpty) return;

    _allowedTokens = [
      for (final tone in ShapeTone.values)
        if (tones.contains(tone))
          for (final shape in ShapeKind.values)
            if (shapes.contains(shape)) LockToken(shape: shape, tone: tone),
    ];

    if (_area == Size.zero) return;
    _seedObjects();
  }

  void setRequiredTokens(List<LockToken> tokens) {
    _requiredTokens = List<LockToken>.from(tokens, growable: false);
    if (_area != Size.zero) _ensureRequiredVisible();
  }

  void setObjectCount(int count) {
    if (!supportedObjectCounts.contains(count) || _objectCount == count) return;
    _objectCount = count;
    if (_area != Size.zero) _seedObjects();
  }

  void setSpeed(FloatingSpeed speed) {
    if (_speed == speed) return;

    final ratio = speed.multiplier / _speed.multiplier;
    _speed = speed;

    for (final object in objects) {
      object.velocity = object.velocity * ratio;
    }
  }

  void setMovementStyle(MovementStyle style) {
    if (_movementStyle == style) return;
    _movementStyle = style;
    _idleSeconds.clear();
    if (_area != Size.zero) _seedObjects();
  }

  /// Applies normalized external motion input for future reactive modes.
  ///
  /// Values are clamped to -1..1 so sensor wiring can pass tilt/gyro force
  /// without exposing raw device units to the physics engine.
  void setExternalForce(Offset force) {
    _externalForce = Offset(
      force.dx.clamp(-1.0, 1.0).toDouble(),
      force.dy.clamp(-1.0, 1.0).toDouble(),
    );
  }

  void clearExternalForce() {
    _externalForce = Offset.zero;
  }

  void setMovementArea(MovementArea area) {
    if (_movementArea == area) return;
    _movementArea = area;
    if (_area != Size.zero) _seedObjects();
  }

  void setTopInset(double inset) {
    final normalized = max(0.0, inset);
    if ((_topInset - normalized).abs() < 0.5) return;
    _topInset = normalized;
    if (_area != Size.zero) _seedObjects();
  }

  double get _movementTop {
    final areaTop =
        _movementArea == MovementArea.lower ? _area.height * 0.40 : 0.0;
    return max(_topInset, areaTop);
  }

  double get _movementHeight => _area.height - _movementTop;

  double get _horizontalInset =>
      _movementArea == MovementArea.lower ? _area.width * 0.09 : 0.0;

  double get _movementLeft => _horizontalInset;

  double get _movementRight => _area.width - _horizontalInset;

  void resize(Size area) {
    if (area.width <= 0 || area.height <= 0) return;

    final firstLayout = _area == Size.zero;
    _area = area;

    if (firstLayout) {
      _seedObjects();
      return;
    }

    for (final object in objects) {
      _clampInside(object);
    }
  }

  void _seedObjects() {
    objects.clear();
    _idleSeconds.clear();
    if (_allowedTokens.isEmpty || _area == Size.zero) return;

    for (var i = 0; i < _objectCount; i++) {
      final token = _allowedTokens[i % _allowedTokens.length];
      objects.add(_spawn(token));
    }
    _ensureRequiredVisible();
  }

  FloatingObject _spawn(LockToken token) {
    final minDimension = min(_area.width, _area.height);
    final radius = minDimension * (0.072 + _random.nextDouble() * 0.018);
    final profile = MotionProfile.forStyle(_movementStyle);
    final speed = minDimension *
        (profile.spawnSpeedBase +
            _random.nextDouble() * profile.spawnSpeedRange) *
        _speed.multiplier;
    final angle = _random.nextDouble() * pi * 2;

    return FloatingObject(
      id: _nextId++,
      token: token,
      position: _findSpawnPosition(radius),
      velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      radius: radius,
    );
  }

  Offset _findSpawnPosition(double radius) {
    final top = _movementTop;
    final usableHeight = max(1.0, _movementHeight - radius * 2);
    Offset candidate = Offset(_area.width / 2, top + _movementHeight / 2);

    for (var attempt = 0; attempt < 30; attempt++) {
      candidate = Offset(
        _movementLeft +
            radius +
            _random.nextDouble() *
                max(1, _movementRight - _movementLeft - radius * 2),
        top + radius + _random.nextDouble() * usableHeight,
      );

      final clear = objects.every((other) {
        final minimumGap = radius + other.radius + 8;
        return (other.position - candidate).distance > minimumGap;
      });

      if (clear) return candidate;
    }

    return candidate;
  }

  void step(double dt) {
    if (_area == Size.zero || dt <= 0) return;

    _elapsedSeconds += dt;

    for (final object in List<FloatingObject>.from(objects)) {
      if (object.isPopping) {
        object.popElapsed += dt;
        if (object.popElapsed >= popDuration) {
          _respawn(object);
        }
        continue;
      }

      _applyExternalForce(object, dt);
      _applyStyleForce(object, dt);

      switch (_movementStyle) {
        case MovementStyle.bounce:
          _stepBounce(object, dt);
          break;
        case MovementStyle.zeroGravity:
          _stepZeroGravity(object, dt);
          break;
        case MovementStyle.orbit:
          _stepOrbit(object, dt);
          break;
        case MovementStyle.underwater:
          _stepUnderwater(object, dt);
          break;
        case MovementStyle.floating:
          _stepFloating(object, dt);
          break;
      }

      _applyDragAndWakeUp(object, dt);
      _limitVelocity(object);
    }

    _applyPairRepulsion(dt);

    // Pair corrections and reactive forces must never leave an object outside
    // the configured lock movement region.
    for (final object in objects) {
      if (!object.isPopping) {
        _clampInside(object);
      }
    }
  }

  void _applyPairRepulsion(double dt) {
    final active = objects.where((object) => !object.isPopping).toList();
    if (active.length < 2) return;

    final minDimension = min(_area.width, _area.height);

    for (var i = 0; i < active.length - 1; i++) {
      final first = active[i];
      for (var j = i + 1; j < active.length; j++) {
        final second = active[j];

        var delta = second.position - first.position;
        var distance = delta.distance;
        if (distance >= first.radius + second.radius) continue;

        if (distance < 0.001) {
          final direction = first.id <= second.id ? 1.0 : -1.0;
          delta = Offset(direction, 0);
          distance = 1.0;
        }

        final minDiameter = min(first.radius, second.radius) * 2;
        final overlapDepth = first.radius + second.radius - distance;
        final overlapRatio = overlapDepth / minDiameter;

        if (overlapRatio <= 0.10) continue;

        final normal = delta / distance;
        final targetDistance =
            first.radius + second.radius - minDiameter * 0.10;
        final excess = max(0.0, targetDistance - distance);

        final double response;
        final double acceleration;
        if (overlapRatio < 0.25) {
          final t = ((overlapRatio - 0.10) / 0.15).clamp(0.0, 1.0);
          response = 0.10 + 0.15 * t;
          acceleration = minDimension * (0.08 + 0.10 * t);
        } else {
          final t = ((overlapRatio - 0.25) / 0.75).clamp(0.0, 1.0);
          response = 0.35 + 0.25 * t;
          acceleration = minDimension * (0.22 + 0.24 * t);
        }

        final profile = MotionProfile.forStyle(_movementStyle);
        final correction = normal *
            (excess * response * profile.collisionPositionScale * 0.5);
        first.position -= correction;
        second.position += correction;

        final impulse = normal *
            (acceleration *
                profile.collisionImpulseScale *
                _speed.multiplier *
                dt *
                0.5);
        first.velocity -= impulse;
        second.velocity += impulse;

        if (_movementStyle == MovementStyle.bounce) {
          _applyElasticPairCollision(first, second, normal);
          _applyBottomHorizontalSpread(first, second, dt, minDimension);
        } else if (_movementStyle == MovementStyle.zeroGravity) {
          _applyZeroGravityMomentumTransfer(first, second, normal);
        } else if (_movementStyle == MovementStyle.underwater) {
          _applyUnderwaterSoftCollision(first, second, normal);
        }

        _clampInside(first);
        _clampInside(second);
      }
    }
  }

  void _applyUnderwaterSoftCollision(
    FloatingObject first,
    FloatingObject second,
    Offset normal,
  ) {
    final relativeVelocity = second.velocity - first.velocity;
    final normalSpeed =
        relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;
    if (normalSpeed >= 0) return;

    const restitution = 0.22;
    final impulseMagnitude = -(1 + restitution) * normalSpeed * 0.5;
    final impulse = normal * impulseMagnitude;

    first.velocity -= impulse;
    second.velocity += impulse;

    // Water-like contact should visibly slow both bodies after touching.
    first.velocity *= 0.94;
    second.velocity *= 0.94;
  }

  void _applyZeroGravityMomentumTransfer(
    FloatingObject first,
    FloatingObject second,
    Offset normal,
  ) {
    final relativeVelocity = second.velocity - first.velocity;
    final normalSpeed =
        relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;

    if (normalSpeed >= 0) return;

    // A soft near-elastic transfer makes contact feel like drifting bodies
    // exchanging momentum rather than rubber balls snapping apart.
    const restitution = 0.72;
    final impulseMagnitude = -(1 + restitution) * normalSpeed * 0.5;
    final impulse = normal * impulseMagnitude;

    first.velocity -= impulse;
    second.velocity += impulse;
  }

  void _applyElasticPairCollision(
    FloatingObject first,
    FloatingObject second,
    Offset normal,
  ) {
    final relativeVelocity = second.velocity - first.velocity;
    final normalSpeed =
        relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;

    // Positive means the pair is already separating.
    if (normalSpeed >= 0) return;

    final restitution = MotionProfile.forStyle(_movementStyle).wallBounce;
    final impulseMagnitude = -(1 + restitution) * normalSpeed * 0.5;
    final impulse = normal * impulseMagnitude;

    first.velocity -= impulse;
    second.velocity += impulse;
  }

  void _applyBottomHorizontalSpread(
    FloatingObject first,
    FloatingObject second,
    double dt,
    double minDimension,
  ) {
    final bottomThreshold = _movementTop + _movementHeight * 0.55;
    if (first.position.dy < bottomThreshold ||
        second.position.dy < bottomThreshold) {
      return;
    }

    var direction = second.position.dx - first.position.dx;
    if (direction.abs() < 0.001) {
      direction = first.id <= second.id ? 1.0 : -1.0;
    }

    final sign = direction.isNegative ? -1.0 : 1.0;
    final horizontalImpulse =
        minDimension * 0.22 * _speed.multiplier * dt * 0.5;

    first.velocity = Offset(
      first.velocity.dx - sign * horizontalImpulse,
      first.velocity.dy,
    );
    second.velocity = Offset(
      second.velocity.dx + sign * horizontalImpulse,
      second.velocity.dy,
    );
  }

  void _clampInside(FloatingObject object) {
    object.position = Offset(
      object.position.dx
          .clamp(
            _movementLeft + object.radius,
            _movementRight - object.radius,
          )
          .toDouble(),
      object.position.dy
          .clamp(_movementTop + object.radius, _area.height - object.radius)
          .toDouble(),
    );
  }

  void _stepFloating(FloatingObject object, double dt) {
    var next = object.position + object.velocity * dt;
    var velocity = object.velocity;

    if (next.dx - object.radius <= _movementLeft) {
      next = Offset(_movementLeft + object.radius, next.dy);
      velocity = Offset(
        velocity.dx.abs() * MotionProfile.forStyle(_movementStyle).wallBounce,
        velocity.dy,
      );
    } else if (next.dx + object.radius >= _movementRight) {
      next = Offset(_movementRight - object.radius, next.dy);
      velocity = Offset(
        -velocity.dx.abs() * MotionProfile.forStyle(_movementStyle).wallBounce,
        velocity.dy,
      );
    }

    if (next.dy - object.radius <= _movementTop) {
      next = Offset(next.dx, _movementTop + object.radius);
      velocity = Offset(
        velocity.dx,
        velocity.dy.abs() * MotionProfile.forStyle(_movementStyle).wallBounce,
      );
    } else if (next.dy + object.radius >= _area.height) {
      next = Offset(next.dx, _area.height - object.radius);
      velocity = Offset(
        velocity.dx,
        -velocity.dy.abs() * MotionProfile.forStyle(_movementStyle).wallBounce,
      );
    }

    object.position = next;
    object.velocity = velocity;
  }

  void _stepOrbit(FloatingObject object, double dt) {
    final minDimension = min(_movementRight - _movementLeft, _movementHeight);
    final center = Offset(
      (_movementLeft + _movementRight) * 0.5,
      _movementTop + _movementHeight * 0.5,
    );

    final ringIndex = object.id % 3;
    final preferredRadius =
        minDimension * (0.18 + ringIndex * 0.085);
    final direction = object.id.isEven ? 1.0 : -1.0;
    final angularSpeed =
        (0.55 + ringIndex * 0.10) * _speed.multiplier * direction;
    final phase = object.id * 2.399963229728653;
    final angle = phase + _elapsedSeconds * angularSpeed;

    final target = center +
        Offset(cos(angle), sin(angle)) * preferredRadius;
    final tangent = Offset(-sin(angle), cos(angle)) * direction;

    final targetVelocity =
        (target - object.position) * 3.2 +
        tangent * (minDimension * 0.12 * _speed.multiplier);

    final blend = (dt * 3.8).clamp(0.0, 1.0).toDouble();
    object.velocity =
        object.velocity * (1.0 - blend) + targetVelocity * blend;

    object.position += object.velocity * dt;
    _clampInside(object);
  }

  void _stepUnderwater(FloatingObject object, double dt) {
    final minDimension = min(_area.width, _area.height);
    final phase = _elapsedSeconds * 1.15 + object.id * 1.31;

    // Strong vertical swell, smaller horizontal sway: visually reads as
    // buoyant underwater motion instead of generic floating.
    final verticalWave =
        sin(phase) * minDimension * 0.055 * _speed.multiplier;
    final horizontalWave =
        cos(phase * 0.46) * minDimension * 0.018 * _speed.multiplier;

    final centerY = _movementTop + _movementHeight * 0.50;
    final buoyancy =
        (centerY - object.position.dy) * 0.42 * _speed.multiplier;

    final targetVelocity = Offset(
      horizontalWave,
      verticalWave + buoyancy,
    );

    final blend = (dt * 2.6).clamp(0.0, 1.0).toDouble();
    object.velocity =
        object.velocity * (1.0 - blend) + targetVelocity * blend;

    var next = object.position + object.velocity * dt;

    if (next.dx - object.radius <= _movementLeft ||
        next.dx + object.radius >= _movementRight) {
      object.velocity =
          Offset(-object.velocity.dx * 0.55, object.velocity.dy);
      next = object.position + object.velocity * dt;
    }

    if (next.dy - object.radius <= _movementTop ||
        next.dy + object.radius >= _area.height) {
      object.velocity =
          Offset(object.velocity.dx, -object.velocity.dy * 0.45);
      next = object.position + object.velocity * dt;
    }

    object.position = next;
    _clampInside(object);
  }

  void _stepZeroGravity(FloatingObject object, double dt) {
    final profile = MotionProfile.forStyle(_movementStyle);
    var next = object.position + object.velocity * dt;
    var velocity = object.velocity;

    if (next.dx - object.radius <= _movementLeft) {
      next = Offset(_movementLeft + object.radius, next.dy);
      velocity = Offset(
        velocity.dx.abs() * profile.wallBounce,
        velocity.dy,
      );
    } else if (next.dx + object.radius >= _movementRight) {
      next = Offset(_movementRight - object.radius, next.dy);
      velocity = Offset(
        -velocity.dx.abs() * profile.wallBounce,
        velocity.dy,
      );
    }

    if (next.dy - object.radius <= _movementTop) {
      next = Offset(next.dx, _movementTop + object.radius);
      velocity = Offset(
        velocity.dx,
        velocity.dy.abs() * profile.wallBounce,
      );
    } else if (next.dy + object.radius >= _area.height) {
      next = Offset(next.dx, _area.height - object.radius);
      velocity = Offset(
        velocity.dx,
        -velocity.dy.abs() * profile.wallBounce,
      );
    }

    object.position = next;
    object.velocity = velocity;
  }

  void _stepBounce(FloatingObject object, double dt) {
    final minDimension = min(_area.width, _area.height);
    final profile = MotionProfile.forStyle(_movementStyle);
    final gravity =
        minDimension * profile.gravityScale * _speed.multiplier;
    var velocity = Offset(
      object.velocity.dx,
      object.velocity.dy + gravity * dt,
    );
    var next = object.position + velocity * dt;

    if (next.dx - object.radius <= _movementLeft) {
      next = Offset(_movementLeft + object.radius, next.dy);
      velocity = Offset(velocity.dx.abs() * profile.wallBounce, velocity.dy);
    } else if (next.dx + object.radius >= _movementRight) {
      next = Offset(_movementRight - object.radius, next.dy);
      velocity = Offset(-velocity.dx.abs() * profile.wallBounce, velocity.dy);
    }

    if (next.dy + object.radius >= _area.height) {
      next = Offset(next.dx, _area.height - object.radius);
      final rebound = max(
        velocity.dy.abs() * profile.wallBounce,
        minDimension * 0.46 * _speed.multiplier,
      );
      velocity = Offset(velocity.dx, -rebound);
    } else if (next.dy - object.radius <= _movementTop) {
      next = Offset(next.dx, _movementTop + object.radius);
      velocity = Offset(velocity.dx, velocity.dy.abs() * profile.wallBounce);
    }

    object.position = next;
    object.velocity = velocity;
  }

  void _applyStyleForce(FloatingObject object, double dt) {
    final minDimension = min(_area.width, _area.height);
    final speedScale = _speed.multiplier;

    switch (_movementStyle) {
      case MovementStyle.floating:
        // A slow, deterministic wandering force keeps Floating alive without
        // looking jittery or changing direction abruptly.
        final phase = _elapsedSeconds * 0.72 + object.id * 1.73;
        final force = Offset(
          cos(phase) + sin(phase * 0.47) * 0.45,
          sin(phase * 0.83) + cos(phase * 0.39) * 0.35,
        );
        object.velocity +=
            force * (minDimension * 0.012 * speedScale * dt);
        break;
      case MovementStyle.bounce:
        // Bounce should preserve its collision-driven trajectory.
        break;
      case MovementStyle.zeroGravity:
        // Barely perceptible drift prevents perfectly repetitive straight-line
        // motion while preserving the long inertial feel.
        final phase = _elapsedSeconds * 0.19 + object.id * 2.11;
        final force = Offset(
          cos(phase) * 0.55,
          sin(phase * 0.71) * 0.45,
        );
        object.velocity +=
            force * (minDimension * 0.0025 * speedScale * dt);
        break;
      case MovementStyle.orbit:
      case MovementStyle.underwater:
        // These styles use dedicated trajectory functions below.
        break;
    }
  }

  void _applyExternalForce(FloatingObject object, double dt) {
    if (_externalForce == Offset.zero) return;

    final minDimension = min(_area.width, _area.height);
    final profile = MotionProfile.forStyle(_movementStyle);
    final acceleration =
        minDimension * profile.externalForceScale * _speed.multiplier;

    object.velocity += _externalForce * (acceleration * dt);
  }

  void _applyDragAndWakeUp(FloatingObject object, double dt) {
    final minDimension = min(_area.width, _area.height);
    final profile = MotionProfile.forStyle(_movementStyle);

    if (profile.dragPerSecond > 0) {
      final drag = max(0.0, 1.0 - profile.dragPerSecond * dt);
      object.velocity *= drag;
    }

    final minSpeed =
        minDimension * profile.minSpeedScale * _speed.multiplier;
    if (object.velocity.distance >= minSpeed) {
      _idleSeconds[object.id] = 0.0;
      return;
    }

    final idle = (_idleSeconds[object.id] ?? 0.0) + dt;
    _idleSeconds[object.id] = idle;
    if (idle < profile.wakeUpAfterSeconds) return;

    final angle = _random.nextDouble() * pi * 2;
    final impulse =
        minDimension * profile.wakeUpImpulseScale * _speed.multiplier;
    object.velocity += Offset(cos(angle), sin(angle)) * impulse;
    _idleSeconds[object.id] = 0.0;
  }

  void _limitVelocity(FloatingObject object) {
    final minDimension = min(_area.width, _area.height);
    final profile = MotionProfile.forStyle(_movementStyle);
    final maxSpeed =
        minDimension * profile.maxSpeedScale * _speed.multiplier;
    final current = object.velocity.distance;
    if (current <= maxSpeed || current <= 0) return;

    object.velocity = object.velocity / current * maxSpeed;
  }

  LockToken? tap(Offset localPosition) {
    FloatingObject? target;
    var closestDistance = double.infinity;

    for (final object in objects) {
      if (object.isPopping) continue;
      final distance = (object.position - localPosition).distance;
      if (distance <= object.radius && distance < closestDistance) {
        target = object;
        closestDistance = distance;
      }
    }

    if (target == null) return null;
    target.popElapsed = 0;
    return target.token;
  }

  void _ensureRequiredVisible() {
    if (_requiredTokens.isEmpty || objects.isEmpty) return;

    final requiredCounts = <String, int>{};
    final tokenById = <String, LockToken>{};
    for (final token in _requiredTokens) {
      requiredCounts[token.id] = (requiredCounts[token.id] ?? 0) + 1;
      tokenById[token.id] = token;
    }

    final visibleCounts = <String, int>{};
    for (final object in objects) {
      if (object.isPopping) continue;
      visibleCounts[object.token.id] =
          (visibleCounts[object.token.id] ?? 0) + 1;
    }

    for (final entry in requiredCounts.entries) {
      final id = entry.key;
      final requiredCount = entry.value;
      final requiredToken = tokenById[id]!;

      while ((visibleCounts[id] ?? 0) < requiredCount) {
        FloatingObject? candidate;

        for (final object in objects) {
          if (object.isPopping || object.token.id == id) continue;

          final candidateId = object.token.id;
          final candidateRequired = requiredCounts[candidateId] ?? 0;
          final candidateVisible = visibleCounts[candidateId] ?? 0;
          if (candidateVisible > candidateRequired) {
            candidate = object;
            break;
          }
        }

        if (candidate == null) break;

        final previousId = candidate.token.id;
        visibleCounts[previousId] = (visibleCounts[previousId] ?? 1) - 1;
        candidate.token = requiredToken;
        visibleCounts[id] = (visibleCounts[id] ?? 0) + 1;
      }
    }
  }

  void _respawn(FloatingObject object) {
    if (_allowedTokens.isEmpty) {
      objects.remove(object);
      return;
    }

    final token = _allowedTokens[_random.nextInt(_allowedTokens.length)];
    final minDimension = min(_area.width, _area.height);
    final profile = MotionProfile.forStyle(_movementStyle);
    final speed = minDimension *
        (profile.spawnSpeedBase +
            _random.nextDouble() * profile.spawnSpeedRange) *
        _speed.multiplier;
    final angle = _random.nextDouble() * pi * 2;

    object
      ..token = token
      ..position = _findSpawnPosition(object.radius)
      ..velocity = Offset(cos(angle) * speed, sin(angle) * speed)
      ..popElapsed = -1;

    _ensureRequiredVisible();
  }
}
