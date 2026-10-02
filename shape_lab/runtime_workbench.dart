import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/floating_preview.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_spec/lab_candidate_scope.dart';
import 'package:my_lock/features/customize/shape_style/widgets/shape_choice_card.dart';

class RuntimeWorkbench extends StatefulWidget {
  const RuntimeWorkbench({super.key, required this.dark});
  final bool dark;
  @override
  State<RuntimeWorkbench> createState() => _RuntimeWorkbenchState();
}

class _RuntimeWorkbenchState extends State<RuntimeWorkbench> {
  late final Future<List<Map<String, dynamic>>> registry = _load();
  String? experiment;
  String view = 'sizes';
  int count = 6;
  int variant = 0;

  @override
  void initState() {
    super.initState();
    experiment = Uri.base.queryParameters['experiment'];
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final json = jsonDecode(await rootBundle.loadString('assets/lab/experiments.json')) as Map<String,dynamic>;
    if (json['schema_version'] != 1) throw const FormatException('지원하지 않는 검수 설정 버전');
    final items = (json['experiments'] as List).cast<Map<String, dynamic>>();
    final ids = <String>{};
    for (final item in items) {
      if (!ids.add(item['id'] as String) ||
          !{'production', 'candy-soft'}.contains(item['profile']) ||
          (item['source_commit'] as String).length != 40 ||
          (item['variants'] as List).isEmpty ||
          (item['sizes'] as List).isEmpty ||
          (item['object_counts'] as List).isEmpty) {
        throw const FormatException('검수 설정의 ID / 프로필 / Source / 표시 옵션을 확인하세요');
      }
      for (final pair in item['variants'] as List) {
        ShapeKind.values.byName(pair['shape'] as String);
        ShapeTone.values.byName(pair['tone'] as String);
      }
      for (final size in item['sizes'] as List) {
        if (size is! num || size <= 0) throw const FormatException('표시 크기는 양수여야 합니다');
      }
      for (final number in item['object_counts'] as List) {
        if (number is! int || number < 1 || number > 12) throw const FormatException('개수는 1~12 정수여야 합니다');
      }
    }
    if (items.isEmpty) throw const FormatException('등록된 검수 항목이 없습니다');
    return items;
  }

  @override
  void dispose() {
    LabCandidateScope.enabled = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: registry,
    builder: (context, snapshot) {
      if (snapshot.hasError) return Text('검수 설정 로드 실패: ${snapshot.error}');
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final items = snapshot.data!;
      final selected = items.firstWhere((e) => e['id'] == experiment, orElse: () => items.first);
      LabCandidateScope.enabled = selected['profile'] == 'candy-soft';
      final pairs = (selected['variants'] as List).map((p) => LockToken(
        shape: ShapeKind.values.byName(p['shape'] as String),
        tone: ShapeTone.values.byName(p['tone'] as String),
      )).toList();
      final token = pairs[variant.clamp(0, pairs.length-1)];
      final fg = widget.dark ? Colors.white : const Color(0xff171923);
      final bg = widget.dark ? const Color(0xff171929) : const Color(0xfffaf9ff);
      return Container(key: ValueKey(selected['id']), padding: const EdgeInsets.all(16), color: bg,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('공통 Runtime 검수', style: TextStyle(color:fg,fontSize:20,fontWeight:FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButton<String>(value:selected['id'] as String,
            dropdownColor:bg, style:TextStyle(color:fg),
            items:[for(final item in items) DropdownMenuItem(value:item['id'] as String,
              child:Text('${item['title']} · ${item['status']}'))],
            onChanged:(id){setState((){experiment=id;variant=0;});
              SystemNavigator.routeInformationUpdated(uri:Uri.base.replace(queryParameters:{
                ...Uri.base.queryParameters, 'lab':'review', 'experiment':id!}), replace:true);}),
          Text('Source ${(selected['source_commit'] as String).substring(0,7)} · 실제 앱 Painter',style:TextStyle(color:fg)),
          Text('남은 사항: ${selected['pending']}',style:TextStyle(color:fg)),
          const SizedBox(height:12),
          Wrap(spacing:8, children:[for(final item in {'sizes':'크기 비교','cards':'앱 카드','motion':'Floating / POP'}.entries)
            ChoiceChip(label:Text(item.value),selected:view==item.key,
              onSelected:(_)=>setState(()=>view=item.key))]),
          const SizedBox(height:16),
          if(view=='sizes') for(final size in (selected['sizes'] as List).cast<num>()) ...[
            Text('${size}px 표시 영역',style:TextStyle(color:fg)),
            Wrap(spacing:12,runSpacing:8,children:[for(final pair in pairs)
              CustomPaint(size:Size.square(size.toDouble()),painter:LockTokenPainter(pair))]),
            const SizedBox(height:16),
          ],
          if(view=='cards') Wrap(spacing:8,runSpacing:8,children:[for(final pair in pairs)
            SizedBox(width:120,height:140,child:ShapeChoiceCard(kind:pair.shape,
              previewTone:pair.tone,label:pair.shape.label,selected:true,onTap:(){}))]),
          if(view=='motion') ...[
            Wrap(spacing:8,children:[for(var i=0;i<pairs.length;i++) ChoiceChip(
              label:Text('${pairs[i].shape.label} · ${pairs[i].tone.label}'),selected:variant==i,
              onSelected:(_)=>setState(()=>variant=i))]),
            Wrap(spacing:8,children:[for(final n in (selected['object_counts'] as List).cast<int>())
              ChoiceChip(label:Text('$n개'),selected:count==n,onSelected:(_)=>setState(()=>count=n))]),
            const SizedBox(height:8),
            Text('도형을 누르면 POP 후 다시 생성됩니다. 상단 Dark 스위치로 배경을 바꿉니다.',style:TextStyle(color:fg)),
            SizedBox(height:420,child:FloatingPreview(key:ValueKey('${token.id}-$count'),
              selectedShapes:{token.shape},selectedTones:{token.tone},objectCount:count)),
          ],
        ]));
    });
}
