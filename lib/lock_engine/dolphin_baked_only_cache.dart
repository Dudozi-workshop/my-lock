import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models.dart';

/// Shared decoded images for the baked-only dolphin renderer.
///
/// All seven color variants use the same silhouette and are generated at build
/// time from one master image. Runtime work is only one image draw per token.
class DolphinBakedOnlyCache extends ChangeNotifier {
  DolphinBakedOnlyCache._();

  static final DolphinBakedOnlyCache instance = DolphinBakedOnlyCache._();

  final Map<ShapeTone, ui.Image> _images = <ShapeTone, ui.Image>{};
  Future<void>? _loadingFuture;

  static const Map<ShapeTone, String> _assets = <ShapeTone, String>{
    ShapeTone.pink: 'assets/shapes/dolphin_baked_v3/dolphin_pink.webp',
    ShapeTone.blue: 'assets/shapes/dolphin_baked_v3/dolphin_blue.webp',
    ShapeTone.yellow: 'assets/shapes/dolphin_baked_v3/dolphin_yellow.webp',
    ShapeTone.purple: 'assets/shapes/dolphin_baked_v3/dolphin_purple.webp',
    ShapeTone.mint: 'assets/shapes/dolphin_baked_v3/dolphin_mint.webp',
    ShapeTone.black: 'assets/shapes/dolphin_baked_v3/dolphin_black.webp',
    ShapeTone.white: 'assets/shapes/dolphin_baked_v3/dolphin_white.webp',
  };

  bool get ready => _images.length == _assets.length;

  ui.Image? image(ShapeTone tone) => _images[tone];

  void ensureLoaded() {
    ensureLoadedAsync();
  }

  Future<void> ensureLoadedAsync() {
    if (ready) return Future<void>.value();
    return _loadingFuture ??= _load();
  }

  Future<void> _load() async {
    try {
      for (final entry in _assets.entries) {
        if (_images.containsKey(entry.key)) continue;
        _images[entry.key] = await _decodeAsset(entry.value);
      }
    } finally {
      _loadingFuture = null;
      notifyListeners();
    }
  }

  Future<ui.Image> _decodeAsset(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 384,
      targetHeight: 384,
    );
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }
}
