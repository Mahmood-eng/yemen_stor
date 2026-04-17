import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart'; // تأكد من مطابقة المسار

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كان الثيم الحالي مظلم أم فاتح
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      obscureText: isPassword,
      textAlign: TextAlign.right,
      // تغيير لون النص المدخل بناءً على الوضع
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: isDark ? AppColors.white : AppColors.textSub,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12.5,
          color: AppColors.textHint,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        // تغيير لون خلفية الحقل تلقائياً في الوضع المظلم
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF0F2F5),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        // إضافة حدود خفيفة جداً في الوضع المظلم لتمييز الحقل
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: isDark
              ? BorderSide(color: Colors.white.withOpacity(0.1))
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }
}
