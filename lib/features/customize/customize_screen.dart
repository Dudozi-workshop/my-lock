import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../lock_engine/floating_preview.dart';
import '../../widgets/customization_card.dart';

class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final previewHeight =
              (constraints.maxHeight * 0.48).clamp(300.0, 440.0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MY LOCK', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  '나만의 잠금화면을 꾸며보세요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Container(
                  height: previewHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFF3FB),
                        Color(0xFFF3F0FF),
                        Color(0xFFEAF5FF),
                      ],
                    ),
                    border: Border.all(color: const Color(0xFFE9E4F3)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x173F2E83),
                        blurRadius: 28,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Positioned.fill(child: FloatingPreview()),
                      Positioned(
                        top: 18,
                        right: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: brandPurple,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        bottom: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            '도형을 눌러보세요',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF615D6A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomizationCard(
                  icon: Icons.wallpaper_rounded,
                  title: '배경',
                  subtitle: 'Soft Gradient',
                  onTap: () => _showPrototypeSheet(context, '배경'),
                ),
                const SizedBox(height: 10),
                CustomizationCard(
                  icon: Icons.category_rounded,
                  title: '도형 & 스타일',
                  subtitle: '원 · 세모 · 네모 / 핑크 · 블루 · 옐로우',
                  onTap: () => _showPrototypeSheet(context, '도형 & 스타일'),
                ),
                const SizedBox(height: 10),
                CustomizationCard(
                  icon: Icons.auto_fix_high_rounded,
                  title: '효과',
                  subtitle: 'Floating · Basic Pop',
                  onTap: () => _showPrototypeSheet(context, '효과'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPrototypeSheet(BuildContext context, String title) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(
                  '다음 단계에서 이 패널에 실제 선택 기능을 연결합니다.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: brandPurple,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
