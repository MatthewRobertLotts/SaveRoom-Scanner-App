import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

const saveRoomOrange = Color(0xFFF5AB00);
const saveRoomBackground = Color(0xFF0D0D0D);
const saveRoomSurface = Color(0xFF3E3E3E);
const saveRoomRaisedSurface = Color(0xFF4D4D4D);

@immutable
class SaveRoomTokens extends ThemeExtension<SaveRoomTokens> {
  const SaveRoomTokens({
    required this.glassFill,
    required this.glassStrong,
    required this.glassBorder,
    required this.orangeGlow,
    required this.positive,
    required this.warning,
  });

  final Color glassFill;
  final Color glassStrong;
  final Color glassBorder;
  final Color orangeGlow;
  final Color positive;
  final Color warning;

  static const dark = SaveRoomTokens(
    glassFill: Color(0xFF3E3E3E),
    glassStrong: Color(0xFF4D4D4D),
    glassBorder: Color(0x55F5AB00),
    orangeGlow: Color(0x00F5AB00),
    positive: Color(0xFF56D68B),
    warning: Color(0xFFFFB34D),
  );

  @override
  SaveRoomTokens copyWith({
    Color? glassFill,
    Color? glassStrong,
    Color? glassBorder,
    Color? orangeGlow,
    Color? positive,
    Color? warning,
  }) => SaveRoomTokens(
    glassFill: glassFill ?? this.glassFill,
    glassStrong: glassStrong ?? this.glassStrong,
    glassBorder: glassBorder ?? this.glassBorder,
    orangeGlow: orangeGlow ?? this.orangeGlow,
    positive: positive ?? this.positive,
    warning: warning ?? this.warning,
  );

  @override
  SaveRoomTokens lerp(covariant SaveRoomTokens? other, double t) {
    if (other == null) return this;
    return SaveRoomTokens(
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassStrong: Color.lerp(glassStrong, other.glassStrong, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      orangeGlow: Color.lerp(orangeGlow, other.orangeGlow, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: saveRoomOrange,
    onPrimary: Color(0xFF1A1200),
    primaryContainer: Color(0xFF5A3F00),
    onPrimaryContainer: Color(0xFFFFEFC7),
    secondary: Color(0xFFFFD900),
    onSecondary: Color(0xFF1A1600),
    secondaryContainer: Color(0xFF5A4C00),
    onSecondaryContainer: Color(0xFFFFF3BF),
    tertiary: Color(0xFFFFDE8C),
    onTertiary: Color(0xFF2D2000),
    error: Color(0xFFFF716C),
    onError: Color(0xFF2B0504),
    surface: saveRoomSurface,
    onSurface: Color(0xFFFFFFFF),
    surfaceContainerHighest: saveRoomRaisedSurface,
    onSurfaceVariant: Color(0xFFC8C8C8),
    outline: Color(0xFF555555),
    outlineVariant: Color(0xFF404040),
  );

  final base = FlexThemeData.dark(
    colorScheme: scheme,
    useMaterial3: true,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 0,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      defaultRadius: 14,
      cardRadius: 18,
      filledButtonRadius: 14,
      inputDecoratorRadius: 16,
      chipRadius: 12,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: saveRoomBackground,
    splashColor: saveRoomOrange.withValues(alpha: 0.14),
    highlightColor: saveRoomOrange.withValues(alpha: 0.08),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: SaveRoomTokens.dark.glassFill,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0x55F5AB00)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: const Color(0xFF1A1200),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SaveRoomTokens.dark.glassFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF555555)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF555555)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: saveRoomOrange, width: 1.4),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: SaveRoomTokens.dark.glassFill,
      surfaceTintColor: Colors.transparent,
      indicatorColor: saveRoomOrange.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? saveRoomOrange
              : scheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textTheme: base.textTheme.copyWith(
      headlineLarge: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: const TextStyle(color: Color(0xFFF0F0F2), fontSize: 16),
      bodyMedium: const TextStyle(color: Color(0xFFC8C8C8), fontSize: 14),
    ),
    extensions: const [SaveRoomTokens.dark],
  );
}

extension SaveRoomTheme on BuildContext {
  SaveRoomTokens get saveRoomTokens =>
      Theme.of(this).extension<SaveRoomTokens>() ?? SaveRoomTokens.dark;
}
