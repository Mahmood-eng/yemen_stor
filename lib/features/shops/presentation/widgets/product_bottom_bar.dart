import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import '../../data/models/product_model.dart';
import '../../../orders/presentation/providers/cart_providers.dart';

class ProductBottomBar extends ConsumerWidget {
  final ProductModel product;

  const ProductBottomBar({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  // Buy now: Add to cart and navigate to CartScreen
                  await ref.read(cartActionsProvider).addToCart(
                    productId: product.id,
                    productName: product.name,
                    price: product.price,
                    imageUrl: product.images.isNotEmpty ? product.images.first : '',
                    shopId: product.shopId,
                    shopName: product.shopName,
                    merchantId: product.merchantId,
                    marketId: product.marketId,
                    categoryId: product.categoryId,
                  );
                  if (context.mounted) {
                    context.push(AppRoutes.cart);
                  }
                },
                icon: Icon(Icons.bolt, color: theme.colorScheme.onPrimary),
                label: Text(
                  "إشتري الآن",
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  // Add to cart and show nice snackbar
                  await ref.read(cartActionsProvider).addToCart(
                    productId: product.id,
                    productName: product.name,
                    price: product.price,
                    imageUrl: product.images.isNotEmpty ? product.images.first : '',
                    shopId: product.shopId,
                    shopName: product.shopName,
                    merchantId: product.merchantId,
                    marketId: product.marketId,
                    categoryId: product.categoryId,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "تم إضافة المنتج إلى السلة ✓",
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.add_shopping_cart, color: theme.colorScheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
