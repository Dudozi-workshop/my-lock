import 'package:flutter/material.dart';

import '../../app/my_lock_settings_controller.dart';
import '../customize/customize_screen.dart';
import '../lock_settings/lock_settings_screen.dart';
import '../shop/shop_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  late final MyLockSettingsController _settings;

  @override
  void initState() {
    super.initState();
    _settings = MyLockSettingsController();
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          CustomizeScreen(settings: _settings),
          const ShopScreen(),
          LockSettingsScreen(settings: _settings),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: '꾸미기',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: '상점',
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_outline_rounded),
            selectedIcon: Icon(Icons.lock_rounded),
            label: '잠금 설정',
          ),
        ],
      ),
    );
  }
}
