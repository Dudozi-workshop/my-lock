import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../lock_engine/floating_preview.dart';
import '../../lock_engine/models.dart';

typedef ShapeStyleChanged = void Function(
  Set<ShapeKind> shapes,
  Set<ShapeTone> tones,
);

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
  late Set<ShapeKind> _shapes;
  late Set<ShapeTone> _tones;

  @override
  void initState() {
    super.initState();
    _shapes = Set<ShapeKind>.from(widget.selectedShapes);
    _tones = Set<ShapeTone>.from(widget.selectedTones);
    _tabController = TabController(length: 3, vsync: this);
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
              child: Container(
                height: 238,
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
                        selectedShapes: _shapes,
                        selectedTones: _tones,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFF4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
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
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildShapeTab(),
                  _buildColorTab(),
                  _buildTextureTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          '사용할 도형을 선택하세요.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ShapeChoice(
                kind: ShapeKind.circle,
                label: '원',
                selected: _shapes.contains(ShapeKind.circle),
                onTap: () => _toggleShape(ShapeKind.circle),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ShapeChoice(
                kind: ShapeKind.triangle,
                label: '세모',
                selected: _shapes.contains(ShapeKind.triangle),
                onTap: () => _toggleShape(ShapeKind.triangle),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ShapeChoice(
                kind: ShapeKind.square,
                label: '네모',
                selected: _shapes.contains(ShapeKind.square),
                onTap: () => _toggleShape(ShapeKind.square),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _FreedomNote(
          text: '한 가지 도형만 사용해도 됩니다. 선택 수를 강제로 제한하지 않습니다.',
        ),
      ],
    );
  }

  Widget _buildColorTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          '사용할 색상을 선택하세요.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ColorChoice(
                tone: ShapeTone.pink,
                label: '핑크',
                color: const Color(0xFFFF79C6),
                selected: _tones.contains(ShapeTone.pink),
                onTap: () => _toggleTone(ShapeTone.pink),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ColorChoice(
                tone: ShapeTone.blue,
                label: '블루',
                color: const Color(0xFF65A7FF),
                selected: _tones.contains(ShapeTone.blue),
                onTap: () => _toggleTone(ShapeTone.blue),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ColorChoice(
                tone: ShapeTone.yellow,
                label: '옐로우',
                color: const Color(0xFFFFCD58),
                selected: _tones.contains(ShapeTone.yellow),
                onTap: () => _toggleTone(ShapeTone.yellow),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _FreedomNote(
          text: '색상도 자유롭게 조합할 수 있습니다. 최소 한 가지 색상은 유지됩니다.',
        ),
      ],
    );
  }

  Widget _buildTextureTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          'MVP에서는 하나의 질감이 전체 도형에 적용됩니다.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Container(
          height: 116,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: brandPurple, width: 2),
          ),
          child: const Row(
            children: [
              _GlossySample(),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Glossy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '기본 제공 · 사용 중',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryInk,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded, color: brandPurple),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleShape(ShapeKind kind) {
    if (_shapes.contains(kind) && _shapes.length == 1) return;

    setState(() {
      if (!_shapes.add(kind)) {
        _shapes.remove(kind);
      }
    });
    _notifyParent();
  }

  void _toggleTone(ShapeTone tone) {
    if (_tones.contains(tone) && _tones.length == 1) return;

    setState(() {
      if (!_tones.add(tone)) {
        _tones.remove(tone);
      }
    });
    _notifyParent();
  }

  void _notifyParent() {
    widget.onChanged(
      Set<ShapeKind>.from(_shapes),
      Set<ShapeTone>.from(_tones),
    );
  }
}

class _ShapeChoice extends StatelessWidget {
  const _ShapeChoice({
    required this.kind,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ShapeKind kind;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ChoiceCard(
      selected: selected,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(54, 54),
            painter: _ChoiceShapePainter(kind: kind),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.tone,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final ShapeTone tone;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ChoiceCard(
      selected: selected,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 132,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? brandPurple : const Color(0xFFE8E6ED),
              width: selected ? 2 : 1,
            ),
            color: selected ? const Color(0xFFFAF9FF) : Colors.white,
          ),
          child: Stack(
            children: [
              Positioned.fill(child: child),
              if (selected)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: brandPurple,
                    size: 21,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreedomNote extends StatelessWidget {
  const _FreedomNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF665C8F),
              fontSize: 12,
            ),
      ),
    );
  }
}

class _GlossySample extends StatelessWidget {
  const _GlossySample();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.4, -0.45),
          colors: [
            Colors.white,
            Color(0xFFFF9BD7),
            Color(0xFFB566F1),
          ],
          stops: [0, 0.42, 1],
        ),
      ),
    );
  }
}

class _ChoiceShapePainter extends CustomPainter {
  const _ChoiceShapePainter({required this.kind});

  final ShapeKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9B8CFF), Color(0xFF7659F6)],
      ).createShader(Offset.zero & size);

    switch (kind) {
      case ShapeKind.circle:
        canvas.drawCircle(center, size.width * 0.43, paint);
      case ShapeKind.triangle:
        final path = Path()
          ..moveTo(center.dx, size.height * 0.08)
          ..lineTo(size.width * 0.92, size.height * 0.86)
          ..lineTo(size.width * 0.08, size.height * 0.86)
          ..close();
        canvas.drawPath(path, paint);
      case ShapeKind.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center,
              width: size.width * 0.78,
              height: size.height * 0.78,
            ),
            const Radius.circular(12),
          ),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _ChoiceShapePainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}
