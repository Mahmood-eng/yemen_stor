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
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgLight,
      fontFamily: 'Cairo',

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgLight,
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

      cardColor: AppColors.cardLight,
      dividerColor: Colors.grey.withOpacity(0.1),

      elevatedButtonTheme: _buttonTheme(AppColors.primary, AppColors.white),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // --- الثيم المظلم (Dark Theme) ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgDark,
      fontFamily: 'Cairo',

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.white,
        ),
      ),

      cardColor: AppColors.cardDark,
      dividerColor: Colors.white10,

      elevatedButtonTheme: _buttonTheme(AppColors.primary, AppColors.white),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        bodyMedium: TextStyle(fontFamily: 'Cairo', color: Colors.white70),
      ),

      // تحسين شكل الحقول في الوضع المظلم
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: _border(Colors.white10),
        enabledBorder: _border(Colors.white10),
        focusedBorder: _border(AppColors.primary),
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
