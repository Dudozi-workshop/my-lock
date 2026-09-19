import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/customize/background/background_style.dart';
import '../lock_engine/effects.dart';
import '../lock_engine/models.dart';
import '../lock_engine/relock_policy.dart';

class MyLockStoredSettings {
  const MyLockStoredSettings({
    required this.selectedShapes,
    required this.selectedTones,
    required this.background,
    required this.movementStyle,
    required this.popStyle,
    required this.password,
    required this.selectedAppIds,
    required this.objectCount,
    required this.speed,
    required this.relockPolicy,
  });

  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final LockBackground background;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final List<LockToken>? password;
  final Set<String> selectedAppIds;
  final int objectCount;
  final FloatingSpeed speed;
  final RelockPolicy relockPolicy;
}

class MyLockSettingsStore {
  MyLockSettingsStore({
    SharedPreferencesAsync? preferences,
    FlutterSecureStorage? secureStorage,
  })  : _preferences = preferences ?? SharedPreferencesAsync(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _shapesKey = 'selected_shapes';
  static const _tonesKey = 'selected_tones';
  static const _backgroundKey = 'background';
  static const _movementKey = 'movement_style';
  static const _popKey = 'pop_style';
  static const _appsKey = 'selected_app_ids';
  static const _objectCountKey = 'object_count';
  static const _speedKey = 'floating_speed';
  static const _relockKey = 'relock_policy';
  static const _passwordKey = 'graphical_password';

  final SharedPreferencesAsync _preferences;
  final FlutterSecureStorage _secureStorage;

  Future<MyLockStoredSettings> load() async {
    final shapes = _parseEnums(
      ShapeKind.values,
      await _preferences.getStringList(_shapesKey),
    );
    final tones = _parseEnums(
      ShapeTone.values,
      await _preferences.getStringList(_tonesKey),
    );

    final passwordRaw = await _secureStorage.read(key: _passwordKey);

    return MyLockStoredSettings(
      selectedShapes: shapes.isEmpty ? ShapeKind.values.toSet() : shapes,
      selectedTones: tones.isEmpty ? ShapeTone.values.toSet() : tones,
      background: _enumOrDefault(
        LockBackground.values,
        await _preferences.getString(_backgroundKey),
        LockBackground.softGradient,
      ),
      movementStyle: _enumOrDefault(
        MovementStyle.values,
        await _preferences.getString(_movementKey),
        MovementStyle.floating,
      ),
      popStyle: _enumOrDefault(
        PopStyle.values,
        await _preferences.getString(_popKey),
        PopStyle.basicPop,
      ),
      password: _decodePassword(passwordRaw),
      selectedAppIds:
          (await _preferences.getStringList(_appsKey) ?? const <String>[])
              .toSet(),
      objectCount: _normalizeObjectCount(
        await _preferences.getInt(_objectCountKey),
      ),
      speed: _enumOrDefault(
        FloatingSpeed.values,
        await _preferences.getString(_speedKey),
        FloatingSpeed.normal,
      ),
      relockPolicy: _enumOrDefault(
        RelockPolicy.values,
        await _preferences.getString(_relockKey),
        RelockPolicy.immediate,
      ),
    );
  }

  Future<void> savePreferences(MyLockStoredSettings settings) async {
    await Future.wait([
      _preferences.setStringList(
        _shapesKey,
        settings.selectedShapes.map((value) => value.name).toList(),
      ),
      _preferences.setStringList(
        _tonesKey,
        settings.selectedTones.map((value) => value.name).toList(),
      ),
      _preferences.setString(_backgroundKey, settings.background.name),
      _preferences.setString(_movementKey, settings.movementStyle.name),
      _preferences.setString(_popKey, settings.popStyle.name),
      _preferences.setStringList(
        _appsKey,
        settings.selectedAppIds.toList(),
      ),
      _preferences.setInt(_objectCountKey, settings.objectCount),
      _preferences.setString(_speedKey, settings.speed.name),
      _preferences.setString(_relockKey, settings.relockPolicy.name),
    ]);
  }

  Future<void> savePassword(List<LockToken> password) async {
    final value = jsonEncode(password.map((token) => token.id).toList());
    await _secureStorage.write(key: _passwordKey, value: value);
  }

  List<LockToken>? _decodePassword(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      final tokens = <LockToken>[];
      for (final value in decoded) {
        if (value is! String) return null;
        final token = _tokenFromId(value);
        if (token == null) return null;
        tokens.add(token);
      }

      if (tokens.length < 3 || tokens.length > 6) return null;
      return tokens;
    } catch (_) {
      return null;
    }
  }

  LockToken? _tokenFromId(String id) {
    for (final tone in ShapeTone.values) {
      for (final shape in ShapeKind.values) {
        final token = LockToken(shape: shape, tone: tone);
        if (token.id == id) return token;
      }
    }
    return null;
  }

  Set<T> _parseEnums<T extends Enum>(
    Iterable<T> values,
    List<String>? names,
  ) {
    if (names == null) return <T>{};
    return {
      for (final value in values)
        if (names.contains(value.name)) value,
    };
  }

  T _enumOrDefault<T extends Enum>(
    Iterable<T> values,
    String? name,
    T fallback,
  ) {
    if (name == null) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  int _normalizeObjectCount(int? value) {
    return const {6, 9, 12}.contains(value) ? value! : 9;
  }
}
