import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/qa/sea_turtle_front_flipper_runtime_qa_screen.dart';
import '../features/qa/sea_turtle_shell_runtime_qa_screen.dart';
import '../features/shell/root_shell.dart';
import 'build_info.dart';
import 'theme.dart';

class MyLockApp extends StatelessWidget {
  const MyLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    final qa = Uri.base.queryParameters['qa'];
    final showShellRuntimeQa = kIsWeb && qa == 'sea-turtle-shell-runtime';
    final showFrontFlipperQa = kIsWeb && qa == 'front-flipper-outer';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK',
      theme: buildMyLockTheme(),
      builder: (context, child) => Stack(
        children: [
          Positioned.fill(child: child ?? const SizedBox.shrink()),
          const Positioned.fill(child: BuildStamp()),
        ],
      ),
      home: showShellRuntimeQa
          ? const SeaTurtleShellRuntimeQaScreen()
          : showFrontFlipperQa
              ? const SeaTurtleFrontFlipperRuntimeQaScreen()
              : const RootShell(),
    );
  }
}
