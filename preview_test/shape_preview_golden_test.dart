import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/crystal_sprite.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(CrystalSprite.load);

  group('shape preview export', () {
    for (final shape in ShapeKind.values) {
      testWidgets('${shape.name} exact 58 logical px', (tester) async {
        tester.view.devicePixelRatio = 4.0;
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.binding.setSurfaceSize(const Size(58, 58));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final previewKey = ValueKey<String>('shape-preview-${shape.name}');
        final token = LockToken(
          shape: shape,
          tone: ShapeTone.blue,
        );

        await tester.pumpWidget(
          RepaintBoundary(
            key: previewKey,
            child: const ColoredBox(
              color: Color(0xFFF4F5F8),
              child: SizedBox.expand(),
            ),
          ),
        );

        await tester.pumpWidget(
          RepaintBoundary(
            key: previewKey,
            child: ColoredBox(
              color: const Color(0xFFF4F5F8),
              child: SizedBox.square(
                dimension: 58,
                child: CustomPaint(
                  painter: LockTokenPainter(
                    token,
                    texture: ShapeTexture.glossy,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        await expectLater(
          find.byKey(previewKey),
          matchesGoldenFile('goldens/${shape.name}_58px_dpr4.png'),
        );
      });
    }

    for (final tone in const [
      ShapeTone.pink,
      ShapeTone.yellow,
    ]) {
      testWidgets('dolphin ${tone.name} exact 58 logical px', (tester) async {
        tester.view.devicePixelRatio = 4.0;
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.binding.setSurfaceSize(const Size(58, 58));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final previewKey =
            ValueKey<String>('dolphin-preview-${tone.name}');
        final token = LockToken(
          shape: ShapeKind.dolphin,
          tone: tone,
        );

        await tester.pumpWidget(
          RepaintBoundary(
            key: previewKey,
            child: ColoredBox(
              color: const Color(0xFFF4F5F8),
              child: SizedBox.square(
                dimension: 58,
                child: CustomPaint(
                  painter: LockTokenPainter(
                    token,
                    texture: ShapeTexture.glossy,
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
            'goldens/dolphin_58px_${tone.name}_dpr4.png',
          ),
        );
      });
    }


    for (final shape in ShapeKind.values) {
      testWidgets('glass ${shape.name} exact 58 logical px', (tester) async {
        tester.view.devicePixelRatio = 4.0;
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.binding.setSurfaceSize(const Size(58, 58));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final previewKey =
            ValueKey<String>('glass-preview-${shape.name}');
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
                dimension: 58,
                child: CustomPaint(
                  painter: LockTokenPainter(
                    token,
                    texture: ShapeTexture.glass,
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
            'goldens/glass_${shape.name}_58px_blue_dpr4.png',
          ),
        );
      });
    }

    for (final tone in const [
      ShapeTone.pink,
      ShapeTone.yellow,
    ]) {
      testWidgets('glass dolphin ${tone.name} exact 58 logical px',
          (tester) async {
        tester.view.devicePixelRatio = 4.0;
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.binding.setSurfaceSize(const Size(58, 58));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final previewKey =
            ValueKey<String>('glass-dolphin-preview-${tone.name}');
        final token = LockToken(
          shape: ShapeKind.dolphin,
          tone: tone,
        );

        await tester.pumpWidget(
          RepaintBoundary(
            key: previewKey,
            child: ColoredBox(
              color: const Color(0xFFF4F5F8),
              child: SizedBox.square(
                dimension: 58,
                child: CustomPaint(
                  painter: LockTokenPainter(
                    token,
                    texture: ShapeTexture.glass,
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
            'goldens/glass_dolphin_58px_${tone.name}_dpr4.png',
          ),
        );
      });
    }

  });
}
