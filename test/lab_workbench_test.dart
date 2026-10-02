import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/shape_spec/candy_soft_candidate.dart';
import 'package:my_lock/lock_engine/shape_spec/lab_candidate_scope.dart';
import 'package:my_lock/features/customize/shape_style/widgets/shape_choice_card.dart';
import '../shape_lab/runtime_workbench.dart';

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
}
