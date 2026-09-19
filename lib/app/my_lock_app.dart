import 'package:flutter/material.dart';

import '../features/shell/root_shell.dart';
import 'theme.dart';

class MyLockApp extends StatelessWidget {
  const MyLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK',
      theme: buildMyLockTheme(),
      home: const RootShell(),
    );
  }
}
