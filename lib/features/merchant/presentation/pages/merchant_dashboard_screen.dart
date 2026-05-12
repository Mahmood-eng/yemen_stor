import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/features/merchant/presentation/widgets/merchant_metric_card.dart';
import 'package:yemen_store/features/merchant/presentation/widgets/merchant_order_tile.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  int _selectedIndex = 0;
  final String _storeName = 'جوالات اليمن الأفضل';
  final String _status = 'نشط';
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '00021334',
      'customer': 'أنس أحمد العهاني',
      'status': 'قيد الانتظار',
      'color': Colors.amber,
    },
    {
      'id': '00021335',
      'customer': 'سارة محمد العبسي',
      'status': 'تم الشحن',
      'color': Colors.blueGrey,
    },
    {
      'id': '00021336',
      'customer': 'خالد صالح اليماني',
      'status': 'تم التسليم',
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لوحة تحكم التاجر',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.storefront, size: 18),
                const SizedBox(width: 6),
                Text(
                  'يمن ستور',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                context.go(AppRoutes.home);
              },
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'تبديل الحساب',
              iconSize: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلاً بك، متجر $_storeName',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _storeName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _status == 'نشط'
                            ? const Color.fromRGBO(76, 175, 80, 0.12)
                            : const Color.fromRGBO(255, 152, 0, 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _status,
                        style: textTheme.bodyMedium?.copyWith(
                          color: _status == 'نشط'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MerchantMetricCard(
                      title: 'تقييم المتجر',
                      value: '4.8',
                      trailing: Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < 4 ? Icons.star : Icons.star_border,
                            size: 18,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MerchantMetricCard(
                      title: 'الطلبات الجديدة',
                      value: '7',
                      trailing: const Icon(Icons.shopping_bag_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MerchantMetricCard(
                      title: 'إجمالي المنتجات',
                      value: '45',
                      trailing: const Icon(Icons.inventory_2_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MerchantMetricCard(
                      title: 'حالة المنتج',
                      value: '87%',
                      trailing: const Icon(Icons.insights_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'آخر الطلبات',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(AppRoutes.merchantOrders);
                    },
                    child: const Text('الطلبات >'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final order in _orders)
                MerchantOrderTile(
                  orderId: order['id'] as String,
                  customerName: order['customer'] as String,
                  status: order['status'] as String,
                  statusColor: order['color'] as Color,
                ),
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              context.go(AppRoutes.merchantDashboard);
              break;
            case 1:
              context.go(AppRoutes.merchantProducts);
              break;
            case 2:
              context.go(AppRoutes.merchantOrders);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: 'المنتجات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'الطلبات',
          ),
        ],
      ),
    );
  }
}
