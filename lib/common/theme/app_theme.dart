import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Paleta de Cores ───────────────────────────────────────────────────────────
class AppColors {
  // Cor primária — violeta vibrante
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);

  // Receitas — verde neon
  static const Color income = Color(0xFF10B981);
  static const Color incomeLight = Color(0xFF34D399);

  // Despesas — vermelho/rosa vibrante
  static const Color expense = Color(0xFFEF4444);
  static const Color expenseLight = Color(0xFFF87171);

  // Saldo positivo/negativo
  static const Color balancePositive = Color(0xFF06B6D4);
  static const Color balanceNegative = Color(0xFFEF4444);

  // Superfícies (dark)
  static const Color surfaceDark = Color(0xFF1E1B2E);
  static const Color cardDark = Color(0xFF2D2847);
  static const Color dividerDark = Color(0xFF3D3866);

  // Superfícies (light)
  static const Color surfaceLight = Color(0xFFF5F3FF);
  static const Color cardLight = Color(0xFFFFFFFF);
}

// Light Theme
final ThemeData appLightTheme = _buildTheme(Brightness.light);

// Dark Theme
final ThemeData appDarkTheme = _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: brightness,
    primary: AppColors.primary,
    secondary: AppColors.income,
    tertiary: AppColors.expense,
    surface: isDark ? AppColors.cardDark : AppColors.cardLight,
    error: AppColors.expense,
  ).copyWith(
    primaryContainer:
        isDark
            ? AppColors.primary.withValues(alpha: 0.25)
            : AppColors.primaryLight.withValues(alpha: 0.3),
    secondaryContainer:
        isDark
            ? AppColors.income.withValues(alpha: 0.2)
            : AppColors.incomeLight.withValues(alpha: 0.2),
    tertiaryContainer:
        isDark
            ? AppColors.expense.withValues(alpha: 0.2)
            : AppColors.expenseLight.withValues(alpha: 0.2),
  );

  final textTheme = GoogleFonts.poppinsTextTheme().copyWith(
    displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
    headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
    headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor:
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      foregroundColor: isDark ? Colors.white : AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor:
          isDark
              ? AppColors.dividerDark.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.expense, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(
        color: isDark ? Colors.white60 : Colors.black54,
      ),
      prefixIconColor: AppColors.primary,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dividerTheme: DividerThemeData(
      color: isDark ? AppColors.dividerDark : Colors.grey.shade200,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
