import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DolphinSpriteCache extends ChangeNotifier {
  DolphinSpriteCache._();

  static final DolphinSpriteCache instance = DolphinSpriteCache._();

  final Map<String, ui.Image> _images = <String, ui.Image>{};
  Future<void>? _loadingFuture;

  bool get ready =>
      _images.containsKey('blue_body') &&
      _images.containsKey('blue_tail') &&
      _images.containsKey('pink_body') &&
      _images.containsKey('pink_tail');

  ui.Image? image(String key) => _images[key];

  void ensureLoaded() {
    ensureLoadedAsync();
  }

  Future<void> ensureLoadedAsync() {
    if (ready) return Future<void>.value();
    return _loadingFuture ??= _load();
  }

  Future<void> _load() async {
    try {
      final entries = <String, String>{
        'blue_body':
            'assets/shapes/dolphin_sprite/dolphin_blue_glossy_body.webp',
        'blue_tail':
            'assets/shapes/dolphin_sprite/dolphin_blue_glossy_tail.webp',
        'pink_body':
            'assets/shapes/dolphin_sprite/dolphin_pink_glossy_body.webp',
        'pink_tail':
            'assets/shapes/dolphin_sprite/dolphin_pink_glossy_tail.webp',
      };

      for (final entry in entries.entries) {
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
      targetWidth: 512,
      targetHeight: 512,
    );
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }
}
