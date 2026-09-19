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
    this.recoveryPin,
    required this.selectedAppIds,
    required this.objectCount,
    required this.speed,
    this.movementArea = MovementArea.full,
    this.onboardingStarted = false,
    this.onboardingCompleted = false,
    this.experimentalScreenLock = false,
    this.experimentalOverlayLock = false,
    required this.relockPolicy,
  });

  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final LockBackground background;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final List<LockToken>? password;
  final String? recoveryPin;
  final Set<String> selectedAppIds;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final bool onboardingStarted;
  final bool onboardingCompleted;
  final bool experimentalScreenLock;
  final bool experimentalOverlayLock;
  final RelockPolicy relockPolicy;
}

abstract class MyLockSettingsPersistence {
  Future<MyLockStoredSettings> load();

  Future<void> savePreferences(MyLockStoredSettings settings);

  Future<void> savePassword(List<LockToken> password);

  Future<void> saveRecoveryPin(String pin) async {}
}

class MyLockSettingsStore implements MyLockSettingsPersistence {
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
  static const _movementAreaKey = 'movement_area';
  static const _onboardingStartedKey = 'onboarding_started';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _experimentalScreenLockKey = 'experimental_screen_lock';
  static const _experimentalOverlayLockKey = 'experimental_overlay_lock';
  static const _relockKey = 'relock_policy';
  static const _passwordKey = 'graphical_password';
  static const _recoveryPinKey = 'recovery_pin';

  final SharedPreferencesAsync _preferences;
  final FlutterSecureStorage _secureStorage;

  @override
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
    final recoveryPinRaw = await _secureStorage.read(key: _recoveryPinKey);

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
      recoveryPin: _normalizeRecoveryPin(recoveryPinRaw),
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
      movementArea: _enumOrDefault(
        MovementArea.values,
        await _preferences.getString(_movementAreaKey),
        MovementArea.full,
      ),
      onboardingStarted:
          await _preferences.getBool(_onboardingStartedKey) ?? false,
      onboardingCompleted:
          await _preferences.getBool(_onboardingCompletedKey) ?? false,
      experimentalScreenLock:
          await _preferences.getBool(_experimentalScreenLockKey) ?? false,
      experimentalOverlayLock:
          await _preferences.getBool(_experimentalOverlayLockKey) ?? false,
      relockPolicy: _enumOrDefault(
        RelockPolicy.values,
        await _preferences.getString(_relockKey),
        RelockPolicy.immediate,
      ),
    );
  }

  @override
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
      _preferences.setString(_movementAreaKey, settings.movementArea.name),
      _preferences.setBool(
        _onboardingStartedKey,
        settings.onboardingStarted,
      ),
      _preferences.setBool(
        _onboardingCompletedKey,
        settings.onboardingCompleted,
      ),
      _preferences.setBool(
        _experimentalScreenLockKey,
        settings.experimentalScreenLock,
      ),
      _preferences.setBool(
        _experimentalOverlayLockKey,
        settings.experimentalOverlayLock,
      ),
      _preferences.setString(_relockKey, settings.relockPolicy.name),
    ]);
  }

  @override
  Future<void> savePassword(List<LockToken> password) async {
    final value = jsonEncode(password.map((token) => token.id).toList());
    await _secureStorage.write(key: _passwordKey, value: value);
  }

  @override
  Future<void> saveRecoveryPin(String pin) async {
    if (_normalizeRecoveryPin(pin) == null) return;
    await _secureStorage.write(key: _recoveryPinKey, value: pin);
  }

  String? _normalizeRecoveryPin(String? value) {
    if (value == null || !RegExp(r'^\d{4}$').hasMatch(value)) return null;
    return value;
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

      if (tokens.length < 2 || tokens.length > 6) return null;
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
