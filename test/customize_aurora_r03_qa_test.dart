import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/app/theme.dart';
import 'package:my_lock/features/customize/background/background_style.dart';
import 'package:my_lock/features/customize/shape_style/shape_style_screen.dart';
import 'package:my_lock/features/customize/shape_style/tabs/color_tab.dart';
import 'package:my_lock/features/customize/shape_style/widgets/color_choice_card.dart';
import 'package:my_lock/lock_engine/effects.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_spec/candy_soft_runtime.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ShapeSpecRegistry.instance.load();
    await ShapeSpecRegistry.instance.loadRasterShapes();
    await CandySoftRuntime.instance.load();
  });

  void setViewport(WidgetTester tester, double width) {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('R03 Signature swatch advances an explicit H02B palette time',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMyLockTheme(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: ColorChoiceCard(
                tone: ShapeTone.auroraSea,
                label: ShapeTone.auroraSea.label,
                selected: false,
                onTap: () {},
                wide: true,
              ),
            ),
          ),
        ),
      ),
    );

    final livePaint = find.byWidgetPredicate((widget) =>
        widget is CustomPaint &&
        widget.painter is LockTokenPainter &&
        (widget.painter! as LockTokenPainter).token.tone ==
            ShapeTone.auroraSea);

    expect(livePaint, findsOneWidget);
    final first = tester.widget<CustomPaint>(livePaint).painter!
        as LockTokenPainter;
    expect(first.token.shape, ShapeKind.circle);
    expect(first.paletteTimeSeconds, isNotNull);

    // The first ticker frame establishes the elapsed-time baseline.
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 200));
    final second = tester.widget<CustomPaint>(livePaint).painter!
        as LockTokenPainter;
    expect(second.paletteTimeSeconds, greaterThan(first.paletteTimeSeconds!));
    expect(tester.takeException(), isNull);
  });

  for (final width in <double>[320, 360, 390, 720]) {
    testWidgets('Color catalog fits ${width.toInt()}px without overflow',
        (tester) async {
      setViewport(tester, width);
      final scale = width == 320 ? 1.4 : 1.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMyLockTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 844),
              textScaler: TextScaler.linear(scale),
            ),
            child: Scaffold(
              body: ColorTab(
                selectedTones: const {ShapeTone.pink, ShapeTone.auroraSea},
                onToggle: (_) {},
                onMinimumSelectionBlocked: () {},
              ),
            ),
          ),
        ),
      );
      // Avoid pumpAndSettle: the approved H02B swatch intentionally ticks.
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byType(ListView),
        const Offset(0, -600),
      );
      await tester.pump(const Duration(milliseconds: 160));
      expect(tester.takeException(), isNull);
      expect(find.byType(ColorChoiceCard), findsWidgets);
      expect(find.text(ShapeTone.auroraSea.label), findsOneWidget);
    });
  }

  testWidgets('Customize shape/color screen retains preview, tabs and save at 320px',
      (tester) async {
    setViewport(tester, 320);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMyLockTheme(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 844),
            textScaler: TextScaler.linear(1.3),
          ),
          child: ShapeStyleScreen(
            selectedShapes: const {ShapeKind.circle, ShapeKind.seaTurtle},
            selectedTones: const {ShapeTone.pink, ShapeTone.auroraSea},
            currentPassword: null,
            style: ShapeStyle.softBasic,
            background: LockBackground.softGradient,
            movementStyle: MovementStyle.floating,
            popStyle: PopStyle.basicPop,
            objectCount: 6,
            speed: FloatingSpeed.normal,
            movementArea: MovementArea.lower,
            onApply: (shapes, tones, style, password) {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('모양 & 색상'), findsOneWidget);
    expect(find.text('모양'), findsOneWidget);
    expect(find.text('색상'), findsOneWidget);
    expect(find.text('저장'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('색상').first);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('전체 색상'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
