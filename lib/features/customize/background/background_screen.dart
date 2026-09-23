import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/effects.dart';
import '../../../lock_engine/floating_preview.dart';
import '../../../lock_engine/models.dart';
import 'background_style.dart';

class BackgroundScreen extends StatefulWidget {
  const BackgroundScreen({
    super.key,
    required this.selectedBackground,
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

  final LockBackground selectedBackground;
  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final MovementStyle movementStyle;
  final PopStyle popStyle;
  final ShapeTexture texture;
  final int objectCount;
  final FloatingSpeed speed;
  final MovementArea movementArea;
  final ValueChanged<LockBackground> onChanged;

  @override
  State<BackgroundScreen> createState() => _BackgroundScreenState();
}

class _BackgroundScreenState extends State<BackgroundScreen> {
  late LockBackground _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedBackground;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '배경',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          children: [
            _buildLivePreview(),
            const SizedBox(height: 22),
            Text(
              '기본 배경',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildGrid(const [
              LockBackground.softGradient,
              LockBackground.basicLight,
              LockBackground.basicDark,
            ]),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '스페셜 배경',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Text(
                  'PLUS · 키샤드 연동 예정',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildGrid(const [
              LockBackground.galaxy,
              LockBackground.ocean,
              LockBackground.aurora,
            ]),
            const SizedBox(height: 20),
            _buildPhotoTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreview() {
    return Container(
      height: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: _selected.gradient,
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
              objectCount: widget.objectCount,
              speed: widget.speed,
              movementArea: widget.movementArea,
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
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
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<LockBackground> items) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _BackgroundTile(
          item: item,
          selected: item == _selected,
          onTap: () => _select(item),
        );
      },
    );
  }

  void _select(LockBackground item) {
    setState(() => _selected = item);
    widget.onChanged(item);

    if (item.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.label} PLUS 배경 · 개발 버전에서는 적용 가능하며 키샤드 소유권은 추후 연결됩니다.',
          ),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Widget _buildPhotoTile() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('내 사진 배경은 사진 권한 연결 단계에서 추가됩니다.'),
              duration: Duration(milliseconds: 1400),
            ),
          );
        },
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8E6ED)),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_photo_alternate_outlined, color: brandPurple),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '내 사진',
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '준비 중',
                style: TextStyle(
                  color: secondaryInk,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundTile extends StatelessWidget {
  const _BackgroundTile({
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? brandPurple : const Color(0xFFE8E6ED),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: item.gradient,
                  ),
                  child: Stack(
                    children: [
                      if (item.locked)
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.86),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                size: 17,
                                color: brandPurple,
                              ),
                            ),
                          ),
                        ),
                      if (selected)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: brandPurple,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
