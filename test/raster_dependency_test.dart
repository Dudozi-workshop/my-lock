import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('integrated raster dependency closure loads and renders both approved static shapes', () async {
    final registry = ShapeSpecRegistry.instance;
    await registry.load();
    await registry.loadRasterShapes();
    for (final shape in [ShapeKind.seaTurtle, ShapeKind.starfish]) {
      final recorder = ui.PictureRecorder();
      ShapeSpecRenderer.paintToken(ui.Canvas(recorder), center:const ui.Offset(32,32), radius:26,
        token:LockToken(shape:shape,tone:ShapeTone.blue),style:ShapeStyle.softBasic,opacity:1);
      final picture = recorder.endRecording();
      final image = await picture.toImage(64,64);
      final data = (await image.toByteData(format:ui.ImageByteFormat.rawRgba))!;
      var visible = 0;
      for (var i=3;i<data.lengthInBytes;i+=4) {if (data.getUint8(i)>0) visible++;}
      expect(visible, greaterThan(300));
      expect(data.getUint8(3),0);
      picture.dispose(); image.dispose();
    }
  });
}
