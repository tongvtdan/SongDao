import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core surfaces
  static const canvas = Color(0xFFF5F4ED);
  static const surface = Color(0xFFFAF9F5);
  static const surfaceSecondary = Color(0xFFE8E6DC);
  static const surfaceContainer = Color(0xFFF0EEE6);
  static const surfaceVariant = Color(0xFFE2DED2);
  static const inverse = Color(0xFF141413);

  // Text
  static const textPrimary = Color(0xFF141413);
  static const textSecondary = Color(0xFF5E5D59);
  static const textTertiary = Color(0xFF87867F);
  static const textInverse = Color(0xFFFAF9F5);
  static const textLink = Color(0xFFC96442);

  // Brand & interaction
  static const brand = Color(0xFFC96442);
  static const brandPressed = Color(0xFFAD5134);
  static const brandSoft = Color(0xFFF2DFD5);
  static const brandDeep = Color(0xFF743820);

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
  static const borderSubtle = Color(0xFFF0EEE6);
  static const borderStrong = Color(0xFFD4CBBB);
  static const borderFocus = Color(0xFFC96442);
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
          return GoogleFonts.sourceSerif4(
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
      textTheme: GoogleFonts.beVietnamProTextTheme(baseTheme.textTheme)
          .copyWith(
            displayLarge: GoogleFonts.sourceSerif4(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
            displayMedium: GoogleFonts.sourceSerif4(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            displaySmall: GoogleFonts.sourceSerif4(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            headlineLarge: GoogleFonts.sourceSerif4(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            headlineMedium: GoogleFonts.sourceSerif4(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
            headlineSmall: GoogleFonts.sourceSerif4(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
            titleLarge: GoogleFonts.sourceSerif4(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            titleMedium: GoogleFonts.beVietnamPro(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.15,
              color: AppColors.textPrimary,
            ),
            titleSmall: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: AppColors.textPrimary,
            ),
            bodyLarge: GoogleFonts.beVietnamPro(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
            bodyMedium: GoogleFonts.beVietnamPro(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: AppColors.textPrimary,
            ),
            bodySmall: GoogleFonts.beVietnamPro(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
            labelLarge: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: AppColors.textPrimary,
            ),
            labelMedium: GoogleFonts.beVietnamPro(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
            labelSmall: GoogleFonts.beVietnamPro(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.textPrimary,
            ),
          ),
    );
  }
}
