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

  test('Production Circle v10 uses finalized Soft Basic master', () async {
    await ShapeSpecRegistry.instance.load();

    final bundle = ShapeSpecRegistry.instance.resolve(
      ShapeStyle.softBasic,
      ShapeKind.circle,
    );

    expect(bundle.shape.version, 10);
    expect(bundle.shape.rotationMode, ShapeRotationMode.fixed);
    expect(bundle.shape.surface.kind, 'solid');
    expect(bundle.shape.layers.length, 9);
    expect(
      bundle.shape.layers.map((layer) => layer.id).toList(),
      [
        'color_shell',
        'color_shell_inner',
        'airbrush_light',
        'airbrush_shade',
        'ambient_bounce',
        'ambient_core',
        'ambient_depth',
        'edge_leaf_halo',
        'edge_leaf',
      ],
    );
    expect(
      bundle.shape.layers.map((layer) => layer.geometry.kind).toList(),
      [
        'circle',
        'circle',
        'circle',
        'circle',
        'ellipse',
        'circle',
        'ellipse',
        'path',
        'path',
      ],
    );
    expect(
      bundle.shape.layers.any((layer) => layer.id == 'core_spec'),
      isFalse,
    );
    expect(
      bundle.shape.layers.any((layer) => layer.geometry.kind == 'mask'),
      isFalse,
    );

    final light = bundle.shape.layers.firstWhere(
      (layer) => layer.id == 'airbrush_light',
    );
    final shade = bundle.shape.layers.firstWhere(
      (layer) => layer.id == 'airbrush_shade',
    );
    final bounce = bundle.shape.layers.firstWhere(
      (layer) => layer.id == 'ambient_bounce',
    );
    final shell = bundle.shape.layers.firstWhere(
      (layer) => layer.id == 'color_shell',
    );
    final leaf = bundle.shape.layers.last;

    expect(light.toneLightnessDelta, closeTo(0.16, 0.0001));
    expect(shade.toneLightnessDelta, closeTo(-0.16, 0.0001));
    expect(bounce.opacity, closeTo(0.16, 0.0001));
    expect(bounce.toneLightnessDelta, closeTo(0.11, 0.0001));
    expect(shell.opacity, closeTo(0.28, 0.0001));
    expect(leaf.role, ShapeLayerRole.spec);
    expect(leaf.blur, greaterThan(0));
  });

  test('Production Circle Edge Leaf path is authored and closed', () async {
    await ShapeSpecRegistry.instance.load();

    final bundle = ShapeSpecRegistry.instance.resolve(
      ShapeStyle.softBasic,
      ShapeKind.circle,
    );
    final leaf = bundle.shape.layers.last;
    final commands = leaf.geometry.values['commands'] as List<dynamic>;

    expect(commands.first['op'], 'M');
    expect(commands.where((value) => value['op'] == 'C').length, 4);
    expect(commands.last['op'], 'Z');
  });

  test('Crayon Soft reuses shape masters with procedural texture', () async {
    await ShapeSpecRegistry.instance.load();

    for (final shape in ShapeKind.values) {
      final bundle = ShapeSpecRegistry.instance.resolve(
        ShapeStyle.crayonSoft,
        shape,
      );

      expect(bundle.style.id, 'crayon_soft');
      expect(bundle.style.renderMode, ShapeRenderMode.crayon);
      expect(bundle.style.shapeSourceId, 'soft_basic');
      expect(bundle.style.crayon, isNotNull);
      expect(bundle.shape.styleId, 'soft_basic');
      expect(bundle.shape.shapeId, shape.name);
    }
  });

}
