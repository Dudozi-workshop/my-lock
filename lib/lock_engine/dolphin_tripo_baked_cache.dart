import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'dolphin_tripo_baked_data.dart';

class DolphinTripoBakedCache extends ChangeNotifier {
  DolphinTripoBakedCache._();

  static final DolphinTripoBakedCache instance = DolphinTripoBakedCache._();

  ui.Image? _image;
  Future<void>? _loadingFuture;

  bool get ready => _image != null;
  ui.Image? get image => _image;

  void ensureLoaded() {
    ensureLoadedAsync();
  }

  Future<void> ensureLoadedAsync() {
    if (ready) return Future<void>.value();
    return _loadingFuture ??= _load();
  }

  Future<void> _load() async {
    try {
      final bytes = base64Decode(kDolphinTripoBakedWebpBase64);
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 384,
        targetHeight: 384,
      );
      final frame = await codec.getNextFrame();
      _image = frame.image;
      codec.dispose();
    } finally {
      _loadingFuture = null;
      notifyListeners();
    }
  }
}
