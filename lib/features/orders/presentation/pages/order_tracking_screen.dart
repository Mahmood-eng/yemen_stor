import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/tracking_map_widget.dart';
import '../widgets/driver_info_widget.dart';
import '../widgets/order_timeline_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            const TrackingMapWidget(),
            _buildBackButton(theme),
            _buildDraggableSheet(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return Positioned(
      top: 50,
      right: 20,
      child: FloatingActionButton.small(
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

  Widget _buildDraggableSheet(ThemeData theme, bool isDark) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.35,
      maxChildSize: 0.8,
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
              const DriverInfoWidget(name: "أحمد سعيد المقطري"),
              const Divider(height: 40),
              const OrderTimelineWidget(),
              const SizedBox(height: 30),
              _buildOrderSummary(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    // تعريف بيانات الطلب التجريبية لحل مشكلة المتغير غير المعرف
    final orderData = {
      'id': widget.orderId,
      'image': 'assets/images/perfume.jpg',
      'items': 'عطر ساواج ديور الرجالي - 100 مل',
      'shop': 'متجر النخبة للعطور',
    };

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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              orderData['image']!,
              width: 65,
              height: 65,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "طلب رقم: #${orderData['id']}",
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  orderData['items']!,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  orderData['shop']!,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // زر عرض الفاتورة / التفاصيل
          TextButton(
            onPressed: () {
              // هنا يمكنك إضافة منطق عرض الفاتورة
            },
            child: const Text(
              "عرض التفاصيل ",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
