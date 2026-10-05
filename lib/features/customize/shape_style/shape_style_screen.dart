import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/effects.dart';
import '../../../lock_engine/models.dart';
import '../../lock_settings/password_setup/password_setup_screen.dart';
import '../background/background_style.dart';
import 'shape_style_controller.dart';
import 'shape_style_preview.dart';
import 'tabs/color_tab.dart';
import 'tabs/shape_tab.dart';

class ShapeStyleScreen extends StatefulWidget {
  const ShapeStyleScreen({
    super.key,
    required this.selectedShapes,
    required this.selectedTones,
    required this.currentPassword,
    required this.style,
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
  final ShapeStyle style;
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
  int _shuffleSeed = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = ShapeStyleController(
      initialShapes: widget.selectedShapes,
      initialTones: widget.selectedTones,
      initialStyle: widget.style,
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
    if (shapeChanged && !toneChanged) return '사용 중인 모양이 변경됐어요.';
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
        titleSpacing: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.palette_rounded, color: Color(0xFFE45C9D), size: 22),
            SizedBox(width: 8),
            Text(
              '모양 & 색상',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: ShapeStylePreview(
                shapes: _controller.shapes,
                tones: _controller.tones,
                background: widget.background,
                movementStyle: widget.movementStyle,
                popStyle: widget.popStyle,
                style: _controller.style,
                objectCount: widget.objectCount,
                speed: widget.speed,
                movementArea: widget.movementArea,
                shuffleSeed: _shuffleSeed,
                onTap: _openRuntimePreview,
                onShuffle: _reshufflePreview,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ShapeColorTabBar(controller: _tabController),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ShapeTab(
                    selectedShapes: _controller.shapes,
                    onToggle: _controller.toggleShape,
                    onMinimumSelectionBlocked: () =>
                        _showMinimumSelectionMessage('모양'),
                  ),
                  ColorTab(
                    selectedTones: _controller.tones,
                    onToggle: _controller.toggleTone,
                    onMinimumSelectionBlocked: () =>
                        _showMinimumSelectionMessage('색상'),
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _controller.hasChanges ? _applyChanges : null,
                child: const Text(
                  '저장',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reshufflePreview() {
    HapticFeedback.selectionClick();
    setState(() => _shuffleSeed++);
  }

  Future<void> _openRuntimePreview() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ShapeStyleRuntimePreviewScreen(
          shapes: _controller.shapes,
          tones: _controller.tones,
          background: widget.background,
          movementStyle: widget.movementStyle,
          popStyle: widget.popStyle,
          style: _controller.style,
          objectCount: widget.objectCount,
          speed: widget.speed,
          movementArea: widget.movementArea,
        ),
      ),
    );
  }

  void _showMinimumSelectionMessage(String category) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$category은(는) 최소 1개 이상 선택해야 해요.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
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
            style: _controller.style,
          ),
        ),
      );

      if (replacementPassword == null || !mounted) return;
    }

    widget.onApply(
      _controller.shapes,
      _controller.tones,
      _controller.style,
      replacementPassword,
    );
    _controller.markApplied();

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('모양과 색상을 저장했어요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _ShapeColorTabBar extends StatelessWidget {
  const _ShapeColorTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFF6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD7CCFF)),
        ),
        labelColor: brandPurple,
        unselectedLabelColor: secondaryInk,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: '모양'),
          Tab(text: '색상'),
        ],
      ),
    );
  }
}
