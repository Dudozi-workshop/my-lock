import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'effects.dart';
import 'baked_sphere_sprite.dart';
import 'floating_engine.dart';
import 'models.dart';
import 'shape_painter.dart';

class FloatingPreview extends StatefulWidget {
  const FloatingPreview({
    super.key,
    required this.selectedShapes,
    required this.selectedTones,
    this.movementStyle = MovementStyle.floating,
    this.popStyle = PopStyle.basicPop,
    this.texture = ShapeTexture.glossy,
    this.onTokenTap,
    this.requiredTokens = const <LockToken>[],
    this.objectCount = FloatingEngine.defaultObjectCount,
    this.speed = FloatingSpeed.normal,
    this.movementArea = MovementArea.full,
    this.topInset = 0,
  });

  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final ShapeTexture texture;
  final ValueChanged<LockToken>? onTokenTap;
  final List<LockToken> requiredTokens;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final double topInset;

  @override
  State<FloatingPreview> createState() => _FloatingPreviewState();
}

class _FloatingPreviewState extends State<FloatingPreview>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final FloatingEngine _engine = FloatingEngine();
  Duration _previous = Duration.zero;
  Size _lastSize = Size.zero;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;
  Offset _tilt = Offset.zero;
  double _gyroZ = 0;
  double _shake = 0;

  @override
  void initState() {
    super.initState();
    _engine
      ..setSelection(widget.selectedShapes, widget.selectedTones)
      ..setMovementStyle(widget.movementStyle)
      ..setObjectCount(widget.objectCount)
      ..setSpeed(widget.speed)
      ..setMovementArea(widget.movementArea)
      ..setTopInset(widget.topInset)
      ..setRequiredTokens(widget.requiredTokens);
    _ticker = createTicker(_onTick)..start();
    _startMotionSensors();
  }

  void _startMotionSensors() {
    try {
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (event) {
          final nextTilt = Offset(
            (-event.x / 9.81).clamp(-1.0, 1.0).toDouble(),
            (event.y / 9.81).clamp(-1.0, 1.0).toDouble(),
          );
          _tilt = Offset(
            _tilt.dx * 0.82 + nextTilt.dx * 0.18,
            _tilt.dy * 0.82 + nextTilt.dy * 0.18,
          );
          _pushReactiveMotion();
        },
        onError: (_) {},
        cancelOnError: false,
      );

      _gyroscopeSubscription = gyroscopeEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (event) {
          _gyroZ = _gyroZ * 0.78 + event.z * 0.22;
          _pushReactiveMotion();
        },
        onError: (_) {},
        cancelOnError: false,
      );

      _userAccelerometerSubscription = userAccelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (event) {
          final magnitude = sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );
          final normalized = ((magnitude - 0.8) / 7.0).clamp(0.0, 1.0).toDouble();
          _shake = max(_shake * 0.82, normalized);
          _pushReactiveMotion();
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {
      _engine.clearReactiveMotion();
    }
  }

  void _pushReactiveMotion() {
    _engine.setReactiveMotion(
      tilt: _tilt,
      gyroZ: _gyroZ,
      shake: _shake,
    );
  }

  @override
  void didUpdateWidget(covariant FloatingPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(oldWidget.selectedShapes, widget.selectedShapes) ||
        !setEquals(oldWidget.selectedTones, widget.selectedTones)) {
      _engine.setSelection(widget.selectedShapes, widget.selectedTones);
    }
    if (oldWidget.movementStyle != widget.movementStyle) {
      _engine.setMovementStyle(widget.movementStyle);
    }
    if (oldWidget.objectCount != widget.objectCount) {
      _engine.setObjectCount(widget.objectCount);
    }
    if (oldWidget.speed != widget.speed) {
      _engine.setSpeed(widget.speed);
    }
    if (oldWidget.movementArea != widget.movementArea) {
      _engine.setMovementArea(widget.movementArea);
    }
    if (oldWidget.topInset != widget.topInset) {
      _engine.setTopInset(widget.topInset);
    }
    _engine.setRequiredTokens(widget.requiredTokens);
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final delta = _previous == Duration.zero
        ? 0.0
        : (elapsed - _previous).inMicroseconds /
            Duration.microsecondsPerSecond;
    _previous = elapsed;

    if (delta > 0) {
      _engine.step(delta.clamp(0.0, 0.035).toDouble());
      setState(() {});
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size != _lastSize && size.width > 0 && size.height > 0) {
          _lastSize = size;
          _engine.resize(size);
        }

        final dolphinIds = _engine.objects
            .where((object) => object.token.shape == ShapeKind.dolphin)
            .map((object) => object.id)
            .toSet();

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final token = _engine.tap(details.localPosition);
            if (token != null) {
              HapticFeedback.lightImpact();
              widget.onTokenTap?.call(token);
              setState(() {});
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: FloatingShapePainter(
                  objects: _engine.objects,
                  popStyle: widget.popStyle,
                  texture: widget.texture,
                  hiddenObjectIds: dolphinIds,
                ),
                child: const SizedBox.expand(),
              ),
              if (dolphinIds.isNotEmpty)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: BakedSphereSpritePainter(
                        objects: _engine.objects,
                        animationSeconds:
                            _previous.inMicroseconds /
                                Duration.microsecondsPerSecond,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
