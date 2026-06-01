import 'package:flutter/material.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';

class ServicesSearchField extends StatelessWidget {
  const ServicesSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha((0.05 * 255).round())
            : const Color(0xFFF2F5F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: "ابحث عن خدمة...",
          hintStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: Colors.grey,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
