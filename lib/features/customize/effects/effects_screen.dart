import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/effects.dart';
import '../../../lock_engine/floating_preview.dart';
import '../../../lock_engine/models.dart';
import '../../../widgets/production_ui.dart';
import '../background/background_style.dart';

typedef EffectChanged = void Function(
  MovementStyle movement,
  PopStyle popStyle,
);

class EffectsScreen extends StatefulWidget {
  const EffectsScreen({
    super.key,
    required this.background,
    required this.selectedShapes,
    required this.selectedTones,
    required this.movementStyle,
    required this.popStyle,
    required this.style,
    required this.objectCount,
    required this.speed,
    required this.movementArea,
    required this.onChanged,
  });

  final LockBackground background;
  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final ShapeStyle style;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final EffectChanged onChanged;

  @override
  State<EffectsScreen> createState() => _EffectsScreenState();
}

class _EffectsScreenState extends State<EffectsScreen>
    with SingleTickerProviderStateMixin {
  late MovementStyle _movement;
  late PopStyle _popStyle;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _movement = widget.movementStyle;
    _popStyle = widget.popStyle;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
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
        titleSpacing: 0,
        title: const Text(
          '움직임 & 반응',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  _CompactEffectPreview(
                    background: widget.background,
                    selectedShapes: widget.selectedShapes,
                    selectedTones: widget.selectedTones,
                    movement: _movement,
                    popStyle: _popStyle,
                    style: widget.style,
                    objectCount: widget.objectCount,
                    speed: widget.speed,
                    movementArea: widget.movementArea,
                  ),
                  const SizedBox(height: 16),
                  _EffectTabs(controller: _tabController),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MotionCatalog(
                    background: widget.background,
                    selectedShapes: widget.selectedShapes,
                    selectedTones: widget.selectedTones,
                    currentMovement: _movement,
                    currentPop: _popStyle,
                    style: widget.style,
                    speed: widget.speed,
                    movementArea: widget.movementArea,
                    onSelect: _selectMovement,
                  ),
                  _ReactionCatalog(
                    background: widget.background,
                    selectedShapes: widget.selectedShapes,
                    selectedTones: widget.selectedTones,
                    currentMovement: _movement,
                    currentPop: _popStyle,
                    style: widget.style,
                    speed: widget.speed,
                    movementArea: widget.movementArea,
                    onSelect: _selectPop,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectMovement(MovementStyle style) {
    if (style.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\${style.label} 모션은 아직 보유하지 않은 항목입니다.'),
          duration: const Duration(milliseconds: 1400),
        ),
      );
      return;
    }

    setState(() => _movement = style);
    widget.onChanged(_movement, _popStyle);
  }

  void _selectPop(PopStyle style) {
    if (style.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\${style.label} 반응은 아직 보유하지 않은 항목입니다.'),
          duration: const Duration(milliseconds: 1400),
        ),
      );
      return;
    }

    setState(() => _popStyle = style);
    widget.onChanged(_movement, _popStyle);
  }
}

class _CompactEffectPreview extends StatelessWidget {
  const _CompactEffectPreview({
    required this.background,
    required this.selectedShapes,
    required this.selectedTones,
    required this.movement,
    required this.popStyle,
    required this.style,
    required this.objectCount,
    required this.speed,
    required this.movementArea,
  });

  final LockBackground background;
  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final MovementStyle movement;
  final PopStyle popStyle;
  final ShapeStyle style;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;

  @override
  Widget build(BuildContext context) {
    return ProductionSoftCard(
      padding: EdgeInsets.zero,
      radius: 28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 154,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: background.gradient),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FloatingPreview(
                    selectedShapes: selectedShapes,
                    selectedTones: selectedTones,
                    movementStyle: movement,
                    popStyle: popStyle,
                    style: style,
                    objectCount: math.min(objectCount, 6),
                    speed: speed,
                    movementArea: movementArea,
                    topInset: 18,
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _PreviewPill(
                    icon: Icons.play_arrow_rounded,
                    label: '\${movement.label} · \${popStyle.label}',
                  ),
                ),
                const Positioned(
                  right: 12,
                  bottom: 12,
                  child: _PreviewPill(
                    icon: Icons.touch_app_rounded,
                    label: '탭해서 반응 확인',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: brandPurple),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5A5664),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EffectTabs extends StatelessWidget {
  const _EffectTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
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
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x147659F6),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        labelColor: brandPurple,
        unselectedLabelColor: secondaryInk,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        tabs: const [
          Tab(text: '움직임'),
          Tab(text: '반응'),
        ],
      ),
    );
  }
}

class _MotionCatalog extends StatelessWidget {
  const _MotionCatalog({
    required this.background,
    required this.selectedShapes,
    required this.selectedTones,
    required this.currentMovement,
    required this.currentPop,
    required this.style,
    required this.speed,
    required this.movementArea,
    required this.onSelect,
  });

  final LockBackground background;
  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final MovementStyle currentMovement;
  final PopStyle currentPop;
  final ShapeStyle style;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final ValueChanged<MovementStyle> onSelect;

