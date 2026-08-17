import 'package:flutter/material.dart';

/// Colors mirroring the desktop app's "tuner console" design language.
class AppColors {
  static const bg = Color(0xFF0D0F14);
  static const bgElevated = Color(0xFF12141B);
  static const panel = Color(0xFF171A23);
  static const panel2 = Color(0xFF1C202A);
  static const line = Color(0xFF262B38);
  static const text = Color(0xFFE7E9EE);
  static const textDim = Color(0xFF8B93A7);
  static const textFaint = Color(0xFF565D70);
  static const accent = Color(0xFFE8A33D);
  static const accentDim = Color(0xFF7A5A25);
  static const live = Color(0xFF37C99A);
  static const danger = Color(0xFFE0555A);
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
      backgroundColor: AppColors.bgElevated,
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
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accentDim),
      ),
      labelStyle: const TextStyle(color: AppColors.textDim),
      hintStyle: const TextStyle(color: AppColors.textFaint),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF1A1305),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    switchTheme: const SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(AppColors.accent),
      trackColor: MaterialStatePropertyAll(AppColors.accentDim),
    ),
  );
}
