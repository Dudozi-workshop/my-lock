import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.badge,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 132,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? brandPurple : const Color(0xFFE8E6ED),
              width: selected ? 2 : 1,
            ),
            color: selected ? const Color(0xFFFAF9FF) : Colors.white,
          ),
          child: Stack(
            children: [
              Positioned.fill(child: child),
              if (badge != null)
                Positioned(
                  top: 9,
                  left: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: brandLavender,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: brandPurple,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              if (selected)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: brandPurple,
                    size: 21,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
