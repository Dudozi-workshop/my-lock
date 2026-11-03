import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/features/shop/shop_screen.dart';
import 'package:my_lock/lock_engine/shape_spec/candy_soft_runtime.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ShapeSpecRegistry.instance.load();
    await ShapeSpecRegistry.instance.loadRasterShapes();
    await CandySoftRuntime.instance.load();
  });

  Future<void> pumpShop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ShopScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('Key Shard entry is visible without a fabricated balance',
      (tester) async {
    await pumpShop(tester);

    expect(find.byKey(const Key('shop_key_shard_entry')), findsOneWidget);
    expect(find.text('Key Shard'), findsOneWidget);
    expect(find.text('0 KS'), findsNothing);

    await tester.tap(find.byKey(const Key('shop_key_shard_entry')));
    await tester.pump();
    expect(find.textContaining('잔액·충전 기능'), findsOneWidget);
  });

  testWidgets('recommendations use a horizontal rail, new items use a grid',
      (tester) async {
    await pumpShop(tester);

    expect(find.byKey(const Key('shop_recommended_rail')), findsOneWidget);
    expect(find.byKey(const Key('shop_new_items_grid')), findsNothing);

    await tester.tap(find.text('신규'));
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byKey(const Key('shop_recommended_rail')), findsNothing);
    expect(find.byKey(const Key('shop_new_items_grid')), findsOneWidget);

    await tester.tap(find.text('추천'));
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.byKey(const Key('shop_recommended_rail')), findsOneWidget);
  });

  testWidgets('existing tabs and empty motion state remain intact',
      (tester) async {
    await pumpShop(tester);

    for (final tab in ['추천', '신규', '컬렉션', '한정']) {
      expect(find.text(tab), findsOneWidget);
    }
    expect(find.text('작은 바닷속'), findsOneWidget);

    await tester.tap(find.text('움직임'));
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('움직임 상품은 준비 중이에요'), findsOneWidget);
    expect(find.byKey(const Key('shop_recommended_rail')), findsNothing);
  });
}
