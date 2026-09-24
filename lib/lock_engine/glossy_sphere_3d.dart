import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import 'models.dart';

/// Cross-platform Flutter GPU / Impeller 3D proof-of-concept.
///
/// This is intentionally a sphere first, not a dolphin model. The goal of this
/// stage is to prove that MY LOCK can render a glossy PBR object inside the same
/// Flutter surface used by the Android overlay and future iOS build.
class GlossySphere3D extends StatefulWidget {
  const GlossySphere3D({
    super.key,
    required this.tone,
    this.interactive = false,
    this.autoRotate = true,
  });

  final ShapeTone tone;
  final bool interactive;
  final bool autoRotate;

  @override
  State<GlossySphere3D> createState() => _GlossySphere3DState();
}

class _GlossySphere3DState extends State<GlossySphere3D> {
  final Scene _scene = Scene();

  Node? _sphere;
  PhysicallyBasedMaterial? _material;
  bool _ready = false;
  Object? _error;

  double _yaw = -0.38;
  double _pitch = 0.22;
  double _scale = 1.0;
  double _gestureStartScale = 1.0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant GlossySphere3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tone != widget.tone) {
      _applyTone();
    }
  }

  Future<void> _initialize() async {
    try {
      await Scene.initializeStaticResources();

      final material = PhysicallyBasedMaterial()
        ..baseColorFactor = _toneVector(widget.tone)
        ..metallicFactor = 0.02
        ..roughnessFactor = 0.16
        ..specular = 1.0
        ..clearcoat = 0.92
        ..clearcoatRoughness = 0.08;

      final sphere = Node(
        name: 'mylock_3d_poc_sphere',
        mesh: Mesh(
          IcosphereGeometry(radius: 0.82, subdivisions: 3),
          material,
        ),
      )
        ..rotation = vm.Quaternion.euler(_yaw, _pitch, 0)
        ..scale = vm.Vector3.all(_scale);

      _scene
        ..exposure = 1.08
        ..renderScale = 1.0
        ..add(sphere);

      _material = material;
      _sphere = sphere;

      if (mounted) {
        setState(() {
          _ready = true;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
        });
      }
    }
  }

  void _applyTone() {
    final material = _material;
    if (material == null) return;
    material.baseColorFactor = _toneVector(widget.tone);
  }

  void _applyTransform({double? elapsedSeconds}) {
    final sphere = _sphere;
    if (sphere == null) return;

    final autoYaw =
        widget.autoRotate && elapsedSeconds != null ? elapsedSeconds * 0.28 : 0.0;

    sphere
      ..rotation = vm.Quaternion.euler(_yaw + autoYaw, _pitch, 0)
      ..scale = vm.Vector3.all(_scale);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (!widget.interactive) return;
    _gestureStartScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!widget.interactive) return;

    setState(() {
      if (details.pointerCount >= 2) {
        _scale = (_gestureStartScale * details.scale).clamp(0.72, 1.45);
      } else {
        _yaw += details.focalPointDelta.dx * 0.012;
        _pitch = (_pitch + details.focalPointDelta.dy * 0.010)
            .clamp(-math.pi * 0.42, math.pi * 0.42);
      }
      _applyTransform();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x221E293B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x335E8FD8)),
        ),
        child: const Center(
          child: Text(
            '3D renderer unavailable',
            style: TextStyle(
              color: Color(0xFF91A4BF),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return const Center(
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final sceneView = SceneView(
      _scene,
      camera: PerspectiveCamera(
        position: vm.Vector3(0, 0.08, -3.25),
        target: vm.Vector3(0, 0, 0),
        fovRadiansY: 36 * math.pi / 180,
      ),
      onTick: (elapsed, deltaSeconds) {
        _applyTransform(
          elapsedSeconds: elapsed.inMicroseconds /
              Duration.microsecondsPerSecond,
        );
      },
    );

    if (!widget.interactive) {
      return IgnorePointer(child: sceneView);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: sceneView,
    );
  }
}

vm.Vector4 _toneVector(ShapeTone tone) {
  return switch (tone) {
    ShapeTone.pink => vm.Vector4(1.00, 0.43, 0.73, 1.0),
    ShapeTone.blue => vm.Vector4(0.22, 0.63, 1.00, 1.0),
    ShapeTone.yellow => vm.Vector4(1.00, 0.69, 0.24, 1.0),
    ShapeTone.purple => vm.Vector4(0.56, 0.38, 0.98, 1.0),
    ShapeTone.mint => vm.Vector4(0.16, 0.84, 0.67, 1.0),
    ShapeTone.black => vm.Vector4(0.08, 0.09, 0.13, 1.0),
    ShapeTone.white => vm.Vector4(0.94, 0.96, 1.00, 1.0),
  };
}
