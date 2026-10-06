import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/customize/background/background_style.dart';
import '../../lock_engine/models.dart';
import '../../lock_engine/shape_painter.dart';
import '../../widgets/production_ui.dart';

enum _ShopTopTab {
  recommended('추천'),
  newItems('신규'),
  collections('컬렉션'),
  limited('한정');

  const _ShopTopTab(this.label);
  final String label;
}

enum _ShopCategory {
  all('전체'),
  shape('모양'),
  color('색상'),
  background('배경'),
  motion('움직임'),
  reaction('반응');

  const _ShopCategory(this.label);
  final String label;
}

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  _ShopTopTab _tab = _ShopTopTab.recommended;
  _ShopCategory _category = _ShopCategory.all;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          ProductionScreenHeader(
            icon: Icons.storefront_rounded,
            title: '상점',
            subtitle: '새로운 모양과 분위기를 둘러보세요.',
            trailing: IconButton.filledTonal(
              tooltip: '찜',
              onPressed: _showWishlistPlaceholder,
              icon: const Icon(Icons.favorite_border_rounded),
              style: IconButton.styleFrom(
                backgroundColor: brandLavender,
                foregroundColor: brandPurple,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _TopTabs(
            selected: _tab,
            onChanged: (value) => setState(() => _tab = value),
          ),
          const SizedBox(height: 18),
          _DropHero(
            tab: _tab,
            onTap: () => _showCollectionPlaceholder('작은 바닷속'),
          ),
          const SizedBox(height: 18),
          _CategoryFilters(
            selected: _category,
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 22),
          _buildCatalog(context),
        ],
      ),
    );
  }

  Widget _buildCatalog(BuildContext context) {
    final premiumShapes =
        ShapeKind.values.where((item) => item.premium).toList();
    final premiumTones =
        ShapeTone.values.where((item) => item.directSale).toList();
    final premiumBackgrounds =
        LockBackground.values.where((item) => item.locked).toList();

    if (_tab == _ShopTopTab.collections) {
      return _CollectionSection(
        onTap: () => _showCollectionPlaceholder('작은 바닷속'),
      );
    }

    if (_tab == _ShopTopTab.limited) {
      return const _LimitedSection();
    }

    final cards = <Widget>[];

    if (_category == _ShopCategory.all || _category == _ShopCategory.shape) {
      for (final shape in premiumShapes) {
        cards.add(
          _ShopProductCard(
            title: shape.label,
            categoryLabel: '모양',
            badge: _tab == _ShopTopTab.newItems ? 'NEW' : null,
            preview: CustomPaint(
              painter: LockTokenPainter(
                LockToken(shape: shape, tone: ShapeTone.pink),
              ),
              child: const SizedBox.expand(),
            ),
            onTap: () => _showProductPlaceholder(shape.label),
          ),
        );
      }
    }

    if (_category == _ShopCategory.all || _category == _ShopCategory.color) {
      for (final tone in premiumTones) {
        cards.add(
          _ShopProductCard(
            title: tone.label,
            categoryLabel: '색상',
            badge: tone == ShapeTone.auroraSea ? 'SIGNATURE' : null,
            preview: CustomPaint(
              painter: LockTokenPainter(
                LockToken(
                  shape: tone == ShapeTone.auroraSea
                      ? ShapeKind.seaTurtle
                      : ShapeKind.circle,
                  tone: tone,
                ),
              ),
              child: const SizedBox.expand(),
            ),
            onTap: () => _showProductPlaceholder(tone.label),
          ),
        );
      }
    }

    if (_category == _ShopCategory.all ||
        _category == _ShopCategory.background) {
      for (final background in premiumBackgrounds) {
        cards.add(
          _ShopProductCard(
            title: background.label,
            categoryLabel: '배경',
            preview: DecoratedBox(
              decoration: BoxDecoration(gradient: background.gradient),
            ),
            onTap: () => _showProductPlaceholder(background.label),
          ),
        );
      }
    }

    if (_category == _ShopCategory.motion ||
        _category == _ShopCategory.reaction) {
      return _EmptyCategory(label: _category.label);
    }

    if (cards.isEmpty) {
      return _EmptyCategory(label: _category.label);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _tab == _ShopTopTab.newItems ? '새로 들어왔어요' : '추천 상품',
                style: const TextStyle(
                  color: ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
            ),
            Text(
              '${cards.length}개',
              style: const TextStyle(
                color: secondaryInk,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.82,
          children: cards,
        ),
      ],
    );
  }

  void _showWishlistPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('찜 목록은 다음 상점 상세 Gate에서 연결합니다.'),
        duration: Duration(milliseconds: 1400),
      ),
    );
  }

  void _showProductPlaceholder(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label 상세 Showcase는 다음 Gate에서 연결합니다.'),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _showCollectionPlaceholder(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label 컬렉션 상세는 다음 Gate에서 연결합니다.'),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({
    required this.selected,
    required this.onChanged,
  });

  final _ShopTopTab selected;
  final ValueChanged<_ShopTopTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFF6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (final item in _ShopTopTab.values)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(item),
                borderRadius: BorderRadius.circular(15),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item == selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: item == selected
                        ? const [
                            BoxShadow(
                              color: Color(0x147659F6),
                              blurRadius: 9,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: item == selected ? brandPurple : secondaryInk,
                      fontSize: 12,
                      fontWeight:
                          item == selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DropHero extends StatelessWidget {
  const _DropHero({
    required this.tab,
    required this.onTap,
  });

  final _ShopTopTab tab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = switch (tab) {
      _ShopTopTab.recommended => '작은 바닷속',
      _ShopTopTab.newItems => '새로운 바다 친구들',
      _ShopTopTab.collections => 'Drop 01 · 작은 바닷속',
      _ShopTopTab.limited => '시즌 한정',
    };
    final subtitle = switch (tab) {
      _ShopTopTab.recommended => '조용히 흐르는, 나만의 작은 바다.',
      _ShopTopTab.newItems => '최근 등록된 바다 아이템을 먼저 만나보세요.',
      _ShopTopTab.collections => '모양 · 색상 · 배경으로 완성하는 첫 번째 Drop.',
      _ShopTopTab.limited => '현재 시즌과 지난 컬렉션을 확인해보세요.',
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 184,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0E4E98),
                Color(0xFF1B85C8),
                Color(0xFF79D8E5),
              ],
            ),
            border: Border.all(color: const Color(0xFFDDE2F1)),
            boxShadow: productionCardShadow,
          ),
          child: Stack(
            children: [
              Positioned(
                left: -34,
                top: -54,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Positioned(
                right: -28,
                bottom: -44,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFB99AF8).withValues(alpha: 0.20),
                  ),
                ),
              ),
              const Positioned(
                right: 18,
                top: 30,
                child: _HeroShape(
                  token: LockToken(
                    shape: ShapeKind.seaTurtle,
                    tone: ShapeTone.aquaMint,
                  ),
                  size: 104,
                ),
              ),
              const Positioned(
                right: 126,
                top: 32,
                child: _HeroShape(
                  token: LockToken(
                    shape: ShapeKind.circle,
                    tone: ShapeTone.auroraSea,
                  ),
                  size: 46,
                ),
              ),
              const Positioned(
                right: 114,
                bottom: 18,
                child: _HeroShape(
                  token: LockToken(
                    shape: ShapeKind.triangle,
                    tone: ShapeTone.coralPink,
                  ),
                  size: 42,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroBadge(label: 'DROP 01'),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.45,
                        shadows: [
                          Shadow(color: Color(0x33000000), blurRadius: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 210,
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontSize: 11.5,
                          height: 1.28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 14,
                top: 14,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.26),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
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

class _HeroShape extends StatelessWidget {
  const _HeroShape({
    required this.token,
    required this.size,
  });

  final LockToken token;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: LockTokenPainter(token),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: brandPurple,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.selected,
    required this.onChanged,
  });

  final _ShopCategory selected;
  final ValueChanged<_ShopCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _ShopCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _ShopCategory.values[index];
          final active = item == selected;
          return InkWell(
            onTap: () => onChanged(item),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 62,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: active ? brandPurple : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? brandPurple : productionBorder,
                ),
                boxShadow: active ? productionCardShadow : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _categoryIcon(item),
                    size: 20,
                    color: active ? Colors.white : _categoryColor(item),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: active ? Colors.white : secondaryInk,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

IconData _categoryIcon(_ShopCategory category) {
  switch (category) {
    case _ShopCategory.all:
      return Icons.auto_awesome_rounded;
    case _ShopCategory.shape:
      return Icons.category_rounded;
    case _ShopCategory.color:
      return Icons.circle_rounded;
    case _ShopCategory.background:
      return Icons.landscape_rounded;
    case _ShopCategory.motion:
      return Icons.waves_rounded;
    case _ShopCategory.reaction:
      return Icons.favorite_rounded;
  }
}

Color _categoryColor(_ShopCategory category) {
  switch (category) {
    case _ShopCategory.all:
      return brandPurple;
    case _ShopCategory.shape:
      return const Color(0xFF34A6A1);
    case _ShopCategory.color:
      return const Color(0xFF5C9CF3);
    case _ShopCategory.background:
      return const Color(0xFF6B8FCB);
    case _ShopCategory.motion:
      return const Color(0xFF38A9D6);
    case _ShopCategory.reaction:
      return const Color(0xFFE06AA5);
  }
}

class _ShopProductCard extends StatefulWidget {
  const _ShopProductCard({
    required this.title,
    required this.categoryLabel,
    required this.preview,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String categoryLabel;
  final Widget preview;
  final VoidCallback onTap;
  final String? badge;

  @override
  State<_ShopProductCard> createState() => _ShopProductCardState();
}

class _ShopProductCardState extends State<_ShopProductCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: productionBorder),
            boxShadow: productionCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F6FB),
                        ),
                        child: widget.preview,
                      ),
                      if (widget.badge != null)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: _CardBadge(label: widget.badge!),
                        ),
                      Positioned(
                        right: 7,
                        top: 7,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setState(() => _liked = !_liked),
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(
                                _liked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 18,
                                color: _liked
                                    ? const Color(0xFFE45C9D)
                                    : secondaryInk,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ink,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.categoryLabel,
                style: const TextStyle(
                  color: secondaryInk,
                  fontSize: 10,
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

class _CardBadge extends StatelessWidget {
  const _CardBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: brandLavender,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: brandPurple,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CollectionSection extends StatelessWidget {
  const _CollectionSection({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '컬렉션',
          style: TextStyle(
            color: ink,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: productionBorder),
                boxShadow: productionCardShadow,
              ),
              child: const Row(
                children: [
                  _CollectionIcon(),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '작은 바닷속',
                          style: TextStyle(
                            color: ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Shape · Color · Background',
                          style: TextStyle(
                            color: secondaryInk,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFA6A2B0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionIcon extends StatelessWidget {
  const _CollectionIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFBDEBFF),
            Color(0xFF86B6FF),
            Color(0xFFD6A7FF),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.water_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _LimitedSection extends StatelessWidget {
  const _LimitedSection();

  @override
  Widget build(BuildContext context) {
    return ProductionSoftCard(
      child: Column(
        children: [
          const Icon(
            Icons.event_available_rounded,
            color: brandPurple,
            size: 30,
          ),
          const SizedBox(height: 10),
          const Text(
            '현재 진행 중인 한정 상품이 없어요',
            style: TextStyle(
              color: ink,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('지난 컬렉션 아카이브는 다음 Gate에서 연결합니다.'),
                ),
              );
            },
            child: const Text('지난 컬렉션 보기'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ProductionSoftCard(
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: secondaryInk,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            '$label 상품은 준비 중이에요',
            style: const TextStyle(
              color: ink,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '실제 등록된 상품만 순차적으로 표시합니다.',
            style: TextStyle(
              color: secondaryInk,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
