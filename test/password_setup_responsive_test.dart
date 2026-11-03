import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/features/lock_settings/password_setup/password_setup_screen.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ShapeSpecRegistry.instance.load();
    await ShapeSpecRegistry.instance.loadRasterShapes();
  });

  Future<void> showPasswordSetup(
    WidgetTester tester, {
    required Size viewport,
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordSetupScreen(
          selectedShapes: {
            ShapeKind.circle,
            ShapeKind.triangle,
            ShapeKind.square,
          },
          selectedTones: {
            ShapeTone.pink,
            ShapeTone.blue,
          },
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('desktop confirmation keeps two slots compact and grid visible',
      (tester) async {
    await showPasswordSetup(tester, viewport: const Size(1650, 900));

    await tester.tap(find.byKey(const Key('password_token_pink_circle')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('password_token_blue_circle')));
    await tester.pump();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('같은 순서로 다시 눌러주세요.'), findsOneWidget);
    expect(find.byKey(const Key('password_pattern_slot_1')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('password_pattern_slot_0'))).width,
      lessThanOrEqualTo(76),
    );
    expect(
      tester.getSize(find.byKey(const Key('password_pattern_slot_1'))).height,
      lessThanOrEqualTo(76),
    );
    expect(
      tester.getBottomRight(find.byKey(const Key('password_token_grid'))).dy,
      lessThan(900),
    );
    expect(
      tester.getBottomRight(find.byKey(const Key('password_setup_action'))).dy,
      lessThan(900),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile layout keeps slots and controls within 320px screen',
      (tester) async {
    await showPasswordSetup(tester, viewport: const Size(320, 720));

    expect(find.byKey(const Key('password_token_grid')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('password_pattern_slot_0'))).width,
      lessThanOrEqualTo(76),
    );
    expect(
      tester.getBottomRight(find.byKey(const Key('password_setup_action'))).dy,
      lessThanOrEqualTo(720),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide viewport does not stretch initial password slots',
      (tester) async {
    await showPasswordSetup(tester, viewport: const Size(1920, 1080));

    expect(
      tester.getSize(find.byKey(const Key('password_pattern_slot_0'))).width,
      lessThanOrEqualTo(76),
    );
    expect(
      tester.getBottomRight(find.byKey(const Key('password_setup_action'))).dy,
      lessThan(1080),
    );
    expect(tester.takeException(), isNull);
  });
}
