import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/whole_shape_idle_runtime.dart';

void main() {
  test('Starfish is registered as premium shape', () {
    expect(ShapeKind.values, contains(ShapeKind.starfish));
    expect(ShapeKind.starfish.premium, isTrue);
  });
  test('micro idle stays inside approved bounds', () {
    const config=<String,dynamic>{'enabled':true,'period_seconds':3.6,'sway_degrees':2.4,'vertical_float_radius_ratio':0.016,'horizontal_drift_radius_ratio':0.006,'breathing_scale':0.012,'random_initial_phase':false};
    for(var i=0;i<=72;i++){
      final v=WholeShapeIdleRuntime.instance.transformFor(key:'qa',timeSeconds:i/20,config:config,radius:29);
      expect(v.rotationRadians.abs(),lessThanOrEqualTo(2.4*pi/180+1e-9));
      expect(v.offset.dy.abs(),lessThanOrEqualTo(29*0.016+1e-9));
      expect(v.scaleX,inInclusiveRange(0.988,1.012));
      expect(v.scaleY,inInclusiveRange(0.988,1.012));
    }
  });
}
