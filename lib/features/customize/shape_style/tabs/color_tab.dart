import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../lock_engine/models.dart';
import '../widgets/catalog_ui.dart';
import '../widgets/color_choice_card.dart';

class ColorTab extends StatefulWidget {
  const ColorTab({
    super.key,
    required this.selectedTones,
    required this.onToggle,
    required this.onMinimumSelectionBlocked,
  });

  final Set<ShapeTone> selectedTones;
  final ValueChanged<ShapeTone> onToggle;
  final VoidCallback onMinimumSelectionBlocked;

  @override
  State<ColorTab> createState() => _ColorTabState();
}

class _ColorTabState extends State<ColorTab> {
  CatalogFilterState _filter = const CatalogFilterState();
  bool _focusSmallSea = false;

  static const _collectionId = 'small_sea_palette';

  static const _collectionTones = [
    ShapeTone.deepOcean,
    ShapeTone.aquaMint,
    ShapeTone.coralPink,
    ShapeTone.sandBeige,
    ShapeTone.lavender,
    ShapeTone.peachOrange,
    ShapeTone.auroraSea,
  ];

  static const _standaloneTones = [
    ShapeTone.pink,
    ShapeTone.blue,
    ShapeTone.yellow,
  ];

  bool get _showCollection =>
      _filter.composition != CatalogCompositionFilter.standalone &&
      (_filter.collectionId == null || _filter.collectionId == _collectionId);

  bool get _showStandalone =>
      _filter.collectionId == null &&
      _filter.composition != CatalogCompositionFilter.collection;

  void _toggle(ShapeTone tone) {
    if (widget.selectedTones.contains(tone) &&
        widget.selectedTones.length == 1) {
      widget.onMinimumSelectionBlocked();
      return;
    }
    widget.onToggle(tone);
  }

  @override
  Widget build(BuildContext context) {
    final summary = <String>[
      if (_filter.composition == CatalogCompositionFilter.collection) '컬렉션',
      if (_filter.composition == CatalogCompositionFilter.standalone) '개별',
      if (_filter.collectionId == _collectionId) '작은 바닷속 팔레트',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '전체 색상',
                style: TextStyle(
                  color: ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            CatalogFilterButton(
              activeCount: _filter.activeCount,
              onTap: _openFilter,
            ),
          ],
        ),
        const SizedBox(height: 10),
        CatalogAppliedSummary(
          labels: summary,
          onClear: () {
            setState(() {
              _filter = const CatalogFilterState();
              _focusSmallSea = false;
            });
          },
        ),
        if (_focusSmallSea) ...[
          CollectionFocusCard(
            title: '작은 바닷속 팔레트',
            subtitle: '바다에서 영감을 받은 색 조합',
            accentColor: const Color(0xFFAFDDFB),
            onBack: () => setState(() => _focusSmallSea = false),
          ),
          _colorGrid(_collectionTones),
        ] else ...[
          if (_showCollection) ...[
            CollectionSectionCard(
              title: '작은 바닷속 팔레트',
              subtitle: '바다에서 영감을 받은 색 조합',
              headerColor: const Color(0xFFAFDDFB),
              onHeaderTap: () => setState(() => _focusSmallSea = true),
              child: _colorGrid(_collectionTones),
            ),
            const SizedBox(height: 18),
          ],
          if (_showStandalone) ...[
            const Text(
              '개별 색상',
              style: TextStyle(
                color: ink,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            _colorGrid(_standaloneTones),
          ],
        ],
      ],
    );
  }

  Widget _colorGrid(List<ShapeTone> items) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final tone = items[index];
        return ColorChoiceCard(
          tone: tone,
          label: tone.label,
          selected: widget.selectedTones.contains(tone),
          onTap: () => _toggle(tone),
        );
      },
    );
  }

  Future<void> _openFilter() async {
    await showCatalogFilterSheet(
      context: context,
      selectedCollectionId: _filter.collectionId,
      composition: _filter.composition,
      collections: const [
        (_collectionId, '작은 바닷속 팔레트', Icons.water_drop_rounded),
      ],
      onChanged: (next) {
        if (!mounted) return;
        setState(() {
          _filter = next;
          if (next.collectionId != _collectionId) {
            _focusSmallSea = false;
          }
        });
      },
    );
  }
}
