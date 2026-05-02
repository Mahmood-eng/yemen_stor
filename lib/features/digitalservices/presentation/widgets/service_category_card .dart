import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';

class ServiceCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;

  const ServiceCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultIconColor = isDark ? AppColors.white : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? defaultIconColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? defaultIconColor, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style:
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ) ??
                const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
