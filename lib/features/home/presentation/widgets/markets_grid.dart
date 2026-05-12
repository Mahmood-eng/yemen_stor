import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import '../../../../features/markets/data/models/market_model.dart';

class MarketsGrid extends StatelessWidget {
  const MarketsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. نأخذ أول 5 أسواق فقط من الموديل
    final List<MarketModel> displayMarkets = mockMarkets.take(5).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.85,
      ),
      // الإجمالي 6 (5 من الموديل + 1 "المزيد")
      itemCount: displayMarkets.length + 1,
      itemBuilder: (context, index) {
        // إذا وصلنا للعنصر الأخير، نظهر "المزيد"
        if (index == displayMarkets.length) {
          return _buildMoreItem(context, isDark);
        }

        final market = displayMarkets[index];
        bool isArta = market.name == "عرطة";
        return _buildMarketItem(context, market, isArta, isDark);
      },
    );
  }

  // ويدجت السوق العادي
  Widget _buildMarketItem(
    BuildContext context,
    MarketModel market,
    bool isArta,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        if (isArta) {
          context.push(AppRoutes.marketsArta);
        } else {
          _showSubcategoriesBottomSheet(context, market);
        }
      },
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha((0.05 * 255).round())
                  : AppColors.primary.withAlpha((0.05 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              border: isArta
                  ? Border.all(color: Colors.orange, width: 1.5)
                  : null,
            ),
            child: Icon(
              market.icon,
              size: 32,
              color: isArta ? Colors.orange : AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            market.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: isArta ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // نافذة منبثقة لعرض أقسام السوق
  void _showSubcategoriesBottomSheet(BuildContext context, MarketModel market) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // الارتفاع المبدئي (60% من الشاشة)
          minChildSize: 0.4, // أقل ارتفاع عند السحب لأسفل قبل الإغلاق
          maxChildSize: 0.9, // أقصى ارتفاع عند السحب لأعلى
          expand: false, // لكي لا تأخذ مساحة الشاشة بالكامل فوراً
          builder: (context, scrollController) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  // مقبض السحب
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // رأس النافذة
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(market.icon, color: AppColors.primary, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          "أقسام ${market.name}",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // قائمة الأقسام مع ربط الـ scrollController
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      itemCount: market.subCategories.length,
                      itemBuilder: (context, index) {
                        final sub = market.subCategories[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Icon(
                              sub['icon'] as IconData,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              sub['title'] as String,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Navigator.pop(context);
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
            );
          },
        );
      },
    );
  }

  // ويدجت "المزيد" الاستثنائي
  Widget _buildMoreItem(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () {
        // يودينا لصفحة كل الأسواق
        context.push(AppRoutes.markets);
      },
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha((0.05 * 255).round())
                  : Colors.grey.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              size: 32,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "المزيد",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
