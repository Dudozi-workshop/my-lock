import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import 'models.dart';

enum Sphere3DMaterialPreset {
  matte('Matte'),
  softGlossy('Soft Glossy'),
  glassyGloss('Glassy Gloss');

  const Sphere3DMaterialPreset(this.label);
  final String label;
}

Sphere3DMaterialPreset sphere3DPresetForTexture(ShapeTexture texture) {
  return switch (texture) {
    ShapeTexture.matte => Sphere3DMaterialPreset.matte,
    ShapeTexture.glass ||
    ShapeTexture.chrome ||
    ShapeTexture.hologram => Sphere3DMaterialPreset.glassyGloss,
    ShapeTexture.glossy ||
    ShapeTexture.jelly ||
    ShapeTexture.metal => Sphere3DMaterialPreset.softGlossy,
  };
}

void _applyMaterialPreset(
  PhysicallyBasedMaterial material,
  Sphere3DMaterialPreset preset,
) {
  switch (preset) {
    case Sphere3DMaterialPreset.matte:
      material
        ..metallicFactor = 0.0
        ..roughnessFactor = 0.86
        ..specular = 0.38
        ..clearcoat = 0.0
        ..clearcoatRoughness = 0.65;
      break;
    case Sphere3DMaterialPreset.softGlossy:
      material
        ..metallicFactor = 0.01
        ..roughnessFactor = 0.14
        ..specular = 1.0
        ..clearcoat = 0.96
        ..clearcoatRoughness = 0.055;
      break;
    case Sphere3DMaterialPreset.glassyGloss:
      material
        ..metallicFactor = 0.0
        ..roughnessFactor = 0.045
        ..specular = 1.0
        ..clearcoat = 1.0
        ..clearcoatRoughness = 0.018;
      break;
  }
}

void _configureStudioScene(
  Scene scene, {
  required bool runtimeOptimized,
}) {
  // flutter_scene supplies a built-in studio IBL when Scene.environment is
  // left null. Add one analytic key light so clearcoat/specular movement reads
  // clearly while keeping shadows off for lock-screen performance.
  scene
    ..exposure = 1.10
    ..environmentIntensity = 1.28
    ..renderScale = runtimeOptimized ? 0.86 : 1.0
    ..directionalLight = DirectionalLight(
      direction: vm.Vector3(-0.46, -0.72, 0.56),
      color: vm.Vector3(1.0, 0.96, 0.92),
      intensity: 2.35,
      castsShadow: false,
    );
}

/// Interactive single-object material preview for Shape Lab.
class GlossySphere3D extends StatefulWidget {
  const GlossySphere3D({
    super.key,
    required this.tone,
    this.interactive = false,
    this.autoRotate = true,
    this.preset = Sphere3DMaterialPreset.softGlossy,
  });

