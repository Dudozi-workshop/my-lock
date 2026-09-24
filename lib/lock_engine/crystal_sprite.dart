import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Optional pre-rendered Crystal pilot. Other shapes and tones keep their
/// canvas renderer until matching assets are approved.
class CrystalSprite {
  CrystalSprite._();

  static ui.Image? blueCircle;
  static Future<void>? _loading;

  static Future<void> load() => _loading ??= _load();

  static Future<void> _load() async {
    final data = await rootBundle.load('assets/materials/crystal_blue_circle.webp');
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    try {
      blueCircle = (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }
}
