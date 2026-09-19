import 'package:flutter/material.dart';

import '../../app/theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        children: [
          Text('상점', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('새로운 스타일은 다음 단계에서 연결합니다.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 22),
          Container(
            height: 220,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFFEDE7FF), Color(0xFFFFEAF7), Color(0xFFE8F4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('GALAXY PACK', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: ink)),
                SizedBox(height: 6),
                Text('테마팩 UI 자리', style: TextStyle(color: secondaryInk)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PlaceholderRow(title: '인기 아이템'),
          const SizedBox(height: 14),
          _PlaceholderRow(title: '새로운 아이템'),
        ],
      ),
    );
  }
}

class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                height: 112,
                margin: EdgeInsets.only(right: index == 2 ? 0 : 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFEDEBF2)),
                ),
                child: Center(
                  child: Icon(
                    [Icons.favorite_rounded, Icons.star_rounded, Icons.blur_on_rounded][index],
                    color: [const Color(0xFFFF81C7), brandPurple, const Color(0xFF60A8FF)][index],
                    size: 38,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
