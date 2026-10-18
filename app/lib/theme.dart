import 'package:flutter/material.dart';

/// Warm kirana palette: saffron primary, terracotta accent, cream surfaces,
/// dark brown text. Big type and 48 dp minimum tap targets for cheap phones.
class KmColors {
  static const saffron = Color(0xFFE8701A);
  static const terracotta = Color(0xFFC1440E);
  static const cream = Color(0xFFFFF6E9);
  static const creamDark = Color(0xFFF6E7D2);
  static const brown = Color(0xFF3E2414);
  static const brownSoft = Color(0xFF7A5540);
  static const leaf = Color(0xFF3A7D44);
  static const alert = Color(0xFFC62828);
  static const userBubble = Color(0xFFFFE0B8);
  static const botBubble = Color(0xFFFFFFFF);
}

ThemeData buildKmTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: KmColors.saffron,
    brightness: Brightness.light,
  ).copyWith(
    primary: KmColors.saffron,
    onPrimary: Colors.white,
    secondary: KmColors.terracotta,
    onSecondary: Colors.white,
    surface: KmColors.cream,
    onSurface: KmColors.brown,
    surfaceContainerHighest: KmColors.creamDark,
    error: KmColors.alert,
  );

  const body = TextStyle(fontSize: 18, height: 1.35, color: KmColors.brown);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: KmColors.cream,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: KmColors.brown),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: KmColors.brown),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: KmColors.brown),
      titleMedium: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: KmColors.brown),
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: TextStyle(fontSize: 15, color: KmColors.brownSoft),
      labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: KmColors.saffron,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 56),
        foregroundColor: KmColors.terracotta,
        side: const BorderSide(color: KmColors.terracotta, width: 1.5),
        textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: KmColors.creamDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: KmColors.creamDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: KmColors.saffron, width: 2),
      ),
      labelStyle: const TextStyle(fontSize: 18, color: KmColors.brownSoft),
      hintStyle: const TextStyle(fontSize: 18, color: Color(0xFFB09A88)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: KmColors.userBubble,
      side: const BorderSide(color: KmColors.saffron, width: 1.5),
      labelStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: KmColors.brown),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: KmColors.userBubble,
      height: 76,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: KmColors.brown),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 28,
          color: states.contains(WidgetState.selected) ? KmColors.terracotta : KmColors.brownSoft,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: KmColors.creamDark),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: KmColors.brown,
      contentTextStyle: TextStyle(fontSize: 17, color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    dividerColor: KmColors.creamDark,
  );
}
