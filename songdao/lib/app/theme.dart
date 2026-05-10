import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core surfaces
  static const canvas = Color(0xFFFAF8F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF3F0E8);
  static const surfaceContainer = Color(0xFFF0EEE8);
  static const surfaceVariant = Color(0xFFE5E2DC);
  static const inverse = Color(0xFF18221E);

  // Text
  static const textPrimary = Color(0xFF1F2522);
  static const textSecondary = Color(0xFF5F6761);
  static const textTertiary = Color(0xFF8A938D);
  static const textInverse = Color(0xFFF8F5ED);
  static const textLink = Color(0xFF1B6E5A);

  // Brand & interaction
  static const brand = Color(0xFF1F7A64);
  static const brandPressed = Color(0xFF155744);
  static const brandSoft = Color(0xFFE2F1EA);
  static const brandDeep = Color(0xFF123C32);

  // Accent
  static const gold = Color(0xFFB8892E);
  static const burgundy = Color(0xFF8F2F3D);
  static const marianBlue = Color(0xFF2F5F8F);

  // Legacy aliases kept for compatibility; map them to current design tokens.
  static const secondary = marianBlue;
  static const secondarySoft = brandSoft;
  static const tertiary = burgundy;
  static const tertiarySoft = statusError;

  // Status
  static const statusComplete = Color(0xFF2F7D4F);
  static const statusWarning = Color(0xFFB8892E);
  static const statusError = Color(0xFFB33A3A);
  static const statusOffline = Color(0xFF5F6761);

  // Borders
  static const borderSubtle = Color(0xFFE2DDD1);
  static const borderStrong = Color(0xFFCFC7B7);
  static const borderFocus = Color(0xFF1F7A64);
}

class LiturgicalColors {
  static const green = Color(0xFF2F7D4F); // Ordinary Time
  static const white = Color(0xFFF7F3E8); // Christmas, Easter, solemnities
  static const gold = Color(0xFFC69A3D); // High feast emphasis
  static const red = Color(0xFFB33A3A); // Martyrs, Palm Sunday, Good Friday
  static const purple = Color(0xFF6B4A7A); // Advent, Lent, penance
  static const rose = Color(0xFFC9788D); // Gaudete and Laetare Sundays
  static const black = Color(0xFF242424); // Rare memorial usage only
}

Color liturgicalColor(String value) {
  switch (value) {
    case 'green':
      return LiturgicalColors.green;
    case 'white':
      return LiturgicalColors.white;
    case 'gold':
      return LiturgicalColors.gold;
    case 'red':
      return LiturgicalColors.red;
    case 'purple':
      return LiturgicalColors.purple;
    case 'rose':
      return LiturgicalColors.rose;
    case 'black':
      return LiturgicalColors.black;
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
        error: AppColors.statusError,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
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
          horizontal: 16,
          vertical: 12,
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
          borderSide: const BorderSide(
            color: AppColors.borderFocus,
            width: 1.4,
          ),
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
          height: 1.5,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.45,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.textPrimary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
          height: 1.3,
          color: AppColors.textPrimary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
