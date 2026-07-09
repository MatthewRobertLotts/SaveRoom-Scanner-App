import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  // Apple-like dark theme: near-black background, clean blue accents
  const seed = Color(0xFF007AFF); // iOS system blue
  const bg = Color(0xFF0A0A0A); // near-black for premium feel
  const surface = Color(0xFF121212); // slightly lighter for cards
  const surfaceVariant = Color(0xFF1E1E1E); // list items

  return ThemeData(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ).copyWith(
          surface: surface,
          surfaceContainerHighest: surfaceVariant,
          primary: const Color(0xFF007AFF), // iOS blue
          onPrimary: Colors.white,
        ),
    scaffoldBackgroundColor: bg,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: bg,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
    ).apply(bodyColor: Colors.white),
  );
}
