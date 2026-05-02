import 'package:flutter/material.dart';
import '../widgets/category_tabs.dart';
import '../widgets/recommendation_product_card.dart';
import '../../data/models/product_model.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class RecommendationsScreen extends StatefulWidget {
  static const String id = 'recommendations_screen';
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ["لك", "وصل حديثاً", "الأعلى تقييماً", "حصري", "رائج"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar يتبع ثيم التطبيق تلقائياً
      appBar: AppBar(
        title: const Text("اقتراحات لك"),
        centerTitle: true,
        ),
      body: Column(
        children: [
          // 1. التبويبات العلوية
          CategoryTabs(
            categories: _tabs,
            selectedIndex: _selectedTabIndex,
            onCategorySelected: (index) {
              setState(() => _selectedTabIndex = index);
            },
          ),

          // 2. شبكة المنتجات
          Expanded(
            child: Consumer<ProductsProvider>(
              builder: (context, productsProvider, child) {
                final products = productsProvider.products;
                if (products.isEmpty) {
                  return const Center(child: Text("لا توجد منتجات مطابقة"));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65, // لضمان ظهور الزر والبيانات بوضوح
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return RecommendationProductCard(
                      product: product,
                      onLinkTap: () {
                        // هنا نضع الكود للانتقال لصفحة المحل
                        debugPrint("الانتقال إلى متجر المنتج: ${product.name}");
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}