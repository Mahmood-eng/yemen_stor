import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    borderSide: BorderSide(color: color, width: 1.2),
  );

  // --- الثيم الفاتح ---
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.bgLight,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      cardColor: Colors.white,
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withOpacity(0.9),
      ),
      dividerColor: Colors.grey.withOpacity(0.2),
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
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Cairo',
          color: colorScheme.onSurface,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Cairo',
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          color: Colors.grey,
        ),
        border: _border(colorScheme.primary.withOpacity(0.2)),
        enabledBorder: _border(colorScheme.primary.withOpacity(0.2)),
        focusedBorder: _border(colorScheme.primary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // --- الثيم المظلم (المضبوط) ---
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primaryDark, // أزرق فاتح ليظهر بوضوح
      secondary: AppColors.accent,
      surface: AppColors.bgDark,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimaryDark, // أبيض خالص للعناوين
      onSurfaceVariant: AppColors.textSecondaryDark, // رمادي فاتح للفرعي
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      cardColor: AppColors.cardDark,
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF2C2C2C).withOpacity(0.9),
      ),
      fontFamily: 'Cairo',

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardDark,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: colorScheme.onSurface,
        ),
      ),

      // ضبط شكل مربعات الإدخال (Search Bar)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark, // تمييز المربع عن الخلفية السوداء
        hintStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          color: AppColors.textHintDark,
        ),
        border: _border(colorScheme.onSurface.withOpacity(0.1)),
        enabledBorder: _border(colorScheme.onSurface.withOpacity(0.1)),
        focusedBorder: _border(colorScheme.primary),
      ),

      // ضبط النصوص عالمياً
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Cairo',
          color: colorScheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Cairo',
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // إصلاح ألوان القائمة السفلية (Bottom Nav)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
