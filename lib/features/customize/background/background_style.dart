import 'package:flutter/material.dart';

enum LockBackground {
  softGradient(
    label: 'Soft Gradient',
    colors: [
      Color(0xFFFFF3FB),
      Color(0xFFF3F0FF),
      Color(0xFFEAF5FF),
    ],
  ),
  basicLight(
    label: 'Basic Light',
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF4F3F8),
    ],
  ),
  basicDark(
    label: 'Basic Dark',
    colors: [
      Color(0xFF17151F),
      Color(0xFF302A46),
    ],
  ),
  galaxy(
    label: 'Galaxy',
    colors: [
      Color(0xFF1B1640),
      Color(0xFF5F43C7),
      Color(0xFFB675D8),
    ],
    locked: true,
  ),
  ocean(
    label: 'Ocean',
    colors: [
      Color(0xFFBDEBFF),
      Color(0xFF5DA9E9),
      Color(0xFF3566C8),
    ],
    locked: true,
  ),
  aurora(
    label: 'Aurora',
    colors: [
      Color(0xFFBDFBE8),
      Color(0xFF86B6FF),
      Color(0xFFD6A7FF),
    ],
    locked: true,
  );

  const LockBackground({
    required this.label,
    required this.colors,
    this.locked = false,
  });

  final String label;
  final List<Color> colors;
  final bool locked;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      );
}
