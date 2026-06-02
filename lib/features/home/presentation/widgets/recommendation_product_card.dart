import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import '../../../shops/data/models/product_model.dart';
import '../../../orders/presentation/providers/cart_providers.dart';
import '../../../orders/presentation/providers/favorites_providers.dart';
import '../../../../core/widgets/custom_favorite_button.dart';

class RecommendationProductCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback? onLinkTap;

  const RecommendationProductCard({
    super.key,
    required this.product,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasImage = product.images.isNotEmpty;
    final imageUrl = hasImage ? product.images.first : '';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
        border: isDark
            ? Border.all(color: theme.dividerColor.withOpacity(0.05))
            : null,
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
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surface
                          : const Color(0xFFF3F5F7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hasImage
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (c, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          )
                        : Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (product.hasDiscount)
                            Text(
                              "${product.originalPrice?.toInt()} ريال",
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.6),
                                fontSize: 9,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // زر الشراء الآن
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await ref
                                .read(cartActionsProvider)
                                .addToCart(
                                  productId: product.id,
                                  productName: product.name,
                                  price: product.hasDiscount
                                      ? product.price
                                      : product.originalPrice ?? product.price,
                                  imageUrl: imageUrl,
                                  shopId: product.shopId,
                                  shopName: product.shopName,
                                );
                            if (context.mounted) {
                              context.push(AppRoutes.cart);
                            }
                          },
                          icon: const Icon(Icons.bolt, size: 14),
                          label: const Text(
                            "شراء الآن",
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // أيقونة السلة (متوافقة مع UX المحل)
            Positioned(
              top: 15,
              right: 15,
              child: GestureDetector(
                onTap: () async {
                  await ref
                      .read(cartActionsProvider)
                      .addToCart(
                        productId: product.id,
                        productName: product.name,
                        price: product.hasDiscount
                            ? product.price
                            : product.originalPrice ?? product.price,
                        imageUrl: imageUrl,
                        shopId: product.shopId,
                        shopName: product.shopName,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تمت الإضافة إلى السلة بنجاح',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
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
                    size: 14,
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
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.secondary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "خصم ${product.discountPercentage.toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),

            // أيقونة القلب
            Positioned(
              top: product.hasDiscount ? 40 : 15,
              left: 15,
              child: Consumer(
                builder: (context, ref, child) {
                  final favoritesAsync = ref.watch(favoritesStreamProvider);
                  final isFavorite = favoritesAsync.maybeWhen(
                    data: (favList) =>
                        favList.any((item) => item.productId == product.id),
                    orElse: () => false,
                  );

                  return CustomFavoriteButton(
                    isFavorite: isFavorite,
                    onTap: () {
                      ref
                          .read(favoritesActionsProvider)
                          .toggleFavorite(
                            productId: product.id,
                            productName: product.name,
                            price: product.hasDiscount
                                ? product.price
                                : product.originalPrice ?? product.price,
                            imageUrl: imageUrl,
                            description: product.description,
                          );
                    },
                  );
                },
              ),
            ),

            // أيقونة الارتباط بالمحل
            Positioned(
              bottom: 89, // أعلى زر الشراء
              left: 15,
              child: GestureDetector(
                onTap:
                    onLinkTap ??
                    () {
                      context.push(
                        AppRoutes.shopDetails,
                        extra: {
                          'shop': {
                            'id': product.shopId,
                            'name': product.shopName,
                          },
                        },
                      );
                    },
                child: Container(
                  padding: const EdgeInsets.all(4),
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
                    Icons.storefront,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
