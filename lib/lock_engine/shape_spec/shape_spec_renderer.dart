import 'dart:math';

import 'package:flutter/material.dart';

import '../models.dart';
import 'shape_spec.dart';
import 'shape_spec_registry.dart';

class ShapeSpecRenderer {
  const ShapeSpecRenderer._();

  static void paintToken(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required LockToken token,
    required ShapeStyle style,
    required double opacity,
  }) {
    final bundle = ShapeSpecRegistry.instance.resolve(style, token.shape);
    final canvasSize = bundle.style.canvasSize;
    final scale = radius * 2 / canvasSize;

    canvas.save();
    canvas.translate(center.dx - radius, center.dy - radius);
    canvas.scale(scale, scale);

    final bodyPath = _pathFor(bundle.shape.body);
    final shadow = bundle.shape.shadow;
    if (shadow.opacity > 0) {
      canvas.save();
      canvas.translate(shadow.offsetX, shadow.offsetY);
      canvas.drawShadow(
        bodyPath,
        Colors.black.withValues(alpha: shadow.opacity * opacity),
        shadow.elevation,
        true,
      );
      canvas.restore();
    }

    final base = baseColorForTone(token.tone);
    final rules = bundle.style.colorRules;
    final light = adjustTone(
      base,
      lightnessDelta: rules.lightnessUp,
      saturationDelta: rules.lightSaturationDelta,
    );
    final shade = adjustTone(
      base,
      lightnessDelta: -rules.lightnessDown,
      saturationDelta: rules.shadeSaturationDelta,
    );

    canvas.drawPath(
      bodyPath,
      Paint()..color = base.withValues(alpha: opacity),
    );

    canvas.save();
    canvas.clipPath(bodyPath);
    for (final layer in bundle.shape.layers) {
      final layerColor = switch (layer.role) {
        ShapeLayerRole.light => light,
        ShapeLayerRole.shade => shade,
        ShapeLayerRole.spec => rules.specColor,
      };

      if (layer.geometry.kind == 'mask') {
        final asset = layer.geometry.values['asset'] as String;
        final image = ShapeSpecRegistry.instance.resolveMask(asset);
        final paint = Paint()
          ..filterQuality = FilterQuality.high
          ..colorFilter = ColorFilter.mode(
            layerColor.withValues(alpha: layer.opacity * opacity),
            BlendMode.srcIn,
          );
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(
            0,
            0,
            image.width.toDouble(),
            image.height.toDouble(),
          ),
          Rect.fromLTWH(0, 0, canvasSize, canvasSize),
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
        ..color = layerColor.withValues(alpha: layer.opacity * opacity);
      if (layer.blur > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, layer.blur);
      }
      canvas.drawPath(geometryPath, paint);
      canvas.restore();
    }
    canvas.restore();

    canvas.restore();
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
