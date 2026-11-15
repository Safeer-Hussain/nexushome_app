import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Dark Theme (Obsidian Smart-Home Palette)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF10B981), // Emerald Pulse
      onPrimary: Color(0xFF022C22),
      primaryContainer: Color(0xFF064E3B),
      onPrimaryContainer: Color(0xFFA7F3D0),
      secondary: Color(0xFFF59E0B), // Warm Solar Amber
      onSecondary: Color(0xFF451A03),
      secondaryContainer: Color(0xFF78350F),
      onSecondaryContainer: Color(0xFFFDE68A),
      tertiary: Color(0xFF06B6D4), // Thread Cyan
      onTertiary: Color(0xFF083344),
      tertiaryContainer: Color(0xFF155E75),
      onTertiaryContainer: Color(0xFFCFFAFE),
      error: Color(0xFFEF4444),
      onError: Color(0xFF450A0A),
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFEE2E2),
      surface: Color(0xFF0B0F17), // Deep Obsidian
      onSurface: Color(0xFFF3F4F6),
      surfaceContainerLowest: Color(0xFF070A0F),
      surfaceContainerLow: Color(0xFF0E1420),
      surfaceContainer: Color(0xFF131B2A),
      surfaceContainerHigh: Color(0xFF1A2436),
      surfaceContainerHighest: Color(0xFF222F46),
      onSurfaceVariant: Color(0xFF94A3B8),
      outline: Color(0xFF334155),
      outlineVariant: Color(0xFF1E293B),
      inverseSurface: Color(0xFFF3F4F6),
      onInverseSurface: Color(0xFF0B0F17),
      inversePrimary: Color(0xFF059669),
      shadow: Color(0x66000000),
      scrim: Color(0xCC000000),
    ),
    scaffoldBackgroundColor: const Color(0xFF0B0F17),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0E1420),
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF131B2A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E293B), width: 1),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF0E1420),
      modalBackgroundColor: Color(0xFF0E1420),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xFF070A0F),
      selectedIconTheme: IconThemeData(color: Color(0xFF10B981)),
      unselectedIconTheme: IconThemeData(color: Color(0xFF94A3B8)),
      indicatorColor: Color(0xFF064E3B),
    ),
  );

  // Light Theme (Crisp Architectural Light Palette)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF059669), // Emerald Accent
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD1FAE5),
      onPrimaryContainer: Color(0xFF064E3B),
      secondary: Color(0xFFD97706), // Solar Gold
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFEF3C7),
      onSecondaryContainer: Color(0xFF78350F),
      tertiary: Color(0xFF0891B2), // Mesh Cyan
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFCFFAFE),
      onTertiaryContainer: Color(0xFF155E75),
      error: Color(0xFFDC2626),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF7F1D1D),
      surface: Color(0xFFF8FAFC), // Pure Architectural Mist
      onSurface: Color(0xFF0F172A),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF1F5F9),
      surfaceContainer: Color(0xFFE2E8F0),
      surfaceContainerHigh: Color(0xFFCBD5E1),
      surfaceContainerHighest: Color(0xFF94A3B8),
      onSurfaceVariant: Color(0xFF475569),
      outline: Color(0xFF94A3B8),
      outlineVariant: Color(0xFFE2E8F0),
      inverseSurface: Color(0xFF0F172A),
      onInverseSurface: Color(0xFFF8FAFC),
      inversePrimary: Color(0xFFA7F3D0),
      shadow: Color(0x1A000000),
      scrim: Color(0x66000000),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      modalBackgroundColor: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xFFF1F5F9),
      selectedIconTheme: IconThemeData(color: Color(0xFF059669)),
      unselectedIconTheme: IconThemeData(color: Color(0xFF64748B)),
      indicatorColor: Color(0xFFD1FAE5),
    ),
  );
}
