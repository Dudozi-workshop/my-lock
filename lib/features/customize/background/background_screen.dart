import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/effects.dart';
import '../../../lock_engine/floating_preview.dart';
import '../../../lock_engine/models.dart';
import '../../../widgets/production_ui.dart';
import 'background_style.dart';

enum _BackgroundFilter {
  all('전체'),
  basic('기본'),
  special('스페셜');

  const _BackgroundFilter(this.label);
  final String label;
}

class BackgroundScreen extends StatefulWidget {
  const BackgroundScreen({
    super.key,
    required this.selectedBackground,
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

  final LockBackground selectedBackground;
  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final ShapeStyle style;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final ValueChanged<LockBackground> onChanged;

  @override
  State<BackgroundScreen> createState() => _BackgroundScreenState();
}

class _BackgroundScreenState extends State<BackgroundScreen> {
  late LockBackground _selected;
  _BackgroundFilter _filter = _BackgroundFilter.all;

  static const _basic = <LockBackground>[
    LockBackground.softGradient,
    LockBackground.basicLight,
    LockBackground.basicDark,
  ];

  static const _special = <LockBackground>[
    LockBackground.galaxy,
    LockBackground.ocean,
    LockBackground.aurora,
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedBackground;
  }

  @override
  Widget build(BuildContext context) {
    final visibleSections = switch (_filter) {
      _BackgroundFilter.all => const [_BackgroundFilter.basic, _BackgroundFilter.special],
      _BackgroundFilter.basic => const [_BackgroundFilter.basic],
      _BackgroundFilter.special => const [_BackgroundFilter.special],
    };

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: const Text(
          '배경',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _HeroBackgroundPreview(
              background: _selected,
              selectedShapes: widget.selectedShapes,
              selectedTones: widget.selectedTones,
              movementStyle: widget.movementStyle,
              popStyle: widget.popStyle,
              style: widget.style,
              objectCount: widget.objectCount,
              speed: widget.speed,
              movementArea: widget.movementArea,
            ),
            const SizedBox(height: 18),
            _BackgroundFilters(
              selected: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 18),
            for (var index = 0; index < visibleSections.length; index++) ...[
              _buildSection(visibleSections[index]),
              if (index != visibleSections.length - 1)
                const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(_BackgroundFilter section) {
    final items = section == _BackgroundFilter.basic ? _basic : _special;
    final title = section == _BackgroundFilter.basic ? '기본' : '스페셜';
    final subtitle = section == _BackgroundFilter.basic
        ? '현재 앱에 등록된 기본 배경'
        : '보유 후 사용할 수 있는 배경';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text(
              '${items.length}개',
              style: const TextStyle(
                color: secondaryInk,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _BackgroundThumbnail(
              item: item,
              selected: item == _selected,
              onTap: () => _select(item),
            );
          },
        ),
      ],
    );
  }

  void _select(LockBackground item) {
    if (item.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.label} 배경은 아직 보유하지 않은 항목입니다.'),
          duration: const Duration(milliseconds: 1400),
        ),
      );
      return;
    }

    setState(() => _selected = item);
    widget.onChanged(item);
  }
}

class _HeroBackgroundPreview extends StatelessWidget {
  const _HeroBackgroundPreview({
    required this.background,
    required this.selectedShapes,
    required this.selectedTones,
    required this.movementStyle,
    required this.popStyle,
    required this.style,
    required this.objectCount,
    required this.speed,
    required this.movementArea,
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

  @override
  Widget build(BuildContext context) {
    return ProductionSoftCard(
      padding: EdgeInsets.zero,
      radius: 30,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: AspectRatio(
          aspectRatio: 1.55,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: background.gradient),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FloatingPreview(
                    selectedShapes: selectedShapes,
                    selectedTones: selectedTones,
                    movementStyle: movementStyle,
                    popStyle: popStyle,
                    style: style,
                    objectCount: objectCount,
                    speed: speed,
                    movementArea: movementArea,
                    topInset: 24,
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      '현재 배경',
                      style: TextStyle(
                        color: Color(0xFF5C5766),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          background.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Color(0x66000000),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          '정적',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
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

class _BackgroundFilters extends StatelessWidget {
  const _BackgroundFilters({
    required this.selected,
    required this.onChanged,
  });

  final _BackgroundFilter selected;
  final ValueChanged<_BackgroundFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _BackgroundFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _BackgroundFilter.values[index];
          final active = item == selected;
          return ChoiceChip(
            label: Text(item.label),
            selected: active,
            onSelected: (_) => onChanged(item),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: active ? Colors.white : secondaryInk,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            selectedColor: brandPurple,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: active ? brandPurple : productionBorder,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
          );
        },
      ),
    );
  }
}

class _BackgroundThumbnail extends StatelessWidget {
  const _BackgroundThumbnail({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final LockBackground item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFBFAFF) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? brandPurple : productionBorder,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? productionCardShadow : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: item.gradient),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (item.locked)
                          ColoredBox(
                            color: Colors.white.withValues(alpha: 0.34),
                          ),
                        Positioned(
                          top: 7,
                          right: 7,
                          child: item.locked
                              ? const _RoundIcon(
                                  icon: Icons.lock_rounded,
                                  foreground: Color(0xFF777480),
                                )
                              : selected
                                  ? const _RoundIcon(
                                      icon: Icons.check_rounded,
                                      foreground: Colors.white,
                                      background: brandPurple,
                                    )
                                  : const _RoundIcon(
                                      icon: Icons.circle_outlined,
                                      foreground: Colors.white,
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  item.locked ? '미보유' : '정적',
                  style: TextStyle(
                    color: item.locked ? secondaryInk : brandPurple,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.foreground,
    this.background = const Color(0x55000000),
  });

  final IconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: foreground, size: 15),
    );
  }
}
