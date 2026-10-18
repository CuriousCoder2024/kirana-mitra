import 'package:flutter/material.dart';

/// Warm kirana palette. Colour values follow docs/design/handoff.md §1 so the
/// design-v2 tokens (lib/theme/tokens.dart on the app branch) can replace this
/// file without a visible jump.
abstract final class KmColors {
  static const saffron = Color(0xFFC85A0E);
  static const terracotta = Color(0xFFA83E12);
  static const cream = Color(0xFFFBF1E2);
  static const creamDark = Color(0xFFEBDAC1);
  static const brown = Color(0xFF2A1A10);
  static const brownSoft = Color(0xFF6E5240);
  static const leaf = Color(0xFF2F7A4B);
  static const alert = Color(0xFFB3261E);
  static const userBubble = Color(0xFFFFE6CC);
  static const botBubble = Color(0xFFFFFCF7);
}

/// Material 3 theme: cream scaffold, saffron seed, 18 sp body, 48 dp+ targets.
ThemeData buildKmTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: KmColors.saffron,
    primary: KmColors.saffron,
    secondary: KmColors.terracotta,
    surface: KmColors.cream,
    error: KmColors.alert,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final text = base.textTheme.apply(
    bodyColor: KmColors.brown,
    displayColor: KmColors.brown,
  );
  return base.copyWith(
    scaffoldBackgroundColor: KmColors.cream,
    textTheme: text.copyWith(
      displaySmall: text.displaySmall?.copyWith(fontWeight: FontWeight.w800),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 18),
      bodySmall: text.bodySmall?.copyWith(color: KmColors.brownSoft, fontSize: 14),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: KmColors.cream,
      foregroundColor: KmColors.brown,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: KmColors.creamDark, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: KmColors.creamDark, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: KmColors.saffron, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: KmColors.botBubble,
      indicatorColor: KmColors.userBubble,
      height: 72,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      side: const BorderSide(color: KmColors.creamDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    cardTheme: CardThemeData(
      color: KmColors.botBubble,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: KmColors.creamDark),
      ),
    ),
  );
}
