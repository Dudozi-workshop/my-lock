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
              '\${cards.length}개',
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
          childAspectRatio: 0.88,
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
      _ShopTopTab.recommended => 'Shape · Color · Background를 한 세계관으로',
      _ShopTopTab.newItems => '최근 추가된 상품을 먼저 만나보세요',
      _ShopTopTab.collections => '모을수록 완성되는 첫 번째 컬렉션',
      _ShopTopTab.limited => '기간이 끝난 컬렉션은 아카이브에서 확인',
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 164,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8F8FF),
                Color(0xFFDDEEFF),
                Color(0xFFEDE6FF),
              ],
            ),
            border: Border.all(color: const Color(0xFFDDE2F1)),
            boxShadow: productionCardShadow,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -14,
                child: Icon(
                  Icons.water_rounded,
                  size: 126,
                  color: Colors.white.withValues(alpha: 0.66),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeroBadge(label: 'DROP 01'),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    style: const TextStyle(
                      color: secondaryInk,
                      fontSize: 11.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Positioned(
                right: 4,
                top: 4,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: brandPurple,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
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
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _ShopCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _ShopCategory.values[index];
          final active = item == selected;
          return ChoiceChip(
            label: Text(item.label),
            selected: active,
            onSelected: (_) => onChanged(item),
            showCheckmark: false,
            selectedColor: brandPurple,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: active ? brandPurple : productionBorder,
            ),
            labelStyle: TextStyle(
              color: active ? Colors.white : secondaryInk,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
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

class _ShopProductCard extends StatefulWidget {
  const _ShopProductCard({
    required this.title,
    required this.preview,
    required this.onTap,
    this.badge,
  });

  final String title;
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
              const Text(
                '상품 보기',
                style: TextStyle(
                  color: secondaryInk,
                  fontSize: 10,
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
