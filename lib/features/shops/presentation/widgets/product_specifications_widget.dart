import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductSpecificationsWidget extends StatelessWidget {
  final ProductModel product;

  const ProductSpecificationsWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.specifications.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // تحديد ما إذا كانت الفئة تتطلب عرض كبسولات (مثلاً الألوان أو المقاسات) بدلاً من جدول
    final bool useChips = product.category.contains("ملابس") || product.category.contains("أحذية");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.05)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                "المواصفات",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (useChips)
            ...product.specifications.entries.map((entry) => _buildChipRow(entry, theme))
          else
            ...product.specifications.entries.map((entry) => _buildTableRow(entry, theme)),
        ],
      ),
    );
  }

  Widget _buildTableRow(MapEntry<String, dynamic> entry, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              entry.key,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              entry.value.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(MapEntry<String, dynamic> entry, ThemeData theme) {
    // If value is a string that looks like a list, try to split it
    List<String> values = [];
    if (entry.value is List) {
      values = (entry.value as List).map((e) => e.toString()).toList();
    } else {
      values = entry.value.toString().split(',').map((e) => e.trim()).toList();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.key,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((val) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                ),
                child: Text(
                  val,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
