import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // دالة مساعدة موحدة للحدود لتجنب التكرار
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    borderSide: BorderSide.none,
  );

  // --- الثيم الفاتح (Light Theme) ---
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.bgLight,
      onPrimary: Colors.white,
      onSurface: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: AppColors.bgLight,
      fontFamily: 'Cairo',

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.primary),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: colorScheme.primary,
        ),
        foregroundColor: colorScheme.primary,
      ),

      cardColor: AppColors.cardLight,
      dividerColor: colorScheme.onSurface,

      elevatedButtonTheme: _buttonTheme(
        colorScheme.primary,
        colorScheme.onPrimary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(foregroundColor: colorScheme.primary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: _border(colorScheme.primary),
        enabledBorder: _border(colorScheme.primary),
        focusedBorder: _border(colorScheme.primary),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Cairo',
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  // --- الثيم المظلم (Dark Theme) ---
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.bgDark,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: AppColors.bgDark,
      fontFamily: 'Cairo',

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.primary, size: 20),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: colorScheme.primary,
        ),
        foregroundColor: colorScheme.primary,
      ),

      cardColor: AppColors.cardDark,
      dividerColor: colorScheme.onSurface.withOpacity(0.1),

      elevatedButtonTheme: _buttonTheme(
        colorScheme.primary,
        colorScheme.onPrimary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.onPrimary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(foregroundColor: colorScheme.onPrimary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: _border(colorScheme.onSurface),
        enabledBorder: _border(colorScheme.onSurface),
        focusedBorder: _border(colorScheme.primary),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Cairo',
          color: colorScheme.onSurface.withOpacity(0.85),
        ),
      ),
    );
  }

  // دالة مساعدة لتوحيد ثيم الأزرار
  static ElevatedButtonThemeData _buttonTheme(Color bg, Color fg) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
}
