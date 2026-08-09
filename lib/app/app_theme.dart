import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const saveRoomPrimary = Color(0xFFFF6E01);
const saveRoomGold = Color(0xFFFFB45C);
const saveRoomBackground = Color(0xFF0B0B0B);
const saveRoomSurface = Color(0xFF181818);
const saveRoomRaisedSurface = Color(0xFF222222);
const saveRoomMutedSurface = Color(0xFF303030);

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
    glassFill: saveRoomSurface,
    glassStrong: saveRoomRaisedSurface,
    glassBorder: Color(0x29FFFFFF),
    orangeGlow: Color(0x33FF6E01),
    positive: Color(0xFF22C55E),
    warning: saveRoomGold,
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
    primary: saveRoomPrimary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF4A2104),
    onPrimaryContainer: Color(0xFFFFD5B0),
    secondary: saveRoomGold,
    onSecondary: Color(0xFF181818),
    secondaryContainer: Color(0xFF3A2612),
    onSecondaryContainer: Color(0xFFFFE0B5),
    tertiary: Color(0xFFFFFFFF),
    onTertiary: Color(0xFF181818),
    error: Color(0xFFFF716C),
    onError: Color(0xFF2B0504),
    surface: saveRoomSurface,
    onSurface: Color(0xFFF7FAF8),
    surfaceContainerHighest: saveRoomMutedSurface,
    onSurfaceVariant: Color(0xFFB7B7B7),
    outline: Color(0xFF3A3A3A),
    outlineVariant: Color(0xFF2A2A2A),
  );

  final base = FlexThemeData.dark(
    colorScheme: scheme,
    useMaterial3: true,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 0,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      defaultRadius: 8,
      cardRadius: 12,
      filledButtonRadius: 8,
      inputDecoratorRadius: 8,
      chipRadius: 999,
    ),
  );

  final textTheme = GoogleFonts.interTightTextTheme(base.textTheme);

  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: saveRoomBackground,
    splashColor: saveRoomPrimary.withValues(alpha: 0.14),
    highlightColor: saveRoomPrimary.withValues(alpha: 0.08),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFFF7FAF8),
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
      ),
    ),
    cardTheme: CardThemeData(
      color: SaveRoomTokens.dark.glassFill,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x29FFFFFF)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        foregroundColor: Colors.white,
        backgroundColor: saveRoomPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: saveRoomBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: saveRoomPrimary, width: 1.4),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: SaveRoomTokens.dark.glassFill,
      surfaceTintColor: Colors.transparent,
      indicatorColor: saveRoomPrimary.withValues(alpha: 0.14),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? saveRoomPrimary
              : scheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    textTheme: textTheme.copyWith(
      headlineLarge: const TextStyle(
        color: Colors.white,
        fontSize: 34,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
      ),
      headlineMedium: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      titleLarge: const TextStyle(
        color: Colors.white,
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: const TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: const TextStyle(color: Color(0xFFB7B7B7), fontSize: 14),
      labelSmall: const TextStyle(color: Color(0xFF7B7B7B), fontSize: 11),
    ),
    extensions: const [SaveRoomTokens.dark],
  );
}

extension SaveRoomTheme on BuildContext {
  SaveRoomTokens get saveRoomTokens =>
      Theme.of(this).extension<SaveRoomTokens>() ?? SaveRoomTokens.dark;
}
