import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/core/widgets/yemen_store_app_bar.dart';
import 'package:yemen_store/features/menu/presentation/pages/app_drawer.dart';
import '../widgets/category_tabs.dart';
import '../widgets/recommendation_product_card.dart';

class RecommendationsScreen extends StatefulWidget {
  static const String id = 'recommendations_screen';
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
  
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTabIndex = 0;
  final List<String> _tabs = [
    "لك",
    "وصل حديثاً",
    "الأعلى تقييماً",
    "حصري",
    "رائج",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
       key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: YemenStoreAppBar(
        title: const Text("المقترحات "),
         leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              context.push(AppRoutes.cart);
            },
          ),
        ], ),
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
