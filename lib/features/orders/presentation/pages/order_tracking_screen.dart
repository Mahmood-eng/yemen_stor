import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/features/orders/data/models/order_status.dart';
import '../providers/order_providers.dart';
import '../widgets/tracking_map_widget.dart';
import '../widgets/driver_info_widget.dart';
import '../widgets/order_timeline_widget.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../data/models/order_model.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final orderAsync = ref.watch(singleOrderStreamProvider(orderId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            const TrackingMapWidget(),
            _buildBackButton(context, theme),
            _buildDraggableSheet(context, theme, isDark, orderAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, ThemeData theme) {
    return Positioned(
      top: 50,
      right: 20,
      child: FloatingActionButton.small(
        heroTag: 'back_btn',
        backgroundColor: theme.colorScheme.surface,
        child: Icon(
          Icons.arrow_back_ios_new,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildDraggableSheet(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AsyncValue<OrderModel?> orderAsync,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(isDark ? 0.6 : 0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(25),
            children: [
              // مقبض السحب
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const DriverInfoWidget(name: 'السائق قادم...'),
              const Divider(height: 40),
              orderAsync.when(
                loading: () => const Center(child: CustomLoadingIndicator()),
                error: (err, _) => Text(
                  'خطأ في تحميل الطلب: $err',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                data: (order) {
                  if (order == null) {
                    return const Text(
                      'لم يتم العثور على الطلب',
                      style: TextStyle(fontFamily: 'Cairo'),
                    );
                  }
                  return Column(
                    children: [
                      // Timeline يعتمد على حالة الطلب الحقيقية
                      OrderTimelineWidget(status: order.status),
                      const SizedBox(height: 20),
                      _buildOrderSummary(context, theme, isDark, order),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    OrderModel order,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? theme.dividerColor : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          // صورة الطلب
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: order.imageUrl.isNotEmpty
                ? Image.network(
                    order.imageUrl,
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 65,
                      height: 65,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    width: 65,
                    height: 65,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.grey,
                    ),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب رقم: #${order.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  order.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  order.storeName.isNotEmpty ? order.storeName : 'المتجر',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.formattedPrice,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // حالة الطلب
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: order.status.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              order.status.label,
              style: TextStyle(
                color: order.status.color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
