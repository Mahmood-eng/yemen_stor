import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';
import 'package:yemen_stor/core/widgets/custom_loading_indicator.dart';
import 'package:yemen_stor/features/markets/data/models/market_model.dart';

class MarketExpansionCard extends StatelessWidget {
  final MarketModel market;
  final bool isDark;

  const MarketExpansionCard({
    super.key,
    required this.market,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    bool isArta = market.name == "عرطة";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isArta ? Border.all(color: Colors.orange, width: 1.2) : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: CircleAvatar(
          backgroundColor: isArta
              ? Colors.orange.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            market.icon,
            color: isArta ? Colors.orange : AppColors.primary,
          ),
        ),
        title: Text(
          market.name,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 16,
            color: isArta ? Colors.orange : null,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () => _onMarketTap(context, isArta),
      ),
    );
  }

  void _onMarketTap(BuildContext context, bool isArta) {
    if (isArta) {
      // العرطة - انتقل مباشرة
      context.push(AppRoutes.marketsArta);
    } else {
      // أسواق أخرى - أظهر BottomSheet مع الأقسام الفرعية
      _showSubcategoriesBottomSheet(context);
    }
  }

  void _showSubcategoriesBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(market.icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "أقسام ${market.name}",
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Subcategories List
            // جلب الأقسام من Firestore مع مؤشر تحميل
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(
                      'app_data/main_config/markets/${market.id}/categories',
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomLoadingIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("خطأ في تحميل الأقسام"));
                  }

                  final categories = (snapshot.data?.docs ?? []).map((doc) {
                    return CategoryModel.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                  }).toList();

                  if (categories.isEmpty) {
                    return const Center(child: Text("لا توجد أقسام متوفرة"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final legacySub = category.toLegacyMap();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            legacySub['icon'] as IconData,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          title: Text(
                            legacySub['title'] as String,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close bottom sheet
                            // الانتقال إلى شاشة الأقسام الفرعية أولاً
                            context.push(
                              AppRoutes.subcategories,
                              extra: {
                                'marketId': market.id,
                                'marketName': market.name,
                                'categoryId': category.id,
                                'subcategoryName': category.name,
                                'iconName': category.iconName,
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
