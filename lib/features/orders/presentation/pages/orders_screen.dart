import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../widgets/order_card.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_status.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "سجل طلباتي",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.brightness == Brightness.dark
                ? Colors.white38
                : Colors.grey,
            labelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: "النشطة"),
              Tab(text: "المكتملة"),
              Tab(text: "الملغاة"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(context, [
              OrderStatus.onWay,
              OrderStatus.processing,
            ]),
            _buildOrdersList(context, [OrderStatus.completed]),
            _buildOrdersList(context, [OrderStatus.canceled]),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<OrderStatus> filterStatus,
  ) {
    final mockOrders = [
      OrderModel(
        id: "1",
        title: "عطر ساواج ديور الرجالي - 100 مل",
        price: "45,000",
        status: OrderStatus.onWay,
        imageset: Image.asset(
          "assets/images/perfume.jpg",
          width: 85,
          height: 85,
          fit: BoxFit.cover,
        ),
        storeName: "متجر النخبة للعطور",
        storeAddress: "شارع جمال",
        marketName: "سوق الجمال",
        categoryName: "عطور",
        time: "اليوم، 10:30 ص",
      ),
      // ... بقية البيانات
    ];

    final filteredOrders = mockOrders
        .where((o) => filterStatus.contains(o.status))
        .toList();

    if (filteredOrders.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return OrderCard(
          order: order,
          onTrackTap: () {
            context.pushNamed(
              AppRoutes.orderTracking,
              pathParameters: {'orderId': order.id},
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 70,
            color: isDark ? Colors.white12 : Colors.grey[300],
          ),
          const SizedBox(height: 15),
          Text(
            "لا توجد طلبات هنا بعد",
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
