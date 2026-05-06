import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/product_card.dart';

class ShopDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  final Color _primaryColor = AppColors.primary;
  final Color _accentColor = AppColors.accent;

  late List<ProductModel> _products;
  String _selectedCategory = "الكل";

  @override
  void initState() {
    super.initState();
    // الحصول على المنتجات حسب معرف المحل
    _products = mockProductsByShop[widget.shop['id']] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final shopName = widget.shop['name'] ?? '';
    final marketType = widget.shop['marketType'] ?? '';

    // تحديد الفئات حسب نوع السوق
    final categories = _getCategoriesForMarketType(marketType);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: categories.length,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFD),
          appBar: AppBar(
            backgroundColor: _primaryColor,
            elevation: 0,
            title: Text(
              shopName,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: categories.map((category) => Tab(text: category)).toList(),
            ),
          ),
          body: TabBarView(
            children: categories.map((category) {
              return _buildProductsGrid(
                category: category,
                marketType: marketType,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  List<String> _getCategoriesForMarketType(String marketType) {
    switch (marketType) {
      case "إلكترونيات":
        return ["الكل", "هواتف ذكية", "أجهزة لوحية", "إكسسوارات"];
      case "أزياء":
        return ["الكل", "ملابس رجالية", "ملابس نسائية", "أحذية"];
      case "الجمال":
        return ["الكل", "عطور", "مكياج", "عناية شخصية"];
      default:
        return ["الكل"];
    }
  }

  Widget _buildProductsGrid({
    required String category,
    required String marketType,
  }) {
    // تصفية المنتجات حسب الفئة
    final filteredProducts = category == "الكل"
        ? _products
        : _products.where((product) => product.category == category).toList();

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "لا توجد منتجات متاحة في هذه الفئة",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: filteredProducts[index],
          marketType: marketType,
        );
      },
    );
  }
}
