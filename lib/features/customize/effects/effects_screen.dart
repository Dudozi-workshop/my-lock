import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/effects.dart';
import '../../../lock_engine/floating_preview.dart';
import '../../../lock_engine/models.dart';
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
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final EffectChanged onChanged;

  @override
  State<EffectsScreen> createState() => _EffectsScreenState();
}

class _EffectsScreenState extends State<EffectsScreen> {
  late MovementStyle _movement;
  late PopStyle _popStyle;

  @override
  void initState() {
    super.initState();
    _movement = widget.movementStyle;
    _popStyle = widget.popStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '효과',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          children: [
            _buildPreview(),
            const SizedBox(height: 24),
            _Section(
              title: '움직임',
              subtitle: '도형이 화면 안에서 움직이는 방식을 선택합니다.',
              children: MovementStyle.values
                  .map(
                    (style) => _EffectTile(
                      label: style.label,
                      selected: style == _movement,
                      locked: style.locked,
                      icon: _movementIcon(style),
                      onTap: () => _selectMovement(style),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            _Section(
              title: '탭 POP',
              subtitle: '도형을 눌렀을 때 나타나는 반응입니다.',
              children: PopStyle.values
                  .map(
                    (style) => _EffectTile(
                      label: style.label,
                      selected: style == _popStyle,
                      locked: style.locked,
                      icon: _popIcon(style),
                      onTap: () => _selectPop(style),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const _ComingSoonTile(
              icon: Icons.volume_up_rounded,
              title: '사운드',
              subtitle: 'POP 사운드 선택 · 다음 연결',
            ),
            const SizedBox(height: 10),
            const _ComingSoonTile(
              icon: Icons.auto_awesome_rounded,
              title: '잠금해제 효과',
              subtitle: 'Scatter · Fade 등 · 다음 연결',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: widget.background.gradient,
        border: Border.all(color: const Color(0xFFE9E4F3)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FloatingPreview(
              selectedShapes: widget.selectedShapes,
              selectedTones: widget.selectedTones,
              movementStyle: _movement,
              popStyle: _popStyle,
              objectCount: widget.objectCount,
              speed: widget.speed,
              movementArea: widget.movementArea,
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: brandPurple,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                '도형을 눌러 효과를 확인하세요',
                style: TextStyle(
                  color: Color(0xFF615D6A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectMovement(MovementStyle style) {
    if (style.locked) {
      _showLocked(style.label);
      return;
    }
    setState(() => _movement = style);
    widget.onChanged(_movement, _popStyle);
  }

  void _selectPop(PopStyle style) {
    if (style.locked) {
      _showLocked(style.label);
      return;
    }
    setState(() => _popStyle = style);
    widget.onChanged(_movement, _popStyle);
  }

  void _showLocked(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label 효과는 상점 아이템입니다.'),
        duration: const Duration(milliseconds: 1200),
      ),
    );
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
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 3),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.35,
          children: children,
        ),
      ],
    );
  }
}

class _EffectTile extends StatelessWidget {
  const _EffectTile({
    required this.label,
    required this.selected,
    required this.locked,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFAF9FF) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? brandPurple : const Color(0xFFE8E6ED),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: locked ? secondaryInk : brandPurple,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (locked)
                const Icon(Icons.lock_rounded, size: 15, color: secondaryInk)
              else if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: brandPurple,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8E6ED)),
      ),
      child: Row(
        children: [
          Icon(icon, color: brandPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: secondaryInk,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
