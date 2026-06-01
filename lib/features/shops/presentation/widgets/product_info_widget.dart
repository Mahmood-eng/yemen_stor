import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductInfoWidget extends StatelessWidget {
  final ProductModel product;

  const ProductInfoWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
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
          Text(
            product.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "${product.price.toInt()} ريال",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 10),
              if (product.hasDiscount)
                Text(
                  "${product.originalPrice!.toInt()} ريال",
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              if (product.hasDiscount)
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "خصم ${product.discountPercentage.toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            product.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(
                product.inStock ? Icons.check_circle : Icons.cancel,
                color: product.inStock ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                product.inStock
                    ? "متوفر (${product.stockQuantity} قطعة)"
                    : "غير متوفر",
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: product.inStock ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
