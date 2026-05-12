import 'package:flutter/material.dart';

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
    // جلب بيانات الثيم الحالية
    final theme = Theme.of(context);

    return TextFormField(
      obscureText: isPassword,
      textAlign: TextAlign.right,
      // ستايل النص المدخل يتبع الثيم تلقائياً
      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        // ستايل نص التلميح (Hint) من الثيم
        hintStyle: theme.inputDecorationTheme.hintStyle,

        // الأيقونة تأخذ لون الـ primary من الثيم
        prefixIcon: Icon(icon, color: theme.primaryColor, size: 20),
        suffixIcon: suffixIcon,

        filled: true,
        // لون الخلفية يتم جلبه من إعدادات الحقول في الثيم
        fillColor: theme.inputDecorationTheme.fillColor,

        contentPadding: const EdgeInsets.all(8.0),

        // الحدود (Borders) يتم التحكم بها مركزياً من ملف الثيم
        border: theme.inputDecorationTheme.border,
        enabledBorder: theme.inputDecorationTheme.enabledBorder,
        focusedBorder: theme.inputDecorationTheme.focusedBorder,
      ),
    );
  }
}
