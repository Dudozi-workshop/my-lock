import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/my_lock_app.dart';
import 'app/my_lock_lock_app.dart';
import 'features/labs/sea_turtle_runtime_lab_screen.dart';
import 'lock_engine/sea_turtle_runtime_poc.dart';
import 'lock_engine/shape_spec/shape_spec_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShapeSpecRegistry.instance.load();
  await SeaTurtleRuntimePoc.instance.load();

  if (kIsWeb &&
      Uri.base.queryParameters['lab'] == 'sea-turtle-runtime') {
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SeaTurtleRuntimeLabScreen(),
      ),
    );
    return;
  }

  runApp(const MyLockApp());
}

@pragma('vm:entry-point')
Future<void> lockMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShapeSpecRegistry.instance.load();
  await SeaTurtleRuntimePoc.instance.load();
  runApp(const MyLockLockApp());
}
