import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

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
