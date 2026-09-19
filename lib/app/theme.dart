import 'package:flutter/material.dart';

const Color brandPurple = Color(0xFF7659F6);
const Color brandLavender = Color(0xFFF1EDFF);
const Color appBackground = Color(0xFFF8F8FC);
const Color ink = Color(0xFF1C1A25);
const Color secondaryInk = Color(0xFF777480);

ThemeData buildMyLockTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: brandPurple,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: appBackground,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: secondaryInk,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 70,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.96),
      indicatorColor: brandLavender,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? brandPurple : secondaryInk,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? brandPurple : const Color(0xFF8F8C98),
          size: 23,
        );
      }),
    ),
  );
}
