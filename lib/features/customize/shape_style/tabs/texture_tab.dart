import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class TextureTab extends StatelessWidget {
  const TextureTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          'MVP에서는 하나의 질감이 전체 도형에 적용됩니다.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Container(
          height: 116,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: brandPurple, width: 2),
          ),
          child: const Row(
            children: [
              _GlossySample(),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Glossy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '기본 제공 · 사용 중',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryInk,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded, color: brandPurple),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlossySample extends StatelessWidget {
  const _GlossySample();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.4, -0.45),
          colors: [
            Colors.white,
            Color(0xFFFF9BD7),
            Color(0xFFB566F1),
          ],
          stops: [0, 0.42, 1],
        ),
      ),
    );
  }
}
