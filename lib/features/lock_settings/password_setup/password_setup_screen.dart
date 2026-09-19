import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/floating_preview.dart';
import '../../../lock_engine/models.dart';
import 'password_setup_controller.dart';

class PasswordSetupScreen extends StatefulWidget {
  const PasswordSetupScreen({
    super.key,
    required this.selectedShapes,
    required this.selectedTones,
  });

  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  late final PasswordSetupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PasswordSetupController()..addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confirming = _controller.phase == PasswordSetupPhase.confirm;

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '비밀번호',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _Header(
                confirming: confirming,
                count: _controller.input.length,
                targetCount: confirming ? _controller.pattern.length : null,
                mismatch: _controller.mismatch,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PatternSlots(
                tokens: _controller.input,
                slotCount: confirming
                    ? _controller.pattern.length
                    : PasswordSetupController.maxLength,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                  child: FloatingPreview(
                    selectedShapes: widget.selectedShapes,
                    selectedTones: widget.selectedTones,
                    objectCount: _setupObjectCount,
                    onTokenTap: _controller.addToken,
                    requiredTokens: _requiredSetupTokens(confirming),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _controller.input.isEmpty
                            ? null
                            : _controller.removeLast,
                        icon: const Icon(Icons.undo_rounded, size: 18),
                        label: const Text('하나 지우기'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _controller.input.isEmpty
                            ? null
                            : _controller.clearInput,
                        child: const Text('전체 지우기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: brandPurple,
                      disabledBackgroundColor: const Color(0xFFD8D3EB),
                    ),
                    onPressed: confirming
                        ? (_controller.canVerify ? _verify : null)
                        : (_controller.canContinue
                            ? _controller.startConfirm
                            : null),
                    child: Text(confirming ? '확인' : '다음'),
                  ),
                  if (confirming) ...[
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _controller.restart,
                      child: const Text('처음부터 다시 설정'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _setupObjectCount {
    final combinationCount =
        widget.selectedShapes.length * widget.selectedTones.length;
    final requiredCapacity = combinationCount + 2;

    if (requiredCapacity <= 6) return 6;
    if (requiredCapacity <= 9) return 9;
    return 12;
  }

  List<LockToken> _requiredSetupTokens(bool confirming) {
    final tokens = <LockToken>[
      for (final tone in ShapeTone.values)
        if (widget.selectedTones.contains(tone))
          for (final shape in ShapeKind.values)
            if (widget.selectedShapes.contains(shape))
              LockToken(shape: shape, tone: tone),
    ];

    if (confirming) {
      tokens.addAll(
        _controller.pattern.skip(_controller.input.length).take(2),
      );
    }

    return tokens;
  }

  void _verify() {
    if (!_controller.verify()) return;
    Navigator.of(context).pop<List<LockToken>>(
      List<LockToken>.from(_controller.pattern),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.confirming,
    required this.count,
    required this.targetCount,
    required this.mismatch,
  });

  final bool confirming;
  final int count;
  final int? targetCount;
  final bool mismatch;

  @override
  Widget build(BuildContext context) {
    final title = confirming
        ? '같은 순서로 다시 눌러주세요.'
        : '3~6개의 도형을 순서대로 눌러주세요.';
    final helper = confirming
        ? '$count / ${targetCount ?? 0}'
        : '$count / ${PasswordSetupController.maxLength} · 최소 ${PasswordSetupController.minLength}개';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          mismatch ? '일치하지 않습니다. 다시 입력하세요.' : helper,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: mismatch ? const Color(0xFFD94262) : secondaryInk,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _PatternSlots extends StatelessWidget {
  const _PatternSlots({
    required this.tokens,
    required this.slotCount,
  });

  final List<LockToken> tokens;
  final int slotCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < slotCount; i++) ...[
          if (i > 0) const SizedBox(width: 7),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                decoration: BoxDecoration(
                  color: i < tokens.length
                      ? Colors.white
                      : const Color(0xFFF0EFF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: i < tokens.length
                        ? brandPurple.withValues(alpha: 0.45)
                        : const Color(0xFFE2E0E7),
                  ),
                ),
                child: i < tokens.length
                    ? CustomPaint(
                        painter: _TokenPainter(tokens[i]),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TokenPainter extends CustomPainter {
  const _TokenPainter(this.token);

  final LockToken token;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.25;
    final paint = Paint()..color = _color(token.tone);

    switch (token.shape) {
      case ShapeKind.circle:
        canvas.drawCircle(center, radius, paint);
        break;
      case ShapeKind.triangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy + radius * 0.85)
          ..lineTo(center.dx - radius, center.dy + radius * 0.85)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ShapeKind.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center,
              width: radius * 1.65,
              height: radius * 1.65,
            ),
            Radius.circular(radius * 0.3),
          ),
          paint,
        );
        break;
    }
  }

  Color _color(ShapeTone tone) {
    switch (tone) {
      case ShapeTone.pink:
        return const Color(0xFFE656AB);
      case ShapeTone.blue:
        return const Color(0xFF3F6FEA);
      case ShapeTone.yellow:
        return const Color(0xFFF0A632);
    }
  }

  @override
  bool shouldRepaint(covariant _TokenPainter oldDelegate) {
    return oldDelegate.token.id != token.id;
  }
}
