import 'package:flutter/foundation.dart';

import '../../lock_engine/models.dart';

enum LockTapResult { correct, wrong, unlocked, ignored }

class LockModeController extends ChangeNotifier {
  LockModeController(List<LockToken> password)
      : assert(password.length >= 3 && password.length <= 6),
        _password = List<LockToken>.from(password);

  final List<LockToken> _password;

  int _progress = 0;
  bool _mismatch = false;
  bool _unlocked = false;

  int get progress => _progress;
  int get passwordLength => _password.length;
  bool get mismatch => _mismatch;
  bool get unlocked => _unlocked;

  List<LockToken> get requiredTokens => _password
      .skip(_progress)
      .take(2)
      .toList(growable: false);

  LockTapResult tap(LockToken token) {
    if (_unlocked) return LockTapResult.ignored;

    final expected = _password[_progress];
    if (token.id != expected.id) {
      _progress = 0;
      _mismatch = true;
      notifyListeners();
      return LockTapResult.wrong;
    }

    _mismatch = false;
    _progress += 1;

    if (_progress == _password.length) {
      _unlocked = true;
      notifyListeners();
      return LockTapResult.unlocked;
    }

    notifyListeners();
    return LockTapResult.correct;
  }

  void reset() {
    _progress = 0;
    _mismatch = false;
    _unlocked = false;
    notifyListeners();
  }
}
