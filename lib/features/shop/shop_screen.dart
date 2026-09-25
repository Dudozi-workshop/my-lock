import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/customize/background/background_style.dart';
import '../../lock_engine/models.dart';
import '../../lock_engine/shape_painter.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premiumShapes =
        ShapeKind.values.where((item) => item.premium).toList();
    final premiumTones =
        ShapeTone.values.where((item) => item.premium).toList();
    final premiumStyles =
        ShapeStyle.values.where((item) => item.premium).toList();
    final premiumBackgrounds =
        LockBackground.values.where((item) => item.locked).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        children: [
          Text('상점', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'PLUS 스타일 카탈로그',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          const _EconomyNotice(),
          const SizedBox(height: 24),
          _SectionTitle(
            title: '도형',
            count: premiumShapes.length,
          ),
          const SizedBox(height: 10),
          _CatalogGrid(
            children: [
              for (final shape in premiumShapes)
                _PreviewCard(
                  label: shape.label,
                  child: CustomPaint(
                    painter: LockTokenPainter(
                      LockToken(
                        shape: shape,
                        tone: ShapeTone.purple,
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(
            title: '색상',
            count: premiumTones.length,
          ),
          const SizedBox(height: 10),
          _CatalogGrid(
            children: [
              for (final tone in premiumTones)
                _PreviewCard(
                  label: tone.label,
                  child: CustomPaint(
                    painter: LockTokenPainter(
                      LockToken(
                        shape: ShapeKind.circle,
                        tone: tone,
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(
            title: '질감',
            count: premiumStyles.length,
          ),
          const SizedBox(height: 10),
          _CatalogGrid(
            children: [
              for (final style in premiumStyles)
                _PreviewCard(
                  label: style.label,
                  child: CustomPaint(
                    painter: LockTokenPainter(
                      const LockToken(
                        shape: ShapeKind.circle,
                        tone: ShapeTone.pink,
                      ),
                      style: style,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(
            title: '배경',
            count: premiumBackgrounds.length,
          ),
          const SizedBox(height: 10),
          _CatalogGrid(
            children: [
              for (final background in premiumBackgrounds)
                _PreviewCard(
                  label: background.label,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: background.gradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            '현재 개발 버전에서는 커스터마이즈 화면에서 PLUS 항목을 직접 적용해 테스트할 수 있습니다. 키샤드 잔액·가격·구매·소유권은 상점 경제 시스템 구현 시 연결됩니다.',
            style: TextStyle(
              color: secondaryInk,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _EconomyNotice extends StatelessWidget {
  const _EconomyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEDE7FF),
            Color(0xFFFFEAF7),
            Color(0xFFE8F4FF),
          ],
        ),
        border: Border.all(color: const Color(0xFFDCD3FF)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.key_rounded,
            color: brandPurple,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KEY SHARD · 키샤드',
                  style: TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '화폐·가격·구매 기능은 다음 상점 단계에서 연결',
                  style: TextStyle(
                    color: secondaryInk,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        '준비 중',
        style: TextStyle(
          color: brandPurple,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Text(
          '$count개',
          style: const TextStyle(
            color: secondaryInk,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CatalogGrid extends StatelessWidget {
  const _CatalogGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.82,
      children: children,
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E6ED)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: child),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: brandLavender,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'PLUS',
                      style: TextStyle(
                        color: brandPurple,
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ink,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
