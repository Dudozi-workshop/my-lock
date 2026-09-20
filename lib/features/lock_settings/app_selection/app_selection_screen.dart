import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/platform_app_catalog.dart';

class LockableApp {
  const LockableApp({
    required this.id,
    required this.name,
    this.icon,
    this.iconBytes,
  });

  final String id;
  final String name;
  final IconData? icon;
  final Uint8List? iconBytes;
}

class AppSelectionScreen extends StatefulWidget {
  const AppSelectionScreen({
    super.key,
    required this.initialSelectedIds,
  });

  final Set<String> initialSelectedIds;

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen>
    with SingleTickerProviderStateMixin {
  static const _demoApps = <LockableApp>[
    LockableApp(
      id: 'instagram',
      name: 'Instagram',
      icon: Icons.photo_camera_outlined,
    ),
    LockableApp(
      id: 'kakao',
      name: '카카오톡',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    LockableApp(
      id: 'gallery',
      name: '갤러리',
      icon: Icons.photo_library_outlined,
    ),
    LockableApp(id: 'messages', name: '메시지', icon: Icons.sms_outlined),
    LockableApp(id: 'browser', name: '브라우저', icon: Icons.language_rounded),
    LockableApp(
      id: 'youtube',
      name: 'YouTube',
      icon: Icons.play_circle_outline_rounded,
    ),
    LockableApp(id: 'notes', name: '메모', icon: Icons.note_alt_outlined),
    LockableApp(id: 'mail', name: '메일', icon: Icons.mail_outline_rounded),
  ];

  final PlatformAppCatalog _catalog = PlatformAppCatalog();

  late final Set<String> _selectedIds;
  late final TabController _tabController;
  List<LockableApp> _apps = const <LockableApp>[];
  bool _loading = true;
  bool _usingDemoApps = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.initialSelectedIds);
    _tabController = TabController(length: 2, vsync: this);
    _loadApps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    if (kIsWeb) {
      if (!mounted) return;
      setState(() {
        _apps = _demoApps;
        _usingDemoApps = true;
        _loading = false;
      });
      return;
    }

    final nativeApps = await _catalog.loadLaunchableApps();

    if (!mounted) return;
    setState(() {
      if (nativeApps.isEmpty) {
        _apps = _demoApps;
        _usingDemoApps = true;
      } else {
        _apps = nativeApps
            .map(
              (app) => LockableApp(
                id: app.id,
                name: app.name,
                icon: Icons.apps_rounded,
                iconBytes: app.iconBytes,
              ),
            )
            .toList(growable: false);
        _usingDemoApps = false;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '보안 앱 설정',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selectedIds),
            child: const Text('완료'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                const Tab(text: '전체 앱'),
                Tab(text: '보안 중  ${_selectedIds.length}'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: '앱 검색',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: brandPurple,
                        strokeWidth: 2.4,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAppList(onlySelected: false),
                        _buildAppList(onlySelected: true),
                      ],
                    ),
            ),
            if (_usingDemoApps)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '웹 미리보기에서는 데모 앱 목록을 사용합니다. Android 앱에서는 실제 실행 가능한 앱만 불러옵니다.',
                  style: TextStyle(
                    color: Color(0xFF665C8F),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppList({required bool onlySelected}) {
    final q = _query.trim().toLowerCase();
    final filtered = _apps.where((app) {
      if (onlySelected && !_selectedIds.contains(app.id)) {
        return false;
      }

      return q.isEmpty ||
          app.name.toLowerCase().contains(q) ||
          app.id.toLowerCase().contains(q);
    }).toList();

    if (onlySelected && filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _selectedIds.isEmpty
                ? '현재 보안 중인 앱이 없습니다.\n전체 앱 탭에서 보호할 앱을 선택해 주세요.'
                : '검색 조건에 맞는 보안 앱이 없습니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: secondaryInk,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final app = filtered[index];
        final selected = _selectedIds.contains(app.id);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _toggle(app.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: brandLavender,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: app.iconBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              app.iconBytes!,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                          )
                        : Icon(
                            app.icon ?? Icons.apps_rounded,
                            color: brandPurple,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      app.name,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: selected,
                    onChanged: (_) => _toggle(app.id),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggle(String id) {
    setState(() {
      if (!_selectedIds.add(id)) {
        _selectedIds.remove(id);
      }
    });
  }
}
