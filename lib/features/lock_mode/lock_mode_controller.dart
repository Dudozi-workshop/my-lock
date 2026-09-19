import 'package:flutter/foundation.dart';

import '../../lock_engine/models.dart';

enum LockTapResult { correct, wrong, unlocked, ignored }

class LockModeController extends ChangeNotifier {
  LockModeController(List<LockToken> password)
      : assert(password.length >= 2 && password.length <= 6),
        _password = List<LockToken>.from(password);

  final List<LockToken> _password;
  final List<LockToken> _input = [];

  bool _mismatch = false;
  bool _unlocked = false;
  int _failedAttempts = 0;

  int get progress => _input.length;
  int get passwordLength => _password.length;
  bool get mismatch => _mismatch;
  bool get unlocked => _unlocked;
  int get failedAttempts => _failedAttempts;

  List<LockToken> get requiredTokens => _password
      .skip(_input.length)
      .take(2)
      .toList(growable: false);

  LockTapResult tap(LockToken token) {
    if (_unlocked) return LockTapResult.ignored;

    _mismatch = false;
    _input.add(token);

    if (_input.length < _password.length) {
      notifyListeners();
      return LockTapResult.correct;
    }

    final matches = List.generate(
      _password.length,
      (index) => _password[index].id == _input[index].id,
    ).every((value) => value);

    if (matches) {
      _unlocked = true;
      notifyListeners();
      return LockTapResult.unlocked;
    }

    _input.clear();
    _mismatch = true;
    _failedAttempts += 1;
    notifyListeners();
    return LockTapResult.wrong;
  }

  void reset() {
    _input.clear();
    _mismatch = false;
    _unlocked = false;
    _failedAttempts = 0;
    notifyListeners();
  }
}
