import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class LockableApp {
  const LockableApp({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final IconData icon;
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

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  static const _demoApps = <LockableApp>[
    LockableApp(id: 'instagram', name: 'Instagram', icon: Icons.photo_camera_outlined),
    LockableApp(id: 'kakao', name: '카카오톡', icon: Icons.chat_bubble_outline_rounded),
    LockableApp(id: 'gallery', name: '갤러리', icon: Icons.photo_library_outlined),
    LockableApp(id: 'messages', name: '메시지', icon: Icons.sms_outlined),
    LockableApp(id: 'browser', name: '브라우저', icon: Icons.language_rounded),
    LockableApp(id: 'youtube', name: 'YouTube', icon: Icons.play_circle_outline_rounded),
    LockableApp(id: 'notes', name: '메모', icon: Icons.note_alt_outlined),
    LockableApp(id: 'mail', name: '메일', icon: Icons.mail_outline_rounded),
  ];

  late final Set<String> _selectedIds;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _demoApps.where((app) {
      final q = _query.trim().toLowerCase();
      return q.isEmpty || app.name.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '잠글 앱',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selectedIds),
            child: const Text('완료'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                children: [
                  Text(
                    '선택된 앱 ${_selectedIds.length}개',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  if (_selectedIds.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(_selectedIds.clear),
                      child: const Text('전체 해제'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
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
                              child: Icon(app.icon, color: brandPurple),
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
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDFF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                '웹 미리보기에서는 데모 앱 목록을 사용합니다. 실제 설치 앱 연동은 Android/iOS 네이티브 단계에서 연결됩니다.',
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

  void _toggle(String id) {
    setState(() {
      if (!_selectedIds.add(id)) {
        _selectedIds.remove(id);
      }
    });
  }
}
