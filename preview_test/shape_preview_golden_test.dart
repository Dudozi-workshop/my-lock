import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';

const _referenceLockWidth = 393.0;
const _canvasSize = 112.0;

const _radiusFactors = <String, double>{
  'small': 0.072,
  'mid': 0.081,
  'large': 0.090,
};

Future<void> _exportBoundary({
  required GlobalKey key,
  required String path,
  required double pixelRatio,
}) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  if (data == null) {
    throw StateError('Failed to encode preview PNG: $path');
  }

  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const previewTextures = <ShapeTexture>[
    ShapeTexture.glossy,
    ShapeTexture.glass,
  ];

  group('live lock-screen shape preview export', () {
    for (final shape in ShapeKind.values) {
      for (final texture in previewTextures) {
        for (final entry in _radiusFactors.entries) {
          testWidgets(
            '${shape.name} ${texture.name} ${entry.key} live size',
            (tester) async {
              await tester.binding.setSurfaceSize(
                const Size.square(_canvasSize),
              );
              addTearDown(() => tester.binding.setSurfaceSize(null));

              final radius = _referenceLockWidth * entry.value;
              final diameter = (radius * 2).round();
              final previewKey = GlobalKey();

              final object = FloatingObject(
                id: 0,
                token: LockToken(
                  shape: shape,
                  tone: ShapeTone.blue,
                ),
                position: const Offset(
                  _canvasSize / 2,
                  _canvasSize / 2,
                ),
                velocity: Offset.zero,
                radius: radius,
              );

              await tester.pumpWidget(
                RepaintBoundary(
                  key: previewKey,
                  child: const ColoredBox(
                    color: Color(0xFFF4F5F8),
                    child: SizedBox.square(
                      dimension: _canvasSize,
                    ),
                  ),
                ),
              );

              final boundaryWidget = RepaintBoundary(
                key: previewKey,
                child: ColoredBox(
                  color: const Color(0xFFF4F5F8),
                  child: SizedBox.square(
                    dimension: _canvasSize,
                    child: CustomPaint(
                      painter: FloatingShapePainter(
                        objects: <FloatingObject>[object],
                        texture: texture,
                      ),
                    ),
                  ),
                ),
              );

              await tester.pumpWidget(boundaryWidget);
              await tester.pump();

              final base =
                  '${shape.name}_${texture.name}_${entry.key}_d${diameter}px';

              await _exportBoundary(
                key: previewKey,
                path: 'preview_test/live/${base}_actual.png',
                pixelRatio: 1,
              );
              await _exportBoundary(
                key: previewKey,
                path: 'preview_test/live_x6/${base}_x6.png',
                pixelRatio: 6,
              );

              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  });
}
