import 'package:flutter/material.dart';

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
    // جلب بيانات الثيم الحالية
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // إذا لم نمرر لون مخصص، فإنه سيأخذ اللون الرئيسي (primary) تلقائياً من الثيم
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,

          // لون النص داخل الزر يسحب من الثيم (غالباً الأبيض)
          foregroundColor: textColor ?? theme.colorScheme.onPrimary,

          // لون الزر عند التعطيل (Disabled)
          disabledBackgroundColor:
              (backgroundColor ?? theme.colorScheme.primary).withAlpha(
                (0.4 * 255).round(),
              ),

          // الحواف والشكل يتم سحبها من إعدادات الثيم الموحدة
          shape: theme.elevatedButtonTheme.style?.shape?.resolve({}),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            // التأكد من استخدام خط Cairo الموحد
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor ?? theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
