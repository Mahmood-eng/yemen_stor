import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_favorite_button.dart';
import '../../../orders/presentation/providers/favorites_providers.dart';
import '../../../orders/presentation/providers/cart_providers.dart';
import '../../data/models/product_model.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;
  final String marketType;

  const ProductCard({
    super.key,
    required this.product,
    required this.marketType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
        border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.05)) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.push(
            AppRoutes.productDetails,
            extra: {'product': product.toJson()},
          );
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // منطقة الصورة
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? theme.colorScheme.surface : const Color(0xFFF3F5F7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                _getIconForMarketType(marketType),
                                size: 40,
                                color: theme.colorScheme.primary.withOpacity(0.5),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              _getIconForMarketType(marketType),
                              size: 40,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                  ),
                ),
                // تفاصيل المنتج
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "${product.price.toInt()} ريال",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (product.hasDiscount)
                            Text(
                              "${product.originalPrice!.toInt()} ريال",
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // زر شراء الآن
                      ElevatedButton.icon(
                        onPressed: () async {
                          // إضافة المنتج للسلة ثم الانتقال إليها
                          await ref.read(cartActionsProvider).addToCart(
                            productId: product.id,
                            productName: product.name,
                            price: product.hasDiscount ? product.price : product.originalPrice ?? product.price,
                            imageUrl: product.images.isNotEmpty ? product.images.first : '',
                            shopId: product.shopId,
                            shopName: product.shopName,
                          );
                          if (context.mounted) {
                            context.push(AppRoutes.cart);
                          }
                        },
                        icon: const Icon(Icons.bolt, size: 16),
                        label: const Text(
                          "شراء الآن",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 36),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // أيقونة السلة
            Positioned(
              top: 15,
              right: 15,
              child: GestureDetector(
                onTap: () async {
                  // إضافة للسلة
                  await ref.read(cartActionsProvider).addToCart(
                    productId: product.id,
                    productName: product.name,
                    price: product.hasDiscount ? product.price : product.originalPrice ?? product.price,
                    imageUrl: product.images.isNotEmpty ? product.images.first : '',
                    shopId: product.shopId,
                    shopName: product.shopName,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تمت الإضافة إلى السلة بنجاح', style: const TextStyle(fontFamily: 'Cairo')),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_shopping_cart,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            // ملصق الخصم
            if (product.hasDiscount)
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.secondary, theme.colorScheme.secondary.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "خصم ${product.discountPercentage.toInt()}%",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),

            // أيقونة القلب
            Positioned(
              top: product.hasDiscount ? 44 : 15,
              left: 15,
              child: Consumer(
                builder: (context, ref, child) {
                  final favoritesAsync = ref.watch(favoritesStreamProvider);
                  final isFavorite = favoritesAsync.maybeWhen(
                    data: (favList) => favList.any((item) => item.productId == product.id),
                    orElse: () => false,
                  );

                  return CustomFavoriteButton(
                    isFavorite: isFavorite,
                    onTap: () {
                      ref.read(favoritesActionsProvider).toggleFavorite(
                        productId: product.id,
                        productName: product.name,
                        price: product.hasDiscount ? product.price : product.originalPrice ?? product.price,
                        imageUrl: product.images.isNotEmpty ? product.images.first : '',
                        description: product.description,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMarketType(String marketType) {
    switch (marketType) {
      case "إلكترونيات":
        return Icons.smartphone;
      case "أزياء":
        return Icons.checkroom;
      case "الجمال":
        return Icons.face_retouching_natural;
      default:
        return Icons.inventory_2;
    }
  }
}
