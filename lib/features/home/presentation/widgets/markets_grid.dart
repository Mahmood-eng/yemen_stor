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
          context.push(AppRoutes.markets);
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
