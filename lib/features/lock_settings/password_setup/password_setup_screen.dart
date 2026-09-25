import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/models.dart';
import '../../../lock_engine/shape_painter.dart';
import 'password_setup_controller.dart';

class PasswordSetupScreen extends StatefulWidget {
  const PasswordSetupScreen({
    super.key,
    required this.selectedShapes,
    required this.selectedTones,
    this.style = ShapeStyle.softBasic,
    this.recoveryMode = false,
  });

  final Set<ShapeKind> selectedShapes;
  final Set<ShapeTone> selectedTones;
  final ShapeStyle style;
  final bool recoveryMode;

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

  List<LockToken> get _availableTokens => [
        for (final shape in ShapeKind.values)
          if (widget.selectedShapes.contains(shape))
            for (final tone in ShapeTone.values)
              if (widget.selectedTones.contains(tone))
                LockToken(shape: shape, tone: tone),
      ];

  @override
  Widget build(BuildContext context) {
    final confirming = _controller.phase == PasswordSetupPhase.confirm;
    final tokens = _availableTokens;

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.recoveryMode ? '새 비밀번호 설정' : '비밀번호',
          style: const TextStyle(fontWeight: FontWeight.w800),
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
                recoveryMode: widget.recoveryMode,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PatternSlots(
                tokens: _controller.input,
                style: widget.style,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFE9E4F3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '사용할 도형을 선택하세요',
                                style: TextStyle(
                                  color: ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              '${tokens.length}개 조합',
                              style: const TextStyle(
                                color: secondaryInk,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF0EDF4)),
                      Expanded(
                        child: _TokenSelectionGrid(
                          tokens: tokens,
                          style: widget.style,
                          onTap: _controller.addToken,
                        ),
                      ),
                    ],
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

  void _verify() {
    if (!_controller.verify()) return;
    Navigator.of(context).pop<List<LockToken>>(
      List<LockToken>.from(_controller.pattern),
    );
  }
}

class _TokenSelectionGrid extends StatelessWidget {
  const _TokenSelectionGrid({
    required this.tokens,
    required this.style,
    required this.onTap,
  });

  final List<LockToken> tokens;
  final ShapeStyle style;
  final ValueChanged<LockToken> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tokens.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 86,
        mainAxisSpacing: 9,
        crossAxisSpacing: 9,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final token = tokens[index];
        return Material(
          color: const Color(0xFFFAF9FC),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => onTap(token),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8E4EF)),
              ),
              padding: const EdgeInsets.all(8),
              child: CustomPaint(
                painter: LockTokenPainter(token, style: style),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.confirming,
    required this.count,
    required this.targetCount,
    required this.mismatch,
    required this.recoveryMode,
  });

  final bool confirming;
  final int count;
  final int? targetCount;
  final bool mismatch;
  final bool recoveryMode;

  @override
  Widget build(BuildContext context) {
    final title = confirming
        ? '같은 순서로 다시 눌러주세요.'
        : recoveryMode
            ? '새 비밀번호를 2~6개의 도형으로 설정하세요.'
            : '2~6개의 도형을 순서대로 눌러주세요.';
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
    required this.style,
    required this.slotCount,
  });

  final List<LockToken> tokens;
  final ShapeStyle style;
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
                        painter: LockTokenPainter(
                          tokens[i],
                          style: style,
                        ),
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

