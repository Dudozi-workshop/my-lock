import 'dart:math';
import 'dart:ui';

import 'models.dart';

class FloatingEngine {
  FloatingEngine({int seed = 4921}) : _random = Random(seed);

  static const int defaultObjectCount = 9;
  static const double popDuration = 0.18;

  final Random _random;
  final List<FloatingObject> objects = [];

  Size _area = Size.zero;
  int _nextId = 0;

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

  void resize(Size area) {
    if (area.width <= 0 || area.height <= 0) return;

    final firstLayout = _area == Size.zero;
    _area = area;

    if (firstLayout) {
      _seedDefaultObjects();
      return;
    }

    for (final object in objects) {
      object.position = Offset(
        object.position.dx.clamp(object.radius, area.width - object.radius).toDouble(),
        object.position.dy.clamp(object.radius, area.height - object.radius).toDouble(),
      );
    }
  }

  void _seedDefaultObjects() {
    objects.clear();
    for (var i = 0; i < defaultObjectCount; i++) {
      objects.add(_spawn(defaultTokens[i]));
    }
  }

  FloatingObject _spawn(LockToken token) {
    final minDimension = min(_area.width, _area.height);
    final radius = minDimension * (0.072 + _random.nextDouble() * 0.018);
    final speed = minDimension * (0.085 + _random.nextDouble() * 0.055);
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

    for (final object in objects) {
      if (object.isPopping) {
        object.popElapsed += dt;
        if (object.popElapsed >= popDuration) {
          _respawn(object);
        }
        continue;
      }

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
  }

  bool tap(Offset localPosition) {
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

    if (target == null) return false;
    target.popElapsed = 0;
    return true;
  }

  void _respawn(FloatingObject object) {
    final token = defaultTokens[_random.nextInt(defaultTokens.length)];
    final minDimension = min(_area.width, _area.height);
    final speed = minDimension * (0.085 + _random.nextDouble() * 0.055);
    final angle = _random.nextDouble() * pi * 2;

    object
      ..token = token
      ..position = _findSpawnPosition(object.radius)
      ..velocity = Offset(cos(angle) * speed, sin(angle) * speed)
      ..popElapsed = -1;
  }
}
