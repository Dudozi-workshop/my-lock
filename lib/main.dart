import 'package:flutter/widgets.dart';

import 'app/my_lock_app.dart';
import 'app/my_lock_lock_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyLockApp());
}


@pragma('vm:entry-point')
void lockMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyLockLockApp());
}
