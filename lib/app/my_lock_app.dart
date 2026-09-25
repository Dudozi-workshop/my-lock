import 'package:flutter/material.dart';

import '../features/shell/root_shell.dart';
import 'build_info.dart';
import 'theme.dart';

class MyLockApp extends StatelessWidget {
  const MyLockApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const RootShell(),
    );
  }
}
