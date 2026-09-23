import 'package:flutter/foundation.dart';

import '../features/customize/background/background_style.dart';
import '../lock_engine/effects.dart';
import '../lock_engine/models.dart';
import '../lock_engine/relock_policy.dart';
import 'my_lock_settings_store.dart';

class MyLockSettingsController extends ChangeNotifier {
  MyLockSettingsController({MyLockSettingsPersistence? store})
      : _store = store ?? MyLockSettingsStore();

  final MyLockSettingsPersistence _store;

  Set<ShapeKind> _selectedShapes = ShapeKind.values.toSet();
  Set<ShapeTone> _selectedTones = ShapeTone.values.toSet();
  LockBackground _background = LockBackground.softGradient;
  MovementStyle _movementStyle = MovementStyle.floating;
  PopStyle _popStyle = PopStyle.basicPop;
  ShapeTexture _texture = ShapeTexture.glossy;

  List<LockToken>? _password;
  String? _recoveryPin;
  Set<String> _selectedAppIds = <String>{};
  int _objectCount = 9;
  FloatingSpeed _speed = FloatingSpeed.normal;
  MovementArea _movementArea = MovementArea.lower;
  bool _onboardingStarted = false;
  bool _onboardingCompleted = false;
  bool _experimentalScreenLock = false;
  RelockPolicy _relockPolicy = RelockPolicy.immediate;

  bool _loaded = false;
  bool get loaded => _loaded;

  Set<ShapeKind> get selectedShapes => Set.unmodifiable(_selectedShapes);
  Set<ShapeTone> get selectedTones => Set.unmodifiable(_selectedTones);
  LockBackground get background => _background;
  MovementStyle get movementStyle => _movementStyle;
  PopStyle get popStyle => _popStyle;
  ShapeTexture get texture => _texture;

  List<LockToken>? get password =>
      _password == null ? null : List.unmodifiable(_password!);
  String? get recoveryPin => _recoveryPin;
  bool get recoveryPinReady => _recoveryPin != null;
  Set<String> get selectedAppIds => Set.unmodifiable(_selectedAppIds);
  int get objectCount => _objectCount;
  FloatingSpeed get speed => _speed;
  MovementArea get movementArea => _movementArea;
  bool get onboardingStarted => _onboardingStarted;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get experimentalScreenLock => _experimentalScreenLock;
  RelockPolicy get relockPolicy => _relockPolicy;

  Future<void> load() async {
    if (_loaded) return;

    final stored = await _store.load();

    _selectedShapes = Set<ShapeKind>.from(stored.selectedShapes);
    _selectedTones = Set<ShapeTone>.from(stored.selectedTones);
    _background = stored.background;
    _movementStyle = stored.movementStyle;
    _popStyle = stored.popStyle;
    _texture = stored.texture;
    _password = stored.password == null
        ? null
        : List<LockToken>.from(stored.password!);
    _recoveryPin = stored.recoveryPin;
    _selectedAppIds = Set<String>.from(stored.selectedAppIds);
    _objectCount = stored.objectCount;
    _speed = stored.speed;
    _movementArea = stored.movementArea;
    _onboardingStarted = stored.onboardingStarted;
    _onboardingCompleted = stored.onboardingCompleted;
    _experimentalScreenLock = stored.experimentalScreenLock;
    _relockPolicy = stored.relockPolicy;
    _loaded = true;
    notifyListeners();
  }

  void setShapeStyle(
    Set<ShapeKind> shapes,
    Set<ShapeTone> tones, {
    ShapeTexture? texture,
  }) {
    if (shapes.isEmpty || tones.isEmpty) return;
    if (setEquals(_selectedShapes, shapes) && setEquals(_selectedTones, tones)) {
      return;
    }
    _selectedShapes = Set<ShapeKind>.from(shapes);
    _selectedTones = Set<ShapeTone>.from(tones);
    if (texture != null) _texture = texture;
    _persistPreferences();
    notifyListeners();
  }

