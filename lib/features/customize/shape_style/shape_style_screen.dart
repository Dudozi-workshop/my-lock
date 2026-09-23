import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/effects.dart';
import '../../../lock_engine/models.dart';
import '../../lock_settings/password_setup/password_setup_screen.dart';
import '../background/background_style.dart';
import 'shape_style_controller.dart';
import 'shape_style_preview.dart';
import 'tabs/color_tab.dart';
import 'tabs/shape_tab.dart';
import 'tabs/texture_tab.dart';

class ShapeStyleScreen extends StatefulWidget {
  const ShapeStyleScreen({
    super.key,
    required this.selectedShapes,
    required this.selectedTones,
    required this.currentPassword,
    required this.background,
    required this.movementStyle,
    required this.popStyle,
    required this.objectCount,
    required this.speed,
    required this.movementArea,
    required this.onApply,
  });

  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final List<LockToken>? currentPassword;
  final LockBackground background;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final ShapeStyleApplied onApply;

  @override
  State<ShapeStyleScreen> createState() => _ShapeStyleScreenState();
}

class _ShapeStyleScreenState extends State<ShapeStyleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ShapeStyleController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = ShapeStyleController(
      initialShapes: widget.selectedShapes,
      initialTones: widget.selectedTones,
    )..addListener(_refresh);
  }

  void _refresh() => setState(() {});

  bool get _passwordChangeRequired {
    final password = widget.currentPassword;
    if (password == null || password.isEmpty) return false;

    return password.any(
      (token) =>
          !_controller.shapes.contains(token.shape) ||
          !_controller.tones.contains(token.tone),
    );
  }

  String get _passwordChangeMessage {
    final password = widget.currentPassword;
    if (password == null) return '사용 중인 항목이 변경됐어요.';

    final shapeChanged =
        password.any((token) => !_controller.shapes.contains(token.shape));
    final toneChanged =
        password.any((token) => !_controller.tones.contains(token.tone));

    if (toneChanged && !shapeChanged) return '사용 중인 색상이 변경됐어요.';
    if (shapeChanged && !toneChanged) return '사용 중인 도형이 변경됐어요.';
    return '사용 중인 항목이 변경됐어요.';
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needsPasswordChange =
        _controller.hasChanges && _passwordChangeRequired;

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '도형 & 스타일',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: ShapeStylePreview(
                shapes: _controller.shapes,
                tones: _controller.tones,
                background: widget.background,
                movementStyle: widget.movementStyle,
                popStyle: widget.popStyle,
                objectCount: widget.objectCount,
                speed: widget.speed,
                movementArea: widget.movementArea,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _StyleTabBar(controller: _tabController),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ShapeTab(
                    selectedShapes: _controller.shapes,
                    onToggle: _controller.toggleShape,
                  ),
                  ColorTab(
                    selectedTones: _controller.tones,
                    onToggle: _controller.toggleTone,
                  ),
                  const TextureTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (needsPasswordChange) ...[
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFFD06B40),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '비밀번호 변경 필요',
                      style: TextStyle(
                        color: Color(0xFFD06B40),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: brandPurple,
                  disabledBackgroundColor: const Color(0xFFD8D3EB),
                ),
                onPressed: _controller.hasChanges ? _applyChanges : null,
                child: const Text('적용'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyChanges() async {
    List<LockToken>? replacementPassword;

    if (_passwordChangeRequired) {
      final shouldChange = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('비밀번호 변경 필요'),
          content: Text(_passwordChangeMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('변경하기'),
            ),
          ],
        ),
      );

      if (shouldChange != true || !mounted) return;

      replacementPassword = await Navigator.of(context).push<List<LockToken>>(
        MaterialPageRoute(
          builder: (context) => PasswordSetupScreen(
            selectedShapes: _controller.shapes,
            selectedTones: _controller.tones,
          ),
        ),
      );

      if (replacementPassword == null || !mounted) return;
    }

    widget.onApply(
      _controller.shapes,
      _controller.tones,
      replacementPassword,
    );
    _controller.markApplied();
  }
}

class _StyleTabBar extends StatelessWidget {
  const _StyleTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFF4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        labelColor: ink,
        unselectedLabelColor: secondaryInk,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: '도형'),
          Tab(text: '색상'),
          Tab(text: '질감'),
        ],
      ),
    );
  }
}
