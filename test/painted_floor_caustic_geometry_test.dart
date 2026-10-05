import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../shape_lab/painted_floor_caustic_layer.dart';
import '../shape_lab/background_asset_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Floor follows the Base cover transform across phone ratios and loops', () async {
    await BackgroundAssetRegistry.load();
    final record=BackgroundAssetRegistry.instance.resolve(
      'background.drop01.shallow_clear.floor_caustic_static_v1');
    final bytes=await rootBundle.load(record.runtimePath!);
    final codec=await ui.instantiateImageCodec(bytes.buffer.asUint8List(bytes.offsetInBytes,bytes.lengthInBytes));
    final texture=(await codec.getNextFrame()).image;
    codec.dispose();
    expect(texture.width,841); expect(texture.height,1870);
    Future<List<int>> frame(ui.Size size,double seconds,{bool reference=false,bool visibleMotion=true,bool cellMotion=true}) async {
      final recorder=ui.PictureRecorder();
      final canvas=ui.Canvas(recorder);
      if(reference) {
        paintImage(canvas:canvas,rect:ui.Offset.zero&size,image:texture,
          fit:BoxFit.cover,filterQuality:FilterQuality.medium);
      } else {
        PaintedFloorCausticPainter(texture,AlwaysStoppedAnimation(seconds/24),visibleMotion:visibleMotion,cellMotion:cellMotion).paint(canvas,size);
      }
      final picture=recorder.endRecording();
      final image=await picture.toImage(size.width.toInt(),size.height.toInt());
      final bytes=(await image.toByteData(format:ui.ImageByteFormat.rawRgba))!.buffer.asUint8List().toList();
      image.dispose(); picture.dispose();
      return bytes;
    }
    for(final ratio in [9/16,9/18,9/19.5,9/20,9/21,.67]) {
      final size=ui.Size(180,(180/ratio).roundToDouble());
      final first=await frame(size,0);
      final reference=await frame(size,0,reference:true);
      final early=await frame(size,1);
      final previousEarly=await frame(size,1,cellMotion:false);
      final later=await frame(size,2);
      final loop=await frame(size,24);
      final scale=math.max(size.width/texture.width,size.height/texture.height);
      final floorTop=((size.height-texture.height*scale)/2+texture.height*scale*.655).floor();
      var referenceDiff=0;
      var loopDiff=0;
      var changed=0;
      var earlyChange=0;
      var previousChange=0;
      var earlyChangedPixels=0;
      for(var i=3;i<first.length;i+=4) {
        final y=(i~/4)~/size.width.toInt();
        if(y<floorTop) expect(later[i],0,reason:'No light above mapped floor, ratio=$ratio');
        referenceDiff+=(first[i]-reference[i]).abs();
        loopDiff=math.max(loopDiff,(first[i]-loop[i]).abs());
        if((first[i]-later[i]).abs()>12) changed++;
        earlyChange+=(first[i]-early[i]).abs();
        previousChange+=(first[i]-previousEarly[i]).abs();
        if((first[i]-early[i]).abs()>12) earlyChangedPixels++;
      }
      expect(referenceDiff/(first.length/4),lessThan(.6),reason:'phase 0 matches Base cover');
      expect(loopDiff,lessThanOrEqualTo(2));
      expect(changed,greaterThan(100));
      expect(earlyChangedPixels,greaterThan(100),reason:"Actual texture changes within 1 second");
      expect(earlyChange,greaterThan(previousChange*1.5),
        reason:"R31 must produce materially more change than R30, ratio=$ratio");
    }
    texture.dispose();
  });
}
