import 'package:flutter/material.dart';
import '../widgets/category_tabs.dart';
import '../widgets/recommendation_product_card.dart';

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
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65, // لضمان ظهور الزر والبيانات بوضوح
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: 10, // عدد تجريبي
              itemBuilder: (context, index) {
                return RecommendationProductCard(
                  onLinkTap: () {
                    // هنا نضع الكود للانتقال لصفحة المحل
                    print("الانتقال إلى متجر المنتج رقم $index");
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