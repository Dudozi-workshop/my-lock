import 'package:flutter/foundation.dart';

import '../../../lock_engine/models.dart';

typedef ShapeStyleChanged = void Function(
  Set<ShapeKind> shapes,
  Set<ShapeTone> tones,
);

class ShapeStyleController extends ChangeNotifier {
  ShapeStyleController({
    required Set<ShapeKind> initialShapes,
    required Set<ShapeTone> initialTones,
    required this.onChanged,
  })  : _shapes = initialShapes.isEmpty
            ? {ShapeKind.circle}
            : Set<ShapeKind>.from(initialShapes),
        _tones = initialTones.isEmpty
            ? {ShapeTone.pink}
            : Set<ShapeTone>.from(initialTones);

  final ShapeStyleChanged onChanged;

  final Set<ShapeKind> _shapes;
  final Set<ShapeTone> _tones;

  Set<ShapeKind> get shapes => Set<ShapeKind>.unmodifiable(_shapes);
  Set<ShapeTone> get tones => Set<ShapeTone>.unmodifiable(_tones);

  void toggleShape(ShapeKind kind) {
    if (_shapes.contains(kind) && _shapes.length == 1) return;

    if (!_shapes.add(kind)) {
      _shapes.remove(kind);
    }
    _emit();
  }

  void toggleTone(ShapeTone tone) {
    if (_tones.contains(tone) && _tones.length == 1) return;

    if (!_tones.add(tone)) {
      _tones.remove(tone);
    }
    _emit();
  }

  void _emit() {
    onChanged(shapes, tones);
    notifyListeners();
  }
}
