import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Soft Basic ShapeSpecs load for all active shapes', () async {
    await ShapeSpecRegistry.instance.load();

    for (final shape in ShapeKind.values) {
      final bundle = ShapeSpecRegistry.instance.resolve(
        ShapeStyle.softBasic,
        shape,
      );

      expect(bundle.style.id, 'soft_basic');
      expect(bundle.shape.shapeId, shape.name);
      expect(bundle.shape.layers.map((layer) => layer.role).toSet(), {
        ShapeLayerRole.light,
        ShapeLayerRole.shade,
        ShapeLayerRole.spec,
      });
    }
  });

  test('Preview 006 circle uses alpha-safe spec masks', () async {
    await ShapeSpecRegistry.instance.load();

    final bundle = ShapeSpecRegistry.instance.resolve(
      ShapeStyle.softBasic,
      ShapeKind.circle,
    );

    expect(bundle.shape.version, 7);
    expect(bundle.shape.rotationMode, ShapeRotationMode.fixed);
    expect(bundle.shape.surface.kind, 'radial');
    expect(bundle.shape.layers.length, 5);
    expect(
      bundle.shape.layers.every((layer) => layer.geometry.kind == 'mask'),
      isTrue,
    );
    expect(
      bundle.shape.layers.map((layer) => layer.blend).toList(),
      [
        ShapeLayerBlend.softLight,
        ShapeLayerBlend.multiply,
        ShapeLayerBlend.screen,
        ShapeLayerBlend.screen,
        ShapeLayerBlend.screen,
      ],
    );

    for (final layer in bundle.shape.layers) {
      final asset = layer.geometry.values['asset'] as String;
      final image = ShapeSpecRegistry.instance.resolveMask(asset);
      expect(image.width, 128);
      expect(image.height, 128);
      if (layer.id == 'soft_spec' || layer.id == 'core_spec') {
        expect(asset.contains('_v4.b64'), isTrue);
      } else {
        expect(asset.contains('_v2.b64'), isTrue);
      }
    }
  });
}
