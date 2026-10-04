import 'package:flutter/material.dart';
import 'package:my_lock/lock_engine/floating_preview.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/features/customize/shape_style/widgets/shape_choice_card.dart';

class CandySoftReview extends StatefulWidget {
  const CandySoftReview({super.key, this.foreground = const Color(0xFF171923)});
  final Color foreground;
  @override
  State<CandySoftReview> createState() => _CandySoftReviewState();
}

class _CandySoftReviewState extends State<CandySoftReview> {
  bool candidate = true;
  bool crayon = false;
  double size = 58;
  int count = 9;
  int respawn = 0;
  int taps = 0;
  static const shapes = [ShapeKind.circle, ShapeKind.triangle, ShapeKind.square];
  static const tones = [ShapeTone.pink, ShapeTone.blue, ShapeTone.yellow];

  Widget token(ShapeKind shape, ShapeTone tone, double dimension) => SizedBox.square(
    dimension: dimension,
    child: CustomPaint(painter: LockTokenPainter(
      LockToken(shape: shape, tone: tone),
      style: crayon ? ShapeStyle.crayonSoft : ShapeStyle.softBasic,
      candySoftCandidate: candidate,
    )),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(style: TextStyle(color: widget.foreground), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Candy Soft · 기본 3도형 최종 검수', style: TextStyle(fontSize:23,fontWeight:FontWeight.w900)),
      const SizedBox(height:6),
      const Text('선택한 캔디 볼륨과 광택을 유지한 256px 정규화본. 3도형 × 핑크·블루·옐로우를 같은 크기로 비교합니다.'),
      const SizedBox(height:8),
      const Text('QA CANDIDATE · 시각 확정 대기 · 정식 앱 미반영',style:TextStyle(fontWeight:FontWeight.w800,color:Color(0xFF7257F5))),
      const SizedBox(height:14),
      Wrap(spacing:8,runSpacing:6,children:[
        ChoiceChip(label:const Text('Candy Soft'),selected:candidate&&!crayon,onSelected:(_)=>setState((){candidate=true;crayon=false;})),
        ChoiceChip(label:const Text('기존 Vector'),selected:!candidate&&!crayon,onSelected:(_)=>setState((){candidate=false;crayon=false;})),
        ChoiceChip(label:const Text('Crayon 확정본'),selected:crayon,onSelected:(_)=>setState(()=>crayon=true)),
        for(final value in [58.0,96.0,160.0]) ChoiceChip(label:Text('${value.toInt()}px'),selected:size==value,onSelected:(_)=>setState(()=>size=value)),
      ]),
      const SizedBox(height:14),
      LayoutBuilder(builder:(context,constraints){
        final width = (constraints.maxWidth-20)/3;
        final dimension = size.clamp(0.0,width).toDouble();
        return Wrap(spacing:10,runSpacing:10,children:[
          for(final shape in shapes) SizedBox(width:width,child:Column(children:[
            Text(shape.label,style:const TextStyle(fontWeight:FontWeight.w800)),
            for(final tone in tones) Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Column(children:[
              token(shape,tone,dimension),
              Text(tone.label,style:const TextStyle(fontSize:11)),
            ])),
          ])),
        ]);
      }),
      const SizedBox(height:18),
      const Text('58px · Light / Dark',style:TextStyle(fontWeight:FontWeight.w800)),
      const SizedBox(height:8),
      Wrap(spacing:12,runSpacing:10,children:[
        for(final dark in [false,true]) Container(
          padding:const EdgeInsets.all(8),
          decoration:BoxDecoration(color:dark?const Color(0xFF101A2B):const Color(0xFFFAFAFC),borderRadius:BorderRadius.circular(14)),
          child:Row(mainAxisSize:MainAxisSize.min,children:[
            token(ShapeKind.circle,ShapeTone.pink,58),
            token(ShapeKind.triangle,ShapeTone.yellow,58),
            token(ShapeKind.square,ShapeTone.blue,58),
          ]),
        ),
      ]),
      const SizedBox(height:20),
      const Text('실제 앱 모양 선택 카드',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
      const SizedBox(height:8),
      Row(children:[for(final shape in shapes) Expanded(child:Padding(padding:const EdgeInsets.all(4),child:ShapeChoiceCard(kind:shape,label:shape.label,selected:false,onTap:(){},candySoftCandidate:candidate,style:crayon?ShapeStyle.crayonSoft:ShapeStyle.softBasic)))]),
      const SizedBox(height:20),
      const Text('실제 Floating · 회전 / POP / 재생성',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
      Wrap(spacing:8,children:[
        for(final value in [6,9,12]) ChoiceChip(label:Text('$value objects'),selected:count==value,onSelected:(_)=>setState(()=>count=value)),
        TextButton(onPressed:()=>setState(()=>respawn++),child:const Text('다시 생성')),
        Padding(padding:const EdgeInsets.all(8),child:Text('POP $taps')),
      ]),
      SizedBox(height:360,child:FloatingPreview(
        key:ValueKey(respawn),selectedShapes:shapes.toSet(),selectedTones:tones.toSet(),
        objectCount:count,style:crayon?ShapeStyle.crayonSoft:ShapeStyle.softBasic,
        candySoftCandidate:candidate,onTokenTap:(_)=>setState(()=>taps++),
      )),
      const SizedBox(height:10),
      const Text('원본 PNG와 Crayon 파라미터는 보존. 작은 크기 색 구분·광택·회전·POP 확인 후 최종 승인합니다. Android 실기기 QA는 별도 미완료.',style:TextStyle(fontSize:12)),
    ]));
  }
}
