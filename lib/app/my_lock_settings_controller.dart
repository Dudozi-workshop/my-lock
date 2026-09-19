import 'package:flutter/foundation.dart';

import '../features/customize/background/background_style.dart';
import '../lock_engine/effects.dart';
import '../lock_engine/models.dart';
import '../lock_engine/relock_policy.dart';

class MyLockSettingsController extends ChangeNotifier {
  Set<ShapeKind> _selectedShapes = ShapeKind.values.toSet();
  Set<ShapeTone> _selectedTones = ShapeTone.values.toSet();
  LockBackground _background = LockBackground.softGradient;
  MovementStyle _movementStyle = MovementStyle.floating;
  PopStyle _popStyle = PopStyle.basicPop;

  List<LockToken>? _password;
  Set<String> _selectedAppIds = <String>{};
  int _objectCount = 9;
  FloatingSpeed _speed = FloatingSpeed.normal;
  RelockPolicy _relockPolicy = RelockPolicy.immediate;

  Set<ShapeKind> get selectedShapes => Set.unmodifiable(_selectedShapes);
  Set<ShapeTone> get selectedTones => Set.unmodifiable(_selectedTones);
  LockBackground get background => _background;
  MovementStyle get movementStyle => _movementStyle;
  PopStyle get popStyle => _popStyle;

  List<LockToken>? get password =>
      _password == null ? null : List.unmodifiable(_password!);
  Set<String> get selectedAppIds => Set.unmodifiable(_selectedAppIds);
  int get objectCount => _objectCount;
  FloatingSpeed get speed => _speed;
  RelockPolicy get relockPolicy => _relockPolicy;

  void setShapeStyle(Set<ShapeKind> shapes, Set<ShapeTone> tones) {
    if (shapes.isEmpty || tones.isEmpty) return;
    if (setEquals(_selectedShapes, shapes) && setEquals(_selectedTones, tones)) {
      return;
    }
    _selectedShapes = Set<ShapeKind>.from(shapes);
    _selectedTones = Set<ShapeTone>.from(tones);
    notifyListeners();
  }

  void setBackground(LockBackground background) {
    if (_background == background) return;
    _background = background;
    notifyListeners();
  }

  void setEffects(MovementStyle movementStyle, PopStyle popStyle) {
    if (_movementStyle == movementStyle && _popStyle == popStyle) return;
    _movementStyle = movementStyle;
    _popStyle = popStyle;
    notifyListeners();
  }

  void setPassword(List<LockToken> password) {
    if (password.length < 3 || password.length > 6) return;
    _password = List<LockToken>.from(password);
    notifyListeners();
  }

  void setSelectedApps(Set<String> appIds) {
    if (setEquals(_selectedAppIds, appIds)) return;
    _selectedAppIds = Set<String>.from(appIds);
    notifyListeners();
  }

  void setScreenBehavior(int objectCount, FloatingSpeed speed) {
    if (!const {6, 9, 12}.contains(objectCount)) return;
    if (_objectCount == objectCount && _speed == speed) return;
    _objectCount = objectCount;
    _speed = speed;
    notifyListeners();
  }

  void setRelockPolicy(RelockPolicy policy) {
    if (_relockPolicy == policy) return;
    _relockPolicy = policy;
    notifyListeners();
  }
}
