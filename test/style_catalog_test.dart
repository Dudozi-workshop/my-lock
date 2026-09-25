import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/app/my_lock_settings_controller.dart';
import 'package:my_lock/app/my_lock_settings_store.dart';
import 'package:my_lock/features/customize/background/background_style.dart';
import 'package:my_lock/lock_engine/effects.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/relock_policy.dart';

void main() {
  test('Soft Basic starts with the free 3x3 token catalog', () {
    expect(
      ShapeKind.values,
      equals([
        ShapeKind.circle,
        ShapeKind.triangle,
        ShapeKind.square,
      ]),
    );
    expect(
      ShapeTone.values,
      equals([
        ShapeTone.pink,
        ShapeTone.blue,
        ShapeTone.yellow,
      ]),
    );
    expect(
      ShapeStyle.values,
      equals([ShapeStyle.softBasic, ShapeStyle.crayonSoft]),
    );

    final ids = <String>{
      for (final shape in ShapeKind.values)
        for (final tone in ShapeTone.values)
          LockToken(shape: shape, tone: tone).id,
    };
    expect(ids.length, 9);
  });

  test('Soft Basic style is persisted with the new shape_style key model', () async {
    final store = _FakeStore();
    final controller = MyLockSettingsController(store: store);
    await controller.load();

    controller.setShapeStyle(
      controller.selectedShapes,
      controller.selectedTones,
      style: ShapeStyle.softBasic,
    );

    expect(controller.style, ShapeStyle.softBasic);
  });
}

class _FakeStore implements MyLockSettingsPersistence {
  MyLockStoredSettings? lastSaved;
  List<LockToken>? savedPassword;

  @override
  Future<MyLockStoredSettings> load() async {
    return const MyLockStoredSettings(
      selectedShapes: {
        ShapeKind.circle,
        ShapeKind.triangle,
        ShapeKind.square,
      },
      selectedTones: {
        ShapeTone.pink,
        ShapeTone.blue,
        ShapeTone.yellow,
      },
      background: LockBackground.softGradient,
      movementStyle: MovementStyle.floating,
      popStyle: PopStyle.basicPop,
      style: ShapeStyle.softBasic,
      password: null,
      selectedAppIds: <String>{},
      objectCount: 9,
      speed: FloatingSpeed.normal,
      movementArea: MovementArea.lower,
      relockPolicy: RelockPolicy.immediate,
    );
  }

  @override
  Future<void> savePreferences(MyLockStoredSettings settings) async {
    lastSaved = settings;
  }

  @override
  Future<void> savePassword(List<LockToken> password) async {
    savedPassword = List<LockToken>.from(password);
  }

  @override
  Future<void> saveRecoveryPin(String pin) async {}
}
