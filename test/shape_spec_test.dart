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

  test('Preview 007 circle uses target-master masks', () async {
    await ShapeSpecRegistry.instance.load();

    final bundle = ShapeSpecRegistry.instance.resolve(
      ShapeStyle.softBasic,
      ShapeKind.circle,
    );

    expect(bundle.shape.version, 8);
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
      switch (layer.id) {
        case 'diffuse_light':
        case 'form_shadow':
        case 'rim_light':
          expect(asset.contains('_v4.b64'), isTrue);
          break;
        case 'soft_spec':
        case 'core_spec':
          expect(asset.contains('_v6.b64'), isTrue);
          break;
      }
    }
  });

  test('Preview 007 Circle mask assets are not fully opaque', () async {
    await ShapeSpecRegistry.instance.load();

    final bundle = ShapeSpecRegistry.instance.resolve(
      ShapeStyle.softBasic,
      ShapeKind.circle,
    );

    for (final layer in bundle.shape.layers) {
      final asset = layer.geometry.values['asset'] as String;
      final image = ShapeSpecRegistry.instance.resolveMask(asset);
      expect(image.width, 128);
      expect(image.height, 128);
    }
  });

}
