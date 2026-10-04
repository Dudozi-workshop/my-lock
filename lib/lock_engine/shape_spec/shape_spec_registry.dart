import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../models.dart';
import 'shape_spec.dart';
import 'raster_shape_spec.dart';
import 'candy_soft_runtime.dart';

class ShapeSpecRegistry {
  ShapeSpecRegistry._();

  static final ShapeSpecRegistry instance = ShapeSpecRegistry._();

  final Map<ShapeStyle, ShapeStyleSpec> _styles = {};
  final Map<(ShapeStyle, ShapeKind), ShapeSpec> _shapes = {};
  final Map<String, ui.Image> _maskImages = {};
  final Map<ShapeKind, RasterShapeSpec> _rasterSpecs = {};
  Future<void>? _rasterLoad;

  static const Map<ShapeKind, String> _rasterShapeAssets = {
    ShapeKind.seaTurtle: 'assets/raster_shapes/sea_turtle_v3_runtime_v5.json',
    ShapeKind.starfish: 'assets/raster_shapes/starfish_runtime_v1.json',
  };
  bool _loaded = false;

  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    for (final style in ShapeStyle.values) {
      final styleSpec = await _loadJson(
        'assets/shape_specs/${style.assetId}/style.json',
      );
      final parsedStyle = ShapeStyleSpec.fromJson(styleSpec);
      _styles[style] = parsedStyle;
      final shapeSourceId = parsedStyle.shapeSourceId ?? style.assetId;

      for (final shape in ShapeKind.values) {
        if (_rasterShapeAssets.containsKey(shape)) continue;

        final shapeJson = await _loadJson(
          'assets/shape_specs/$shapeSourceId/${shape.name}.json',
        );
        final spec = ShapeSpec.fromJson(shapeJson);
        if (spec.styleId != shapeSourceId || spec.shapeId != shape.name) {
          throw StateError(
            'ShapeSpec id mismatch: $shapeSourceId/${shape.name}',
          );
        }
        _shapes[(style, shape)] = spec;

        if (parsedStyle.renderMode != ShapeRenderMode.layered) {
          continue;
        }

        for (final layer in spec.layers) {
          if (layer.geometry.kind != 'mask') continue;
          final asset = layer.geometry.values['asset'] as String?;
          if (asset == null ||
              asset.isEmpty ||
              _maskImages.containsKey(asset)) {
            continue;
          }
          _maskImages[asset] = await _loadMaskImage(asset);
        }
      }
    }

    await CandySoftRuntime.instance.load();
    _loaded = true;
  }

  bool isRasterShape(ShapeKind shape) => _rasterShapeAssets.containsKey(shape);

  String? rasterAssetPath(ShapeKind shape) => _rasterShapeAssets[shape];

  Future<void> loadRasterShapes() =>
      _rasterLoad ??= _loadRasterSpecs().catchError((Object error) {
        _rasterLoad = null;
        throw error;
      });

  Future<void> _loadRasterSpecs() async {
    for (final entry in _rasterShapeAssets.entries) {
      if (_rasterSpecs.containsKey(entry.key)) continue;
      final metadata = RasterShapeMetadata.fromJson(
        await _loadJson(entry.value),
      );
      final images = <ui.Image>[];
      final swimPoses = <String, RasterPoseImages>{};
      try {
        for (final layer in ['master', 'palette_base', 'fixed_finish']) {
          images.add(await _loadRasterImage(metadata.asset(layer)));
        }

        final poseConfigs = metadata.swim['poses'] as Map?;
        if (poseConfigs != null) {
          for (final rawPose in poseConfigs.keys) {
            final pose = rawPose as String;
            if (pose == 's0') continue;
            final paletteParts = metadata.swimAssetParts(pose, 'palette_base');
            final finishParts = metadata.swimAssetParts(pose, 'fixed_finish');
            if (paletteParts.isEmpty || finishParts.isEmpty) continue;

            final palette = await _loadChunkedRasterImage(paletteParts);
            final finish = await _loadChunkedRasterImage(finishParts);
            images
              ..add(palette)
              ..add(finish);
            swimPoses[pose] = RasterPoseImages(
              paletteBase: palette,
              fixedFinish: finish,
            );
          }
        }

        if (images.any(
          (image) =>
              image.width != metadata.runtimeCanvas.width ||
              image.height != metadata.runtimeCanvas.height,
        )) {
          throw StateError('Raster canvas mismatch: ${metadata.shapeId}');
        }
        _rasterSpecs[entry.key] = RasterShapeSpec(
          metadata: metadata,
          master: images[0],
          paletteBase: images[1],
          fixedFinish: images[2],
          swimPoses: swimPoses,
        );
      } catch (_) {
        for (final image in images) {
          image.dispose();
        }
        rethrow;
      }
    }
  }

  RasterShapeSpec resolveRasterSpec(ShapeKind shape) {
    final spec = _rasterSpecs[shape];
    if (spec == null)
      throw StateError('Missing raster Shape asset: ${shape.name}');
    return spec;
  }

  ui.Image resolveRasterShape(ShapeKind shape) =>
      resolveRasterSpec(shape).master;

  ShapeSpecBundle resolve(ShapeStyle style, ShapeKind shape) {
    if (!_loaded) {
      throw StateError('ShapeSpecRegistry must be loaded before rendering.');
    }

    final styleSpec = _styles[style];
    final shapeSpec = _shapes[(style, shape)];
    if (styleSpec == null || shapeSpec == null) {
      throw StateError('Missing ShapeSpec: ${style.name}/${shape.name}');
    }

    return ShapeSpecBundle(style: styleSpec, shape: shapeSpec);
  }

  ui.Image resolveMask(String asset) {
    final image = _maskImages[asset];
    if (image == null) {
      throw StateError('Missing ShapeSpec mask asset: $asset');
    }
    return image;
  }

  Future<Map<String, dynamic>> _loadJson(String path) async {
    final raw = await rootBundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<ui.Image> _loadRasterImage(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }

  Future<ui.Image> _loadChunkedRasterImage(List<String> parts) async {
    final encoded = StringBuffer();
    for (final part in parts) {
      encoded.write((await rootBundle.loadString(part)).trim());
    }

    try {
      final codec = await ui.instantiateImageCodec(
        base64Decode(encoded.toString()),
      );
      try {
        return (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    } catch (error) {
      throw StateError(
        'Invalid chunked raster asset: ${parts.join(', ')}: $error',
      );
    }
  }

  Future<ui.Image> _loadMaskImage(String asset) async {
    final encoded = (await rootBundle.loadString(asset)).trim();
    final bytes = base64Decode(encoded);
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }
}
