import 'package:flutter/foundation.dart';

import '../../../lock_engine/models.dart';

enum PasswordSetupPhase { create, confirm }

class PasswordSetupController extends ChangeNotifier {
  static const int minLength = 3;
  static const int maxLength = 6;

  PasswordSetupPhase _phase = PasswordSetupPhase.create;
  final List<LockToken> _pattern = [];
  final List<LockToken> _input = [];
  bool _mismatch = false;

  PasswordSetupPhase get phase => _phase;
  List<LockToken> get input => List.unmodifiable(_input);
  List<LockToken> get pattern => List.unmodifiable(_pattern);
  bool get mismatch => _mismatch;

  int get inputLimit =>
      _phase == PasswordSetupPhase.confirm ? _pattern.length : maxLength;

  bool get canContinue =>
      _phase == PasswordSetupPhase.create &&
      _input.length >= minLength &&
      _input.length <= maxLength;

  bool get canVerify =>
      _phase == PasswordSetupPhase.confirm &&
      _input.length == _pattern.length;

  void addToken(LockToken token) {
    if (_input.length >= inputLimit) return;
    _mismatch = false;
    _input.add(token);
    notifyListeners();
  }

  void removeLast() {
    if (_input.isEmpty) return;
    _mismatch = false;
    _input.removeLast();
    notifyListeners();
  }

  void clearInput() {
    if (_input.isEmpty && !_mismatch) return;
    _mismatch = false;
    _input.clear();
    notifyListeners();
  }

  void startConfirm() {
    if (!canContinue) return;
    _pattern
      ..clear()
      ..addAll(_input);
    _input.clear();
    _mismatch = false;
    _phase = PasswordSetupPhase.confirm;
    notifyListeners();
  }

  bool verify() {
    if (!canVerify) return false;

    final matches = List.generate(
      _pattern.length,
      (index) => _pattern[index].id == _input[index].id,
    ).every((value) => value);

    if (matches) return true;

    _input.clear();
    _mismatch = true;
    notifyListeners();
    return false;
  }

  void restart() {
    _phase = PasswordSetupPhase.create;
    _pattern.clear();
    _input.clear();
    _mismatch = false;
    notifyListeners();
  }
}
