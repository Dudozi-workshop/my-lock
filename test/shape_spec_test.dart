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
}
