import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_spec/lab_candidate_scope.dart';
import 'package:url_launcher/url_launcher.dart';
import 'runtime_workbench.dart';

/// Workflow metadata is an evidence index, never an automatic approval gate.
class ProductionFlow extends StatefulWidget {
  const ProductionFlow({super.key, required this.dark});
  final bool dark;
  @override
  State<ProductionFlow> createState() => _ProductionFlowState();
}

class _ProductionFlowState extends State<ProductionFlow> {
  late final Future<Map<String, dynamic>> data = _load();
  String? id = Uri.base.queryParameters['experiment'];
  String stage = Uri.base.queryParameters['stage'] ?? 'compare';
  String group = 'active';
  double size = 72;
  static const stages = {'make':'제작', 'compare':'비교', 'qa':'검수', 'close':'마감'};
  Future<Map<String, dynamic>> _load() async {
    final experiments = jsonDecode(await rootBundle.loadString('assets/lab/experiments.json')) as Map<String, dynamic>;
    final workflow = jsonDecode(await rootBundle.loadString('assets/lab/workflow.json')) as Map<String, dynamic>;
    return {'experiments':experiments['experiments'], 'tasks':workflow['tasks']};
  }
  void _open(String? next, [String? step]) {
    setState(() { id = next; stage = step ?? 'compare'; });
    final query = {...Uri.base.queryParameters, 'lab':'home'};
    query.remove('experiment'); query.remove('stage');
    if (next != null) { query['experiment'] = next; query['stage'] = stage; }
    SystemNavigator.routeInformationUpdated(uri:Uri.base.replace(queryParameters:query), replace:true);
  }
  Widget _link(String label, String url) => TextButton.icon(
    onPressed:()=>launchUrl(Uri.parse(url), webOnlyWindowName:'_blank'),
    icon:const Icon(Icons.open_in_new, size:16), label:Text(label));
  @override
  Widget build(BuildContext context) {
    final fg = widget.dark ? Colors.white : const Color(0xff171923);
    return DefaultTextStyle(style:TextStyle(color:fg, fontSize:14), child:FutureBuilder<Map<String,dynamic>>(
      future:data, builder:(context,snapshot) {
        if(snapshot.hasError) return Text('작업 목록 로드 실패: ${snapshot.error}');
        if(!snapshot.hasData) return const Center(child:CircularProgressIndicator());
        final items = (snapshot.data!['experiments'] as List).cast<Map<String,dynamic>>();
        final tasks = (snapshot.data!['tasks'] as List).cast<Map<String,dynamic>>();
        final matches = tasks.where((t)=>t['id']==id);
        if(id == null || matches.isEmpty) return Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          const Text('작업 목록',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
          const SizedBox(height:8),
          const Text('같은 랩에서 제작부터 검수·마감까지 이어갑니다.'),
          if(id != null) const Text('등록되지 않은 작업입니다. 목록에서 선택하세요.'),
          const SizedBox(height:12),
          Wrap(spacing:8,children:[for(final g in {'active':'진행 중','baseline':'현재 기준','archive':'종료 기록'}.entries)
            ChoiceChip(label:Text(g.value),selected:group==g.key,onSelected:(_)=>setState(()=>group=g.key))]),
          const SizedBox(height:12),
          if(!tasks.any((t)=>t['group']==group)) const Padding(padding:EdgeInsets.all(24),child:Text('등록된 기록이 없습니다.')),
          for(final task in tasks.where((t)=>t['group']==group)) Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(items.firstWhere((e)=>e['id']==task['id'])['title'] as String, style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            Text('현재 단계: ${task['current_label']}'),
            Text('다음 행동: ${task['next_action']}'),
            const SizedBox(height:8),
            FilledButton(onPressed:()=>_open(task['id'] as String, task['stage'] as String),child:const Text('이어서 진행')),
          ]))),
          _link('Main · 반영된 앱 확인','https://my-lock-preview.rlatkd5959.workers.dev/'),
        ]);
        final task = matches.first;
        final experiment = items.firstWhere((e)=>e['id']==id);
        final pairs = (experiment['variants'] as List).map((p)=>LockToken(shape:ShapeKind.values.byName(p['shape'] as String),tone:ShapeTone.values.byName(p['tone'] as String))).toList();
        return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          TextButton.icon(onPressed:()=>_open(null),icon:const Icon(Icons.arrow_back),label:const Text('작업 목록')),
          Text(experiment['title'] as String,style:const TextStyle(fontSize:23,fontWeight:FontWeight.bold)),
          Text('Source 승인: ${experiment['status']} · 검수: ${task['qa_status']}'),
          Text('다음 행동: ${task['next_action']}'),
          const SizedBox(height:12),
          Wrap(spacing:8,children:[for(final s in stages.entries) ChoiceChip(label:Text(s.value),selected:stage==s.key,onSelected:(_)=>_open(id,s.key))]),
          const SizedBox(height:16),
          if(stage=='make') ...[
            Text(task['goal'] as String),
            const SizedBox(height:12),
            Text('변경 범위: ${task['scope']}'),
            Text('지원 조합: ${pairs.map((p)=>'${p.shape.label} ${p.tone.label}').join(' / ')}'),
            const Text('후보 조절은 기존 제작 도구를 재사용합니다. 미지원 색은 후보 적용 결과로 인정하지 않습니다.'),
            _link('후보 Source 확인',task['source_url'] as String),
          ],
          if(stage=='compare') ...[
            const Text('같은 크기·색·배경으로 비교합니다. Dark는 상단에서 전환하세요.'),
            Wrap(spacing:8,children:[for(final n in [58.0,72.0,96.0,160.0]) ChoiceChip(label:Text('${n.toInt()}px'),selected:size==n,onSelected:(_)=>setState(()=>size=n))]),
            const SizedBox(height:12),
            for(final pair in pairs) Padding(padding:const EdgeInsets.only(bottom:16),child:Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[
              for(final candidate in [false,true]) Column(children:[
                Text(candidate ? (experiment['profile']=='candy-soft' ? '후보':'현재 승인본') : 'Production 기준'),
                const SizedBox(height:8),
                CustomPaint(size:Size.square(size),painter:_ComparisonPainter(pair,candidate && experiment['profile']=='candy-soft')),
                Text('${pair.shape.label} · ${pair.tone.label}'),
              ]),
            ])),
            const Text('방향 선택과 최종 승인은 구분합니다. 선택 결과는 후보 ID·Source와 함께 기록합니다.'),
          ],
          if(stage=='qa') ...[
            const Text('필수 검수 · 결과는 검수한 Source와 증거에 연결합니다.',style:TextStyle(fontWeight:FontWeight.bold)),
            for(final check in (task['checks'] as List).cast<Map<String,dynamic>>()) ListTile(contentPadding:EdgeInsets.zero,
              leading:const Icon(Icons.pending_outlined),title:Text(check['label'] as String),subtitle:Text(check['result'] as String)),
            RuntimeWorkbench(key:ValueKey(id),dark:widget.dark,experimentId:id,showDownload:false),
          ],
          if(stage=='close') ...[
            Text('선택·승인 기록: ${task['approval']}'),
            Text('Main 반영: ${task['integration']}'),
            Text('Android: ${task['android']}'),
            const SizedBox(height:8),
            const Text('승인본 = Main 반영본 = 배포본을 확인한 뒤 마감합니다. 미확인 실기기 검수는 남겨둡니다.'),
            _link('Source / 마감 근거',task['source_url'] as String),
            _link('Main 확인','https://my-lock-preview.rlatkd5959.workers.dev/'),
            if(task['apk_url'] != null) _link('정식 APK · 버전·포함 범위 확인 후 설치',task['apk_url'] as String),
          ],
        ]);
      }));
  }
}

/// Shared production painter; scope restored synchronously after every paint.
class _ComparisonPainter extends CustomPainter {
  _ComparisonPainter(this.token,this.candidate);
  final LockToken token;
  final bool candidate;
  @override
  void paint(Canvas canvas, Size size) {
    final previous = LabCandidateScope.enabled;
    try { LabCandidateScope.enabled = candidate; LockTokenPainter(token).paint(canvas,size); }
    finally { LabCandidateScope.enabled = previous; }
  }
  @override
  bool shouldRepaint(covariant _ComparisonPainter old) => old.token!=token || old.candidate!=candidate;
}
