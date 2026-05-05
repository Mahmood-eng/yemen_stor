import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/shop_model.dart';
import '../widgets/product_card.dart';

class ShopDetailsScreen extends StatefulWidget {
  final ShopModel? shop;

  const ShopDetailsScreen({super.key, this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: primaryColor,
            elevation: 0,
            title: Text(
              widget.shop?.name ?? 'تفاصيل المحل',
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
              unselectedLabelColor: Colors.white.withAlpha((0.6 * 255).round()),
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: [
                const Tab(text: "الكل"),
                _buildTabWithPopup("iPhone", [
                  "15 Pro Max",
                  "14 Pro",
                  "13 Pro",
                ]),
                _buildTabWithPopup("Samsung", ["S24 Ultra", "Fold 5", "A54"]),
                _buildTabWithPopup("Xiaomi", ["Redmi 13", "Poco F5"]),
                _buildTabWithPopup("إكسسوارات", [
                  "شواحن وكابلات",
                  "غلافات",
                  "شاشات حماية",
                  "سماعات",
                  "أدوات تصوير",
                ]),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildProductsGrid(contentType: "mixed"),
              _buildProductsGrid(contentType: "phones"),
              _buildProductsGrid(contentType: "phones"),
              _buildProductsGrid(contentType: "phones"),
              _buildProductsGrid(contentType: "accessories"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabWithPopup(String title, List<String> options) {
    return Tab(
      child: PopupMenuButton<String>(
        offset: const Offset(0, 45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text(title), const Icon(Icons.arrow_drop_down, size: 18)],
        ),
        itemBuilder: (context) => options
            .map(
              (opt) => PopupMenuItem(
                value: opt,
                child: Text(
                  opt,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildProductsGrid({required String contentType}) {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        if (contentType == "mixed") {
          if (index % 3 == 0)
            return ProductCard(
              name: "iPhone 15 Pro",
              price: 1150,
              icon: Icons.smartphone,
              hasDiscount: true,
              onAddToCart: () {},
            );
          if (index % 3 == 1)
            return ProductCard(
              name: "شاحن سريع 65W",
              price: 35,
              icon: Icons.bolt,
              onAddToCart: () {},
            );
          return ProductCard(
            name: "سماعة لاسلكية",
            price: 85,
            icon: Icons.headset,
            hasDiscount: true,
            onAddToCart: () {},
          );
        } else if (contentType == "accessories") {
          return ProductCard(
            name: "إكسسوار مميز",
            price: 20,
            icon: Icons.extension,
            hasDiscount: index % 2 == 0,
            onAddToCart: () {},
          );
        } else {
          return ProductCard(
            name: "هاتف ذكي",
            price: 900,
            icon: Icons.smartphone,
            hasDiscount: true,
            onAddToCart: () {},
          );
        }
      },
    );
  }
}