  final ShapeTone tone;
  final bool interactive;
  final bool autoRotate;
  final Sphere3DMaterialPreset preset;

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
    if (oldWidget.preset != widget.preset) {
      final material = _material;
      if (material != null) {
        _applyMaterialPreset(material, widget.preset);
      }
    }
  }

  Future<void> _initialize() async {
    try {
      await Scene.initializeStaticResources();

      final material = PhysicallyBasedMaterial()
        ..baseColorFactor = _toneVector(widget.tone);
      _applyMaterialPreset(material, widget.preset);

      final sphere = Node(
        name: 'mylock_3d_poc_sphere',
        mesh: Mesh(
          IcosphereGeometry(radius: 0.82, subdivisions: 3),
          material,
        ),
      )
        ..rotation = vm.Quaternion.euler(_yaw, _pitch, 0)
        ..scale = vm.Vector3.all(_scale);

      _configureStudioScene(_scene, runtimeOptimized: false);
      _scene.add(sphere);

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
      return const _ThreeDError();
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
          elapsedSeconds:
              elapsed.inMicroseconds / Duration.microsecondsPerSecond,
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

/// One retained 3D Scene for every moving dolphin slot.
///
/// The previous PoC created a SceneView per moving object. This widget keeps a
/// single SceneView and a fixed pool of nodes, then updates only node transforms
/// from FloatingEngine. That is the architecture we want to benchmark before
/// replacing spheres with Dolphin.glb.
class FloatingSphere3DScene extends StatefulWidget {
  const FloatingSphere3DScene({
    super.key,
    required this.objects,
    required this.viewportSize,
    required this.texture,
    this.maxObjects = 12,
  });

  final List<FloatingObject> objects;
  final Size viewportSize;
  final ShapeTexture texture;
  final int maxObjects;

  @override
  State<FloatingSphere3DScene> createState() => _FloatingSphere3DSceneState();
}

class _FloatingSphere3DSceneState extends State<FloatingSphere3DScene> {
  final Scene _scene = Scene();
  final List<Node> _nodes = <Node>[];
  final List<PhysicallyBasedMaterial> _materials =
      <PhysicallyBasedMaterial>[];

  bool _ready = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant FloatingSphere3DScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.texture != widget.texture) {
      _applyPresetToAll();
    }
    _syncObjects();
  }

  Future<void> _initialize() async {
    try {
      await Scene.initializeStaticResources();

      final geometry = IcosphereGeometry(radius: 0.82, subdivisions: 2);
      final preset = sphere3DPresetForTexture(widget.texture);

      for (var i = 0; i < widget.maxObjects; i++) {
        final material = PhysicallyBasedMaterial()
          ..baseColorFactor = _toneVector(ShapeTone.blue);
        _applyMaterialPreset(material, preset);

        final node = Node(
          name: 'mylock_3d_runtime_$i',
          mesh: Mesh(geometry, material),
        )
          ..position = vm.Vector3(0, 0, 0)
          ..scale = vm.Vector3.all(0.001);

        _materials.add(material);
        _nodes.add(node);
        _scene.add(node);
      }

      _configureStudioScene(_scene, runtimeOptimized: true);
      _syncObjects();

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

  void _applyPresetToAll() {
    final preset = sphere3DPresetForTexture(widget.texture);
    for (final material in _materials) {
      _applyMaterialPreset(material, preset);
    }
  }

  void _syncObjects() {
    if (_nodes.isEmpty) return;
    final size = widget.viewportSize;
    if (size.width <= 0 || size.height <= 0) return;

    final dolphins = widget.objects
        .where((object) => object.token.shape == ShapeKind.dolphin)
        .take(_nodes.length)
        .toList(growable: false);

    final worldHeight = 5.0;
    final worldWidth = worldHeight * size.width / size.height;
    final minDimension = math.min(size.width, size.height);

    for (var i = 0; i < _nodes.length; i++) {
      final node = _nodes[i];

      if (i >= dolphins.length) {
        node.scale = vm.Vector3.all(0.001);
        continue;
      }

      final object = dolphins[i];
      final normalizedX = object.position.dx / size.width - 0.5;
      final normalizedY = object.position.dy / size.height - 0.5;

      final worldX = normalizedX * worldWidth;
      final worldY = -normalizedY * worldHeight;

      final diameterFraction = (object.radius * 2) / minDimension;
      var worldScale = diameterFraction * worldHeight * 0.72;

      if (object.isPopping) {
        final progress =
            (object.popElapsed / 0.18).clamp(0.0, 1.0).toDouble();
        worldScale *= 1.0 + progress * 0.34;
      }

      node
        ..position = vm.Vector3(worldX, worldY, 0)
        ..rotation = vm.Quaternion.euler(
          object.rotation * 0.22,
          object.rotation,
          object.rotation * 0.10,
        )
        ..scale = vm.Vector3.all(worldScale);

      _materials[i].baseColorFactor = _toneVector(object.token.tone);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return const _ThreeDError();
    }

    if (!_ready) {
      return const SizedBox.expand();
    }

    _syncObjects();

    return IgnorePointer(
      child: SceneView(
        _scene,
        camera: PerspectiveCamera(
          position: vm.Vector3(0, 0, -7.15),
          target: vm.Vector3(0, 0, 0),
          fovRadiansY: 39 * math.pi / 180,
        ),
        onTick: (elapsed, deltaSeconds) {
          _syncObjects();
        },
      ),
    );
  }
}

class _ThreeDError extends StatelessWidget {
  const _ThreeDError();

  @override
  Widget build(BuildContext context) {
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
