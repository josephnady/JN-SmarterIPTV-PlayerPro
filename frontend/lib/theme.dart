import 'package:flutter/material.dart';

/// Colors simulating a modern streaming service (Netflix style).
class AppColors {
  static const bg = Color(0xFF141414);       // Netflix Dark Grey background
  static const bgElevated = Color(0xFF181818);
  static const panel = Color(0xFF2F2F2F);
  static const panel2 = Color(0xFF333333);
  static const line = Color(0xFF404040);
  static const text = Color(0xFFE5E5E5);     // Off-white text
  static const textDim = Color(0xFFB3B3B3);
  static const textFaint = Color(0xFF808080);
  static const accent = Color(0xFFE50914);   // Netflix Red
  static const accentDim = Color(0xFF91060D);
  static const live = Color(0xFFE50914);     // Red also used for live indicators
  static const danger = Color(0xFFB9090B);
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.live,
      surface: AppColors.panel,
      error: AppColors.danger,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black, // Netflix typically uses pure black for top bars
      foregroundColor: AppColors.text,
      elevation: 0,
    ),
    cardColor: AppColors.panel,
    dividerColor: AppColors.line,
    dividerTheme: const DividerThemeData(color: AppColors.line),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgElevated,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4), // Slightly sharper corners
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      labelStyle: const TextStyle(color: AppColors.textDim),
      hintStyle: const TextStyle(color: AppColors.textFaint),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(AppColors.accent),
      trackColor: WidgetStatePropertyAll(AppColors.accent.withValues(alpha: 0.5)),
    ),
  );
}
