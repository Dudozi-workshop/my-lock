import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

enum CatalogCompositionFilter { all, collection, standalone }

class CatalogFilterState {
  const CatalogFilterState({
    this.composition = CatalogCompositionFilter.all,
    this.collectionId,
  });

  final CatalogCompositionFilter composition;
  final String? collectionId;

  int get activeCount =>
      (composition == CatalogCompositionFilter.all ? 0 : 1) +
      (collectionId == null ? 0 : 1);

  CatalogFilterState copyWith({
    CatalogCompositionFilter? composition,
    String? collectionId,
    bool clearCollection = false,
  }) {
    return CatalogFilterState(
      composition: composition ?? this.composition,
      collectionId: clearCollection ? null : collectionId ?? this.collectionId,
    );
  }

  CatalogFilterState reset() => const CatalogFilterState();
}

class CatalogFilterButton extends StatelessWidget {
  const CatalogFilterButton({
    super.key,
    required this.activeCount,
    required this.onTap,
  });

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.tune_rounded, size: 17),
      label: Text(activeCount == 0 ? '필터' : '필터 $activeCount'),
      style: OutlinedButton.styleFrom(
        foregroundColor: brandPurple,
        side: const BorderSide(color: Color(0xFFE2DCF8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class CatalogAppliedSummary extends StatelessWidget {
  const CatalogAppliedSummary({
    super.key,
    required this.labels,
    required this.onClear,
  });

  final List<String> labels;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    final label = labels.length <= 2 ? labels.join(' · ') : '필터 ${labels.length}';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(11, 7, 7, 7),
        decoration: BoxDecoration(
          color: brandLavender,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: brandPurple,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onClear,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: brandPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionSectionCard extends StatelessWidget {
  const CollectionSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.headerColor,
    this.progressLabel,
    this.onHeaderTap,
    this.completed = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Color headerColor;
  final String? progressLabel;
  final VoidCallback? onHeaderTap;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: completed ? null : Colors.white,
        gradient: completed
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  headerColor.withValues(alpha: 0.92),
                  Colors.white,
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: completed
              ? headerColor.withValues(alpha: 0.55)
              : const Color(0xFFEDEAF2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: headerColor.withValues(alpha: completed ? 0.22 : 0.15),
            child: InkWell(
              onTap: onHeaderTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 11, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        completed
                            ? Icons.auto_awesome_rounded
                            : Icons.collections_bookmark_rounded,
                        color: brandPurple,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: secondaryInk,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (progressLabel != null)
                      Text(
                        progressLabel!,
                        style: const TextStyle(
                          color: brandPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    if (onHeaderTap != null) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFFA6A2B0),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class CollectionFocusCard extends StatelessWidget {
  const CollectionFocusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onBack,
    this.progressLabel,
    this.completed = false,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onBack;
  final String? progressLabel;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: completed
              ? [
                  accentColor.withValues(alpha: 0.30),
                  const Color(0xFFF3F0FF),
                  Colors.white,
                ]
              : [
                  accentColor.withValues(alpha: 0.17),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: completed ? 0.50 : 0.24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
            visualDensity: VisualDensity.compact,
            tooltip: '전체로 돌아가기',
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              completed ? Icons.auto_awesome_rounded : Icons.waves_rounded,
              color: brandPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: secondaryInk,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (progressLabel != null)
            Text(
              progressLabel!,
              style: const TextStyle(
                color: brandPurple,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> showCatalogFilterSheet({
  required BuildContext context,
  required String? selectedCollectionId,
  required CatalogCompositionFilter composition,
  required ValueChanged<CatalogFilterState> onChanged,
  required List<(String id, String label, IconData icon)> collections,
}) async {
  var draft = CatalogFilterState(
    composition: composition,
    collectionId: selectedCollectionId,
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          void apply(CatalogFilterState next) {
            draft = next;
            setSheetState(() {});
            onChanged(next);
          }

          Widget choiceChip({
            required String label,
            required bool selected,
            required VoidCallback? onTap,
          }) {
            return ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: onTap == null ? null : (_) => onTap(),
              selectedColor: brandPurple,
              disabledColor: const Color(0xFFF1F0F4),
              labelStyle: TextStyle(
                color: selected ? Colors.white : secondaryInk,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            );
          }

          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D6DF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '필터',
                        style: TextStyle(
                          color: ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => apply(const CatalogFilterState()),
                      child: const Text('초기화'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '보유 상태',
                  style: TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    choiceChip(
                      label: '전체',
                      selected: true,
                      onTap: () {},
                    ),
                    choiceChip(
                      label: '보유 중',
                      selected: false,
                      onTap: null,
                    ),
                    choiceChip(
                      label: '미보유',
                      selected: false,
                      onTap: null,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  '보유 상태는 Store ownership 연동 후 사용할 수 있어요.',
                  style: TextStyle(
                    color: secondaryInk,
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '종류',
                  style: TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    choiceChip(
                      label: '전체',
                      selected:
                          draft.composition == CatalogCompositionFilter.all,
                      onTap: () => apply(
                        draft.copyWith(
                          composition: CatalogCompositionFilter.all,
                        ),
                      ),
                    ),
                    choiceChip(
                      label: '컬렉션',
                      selected: draft.composition ==
                          CatalogCompositionFilter.collection,
                      onTap: () => apply(
                        draft.copyWith(
                          composition: CatalogCompositionFilter.collection,
                        ),
                      ),
                    ),
                    choiceChip(
                      label: '개별',
                      selected: draft.composition ==
                          CatalogCompositionFilter.standalone,
                      onTap: () => apply(
                        draft.copyWith(
                          composition: CatalogCompositionFilter.standalone,
                          clearCollection: true,
                        ),
                      ),
                    ),
                  ],
                ),
                if (collections.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    '컬렉션',
                    style: TextStyle(
                      color: ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final item in collections)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: brandLavender,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.$3, color: brandPurple, size: 19),
                      ),
                      title: Text(
                        item.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: Radio<String?>(
                        value: item.$1,
                        groupValue: draft.collectionId,
                        onChanged: (_) => apply(
                          draft.copyWith(
                            composition:
                                CatalogCompositionFilter.collection,
                            collectionId: item.$1,
                          ),
                        ),
                      ),
                      onTap: () => apply(
                        draft.copyWith(
                          composition: CatalogCompositionFilter.collection,
                          collectionId: item.$1,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}
