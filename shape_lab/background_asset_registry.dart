import 'dart:convert';

import 'package:flutter/services.dart';

class BackgroundAssetRecord {
  const BackgroundAssetRecord({
    required this.assetId,
    required this.slot,
    required this.nameKo,
    required this.lifecycle,
    required this.activeForLab,
    required this.runtimePath,
  });

  final String assetId;
  final String slot;
  final String nameKo;
  final String lifecycle;
  final bool activeForLab;
  final String? runtimePath;
}

class BackgroundAssetRegistry {
  BackgroundAssetRegistry._(this._records);

  final Map<String, BackgroundAssetRecord> _records;

  static BackgroundAssetRegistry? _instance;

  static BackgroundAssetRegistry get instance {
    final value = _instance;
    if (value == null) {
      throw StateError('BackgroundAssetRegistry.load() must run first.');
    }
    return value;
  }

  static Future<BackgroundAssetRegistry> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString(
      'assets/backgrounds/drop01/ASSET_REGISTRY.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final records = <String, BackgroundAssetRecord>{};
    final groups = <List<dynamic>>[
      (json['active_backgrounds'] as List<dynamic>? ?? const []),
      (json['lab_assets'] as List<dynamic>? ?? const []),
    ];

    for (final entry in groups.expand((items) => items).cast<Map<String, dynamic>>()) {
      final runtime = entry['runtime_ref'] as Map<String, dynamic>?;
      final record = BackgroundAssetRecord(
        assetId: entry['asset_id'] as String,
        slot: entry['slot'] as String,
        nameKo: entry['name_ko'] as String,
        lifecycle: entry['lifecycle'] as String,
        activeForLab: entry['active_for_lab'] as bool,
        runtimePath: runtime?['path'] as String?,
      );
      records[record.assetId] = record;
    }

    return _instance = BackgroundAssetRegistry._(records);
  }

  BackgroundAssetRecord resolve(String assetId) {
    final record = _records[assetId];
    if (record == null) {
      throw StateError('Unknown background asset id: $assetId');
    }
    if (record.runtimePath == null) {
      throw StateError('Background asset has no runtime reference: $assetId');
    }
    return record;
  }
}
