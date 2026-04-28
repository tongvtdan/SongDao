import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const canvas = Color(0xFFFCF9F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF6F3ED);
  static const surfaceContainer = Color(0xFFF0EEE8);
  static const surfaceVariant = Color(0xFFE5E2DC);
  static const inverse = Color(0xFF31312D);

  static const textPrimary = Color(0xFF1C1C18);
  static const textSecondary = Color(0xFF414941);
  static const textTertiary = Color(0xFF727970);

  static const brand = Color(0xFF204E2B);
  static const brandPressed = Color(0xFF3A6843);
  static const brandSoft = Color(0xFFBCEFC0);

  static const secondary = Color(0xFF6E5097);
  static const secondarySoft = Color(0xFFD1AFFE);

  static const tertiary = Color(0xFF841D24);
  static const tertiarySoft = Color(0xFFA43539);

  static const gold = Color(0xFFB8892E);
  static const burgundy = Color(0xFF8F2F3D);

  static const borderSubtle = Color(0xFFF0EEE8);
  static const borderStrong = Color(0xFFC1C9BE);
}

Color liturgicalColor(String value) {
  switch (value) {
    case 'green':
      return AppColors.brand; // Ordinary Time
    case 'white':
      return AppColors.canvas; // Or surface, Easter/Christmas
    case 'gold':
      return AppColors.gold;
    case 'red':
      return const Color(0xFFBC4749); // Feasts & Martyrs
    case 'purple':
      return const Color(0xFF6A4C93); // Lent & Advent
    case 'rose':
      return const Color(0xFFC9788D);
    case 'black':
      return AppColors.textPrimary;
    default:
      return AppColors.brand;
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        primary: AppColors.brand,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        tertiary: AppColors.tertiary,
        onTertiary: Colors.white,
        surface: AppColors.canvas,
        onSurface: AppColors.textPrimary,
        error: const Color(0xFFBA1A1A),
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceVariant,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          minimumSize: const Size.fromHeight(44),
          side: const BorderSide(color: AppColors.borderStrong),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.4),
        ),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceSecondary,
        indicatorColor: AppColors.brandSoft.withValues(alpha: 0.5),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.notoSerif(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.brand
                : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.brand
                : AppColors.textSecondary,
          );
        }),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        surfaceTintColor: AppColors.canvas,
      ),
      useMaterial3: true,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.notoSerif(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.notoSerif(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.notoSerif(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.notoSerif(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.notoSerif(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.notoSerif(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.notoSerif(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.textPrimary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
          height: 1,
          color: AppColors.textPrimary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
