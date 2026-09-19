import 'package:flutter/material.dart';

class FreedomNote extends StatelessWidget {
  const FreedomNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF665C8F),
              fontSize: 12,
            ),
      ),
    );
  }
}
