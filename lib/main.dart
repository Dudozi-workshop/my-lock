import 'package:flutter/widgets.dart';

import 'app/my_lock_app.dart';
import 'app/my_lock_lock_app.dart';
import 'lock_engine/crystal_sprite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CrystalSprite.load();
  runApp(const MyLockApp());
}


@pragma('vm:entry-point')
Future<void> lockMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CrystalSprite.load();
  runApp(const MyLockLockApp());
}
