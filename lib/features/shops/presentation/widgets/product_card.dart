import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String marketType;

  const ProductCard({
    super.key,
    required this.product,
    required this.marketType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
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
                      color: const Color(0xFFF3F5F7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForMarketType(marketType),
                        size: 50,
                        color: Colors.grey[400],
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
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            "\$${product.price}",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (product.hasDiscount)
                            Text(
                              "\$${product.originalPrice!.toInt()}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // زر شراء الآن
                      ElevatedButton(
                        onPressed: () {
                          // منطق الشراء
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 38),
                          elevation: 0,
                        ),
                        child: const Text(
                          "شراء الآن",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                onTap: () {
                  // إضافة للسلة
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_shopping_cart,
                    size: 18,
                    color: AppColors.primary,
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
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "خصم ${product.discountPercentage.toInt()}%",
                    style: const TextStyle(
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
              top: product.hasDiscount ? 48 : 15,
              left: 15,
              child: GestureDetector(
                onTap: () {
                  // إضافة للمفضلة
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
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
