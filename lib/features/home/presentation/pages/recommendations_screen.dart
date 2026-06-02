import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';
import 'package:yemen_stor/features/menu/presentation/pages/app_drawer.dart';
import 'package:yemen_stor/features/shops/data/models/product_model.dart';
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

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: YemenStoreAppBar(
        title: const Text(
          "المقترحات",
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
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
        ],
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

          // 2. شبكة المنتجات الحقيقية من Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "حدث خطأ في تحميل المقترحات: ${snapshot.error}",
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text(
                          "لا توجد منتجات مقترحة حالياً",
                          style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final List<ProductModel> products = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['id'] == null || data['id'] == '') {
                    data['id'] = doc.id;
                  }
                  return ProductModel.fromJson(data);
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return RecommendationProductCard(
                      product: product,
                      onLinkTap: () {
                        context.push(AppRoutes.shopDetails, extra: {
                          'shop': {
                            'id': product.shopId,
                            'name': product.shopName,
                          }
                        });
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
