import 'package:flutter/foundation.dart';

import '../../../lock_engine/models.dart';

typedef ShapeStyleChanged = void Function(
  Set<ShapeKind> shapes,
  Set<ShapeTone> tones,
);

typedef ShapeStyleApplied = void Function(
  Set<ShapeKind> shapes,
  Set<ShapeTone> tones,
  ShapeStyle style,
  List<LockToken>? replacementPassword,
);

class ShapeStyleController extends ChangeNotifier {
  ShapeStyleController({
    required Set<ShapeKind> initialShapes,
    required Set<ShapeTone> initialTones,
    ShapeStyle initialStyle = ShapeStyle.softBasic,
  })  : _shapes = initialShapes.isEmpty
            ? {ShapeKind.circle}
            : Set<ShapeKind>.from(initialShapes),
        _tones = initialTones.isEmpty
            ? {ShapeTone.pink}
            : Set<ShapeTone>.from(initialTones),
        _savedShapes = initialShapes.isEmpty
            ? {ShapeKind.circle}
            : Set<ShapeKind>.from(initialShapes),
        _savedTones = initialTones.isEmpty
            ? {ShapeTone.pink}
            : Set<ShapeTone>.from(initialTones),
        _style = initialStyle,
        _savedStyle = initialStyle;

  final Set<ShapeKind> _shapes;
  final Set<ShapeTone> _tones;
  Set<ShapeKind> _savedShapes;
  Set<ShapeTone> _savedTones;
  ShapeStyle _style;
  ShapeStyle _savedStyle;

  Set<ShapeKind> get shapes => Set<ShapeKind>.unmodifiable(_shapes);
  Set<ShapeTone> get tones => Set<ShapeTone>.unmodifiable(_tones);
  ShapeStyle get style => _style;

  bool get hasChanges =>
      !setEquals(_shapes, _savedShapes) ||
      !setEquals(_tones, _savedTones) ||
      _style != _savedStyle;

  void toggleShape(ShapeKind kind) {
    if (_shapes.contains(kind) && _shapes.length == 1) return;

    if (!_shapes.add(kind)) {
      _shapes.remove(kind);
    }
    notifyListeners();
  }

  void toggleTone(ShapeTone tone) {
    if (_tones.contains(tone) && _tones.length == 1) return;

    if (!_tones.add(tone)) {
      _tones.remove(tone);
    }
    notifyListeners();
  }

  void selectStyle(ShapeStyle style) {
    if (_style == style) return;
    _style = style;
    notifyListeners();
  }

  void markApplied() {
    _savedShapes = Set<ShapeKind>.from(_shapes);
    _savedTones = Set<ShapeTone>.from(_tones);
    _savedStyle = _style;
    notifyListeners();
  }
}
