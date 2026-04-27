import 'package:flutter/material.dart';

class AppColors {
  static const canvas = Color(0xFFFAF8F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF3F0E8);
  static const inverse = Color(0xFF18221E);

  static const textPrimary = Color(0xFF1F2522);
  static const textSecondary = Color(0xFF5F6761);
  static const textTertiary = Color(0xFF8A938D);

  static const brand = Color(0xFF1F7A64);
  static const brandPressed = Color(0xFF155744);
  static const brandSoft = Color(0xFFE2F1EA);

  static const gold = Color(0xFFB8892E);
  static const burgundy = Color(0xFF8F2F3D);
  static const marianBlue = Color(0xFF2F5F8F);

  static const borderSubtle = Color(0xFFE2DDD1);
  static const borderStrong = Color(0xFFCFC7B7);
}

Color liturgicalColor(String value) {
  switch (value) {
    case 'green':
      return const Color(0xFF2F7D4F);
    case 'white':
      return const Color(0xFFF7F3E8);
    case 'gold':
      return const Color(0xFFC69A3D);
    case 'red':
      return const Color(0xFFB33A3A);
    case 'purple':
      return const Color(0xFF6B4A7A);
    case 'rose':
      return const Color(0xFFC9788D);
    case 'black':
      return const Color(0xFF242424);
    default:
      return AppColors.brand;
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        primary: AppColors.brand,
        onPrimary: Colors.white,
        surface: AppColors.canvas,
        onSurface: AppColors.textPrimary,
        error: const Color(0xFFB33A3A),
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.brand,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
      useMaterial3: true,
    );
  }
}
