import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';
import 'package:yemen_stor/core/widgets/notification_badge_icon.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/order_providers.dart';
import '../widgets/order_card.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_status.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(userOrdersStreamProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: YemenStoreAppBar(
          title: const Text('سجل طلباتي'),
          leading: const SizedBox.shrink(),
          actions: [
            NotificationBadgeIcon(
              color: theme.appBarTheme.iconTheme?.color,
            ),
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: theme.appBarTheme.iconTheme?.color,
              ),
              onPressed: () => context.push(AppRoutes.cart),
            ),
          ],
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.brightness == Brightness.dark
                ? Colors.white38
                : Colors.grey,
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'النشطة'),
              Tab(text: 'المكتملة'),
              Tab(text: 'الملغاة'),
            ],
          ),
        ),
        body: ordersAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'حدث خطأ: $err',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          data: (orders) => TabBarView(
            children: [
              _buildOrdersList(
                context,
                orders,
                [OrderStatus.onWay, OrderStatus.processing],
              ),
              _buildOrdersList(
                context,
                orders,
                [OrderStatus.completed],
              ),
              _buildOrdersList(
                context,
                orders,
                [OrderStatus.canceled],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<OrderModel> allOrders,
    List<OrderStatus> filterStatus,
  ) {
    final filtered =
        allOrders.where((o) => filterStatus.contains(o.status)).toList();

    if (filtered.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        return OrderCard(
          order: order,
          onTrackTap: () {
            context.push('${AppRoutes.orders}/tracking/${order.id}');
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
            'لا توجد طلبات هنا بعد',
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
