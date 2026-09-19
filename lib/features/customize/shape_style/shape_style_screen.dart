import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/models.dart';
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
    required this.onChanged,
  });

  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final ShapeStyleChanged onChanged;

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
      onChanged: widget.onChanged,
    )..addListener(_refresh);
  }

  void _refresh() => setState(() {});

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: ShapeStylePreview(
                shapes: _controller.shapes,
                tones: _controller.tones,
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
    );
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
