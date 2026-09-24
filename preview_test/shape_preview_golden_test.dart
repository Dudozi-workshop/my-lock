import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const previewTextures = <ShapeTexture>[
    ShapeTexture.glossy,
    ShapeTexture.glass,
  ];
  const previewSizes = <double>[55, 65, 75];

  group('shape preview export', () {
    for (final shape in ShapeKind.values) {
      for (final texture in previewTextures) {
        for (final logicalSize in previewSizes) {
          testWidgets(
            '${shape.name} ${texture.name} ${logicalSize.toInt()} logical px',
            (tester) async {
              tester.view.devicePixelRatio = 4.0;
              addTearDown(tester.view.resetDevicePixelRatio);

              final size = Size.square(logicalSize);
              await tester.binding.setSurfaceSize(size);
              addTearDown(() => tester.binding.setSurfaceSize(null));

              final px = logicalSize.toInt();
              final previewKey = ValueKey<String>(
                'shape-preview-${shape.name}-${texture.name}-$px',
              );
              final token = LockToken(
                shape: shape,
                tone: ShapeTone.blue,
              );

              await tester.pumpWidget(
                RepaintBoundary(
                  key: previewKey,
                  child: ColoredBox(
                    color: const Color(0xFFF4F5F8),
                    child: SizedBox.square(
                      dimension: logicalSize,
                      child: CustomPaint(
                        painter: LockTokenPainter(
                          token,
                          texture: texture,
                        ),
                      ),
                    ),
                  ),
                ),
              );

              await tester.pump();

              await expectLater(
                find.byKey(previewKey),
                matchesGoldenFile(
                  'goldens/${shape.name}_${texture.name}_${px}px_dpr4.png',
                ),
              );
            },
          );
        }
      }
    }
  });
}
