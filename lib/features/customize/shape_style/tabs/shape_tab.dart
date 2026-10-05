import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../lock_engine/models.dart';
import '../widgets/catalog_ui.dart';
import '../widgets/shape_choice_card.dart';

class ShapeTab extends StatefulWidget {
  const ShapeTab({
    super.key,
    required this.selectedShapes,
    required this.onToggle,
    required this.onMinimumSelectionBlocked,
  });

  final Set<ShapeKind> selectedShapes;
  final ValueChanged<ShapeKind> onToggle;
  final VoidCallback onMinimumSelectionBlocked;

  @override
  State<ShapeTab> createState() => _ShapeTabState();
}

class _ShapeTabState extends State<ShapeTab> {
  CatalogFilterState _filter = const CatalogFilterState();
  bool _focusSmallSea = false;

  static const _collectionId = 'small_sea';

  bool get _showCollection =>
      _filter.composition != CatalogCompositionFilter.standalone &&
      (_filter.collectionId == null || _filter.collectionId == _collectionId);

  bool get _showStandalone =>
      _filter.collectionId == null &&
      _filter.composition != CatalogCompositionFilter.collection;

  void _toggle(ShapeKind kind) {
    if (widget.selectedShapes.contains(kind) &&
        widget.selectedShapes.length == 1) {
      widget.onMinimumSelectionBlocked();
      return;
    }
    widget.onToggle(kind);
  }

  @override
  Widget build(BuildContext context) {
    final summary = <String>[
      if (_filter.composition == CatalogCompositionFilter.collection) '컬렉션',
      if (_filter.composition == CatalogCompositionFilter.standalone) '개별',
      if (_filter.collectionId == _collectionId) '작은 바닷속',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '전체 모양',
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
            title: '작은 바닷속',
            subtitle: '포근한 바다 속 친구들',
            accentColor: const Color(0xFF89DDF1),
            onBack: () => setState(() => _focusSmallSea = false),
          ),
          _shapeGrid([ShapeKind.seaTurtle]),
        ] else ...[
          if (_showCollection) ...[
            CollectionSectionCard(
              title: '작은 바닷속',
              subtitle: '포근한 바다 속 친구들',
              headerColor: const Color(0xFF89DDF1),
              onHeaderTap: () => setState(() => _focusSmallSea = true),
              child: _shapeGrid([ShapeKind.seaTurtle]),
            ),
            const SizedBox(height: 18),
          ],
          if (_showStandalone) ...[
            const Text(
              '개별 모양',
              style: TextStyle(
                color: ink,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            _shapeGrid(
              const [
                ShapeKind.circle,
                ShapeKind.triangle,
                ShapeKind.square,
              ],
            ),
          ],
        ],
      ],
    );
  }

  Widget _shapeGrid(List<ShapeKind> items) {
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
        final kind = items[index];
        return ShapeChoiceCard(
          kind: kind,
          label: kind.label,
          selected: widget.selectedShapes.contains(kind),
          onTap: () => _toggle(kind),
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
        (_collectionId, '작은 바닷속', Icons.waves_rounded),
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
