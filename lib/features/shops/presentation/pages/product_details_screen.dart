import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/product_info_widget.dart';
import '../widgets/product_specifications_widget.dart';
import '../widgets/shop_info_widget.dart';
import '../widgets/product_bottom_bar.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final productModel = ProductModel.fromJson(product);
    final marketType = productModel.category; // أو يمكن تحديده من shop

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            productModel.name,
            style: TextStyle(
              color: AppColors.primary,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.share, color: AppColors.primary),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.favorite_border, color: AppColors.accent),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              _buildProductImage(),

              // معلومات المنتج
              ProductInfoWidget(product: productModel),

              // المواصفات
              ProductSpecificationsWidget(product: productModel),

              // معلومات المحل
              ShopInfoWidget(
                shop: {
                  'name': productModel.shopName,
                  'rating': 4.8,
                  'location': 'تعز',
                  'status': 'مفتوح الآن',
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: ProductBottomBar(product: productModel),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 300,
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          _getIconForCategory(product['category'] ?? ''),
          size: 100,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case "هواتف ذكية":
        return Icons.smartphone;
      case "ملابس رجالية":
        return Icons.man;
      case "ملابس نسائية":
        return Icons.woman;
      case "عطور":
        return Icons.opacity;
      case "مكياج":
        return Icons.brush;
      default:
        return Icons.inventory_2;
    }
  }
}