  void setShapeStyleAndPassword(
    Set<ShapeKind> shapes,
    Set<ShapeTone> tones,
    List<LockToken> password, {
    ShapeTexture? texture,
  }) {
    if (shapes.isEmpty || tones.isEmpty) return;
    if (password.length < 2 || password.length > 6) return;

    _selectedShapes = Set<ShapeKind>.from(shapes);
    _selectedTones = Set<ShapeTone>.from(tones);
    if (texture != null) _texture = texture;
    _password = List<LockToken>.from(password);
    _persistPreferences();
    _store.savePassword(_password!);
    notifyListeners();
  }

  void setTexture(ShapeTexture texture) {
    if (_texture == texture) return;
    _texture = texture;
    _persistPreferences();
    notifyListeners();
  }

  void setBackground(LockBackground background) {
    if (_background == background) return;
    _background = background;
    _persistPreferences();
    notifyListeners();
  }

  void setEffects(MovementStyle movementStyle, PopStyle popStyle) {
    if (_movementStyle == movementStyle && _popStyle == popStyle) return;
    _movementStyle = movementStyle;
    _popStyle = popStyle;
    _persistPreferences();
    notifyListeners();
  }

  void setPassword(List<LockToken> password) {
    if (password.length < 2 || password.length > 6) return;
    _password = List<LockToken>.from(password);
    _store.savePassword(_password!);
    notifyListeners();
  }

  void setRecoveryPin(String pin) {
    if (!RegExp(r'^\d{4}$').hasMatch(pin) || _recoveryPin == pin) return;
    _recoveryPin = pin;
    _store.saveRecoveryPin(pin);
    notifyListeners();
  }

  bool verifyRecoveryPin(String pin) =>
      _recoveryPin != null && _recoveryPin == pin;

  void setSelectedApps(Set<String> appIds) {
    if (setEquals(_selectedAppIds, appIds)) return;
    _selectedAppIds = Set<String>.from(appIds);
    _persistPreferences();
    notifyListeners();
  }

  void setScreenBehavior(
    int objectCount,
    FloatingSpeed speed,
    MovementArea movementArea,
  ) {
    if (!const {6, 9, 12}.contains(objectCount)) return;
    if (_objectCount == objectCount &&
        _speed == speed &&
        _movementArea == movementArea) {
      return;
    }
    _objectCount = objectCount;
    _speed = speed;
    _movementArea = movementArea;
    _persistPreferences();
    notifyListeners();
  }

  void startOnboarding() {
    if (_onboardingStarted) return;
    _onboardingStarted = true;
    _persistPreferences();
    notifyListeners();
  }

  void completeOnboarding() {
    if (_onboardingCompleted) return;
    _onboardingCompleted = true;
    _persistPreferences();
    notifyListeners();
  }

  void setExperimentalScreenLock(bool enabled) {
    if (_experimentalScreenLock == enabled) return;
    _experimentalScreenLock = enabled;
    _persistPreferences();
    notifyListeners();
  }

  void setRelockPolicy(RelockPolicy policy) {
    if (_relockPolicy == policy) return;
    _relockPolicy = policy;
    _persistPreferences();
    notifyListeners();
  }

  void _persistPreferences() {
    _store.savePreferences(
      MyLockStoredSettings(
        selectedShapes: _selectedShapes,
        selectedTones: _selectedTones,
        background: _background,
        movementStyle: _movementStyle,
        popStyle: _popStyle,
        texture: _texture,
        password: _password,
        recoveryPin: _recoveryPin,
        selectedAppIds: _selectedAppIds,
        objectCount: _objectCount,
        speed: _speed,
        movementArea: _movementArea,
        onboardingStarted: _onboardingStarted,
        onboardingCompleted: _onboardingCompleted,
        experimentalScreenLock: _experimentalScreenLock,
        relockPolicy: _relockPolicy,
      ),
    );
  }
}
