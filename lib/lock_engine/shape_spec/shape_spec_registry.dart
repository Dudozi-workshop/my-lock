import 'dart:convert';

import 'package:flutter/services.dart';

import '../models.dart';
import 'shape_spec.dart';

class ShapeSpecRegistry {
  ShapeSpecRegistry._();

  static final ShapeSpecRegistry instance = ShapeSpecRegistry._();

  final Map<ShapeStyle, ShapeStyleSpec> _styles = {};
  final Map<(ShapeStyle, ShapeKind), ShapeSpec> _shapes = {};
  bool _loaded = false;

  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    for (final style in ShapeStyle.values) {
      final styleSpec = await _loadJson(
        'assets/shape_specs/${style.assetId}/style.json',
      );
      _styles[style] = ShapeStyleSpec.fromJson(styleSpec);

      for (final shape in ShapeKind.values) {
        final shapeJson = await _loadJson(
          'assets/shape_specs/${style.assetId}/${shape.name}.json',
        );
        final spec = ShapeSpec.fromJson(shapeJson);
        if (spec.styleId != style.assetId || spec.shapeId != shape.name) {
          throw StateError(
            'ShapeSpec id mismatch: ${style.assetId}/${shape.name}',
          );
        }
        _shapes[(style, shape)] = spec;
      }
    }

    _loaded = true;
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

  Future<Map<String, dynamic>> _loadJson(String path) async {
    final raw = await rootBundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
