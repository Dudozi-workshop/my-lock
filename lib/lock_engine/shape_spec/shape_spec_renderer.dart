import 'dart:math';

import 'package:flutter/material.dart';

import '../models.dart';
import 'shape_render_overrides.dart';
import 'shape_spec.dart';
import 'shape_spec_registry.dart';

class ShapeSpecRenderer {
  const ShapeSpecRenderer._();

  static final Map<String, _CrayonTextureGeometry> _crayonTextureCache = {};

  static void paintToken(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required LockToken token,
    required ShapeStyle style,
    required double opacity,
    double objectRotation = 0,
    CrayonTextureSpec? crayonOverride,
    ShapeRenderOverrides? overrides,
  }) {
    final bundle = ShapeSpecRegistry.instance.resolve(style, token.shape);
    final canvasSize = bundle.style.canvasSize;
    final scale = radius * 2 / canvasSize;

    canvas.save();
    if (bundle.shape.rotationMode == ShapeRotationMode.rotateWithObject &&
        objectRotation != 0) {
      canvas
        ..translate(center.dx, center.dy)
        ..rotate(objectRotation)
        ..translate(-center.dx, -center.dy);
    }
    canvas.translate(center.dx - radius, center.dy - radius);
    canvas.scale(scale, scale);

    final bodyPath = _pathFor(overrides?.bodyGeometry ?? bundle.shape.body);

    if (bundle.style.renderMode == ShapeRenderMode.crayon) {
      _paintCrayonToken(
        canvas,
        bodyPath: bodyPath,
        style: bundle.style,
        token: token,
        opacity: opacity,
        configOverride: crayonOverride,
      );
      canvas.restore();
      return;
    }

    final shadow = bundle.shape.shadow;
    final shadowOpacity =
        shadow.opacity * (overrides?.shadowOpacityScale ?? 1);
    final shadowElevation =
        shadow.elevation * (overrides?.shadowElevationScale ?? 1);
    if (shadowOpacity > 0) {
      canvas.save();
      canvas.translate(shadow.offsetX, shadow.offsetY);
      canvas.drawShadow(
        bodyPath,
        Colors.black.withValues(alpha: shadowOpacity * opacity),
        shadowElevation,
        true,
      );
      canvas.restore();
    }

    final base = baseColorForTone(token.tone);
    final rules = bundle.style.colorRules;
    final toneScale = _perceptualToneScale(token.tone);
    final light = adjustTone(
      base,
      lightnessDelta: rules.lightnessUp * toneScale.light,
      saturationDelta: rules.lightSaturationDelta,
    );
    final shade = adjustTone(
      base,
      lightnessDelta: -rules.lightnessDown * toneScale.shade,
      saturationDelta: rules.shadeSaturationDelta,
    );

    final surfaceLight = adjustTone(
      base,
      lightnessDelta: rules.lightnessUp * 0.26 * toneScale.light,
      saturationDelta: rules.lightSaturationDelta,
    );
    final surfaceShade = adjustTone(
      base,
      lightnessDelta: -rules.lightnessDown * 0.22 * toneScale.shade,
      saturationDelta: rules.shadeSaturationDelta * 0.5,
    );

    final bodyPaint = Paint();
    if (bundle.shape.surface.kind == 'radial') {
      final surface = bundle.shape.surface;
      bodyPaint.shader = RadialGradient(
        center: Alignment(
          overrides?.surfaceCenterX ?? surface.centerX,
          overrides?.surfaceCenterY ?? surface.centerY,
        ),
        radius: overrides?.surfaceRadius ?? surface.radius,
        colors: [
          surfaceLight.withValues(alpha: opacity),
          base.withValues(alpha: opacity),
          base.withValues(alpha: opacity),
          surfaceShade.withValues(alpha: opacity),
        ],
        stops: surface.stops,
      ).createShader(Rect.fromLTWH(0, 0, canvasSize, canvasSize));
    } else {
      bodyPaint.color = base.withValues(alpha: opacity);
    }
    canvas.drawPath(bodyPath, bodyPaint);

    canvas.save();
    canvas.clipPath(bodyPath);
    for (final layer in bundle.shape.layers) {
      final layerOpacity =
          overrides?.resolveLayerOpacity(layer) ?? layer.opacity;
      final defaultLayerColor = switch (layer.role) {
        ShapeLayerRole.light => light,
        ShapeLayerRole.shade => shade,
        ShapeLayerRole.spec => rules.specColor,
      };
      final layerColor = layer.toneLightnessDelta == null &&
              layer.toneSaturationDelta == null
          ? defaultLayerColor
          : adjustTone(
              base,
              lightnessDelta: layer.toneLightnessDelta ?? 0,
              saturationDelta: layer.toneSaturationDelta ?? 0,
            );

      if (layer.geometry.kind == 'mask') {
        final asset = layer.geometry.values['asset'] as String;
        final image = ShapeSpecRegistry.instance.resolveMask(asset);
        final paint = Paint()
          ..filterQuality = FilterQuality.high
          ..blendMode = _blendModeFor(layer.blend)
          ..colorFilter = ColorFilter.mode(
            layerColor.withValues(alpha: layerOpacity * opacity),
            BlendMode.srcIn,
          );
        final transform = overrides?.layerTransformById[layer.id];
        final destRect = transform == null
            ? Rect.fromLTWH(0, 0, canvasSize, canvasSize)
            : Rect.fromCenter(
                center: Offset(
                  canvasSize / 2 + transform.offsetX,
                  canvasSize / 2 + transform.offsetY,
                ),
                width: canvasSize * transform.scaleX,
                height: canvasSize * transform.scaleY,
              );
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(
            0,
            0,
            image.width.toDouble(),
            image.height.toDouble(),
          ),
          destRect,
          paint,
        );
        continue;
      }

      final geometryPath = _pathFor(layer.geometry);
      final center = _centerFor(layer.geometry);

      canvas.save();
      if (layer.rotationDeg != 0) {
        canvas
          ..translate(center.dx, center.dy)
          ..rotate(layer.rotationDeg * pi / 180)
          ..translate(-center.dx, -center.dy);
      }

      final paint = Paint()
        ..blendMode = _blendModeFor(layer.blend)
        ..color = layerColor.withValues(alpha: layerOpacity * opacity);
      if (layer.blur > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, layer.blur);
      }
      canvas.drawPath(geometryPath, paint);
      canvas.restore();
    }
    canvas.restore();

    canvas.restore();
  }

  static void _paintCrayonToken(
    Canvas canvas, {
    required Path bodyPath,
    required ShapeStyleSpec style,
    required LockToken token,
    required double opacity,
    CrayonTextureSpec? configOverride,
  }) {
    final config = configOverride ?? style.crayon;
    if (config == null) {
      throw StateError('Crayon render mode requires crayon style config.');
    }

    final base = baseColorForTone(token.tone);
    final fill = adjustTone(
      base,
      lightnessDelta: 0.015,
      saturationDelta: -0.035,
    );
    final dark = adjustTone(
      base,
      lightnessDelta: -0.13,
      saturationDelta: 0.025,
    );
    final light = adjustTone(
      base,
      lightnessDelta: 0.18,
      saturationDelta: -0.055,
    );

    canvas.save();
    canvas.translate(0.15, 0.75);
    canvas.drawShadow(
      bodyPath,
      Colors.black.withValues(alpha: 0.035 * opacity),
      1.5,
      true,
    );
    canvas.restore();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = fill.withValues(
          alpha: config.underpaintOpacity * opacity,
        ),
    );

    final cacheKey =
        '${style.id}:${style.version}:${token.id}:${_crayonConfigKey(config)}';
    final texture = _crayonTextureCache.putIfAbsent(
      cacheKey,
      () => _buildCrayonTexture(config, cacheKey),
    );

    canvas.save();
    canvas.clipPath(bodyPath);

    if (texture.baseStrokes.isNotEmpty && config.baseStrokeOpacity > 0) {
      final basePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = config.strokeWidth * 1.12
        ..color = base.withValues(alpha: config.baseStrokeOpacity * opacity);
      for (final path in texture.baseStrokes) {
        canvas.drawPath(path, basePaint);
      }
    }

    final darkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = config.strokeWidth
      ..color = dark.withValues(alpha: config.darkOpacity * opacity);

    for (final path in texture.darkStrokes) {
      canvas.drawPath(path, darkPaint);
    }

    final lightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = config.strokeWidth * 0.82
      ..color = light.withValues(alpha: config.lightOpacity * opacity);

    for (final path in texture.lightStrokes) {
      canvas.drawPath(path, lightPaint);
    }

    final grainPaint = Paint()
      ..color = light.withValues(alpha: config.grainOpacity * opacity);
    for (final dot in texture.grain) {
      canvas.drawCircle(dot.center, dot.radius, grainPaint);
    }

    canvas.restore();

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeJoin = StrokeJoin.round
      ..color = dark.withValues(alpha: config.edgeOpacity * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.3);
    canvas.drawPath(bodyPath, edgePaint);

    canvas.save();
    canvas.translate(0.35, -0.2);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..strokeJoin = StrokeJoin.round
        ..color = light.withValues(alpha: config.edgeOpacity * 0.5 * opacity),
    );
    canvas.restore();
  }

  static _CrayonTextureGeometry _buildCrayonTexture(
    CrayonTextureSpec config,
    String seedText,
  ) {
    final random = Random(_stableSeed(seedText));

    List<Path> buildStrokes(
      int count,
      double angleOffset, {
      double breakScale = 1.0,
    }) {
      final angle = (config.angleDeg + angleOffset) * pi / 180;
      final direction = Offset(cos(angle), sin(angle));
      final normal = Offset(-direction.dy, direction.dx);
      final strokes = <Path>[];

      for (var i = 0; i < count; i++) {
        final fraction = count <= 1 ? 0.5 : i / (count - 1);
        final lane = -72 + fraction * 144 +
            (random.nextDouble() - 0.5) * config.jitter * 1.8;
        final path = Path();

        for (var step = 0; step <= 14; step++) {
          final travel = -86 + step * (172 / 14);
          final wobble = (random.nextDouble() - 0.5) * config.jitter;
          final alongWobble =
              (random.nextDouble() - 0.5) * config.jitter * 0.45;
          final point = const Offset(50, 50) +
              direction * (travel + alongWobble) +
              normal * (lane + wobble);
          final shouldBreak = step > 0 &&
              random.nextDouble() <
                  (config.strokeBreakChance * breakScale).clamp(0.0, 0.85);
          if (step == 0 || shouldBreak) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        strokes.add(path);
      }
      return strokes;
    }

    final baseStrokes = buildStrokes(
      config.baseStrokeCount,
      -3,
      breakScale: 1.15,
    );
    final darkStrokes = buildStrokes(config.darkStrokeCount, 0);
    final lightStrokes = buildStrokes(
      config.lightStrokeCount,
      9,
      breakScale: 0.70,
    );

    final grain = <_CrayonGrainDot>[];
    for (var i = 0; i < config.grainCount; i++) {
      grain.add(
        _CrayonGrainDot(
          Offset(
            5 + random.nextDouble() * 90,
            5 + random.nextDouble() * 90,
          ),
          0.22 + random.nextDouble() * 0.72,
        ),
      );
    }

    return _CrayonTextureGeometry(
      baseStrokes: baseStrokes,
      darkStrokes: darkStrokes,
      lightStrokes: lightStrokes,
      grain: grain,
    );
  }

  static String _crayonConfigKey(CrayonTextureSpec config) {
    return [
      config.darkStrokeCount,
      config.lightStrokeCount,
      config.grainCount,
      config.strokeWidth,
      config.angleDeg,
      config.jitter,
      config.darkOpacity,
      config.lightOpacity,
      config.grainOpacity,
      config.edgeOpacity,
      config.baseStrokeCount,
      config.underpaintOpacity,
      config.baseStrokeOpacity,
      config.strokeBreakChance,
    ].join(':');
  }

  static int _stableSeed(String value) {
    var hash = 0x811C9DC5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  static Path _pathFor(ShapeGeometrySpec geometry) {
    final v = geometry.values;
    switch (geometry.kind) {
      case 'circle':
        return Path()
          ..addOval(
            Rect.fromCircle(
              center: Offset(
                (v['cx'] as num).toDouble(),
                (v['cy'] as num).toDouble(),
              ),
              radius: (v['r'] as num).toDouble(),
            ),
          );
      case 'ellipse':
        final cx = (v['cx'] as num).toDouble();
        final cy = (v['cy'] as num).toDouble();
        final rx = (v['rx'] as num).toDouble();
        final ry = (v['ry'] as num).toDouble();
        return Path()
          ..addOval(Rect.fromLTRB(cx - rx, cy - ry, cx + rx, cy + ry));
      case 'roundRect':
        final rect = Rect.fromLTWH(
          (v['x'] as num).toDouble(),
          (v['y'] as num).toDouble(),
          (v['w'] as num).toDouble(),
          (v['h'] as num).toDouble(),
        );
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              rect,
              Radius.circular((v['radius'] as num).toDouble()),
            ),
          );
      case 'roundedPolygon':
        final points = [
          for (final point in v['points'] as List<dynamic>)
            Offset(
              ((point as List<dynamic>)[0] as num).toDouble(),
              (point[1] as num).toDouble(),
            ),
        ];
        return _roundedPolygonPath(
          points,
          (v['cornerRadius'] as num).toDouble(),
        );
      case 'path':
        final path = Path();
        for (final raw in v['commands'] as List<dynamic>) {
          final command = raw as Map<String, dynamic>;
          switch (command['op'] as String) {
            case 'M':
              path.moveTo(
                (command['x'] as num).toDouble(),
                (command['y'] as num).toDouble(),
              );
              break;
            case 'L':
              path.lineTo(
                (command['x'] as num).toDouble(),
                (command['y'] as num).toDouble(),
              );
              break;
            case 'Q':
              path.quadraticBezierTo(
                (command['cx'] as num).toDouble(),
                (command['cy'] as num).toDouble(),
                (command['x'] as num).toDouble(),
                (command['y'] as num).toDouble(),
              );
              break;
            case 'C':
              path.cubicTo(
                (command['c1x'] as num).toDouble(),
                (command['c1y'] as num).toDouble(),
                (command['c2x'] as num).toDouble(),
                (command['c2y'] as num).toDouble(),
                (command['x'] as num).toDouble(),
                (command['y'] as num).toDouble(),
              );
              break;
            case 'Z':
              path.close();
              break;
          }
        }
        return path;
      default:
        throw StateError('Unsupported ShapeSpec geometry: ${geometry.kind}');
    }
  }

  static Offset _centerFor(ShapeGeometrySpec geometry) {
    final v = geometry.values;
    switch (geometry.kind) {
      case 'circle':
      case 'ellipse':
        return Offset(
          (v['cx'] as num).toDouble(),
          (v['cy'] as num).toDouble(),
        );
      case 'roundRect':
        return Offset(
          (v['x'] as num).toDouble() + (v['w'] as num).toDouble() / 2,
          (v['y'] as num).toDouble() + (v['h'] as num).toDouble() / 2,
        );
      case 'roundedPolygon':
        final points = v['points'] as List<dynamic>;
        var x = 0.0;
        var y = 0.0;
        for (final point in points) {
          final p = point as List<dynamic>;
          x += (p[0] as num).toDouble();
          y += (p[1] as num).toDouble();
        }
        return Offset(x / points.length, y / points.length);
      case 'path':
        return _pathFor(geometry).getBounds().center;
      default:
        return Offset.zero;
    }
  }

  static ({double light, double shade}) _perceptualToneScale(
    ShapeTone tone,
  ) {
    switch (tone) {
      case ShapeTone.pink:
        return (light: 0.88, shade: 1.12);
      case ShapeTone.blue:
        return (light: 0.84, shade: 1.00);
      case ShapeTone.yellow:
        return (light: 0.68, shade: 1.30);
    }
  }

  static BlendMode _blendModeFor(ShapeLayerBlend blend) {
    switch (blend) {
      case ShapeLayerBlend.normal:
        return BlendMode.srcOver;
      case ShapeLayerBlend.softLight:
        return BlendMode.softLight;
      case ShapeLayerBlend.multiply:
        return BlendMode.multiply;
      case ShapeLayerBlend.screen:
        return BlendMode.screen;
    }
  }

  static Path _roundedPolygonPath(
    List<Offset> points,
    double cornerRadius,
  ) {
    if (points.length < 3) return Path();

    Offset toward(Offset from, Offset to, double distance) {
      final delta = to - from;
      final length = delta.distance;
      if (length == 0) return from;
      return from + delta / length * min(distance, length * 0.45);
    }

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final previous = points[(i - 1 + points.length) % points.length];
      final current = points[i];
      final next = points[(i + 1) % points.length];
      final start = toward(current, previous, cornerRadius);
      final end = toward(current, next, cornerRadius);

      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      } else {
        path.lineTo(start.dx, start.dy);
      }
      path.quadraticBezierTo(current.dx, current.dy, end.dx, end.dy);
    }
    return path..close();
  }
}


class _CrayonTextureGeometry {
  const _CrayonTextureGeometry({
    required this.baseStrokes,
    required this.darkStrokes,
    required this.lightStrokes,
    required this.grain,
  });

  final List<Path> baseStrokes;
  final List<Path> darkStrokes;
  final List<Path> lightStrokes;
  final List<_CrayonGrainDot> grain;
}

class _CrayonGrainDot {
  const _CrayonGrainDot(this.center, this.radius);

  final Offset center;
  final double radius;
}
