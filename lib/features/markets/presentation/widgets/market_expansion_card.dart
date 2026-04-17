import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/features/markets/data/models/market_model.dart';

class MarketExpansionCard extends StatelessWidget {
  final MarketModel market;
  final bool isDark;

  const MarketExpansionCard({super.key, required this.market, required this.isDark});

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
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: isArta ? Colors.orange.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
          child: Icon(market.icon, color: isArta ? Colors.orange : AppColors.primary),
        ),
        title: Text(
          market.name,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 16,
            color: isArta ? Colors.orange : null,
          ),
        ),
        children: market.subCategories.map((sub) => ListTile(
          leading: Icon(sub['icon'], size: 18, color: Colors.grey),
          title: Text(sub['title'], style: const TextStyle(fontSize: 14)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 12),
          onTap: () { /* التنقل لصفحة المحلات */ },
        )).toList(),
      ),
    );
  }
}