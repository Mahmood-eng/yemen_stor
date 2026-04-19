import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // دالة مساعدة لتوحيد شكل الحدود (Borders)
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(color: color, width: 1),
  );

  // --- الثيم الفاتح (Light Mode) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light, // مطابقة للثيم
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.textDark,
      ),

      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Cairo',

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.primary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey.shade400),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.primary,
        border: _border(Colors.grey.shade200),
        enabledBorder: _border(Colors.grey.shade100),
        focusedBorder: _border(AppColors.primary),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.textDark),
        bodyMedium: TextStyle(fontFamily: 'Cairo', color: AppColors.textDark),
      ),
    );
  }

  // --- الثيم المظلم (Dark Mode) ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, 

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark, 
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.white,
      ),

      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: 'Cairo',

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white38),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.primary,
        border: _border(Colors.white10),
        enabledBorder: _border(Colors.white10),
        focusedBorder: _border(AppColors.primary),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.white),
        bodyMedium: TextStyle(fontFamily: 'Cairo', color: Colors.white70),
      ),
    );
  }
}