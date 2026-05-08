import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';

class MerchantOrdersScreen extends StatefulWidget {
  const MerchantOrdersScreen({super.key});

  @override
  State<MerchantOrdersScreen> createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends State<MerchantOrdersScreen> {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '00021334',
      'customer': 'أنس أحمد العهاني',
      'status': 'قيد الانتظار',
      'statusColor': Colors.amber,
      'items': [
        {'name': 'هاتف سامسونج', 'quantity': 1, 'price': 250000},
      ],
      'total': 250000,
      'date': '2024-01-15',
    },
    {
      'id': '00021335',
      'customer': 'سارة محمد العبسي',
      'status': 'تم الشحن',
      'statusColor': Colors.blue,
      'items': [
        {'name': 'سماعات بلوتوث', 'quantity': 2, 'price': 15000},
      ],
      'total': 30000,
      'date': '2024-01-14',
    },
    {
      'id': '00021336',
      'customer': 'خالد صالح اليماني',
      'status': 'تم التسليم',
      'statusColor': Colors.green,
      'items': [
        {'name': 'لابتوب ديل', 'quantity': 1, 'price': 450000},
      ],
      'total': 450000,
      'date': '2024-01-13',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الطلبات',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'طلب #${order['id']}',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: order['statusColor'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order['status'],
                                style: textTheme.bodySmall?.copyWith(
                                  color: order['statusColor'],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order['customer'],
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order['date'],
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'المنتجات:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...order['items'].map<Widget>((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item['name']} (x${item['quantity']})'),
                                Text(
                                  '${item['price'] * item['quantity']} ريال',
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'المجموع:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${order['total']} ريال',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (order['status'] == 'قيد الانتظار') ...[
                              TextButton.icon(
                                onPressed: () =>
                                    _updateOrderStatus(order, 'جاري التجهيز'),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text(
                                  'قبول',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                  foregroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: const Size(60, 32),
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton.icon(
                                onPressed: () =>
                                    _showRejectDialog(context, order),
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text(
                                  'رفض',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: const Size(60, 32),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () {
                                  _sendNotification(
                                    order,
                                    'تم إرسال طلبك للمراجعة من قبل التاجر.',
                                  );
                                },
                                icon: const Icon(
                                  Icons.notifications_active,
                                  size: 16,
                                ),
                                tooltip: 'إشعار',
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  foregroundColor: Colors.blue,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ] else if (order['status'] == 'جاري التجهيز') ...[
                              TextButton.icon(
                                onPressed: () =>
                                    _updateOrderStatus(order, 'جاري التوصيل'),
                                icon: const Icon(
                                  Icons.local_shipping,
                                  size: 16,
                                ),
                                label: const Text(
                                  'توصيل',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  foregroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: const Size(60, 32),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () {
                                  _sendNotification(
                                    order,
                                    'طلبك الآن في مرحلة التجهيز لدى التاجر.',
                                  );
                                },
                                icon: const Icon(Icons.info_outline, size: 16),
                                tooltip: 'إشعار',
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.orange.withOpacity(
                                    0.1,
                                  ),
                                  foregroundColor: Colors.orange,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ] else if (order['status'] == 'جاري التوصيل') ...[
                              TextButton.icon(
                                onPressed: () =>
                                    _updateOrderStatus(order, 'تم التسليم'),
                                icon: const Icon(Icons.check_circle, size: 16),
                                label: const Text(
                                  'تسليم',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                  foregroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: const Size(60, 32),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () {
                                  _sendNotification(
                                    order,
                                    'طلبك في الطريق وسيصلك قريباً.',
                                  );
                                },
                                icon: const Icon(
                                  Icons.local_shipping_outlined,
                                  size: 16,
                                ),
                                tooltip: 'تتبع',
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.purple.withOpacity(
                                    0.1,
                                  ),
                                  foregroundColor: Colors.purple,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ] else if (order['status'] == 'تم التسليم') ...[
                              IconButton(
                                onPressed: null,
                                icon: const Icon(Icons.done_all, size: 16),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                  foregroundColor: Colors.green,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ] else if (order['status'] == 'مرفوض') ...[
                              IconButton(
                                onPressed: null,
                                icon: const Icon(Icons.cancel, size: 16),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  foregroundColor: Colors.red,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
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

  void _updateOrderStatus(Map<String, dynamic> order, String newStatus) {
    setState(() {
      order['status'] = newStatus;
      switch (newStatus) {
        case 'مرفوض':
          order['statusColor'] = Colors.red;
          break;
        case 'جاري التجهيز':
          order['statusColor'] = Colors.orange;
          break;
        case 'جاري التوصيل':
          order['statusColor'] = Colors.blue;
          break;
        case 'تم التسليم':
          order['statusColor'] = Colors.green;
          break;
      }
    });

    String message;
    switch (newStatus) {
      case 'مرفوض':
        message = 'تم رفض الطلب وتم إرسال السبب للعميل.';
        break;
      case 'جاري التجهيز':
        message = 'تم قبول الطلب ويجري الآن التجهيز.';
        break;
      case 'جاري التوصيل':
        message = 'تم تجهيز الطلب ويجري توصيله الآن.';
        break;
      case 'تم التسليم':
        message = 'تم تسليم الطلب بنجاح.';
        break;
      default:
        message = 'تم تحديث حالة الطلب إلى: $newStatus';
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _sendNotification(Map<String, dynamic> order, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('إشعار للمستخدم: $message')));
  }

  void _showRejectDialog(BuildContext context, Map<String, dynamic> order) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اكتب سبب الرفض ليصله العميل:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'سبب الرفض...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال سبب الرفض.')),
                );
                return;
              }
              setState(() {
                order['status'] = 'مرفوض';
                order['statusColor'] = Colors.red;
                order['rejectReason'] = reason;
              });
              Navigator.of(context).pop();
              _sendNotification(order, 'تم رفض طلبك. السبب: $reason');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }
}
