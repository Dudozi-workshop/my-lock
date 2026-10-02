import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/shape_spec/candy_soft_candidate.dart';
import 'package:my_lock/lock_engine/shape_spec/lab_candidate_scope.dart';
import 'package:my_lock/features/customize/shape_style/widgets/shape_choice_card.dart';
import '../shape_lab/runtime_workbench.dart';
import '../shape_lab/production_flow.dart';

void main() {
  testWidgets('candidate scope follows workbench lifecycle and real cards', (tester) async {
    await tester.runAsync(() => CandySoftCandidate.instance.load());
    expect(LabCandidateScope.enabled, isFalse);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: SingleChildScrollView(child: RuntimeWorkbench(dark: false)),
    )));
    await tester.pumpAndSettle();
    expect(find.text('58px 표시 영역'), findsOneWidget);
    expect(LabCandidateScope.enabled, isTrue);
    await tester.tap(find.text('앱 카드'));
    await tester.pumpAndSettle();
    expect(find.byType(ShapeChoiceCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(LabCandidateScope.enabled, isFalse);
  });
  testWidgets('workflow opens candidate comparison without leaking renderer scope', (tester) async {
    await tester.runAsync(() => CandySoftCandidate.instance.load());
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body:
      SingleChildScrollView(child: ProductionFlow(dark: false)))));
    await tester.pumpAndSettle();
    expect(find.text('작업 목록'), findsOneWidget);
    await tester.tap(find.text('이어서 진행').first);
    await tester.pumpAndSettle();
    expect(find.text('Production 기준'), findsNWidgets(3));
    expect(find.text('후보'), findsNWidgets(3));
    expect(LabCandidateScope.enabled, isFalse);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('마감').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('후보는 정식 APK 미포함'), findsOneWidget);
    expect(find.text('정식 APK · 버전·포함 범위 확인 후 설치'), findsNothing);
  });

}
