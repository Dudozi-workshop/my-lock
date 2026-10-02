import 'package:flutter/material.dart';

class LabHomeScreen extends StatelessWidget {
  const LabHomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final groups = <(String,String,List<(String,String)>)>[
      ('Background Lab','Drop 01 · 작은 바닷속',[('Common · 투명바다 · Gate 01','?qa=background-composition')]),
      ('Shape Lab','Sea Turtle v3 · QA',[('Whole Runtime','?qa=sea-turtle-whole'),('Production Runtime','?qa=sea-turtle-production'),('App Integration','?qa=sea-turtle-app-integration'),('Swim Motion Master v1','?qa=sea-turtle-swim-v1')]),
      ('Part QA','Locked part 검증',[('Shell','?qa=sea-turtle-shell-runtime'),('Front Flipper · Near','?qa=front-flipper-outer'),('Front Flipper · Far','?qa=front-flipper-far'),('Body + Rear','?qa=sea-turtle-body-with-rear'),('Underbelly','?qa=sea-turtle-underbelly')]),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
      appBar: AppBar(title: const Text('MY LOCK Lab')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Lab Home', style: TextStyle(fontSize:26,fontWeight:FontWeight.w900)),
        const SizedBox(height:6),
        const Text('Production과 분리된 비교 · 검증 공간입니다. Candidate는 승인 전 Main에 반영하지 않습니다.'),
        const SizedBox(height:20),
        for (final group in groups) Card(child: Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(group.$1,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
          Text(group.$2,style:const TextStyle(color:Color(0xFF77717F))),
          const SizedBox(height:10),
          for(final item in group.$3) ListTile(contentPadding:EdgeInsets.zero,title:Text(item.$1,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(item.$2)),
        ]))),
      ]),
    );
  }
}
