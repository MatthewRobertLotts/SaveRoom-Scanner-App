import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seed = Color(0xFF6C3BFF);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    useMaterial3: true,
  );
}
