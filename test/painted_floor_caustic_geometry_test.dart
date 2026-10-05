import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import '../shape_lab/painted_floor_caustic_layer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Floor follows the Base cover transform across phone ratios and loops', () async {
    // Geometric fixture, not a stand-in for actual texture/browser art review.
    final recorder=ui.PictureRecorder();
    final canvas=ui.Canvas(recorder);
    for(var y=680;y<1000;y+=17) {
      canvas.drawRect(ui.Rect.fromLTWH(20+(y%43).toDouble(),y.toDouble(),380,6),
        ui.Paint()..color=const ui.Color(0xBFFFF0C0));
    }
    final picture=recorder.endRecording();
    final texture=await picture.toImage(450,1000);
    picture.dispose();
    Future<List<int>> frame(ui.Size size,double seconds,{bool reference=false}) async {
      final recorder=ui.PictureRecorder();
      final canvas=ui.Canvas(recorder);
      if(reference) {
        paintImage(canvas:canvas,rect:ui.Offset.zero&size,image:texture,
          fit:BoxFit.cover,filterQuality:FilterQuality.medium);
      } else {
        PaintedFloorCausticPainter(texture,AlwaysStoppedAnimation(seconds/24)).paint(canvas,size);
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
      final later=await frame(size,2);
      final loop=await frame(size,24);
      final scale=math.max(size.width/texture.width,size.height/texture.height);
      final floorTop=((size.height-texture.height*scale)/2+texture.height*scale*.655).floor();
      var referenceDiff=0;
      var loopDiff=0;
      var changed=0;
      for(var i=3;i<first.length;i+=4) {
        final y=(i~/4)~/size.width.toInt();
        if(y<floorTop) expect(later[i],0,reason:'No light above mapped floor, ratio=$ratio');
        referenceDiff+=(first[i]-reference[i]).abs();
        loopDiff=math.max(loopDiff,(first[i]-loop[i]).abs());
        if((first[i]-later[i]).abs()>12) changed++;
      }
      expect(referenceDiff/(first.length/4),lessThan(.6),reason:'phase 0 matches Base cover');
      expect(loopDiff,lessThanOrEqualTo(2));
      expect(changed,greaterThan(100));
    }
    texture.dispose();
  });
}
