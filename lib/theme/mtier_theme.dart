import 'package:flutter/material.dart';

/// M-TIER design tokens and Material 3 themes.
class MTierTheme {
  MTierTheme._();

  static const Color accent = Color(0xFFC8F169);
  static const Color darkBackground = Color(0xFF0B1110);
  static const Color darkSurface = Color(0xFF141D1A);
  static const Color lightBackground = Color(0xFFF5F7F1);

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accent,
      onPrimary: const Color(0xFF17210B),
      secondary: const Color(0xFF9ED8C1),
      surface: darkSurface,
      onSurface: const Color(0xFFF0F4EE),
      surfaceContainerHighest: const Color(0xFF202B26),
      outline: const Color(0xFF64736A),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: Color(0xFFF0F4EE),
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF35433B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: Color(0xFF34442A),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF35433B)),
    );
  }

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6D8E2D),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF49651A),
      onPrimary: Colors.white,
      secondary: const Color(0xFF276B58),
      surface: Colors.white,
      onSurface: const Color(0xFF17211C),
      surfaceContainerHighest: const Color(0xFFE9EEE5),
      outline: const Color(0xFF737E75),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF10243A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD5DDD2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6D8E2D), width: 1.5),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFE3EDCF),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFD5DDD2)),
    );
  }
}
