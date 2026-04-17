import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart'; 

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor; 
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // التحقق مما إذا كان التطبيق في وضع الـ Dark Mode
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // إذا لم نمرر لون مخصص، نأخذ اللون الرئيسي من ملف الألوان
          backgroundColor: backgroundColor ?? AppColors.primary,

          // لون الزر عند التعطيل (يصبح شفافاً قليلاً)
          disabledBackgroundColor: (backgroundColor ?? AppColors.primary)
              .withOpacity(0.4),

          // لون النص والأيقونات داخل الزر
          foregroundColor: textColor ?? AppColors.white,

          // الحواف (تأخذ شكلها من الثيم أو القيمة الثابتة)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0, // تصميم مسطح (Flat) أكثر عصرية
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
