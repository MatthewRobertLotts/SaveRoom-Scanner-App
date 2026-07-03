import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seed = Color(0xFF7C4DFF);
  const bg = Color(0xFF0C1018);
  return ThemeData(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF141A24),
          surfaceContainerHighest: const Color(0xFF202838),
        ),
    scaffoldBackgroundColor: bg,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: false, backgroundColor: bg),
    cardTheme: CardThemeData(
      color: const Color(0xFF141A24),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
