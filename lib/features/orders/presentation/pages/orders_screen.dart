// lib/features/orders/presentation/pages/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/features/orders/presentation/widgets/OrderCard.dart';


class OrdersScreen extends StatelessWidget {
  static const String id = 'orders_screen';

  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF4F7F9),
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: Text("سجل طلباتي",
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary)),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? Colors.white38 : Colors.grey,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "النشطة"),
              Tab(text: "المكتملة"),
              Tab(text: "الملغاة"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersList(type: "active"),
            OrdersList(type: "completed"),
            OrdersList(type: "cancelled"),
          ],
        ),
        // هنا نربطها بالشريط السفلي المشترك
        
      ),
    );
  }
}

// ويدجت القائمة المنفصلة
class OrdersList extends StatelessWidget {
  final String type;
  const OrdersList({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
   
    final List<Map<String, dynamic>> allOrders = [
      {
        'id': '12345',
        'status': 'قيد التوصيل',
        'statusColor': Colors.orange,
        'date': '2024-06-15',
        'total': 250.00,
        'type': 'active',
      },
      {
        'id': '67890',
        'status': 'تم التوصيل',
        'statusColor': Colors.green,
        'date': '2024-05-20',
        'total': 150.00,
        'type': 'completed',
      },
      {
        'id': '54321',
        'status': 'ملغى',
        'statusColor': Colors.red,
        'date': '2024-04-10',
        'total': 300.00,
        'type': 'cancelled',
      },
    ];

    final filteredOrders = allOrders.where((o) => o['type'] == type).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text("لا توجد طلبات هنا",
            style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[400])),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return OrderCard(
          order: filteredOrders[index],
          onTrackPressed: () {
            // الانتقال لصفحة التتبع عبر الرووت
            Navigator.pushNamed(context, '/order_tracking', arguments: filteredOrders[index]);
          },
        );
      },
    );
  }
}