  @override
  Widget build(BuildContext context) {
    return _CatalogBody(
      heading: '움직임',
      supporting: '화면을 떠다니는 방식을 하나 선택해요.',
      children: MovementStyle.values
          .map(
            (candidate) => _EffectChoiceCard(
              title: candidate.label,
              description: _movementDescription(candidate),
              icon: _movementIcon(candidate),
              selected: candidate == currentMovement,
              locked: candidate.locked,
              onTap: () => onSelect(candidate),
              preview: _ShortRuntimePreview(
                background: background,
                selectedShapes: selectedShapes,
                selectedTones: selectedTones,
                movement: candidate,
                popStyle: currentPop,
                style: style,
                speed: speed,
                movementArea: movementArea,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ReactionCatalog extends StatelessWidget {
  const _ReactionCatalog({
    required this.background,
    required this.selectedShapes,
    required this.selectedTones,
    required this.currentMovement,
    required this.currentPop,
    required this.style,
    required this.speed,
    required this.movementArea,
    required this.onSelect,
  });

  final LockBackground background;
  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final MovementStyle currentMovement;
  final PopStyle currentPop;
  final ShapeStyle style;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final ValueChanged<PopStyle> onSelect;

  @override
  Widget build(BuildContext context) {
    return _CatalogBody(
      heading: '반응',
      supporting: '도형을 눌렀을 때 나타나는 반응을 하나 선택해요.',
      children: PopStyle.values
          .map(
            (candidate) => _EffectChoiceCard(
              title: candidate.label,
              description: _popDescription(candidate),
              icon: _popIcon(candidate),
              selected: candidate == currentPop,
              locked: candidate.locked,
              onTap: () => onSelect(candidate),
              preview: _ShortRuntimePreview(
                background: background,
                selectedShapes: selectedShapes,
                selectedTones: selectedTones,
                movement: currentMovement,
                popStyle: candidate,
                style: style,
                speed: speed,
                movementArea: movementArea,
                reactionPreview: true,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CatalogBody extends StatelessWidget {
  const _CatalogBody({
    required this.heading,
    required this.supporting,
    required this.children,
  });

  final String heading;
  final String supporting;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Text(
          heading,
          style: const TextStyle(
            color: ink,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.25,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          supporting,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.91,
          children: children,
        ),
      ],
    );
  }
}

class _EffectChoiceCard extends StatelessWidget {
  const _EffectChoiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.locked,
    required this.onTap,
    required this.preview,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFBFAFF) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? brandPurple : productionBorder,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? productionCardShadow : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: preview),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: locked
                            ? const Color(0xFFF1F0F4)
                            : brandLavender,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: 17,
                        color: locked ? secondaryInk : brandPurple,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: secondaryInk,
                              fontSize: 10,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (locked)
                      const Icon(
                        Icons.lock_rounded,
                        size: 17,
                        color: secondaryInk,
                      )
                    else if (selected)
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: brandPurple,
                      )
                    else
                      const Icon(
                        Icons.circle_outlined,
                        size: 20,
                        color: Color(0xFFB8B4C1),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortRuntimePreview extends StatefulWidget {
  const _ShortRuntimePreview({
    required this.background,
    required this.selectedShapes,
    required this.selectedTones,
    required this.movement,
    required this.popStyle,
    required this.style,
    required this.speed,
    required this.movementArea,
    this.reactionPreview = false,
  });

  final LockBackground background;
  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final MovementStyle movement;
  final PopStyle popStyle;
  final ShapeStyle style;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final bool reactionPreview;

  @override
  State<_ShortRuntimePreview> createState() => _ShortRuntimePreviewState();
}

class _ShortRuntimePreviewState extends State<_ShortRuntimePreview> {
  Timer? _timer;
  bool _playing = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: widget.background.gradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: TickerMode(
              enabled: _playing,
              child: FloatingPreview(
                selectedShapes: widget.selectedShapes,
                selectedTones: widget.selectedTones,
                movementStyle: widget.movement,
                popStyle: widget.popStyle,
                style: widget.style,
                objectCount: 3,
                speed: widget.speed,
                movementArea: widget.movementArea,
                topInset: 8,
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.42),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.reactionPreview
                    ? Icons.touch_app_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _movementIcon(MovementStyle style) {
  switch (style) {
    case MovementStyle.floating:
      return Icons.air_rounded;
    case MovementStyle.bounce:
      return Icons.sports_basketball_rounded;
    case MovementStyle.orbit:
      return Icons.blur_circular_rounded;
    case MovementStyle.zeroGravity:
      return Icons.public_rounded;
    case MovementStyle.underwater:
      return Icons.water_rounded;
  }
}

IconData _popIcon(PopStyle style) {
  switch (style) {
    case PopStyle.basicPop:
      return Icons.brightness_5_rounded;
    case PopStyle.bubble:
      return Icons.bubble_chart_rounded;
    case PopStyle.spark:
      return Icons.auto_awesome_rounded;
    case PopStyle.pixel:
      return Icons.grid_view_rounded;
    case PopStyle.glassBreak:
      return Icons.change_history_rounded;
  }
}

String _movementDescription(MovementStyle style) {
  switch (style) {
    case MovementStyle.floating:
      return '부드럽게 떠다니는 기본 움직임';
    case MovementStyle.bounce:
      return '통통 튀는 리듬감 있는 움직임';
    case MovementStyle.orbit:
      return '부드러운 궤도를 따라 도는 움직임';
    case MovementStyle.zeroGravity:
      return '무중력처럼 천천히 흘러가는 움직임';
    case MovementStyle.underwater:
      return '물속을 유영하듯 잔잔한 움직임';
  }
}

String _popDescription(PopStyle style) {
  switch (style) {
    case PopStyle.basicPop:
      return '가볍게 커졌다 돌아오는 기본 반응';
    case PopStyle.bubble:
      return '물방울처럼 퍼지는 반응';
    case PopStyle.spark:
      return '반짝이는 입자 반응';
    case PopStyle.pixel:
      return '픽셀처럼 흩어지는 반응';
    case PopStyle.glassBreak:
      return '유리 파편처럼 퍼지는 반응';
  }
}
