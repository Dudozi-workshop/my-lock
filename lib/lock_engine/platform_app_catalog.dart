import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformAppInfo {
  const PlatformAppInfo({
    required this.id,
    required this.name,
    this.iconBytes,
  });

  final String id;
  final String name;
  final Uint8List? iconBytes;
}

class PlatformAppCatalog {
  PlatformAppCatalog({
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel('com.mylock.app/lock');

  final MethodChannel _channel;

  Future<List<PlatformAppInfo>> loadLaunchableApps() async {
    if (kIsWeb) return const <PlatformAppInfo>[];

    try {
      final result = await _channel.invokeListMethod<Object?>(
        'getLaunchableApps',
      );

      if (result == null) return const <PlatformAppInfo>[];

      final apps = <PlatformAppInfo>[];
      for (final item in result) {
        if (item is! Map) continue;

        final id = item['id'];
        final name = item['name'];
        if (id is! String || id.isEmpty || name is! String || name.isEmpty) {
          continue;
        }

        Uint8List? iconBytes;
        final iconBase64 = item['iconBase64'];
        if (iconBase64 is String && iconBase64.isNotEmpty) {
          try {
            iconBytes = base64Decode(iconBase64);
          } on FormatException {
            iconBytes = null;
          }
        }

        apps.add(
          PlatformAppInfo(
            id: id,
            name: name,
            iconBytes: iconBytes,
          ),
        );
      }

      return apps;
    } on MissingPluginException {
      return const <PlatformAppInfo>[];
    } on PlatformException {
      return const <PlatformAppInfo>[];
    }
  }
}
