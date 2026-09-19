import 'dart:math';
import 'dart:ui';

import 'effects.dart';
import 'models.dart';

class FloatingEngine {
  FloatingEngine({int seed = 4921}) : _random = Random(seed);

  static const int defaultObjectCount = 9;
  static const Set<int> supportedObjectCounts = {6, 9, 12};
  static const double popDuration = 0.18;

  final Random _random;
  final List<FloatingObject> objects = [];

  Size _area = Size.zero;
  int _nextId = 0;
  MovementStyle _movementStyle = MovementStyle.floating;
  FloatingSpeed _speed = FloatingSpeed.normal;
  int _objectCount = defaultObjectCount;
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
    if (_area != Size.zero) _seedObjects();
  }

  void resize(Size area) {
    if (area.width <= 0 || area.height <= 0) return;

    final firstLayout = _area == Size.zero;
    _area = area;

    if (firstLayout) {
      _seedObjects();
      return;
    }

    for (final object in objects) {
      object.position = Offset(
        object.position.dx
            .clamp(object.radius, area.width - object.radius)
            .toDouble(),
        object.position.dy
            .clamp(object.radius, area.height - object.radius)
            .toDouble(),
      );
    }
  }

  void _seedObjects() {
    objects.clear();
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
    final speedScale =
        _movementStyle == MovementStyle.bounce ? 0.13 : 0.085;
    final speedRange =
        _movementStyle == MovementStyle.bounce ? 0.06 : 0.055;
    final speed = minDimension *
        (speedScale + _random.nextDouble() * speedRange) *
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
    Offset candidate = Offset(_area.width / 2, _area.height / 2);

    for (var attempt = 0; attempt < 30; attempt++) {
      candidate = Offset(
        radius + _random.nextDouble() * max(1, _area.width - radius * 2),
        radius + _random.nextDouble() * max(1, _area.height - radius * 2),
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

    for (final object in List<FloatingObject>.from(objects)) {
      if (object.isPopping) {
        object.popElapsed += dt;
        if (object.popElapsed >= popDuration) {
          _respawn(object);
        }
        continue;
      }

      switch (_movementStyle) {
        case MovementStyle.bounce:
          _stepBounce(object, dt);
          break;
        case MovementStyle.floating:
        case MovementStyle.orbit:
        case MovementStyle.zeroGravity:
        case MovementStyle.underwater:
          _stepFloating(object, dt);
          break;
      }
    }

    _applyPairRepulsion(dt);
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

        final correction = normal * (excess * response * 0.5);
        first.position -= correction;
        second.position += correction;

        final impulse =
            normal * (acceleration * _speed.multiplier * dt * 0.5);
        first.velocity -= impulse;
        second.velocity += impulse;

        if (_movementStyle == MovementStyle.bounce) {
          _applyBottomHorizontalSpread(first, second, dt, minDimension);
        }

        _clampInside(first);
        _clampInside(second);
      }
    }
  }

  void _applyBottomHorizontalSpread(
    FloatingObject first,
    FloatingObject second,
    double dt,
    double minDimension,
  ) {
    final bottomThreshold = _area.height * 0.70;
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
          .clamp(object.radius, _area.width - object.radius)
          .toDouble(),
      object.position.dy
          .clamp(object.radius, _area.height - object.radius)
          .toDouble(),
    );
  }

  void _stepFloating(FloatingObject object, double dt) {
    var next = object.position + object.velocity * dt;
    var velocity = object.velocity;

    if (next.dx - object.radius <= 0) {
      next = Offset(object.radius, next.dy);
      velocity = Offset(velocity.dx.abs(), velocity.dy);
    } else if (next.dx + object.radius >= _area.width) {
      next = Offset(_area.width - object.radius, next.dy);
      velocity = Offset(-velocity.dx.abs(), velocity.dy);
    }

    if (next.dy - object.radius <= 0) {
      next = Offset(next.dx, object.radius);
      velocity = Offset(velocity.dx, velocity.dy.abs());
    } else if (next.dy + object.radius >= _area.height) {
      next = Offset(next.dx, _area.height - object.radius);
      velocity = Offset(velocity.dx, -velocity.dy.abs());
    }

    object.position = next;
    object.velocity = velocity;
  }

  void _stepBounce(FloatingObject object, double dt) {
    final minDimension = min(_area.width, _area.height);
    final gravity = minDimension * 0.9 * _speed.multiplier;
    var velocity = Offset(
      object.velocity.dx,
      object.velocity.dy + gravity * dt,
    );
    var next = object.position + velocity * dt;

    if (next.dx - object.radius <= 0) {
      next = Offset(object.radius, next.dy);
      velocity = Offset(velocity.dx.abs(), velocity.dy);
    } else if (next.dx + object.radius >= _area.width) {
      next = Offset(_area.width - object.radius, next.dy);
      velocity = Offset(-velocity.dx.abs(), velocity.dy);
    }

    if (next.dy + object.radius >= _area.height) {
      next = Offset(next.dx, _area.height - object.radius);
      final rebound = max(
        velocity.dy.abs() * 0.82,
        minDimension * 0.24 * _speed.multiplier,
      );
      velocity = Offset(velocity.dx, -rebound);
    } else if (next.dy - object.radius <= 0) {
      next = Offset(next.dx, object.radius);
      velocity = Offset(velocity.dx, velocity.dy.abs());
    }

    object.position = next;
    object.velocity = velocity;
  }

  LockToken? tap(Offset localPosition) {
    FloatingObject? target;
    var closestDistance = double.infinity;

    for (final object in objects) {
      if (object.isPopping) continue;
      final distance = (object.position - localPosition).distance;
      if (distance <= object.radius * 1.22 && distance < closestDistance) {
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
    final speedScale =
        _movementStyle == MovementStyle.bounce ? 0.13 : 0.085;
    final speedRange =
        _movementStyle == MovementStyle.bounce ? 0.06 : 0.055;
    final speed = minDimension *
        (speedScale + _random.nextDouble() * speedRange) *
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
