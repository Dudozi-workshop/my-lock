import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../models.dart';
import 'shape_spec.dart';

class ShapeSpecRegistry {
  ShapeSpecRegistry._();

  static final ShapeSpecRegistry instance = ShapeSpecRegistry._();

  final Map<ShapeStyle, ShapeStyleSpec> _styles = {};
  final Map<(ShapeStyle, ShapeKind), ShapeSpec> _shapes = {};
  final Map<String, ui.Image> _maskImages = {};
  final Map<ShapeKind, ui.Image> _rasterImages = {};

  static const Map<ShapeKind, String> _rasterShapeAssets = {
    ShapeKind.seaTurtle:
        'assets/raster_shapes/sea_turtle_v3_runtime58.png.b64',
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
          if (asset == null || asset.isEmpty || _maskImages.containsKey(asset)) {
            continue;
          }
          _maskImages[asset] = await _loadMaskImage(asset);
        }
      }
    }

    _loaded = true;
  }

  bool isRasterShape(ShapeKind shape) => _rasterShapeAssets.containsKey(shape);

  String? rasterAssetPath(ShapeKind shape) => _rasterShapeAssets[shape];

  Future<void> loadRasterShapes() async {
    for (final entry in _rasterShapeAssets.entries) {
      if (_rasterImages.containsKey(entry.key)) continue;
      _rasterImages[entry.key] = await _loadMaskImage(entry.value);
    }
  }

  ui.Image resolveRasterShape(ShapeKind shape) {
    final image = _rasterImages[shape];
    if (image == null) {
      throw StateError('Missing raster Shape asset: ${shape.name}');
    }
    return image;
  }

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

  Future<ui.Image> _loadMaskImage(String asset) async {
    final encoded = (await rootBundle.loadString(asset)).trim();
    final bytes = base64Decode(encoded);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
