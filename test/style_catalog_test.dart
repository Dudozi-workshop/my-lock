import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/app/my_lock_settings_controller.dart';
import 'package:my_lock/app/my_lock_settings_store.dart';
import 'package:my_lock/features/customize/background/background_style.dart';
import 'package:my_lock/lock_engine/effects.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/relock_policy.dart';

void main() {
  test('default style catalog remains the original 3x3 token set', () {
    expect(
      ShapeKind.defaults,
      equals({
        ShapeKind.circle,
        ShapeKind.triangle,
        ShapeKind.square,
      }),
    );
    expect(
      ShapeTone.defaults,
      equals({
        ShapeTone.pink,
        ShapeTone.blue,
        ShapeTone.yellow,
      }),
    );

    final ids = <String>{
      for (final shape in ShapeKind.values)
        for (final tone in ShapeTone.values)
          LockToken(shape: shape, tone: tone).id,
    };
    expect(ids.length, ShapeKind.values.length * ShapeTone.values.length);
  });

  test('premium catalog metadata is separate from free defaults', () {
    expect(ShapeKind.defaults.every((item) => !item.premium), isTrue);
    expect(ShapeTone.defaults.every((item) => !item.premium), isTrue);
    expect(ShapeTexture.glossy.premium, isFalse);
    expect(ShapeKind.dolphin.premium, isTrue);
    expect(
      ShapeTexture.values.where((item) => item.premium).length,
      greaterThan(0),
    );
  });

  test('texture-only style change is persisted', () async {
    final store = _FakeStore();
    final controller = MyLockSettingsController(store: store);
    await controller.load();

    controller.setShapeStyle(
      controller.selectedShapes,
      controller.selectedTones,
      texture: ShapeTexture.hologram,
    );

    expect(controller.texture, ShapeTexture.hologram);
    expect(store.lastSaved?.texture, ShapeTexture.hologram);
  });

  test('expanded shape and tone can be applied as real lock tokens', () async {
    final store = _FakeStore();
    final controller = MyLockSettingsController(store: store);
    await controller.load();

    const password = [
      LockToken(shape: ShapeKind.star, tone: ShapeTone.purple),
      LockToken(shape: ShapeKind.heart, tone: ShapeTone.mint),
    ];

    controller.setShapeStyleAndPassword(
      {ShapeKind.star, ShapeKind.heart},
      {ShapeTone.purple, ShapeTone.mint},
      password,
      texture: ShapeTexture.glass,
    );

    expect(controller.selectedShapes, contains(ShapeKind.star));
    expect(controller.selectedTones, contains(ShapeTone.mint));
    expect(controller.texture, ShapeTexture.glass);
    expect(controller.password, password);
    expect(store.savedPassword, password);
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
