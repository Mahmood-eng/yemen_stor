import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/features/markets/data/models/market_model.dart';

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
              ? Colors.orange.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
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
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: market.subCategories.length,
                itemBuilder: (context, index) {
                  final sub = market.subCategories[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        sub['icon'],
                        color: AppColors.primary,
                        size: 24,
                      ),
                      title: Text(
                        sub['title'],
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
                        context.push(
                          AppRoutes.shopsList,
                          extra: {
                            'market': market.toJson(),
                            'subcategory': sub,
                          },
                        );
                      },
                    ),
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
