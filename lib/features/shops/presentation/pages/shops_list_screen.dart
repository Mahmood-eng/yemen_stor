import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/shop_model.dart';

class ShopsListScreen extends StatelessWidget {
  final Map<String, dynamic> market;
  final Map<String, dynamic> subcategory;

  const ShopsListScreen({
    super.key,
    required this.market,
    required this.subcategory,
  });

  @override
  Widget build(BuildContext context) {
    final marketName = market['name'] ?? '';
    final subcategoryName = subcategory['title'] ?? '';
    final subcategoryIcon = subcategory['icon'];

    // الحصول على المحلات المناسبة لنوع السوق
    final shops = mockShopsByMarket[marketName] ?? [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            subcategoryName,
            style: TextStyle(
              color: AppColors.primary,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            // شريط البحث في المحلات
            _buildSearchField(),

            // قائمة المحلات
            Expanded(
              child: shops.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      itemCount: shops.length,
                      itemBuilder: (context, index) {
                        return _buildShopCard(context, shops[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: TextField(
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: "بحث عن محل في مدينة تعز...",
          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "لا توجد محلات متاحة حالياً",
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

  Widget _buildShopCard(BuildContext context, ShopModel shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              shop.name[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          shop.name,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  "${shop.rating} • ",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  shop.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: shop.status == "مفتوح الآن"
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              shop.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.primary.withOpacity(0.5),
        ),
        onTap: () {
          context.push(AppRoutes.shopDetails, extra: {'shop': shop.toJson()});
        },
      ),
    );
  }
}
