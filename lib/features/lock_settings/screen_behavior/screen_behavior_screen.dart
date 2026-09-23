import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/effects.dart';
import '../../../lock_engine/floating_preview.dart';
import '../../../lock_engine/models.dart';

class ScreenBehaviorScreen extends StatefulWidget {
  const ScreenBehaviorScreen({
    super.key,
    required this.selectedShapes,
    required this.selectedTones,
    required this.movementStyle,
    required this.popStyle,
    required this.texture,
    required this.objectCount,
    required this.speed,
    required this.movementArea,
    required this.onChanged,
  });

  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final ShapeTexture texture;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final void Function(
    int objectCount,
    FloatingSpeed speed,
    MovementArea movementArea,
  ) onChanged;

  @override
  State<ScreenBehaviorScreen> createState() => _ScreenBehaviorScreenState();
}

class _ScreenBehaviorScreenState extends State<ScreenBehaviorScreen> {
  late int _objectCount;
  late FloatingSpeed _speed;
  late MovementArea _movementArea;

  @override
  void initState() {
    super.initState();
    _objectCount = widget.objectCount;
    _speed = widget.speed;
    _movementArea = widget.movementArea;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '화면 동작',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              height: 290,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF4FB),
                    Color(0xFFF1EEFF),
                    Color(0xFFECF7FF),
                  ],
                ),
                border: Border.all(color: const Color(0xFFE9E4F3)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FloatingPreview(
                      selectedShapes: widget.selectedShapes,
                      selectedTones: widget.selectedTones,
                      movementStyle: widget.movementStyle,
                      popStyle: widget.popStyle,
                      texture: widget.texture,
                      objectCount: _objectCount,
                      speed: _speed,
                      movementArea: _movementArea,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.84),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: brandPurple,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('도형 수', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '화면에 동시에 표시되는 도형 수입니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ChoiceCard(
                    title: '적게',
                    subtitle: '6개',
                    selected: _objectCount == 6,
                    onTap: () => _setObjectCount(6),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ChoiceCard(
                    title: '보통',
                    subtitle: '9개',
                    selected: _objectCount == 9,
                    onTap: () => _setObjectCount(9),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ChoiceCard(
                    title: '많이',
                    subtitle: '12개',
                    selected: _objectCount == 12,
                    onTap: () => _setObjectCount(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('이동 영역', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '도형이 움직일 수 있는 세로 범위를 선택합니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ChoiceCard(
                    title: '전체',
                    subtitle: '화면 전체',
                    selected: _movementArea == MovementArea.full,
                    onTap: () => _setMovementArea(MovementArea.full),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ChoiceCard(
                    title: '하단 영역',
                    subtitle: '화면 아래 60%',
                    selected: _movementArea == MovementArea.lower,
                    onTap: () => _setMovementArea(MovementArea.lower),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('속도', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '도형이 움직이는 기본 속도를 조절합니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ChoiceCard(
                    title: '느리게',
                    selected: _speed == FloatingSpeed.slow,
                    onTap: () => _setSpeed(FloatingSpeed.slow),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ChoiceCard(
                    title: '보통',
                    selected: _speed == FloatingSpeed.normal,
                    onTap: () => _setSpeed(FloatingSpeed.normal),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ChoiceCard(
                    title: '빠르게',
                    selected: _speed == FloatingSpeed.fast,
                    onTap: () => _setSpeed(FloatingSpeed.fast),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setObjectCount(int value) {
    if (_objectCount == value) return;
    setState(() => _objectCount = value);
    widget.onChanged(_objectCount, _speed, _movementArea);
  }

  void _setSpeed(FloatingSpeed value) {
    if (_speed == value) return;
    setState(() => _speed = value);
    widget.onChanged(_objectCount, _speed, _movementArea);
  }

  void _setMovementArea(MovementArea value) {
    if (_movementArea == value) return;
    setState(() => _movementArea = value);
    widget.onChanged(_objectCount, _speed, _movementArea);
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? brandLavender : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? brandPurple : const Color(0xFFE8E5ED),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? brandPurple : ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: secondaryInk,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
