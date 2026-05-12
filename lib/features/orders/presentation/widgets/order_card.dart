import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_status.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTrackTap;

  const OrderCard({super.key, required this.order, required this.onTrackTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: theme.cardColor, // يستخدم اللون المحدد في الثيم
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: order.imageset,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "طلب رقم: ${order.id}",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildStatusBadge(context, order.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.time,
                        style: theme
                            .textTheme
                            .bodySmall, // يستخدم تنسيق الخط من الثيم
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${order.price} ريال",
                        style: TextStyle(
                          color: colorScheme
                              .primary, // جلب اللون الكحلي من الـ ColorScheme
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // المنطق الذكي للزر
          if (order.status == OrderStatus.onWay ||
              order.status == OrderStatus.processing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: ElevatedButton(
                onPressed: onTrackTap,
                child: const Text("تتبع مسار الطلب"),
              ),
            ),

          const SizedBox(height: 8),

          // القسم السفلي (موقع المتجر)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(
                0.05,
              ), // اشتقاق لون خفيف من اللون الرئيسي
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.store_mall_directory_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${order.marketName} • ${order.categoryName}',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    '${order.storeName} (${order.storeAddress})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(
          0.25,
        ), // زيادة الشفافية لجعل الخلفية أكثر وضوحاً
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
