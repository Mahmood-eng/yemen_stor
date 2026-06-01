import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';
import '../providers/merchant_providers.dart';

class MerchantOrdersScreen extends ConsumerStatefulWidget {
  const MerchantOrdersScreen({super.key});

  @override
  ConsumerState<MerchantOrdersScreen> createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends ConsumerState<MerchantOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'الرجاء تسجيل الدخول أولاً للوصول لطلبات متجرك',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('العودة للرئيسية', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      );
    }

    // Watch merchant shop stream from Clean Architecture layer via Riverpod
    final shopAsync = ref.watch(merchantShopStreamProvider(uid));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: shopAsync.when(
        loading: () => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
            child: Text(
              'حدث خطأ في تحميل المتجر: $error',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ),
        data: (shop) {
          if (shop == null) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: YemenStoreAppBar(
                title: Text(
                  'طلبات المتجر',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.appBarTheme.iconTheme?.color),
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 80,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'لا يوجد متجر مرتبط بحسابك لعرض الطلبات',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.go(AppRoutes.merchantRegistration),
                        child: const Text(
                          'سجل متجرك الآن',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final shopId = shop.id;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: YemenStoreAppBar(
              title: Text(
                'طلبات متجري',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.appBarTheme.iconTheme?.color),
                onPressed: () => context.go(AppRoutes.merchantDashboard),
              ),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('shopId', isEqualTo: shopId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, ordersSnapshot) {
                if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!ordersSnapshot.hasData || ordersSnapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: colorScheme.onSurface.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد طلبات واردة حالياً للمتجر',
                            style: textTheme.titleMedium?.copyWith(
                              fontFamily: 'Cairo',
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final orders = ordersSnapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final doc = orders[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final orderId = doc.id;
                    final displayId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;

                    final customer = data['customerName'] ?? data['customer'] ?? 'عميل يمن ستور';
                    final status = data['status'] ?? 'قيد الانتظار';
                    final total = (data['total'] ?? 0.0).toDouble();

                    // تحويل التاريخ وعرضه
                    String dateStr = 'اليوم';
                    if (data['createdAt'] != null) {
                      final timestamp = data['createdAt'] as Timestamp;
                      final date = timestamp.toDate();
                      dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    } else if (data['date'] != null) {
                      dateStr = data['date'].toString();
                    }

                    final items = List<Map<String, dynamic>>.from(
                      data['items'] ??
                          [
                            {
                              'name': 'منتج مضاف من المتجر',
                              'quantity': 1,
                              'price': total,
                            },
                          ],
                    );

                    Color statusColor = Colors.amber;
                    switch (status) {
                      case 'مرفوض':
                        statusColor = Colors.red;
                        break;
                      case 'جاري التجهيز':
                        statusColor = Colors.orange;
                        break;
                      case 'جاري التوصيل':
                        statusColor = Colors.blue;
                        break;
                      case 'تم التسليم':
                        statusColor = Colors.green;
                        break;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                                  'طلب #$displayId',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontFamily: 'Cairo',
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
                                const SizedBox(width: 6),
                                Text(
                                  customer,
                                  style: textTheme.bodyMedium?.copyWith(fontFamily: 'Cairo'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
                                const SizedBox(width: 6),
                                Text(
                                  dateStr,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontFamily: 'Cairo',
                                    color: colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'المنتجات والكميات المطلوبة:',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...items.map<Widget>((item) {
                              final name = item['name'] ?? 'منتج';
                              final qty = item['quantity'] ?? 1;
                              final price = (item['price'] ?? 0.0).toDouble();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$name (x$qty)',
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                    ),
                                    Text(
                                      '${(price * qty).toStringAsFixed(0)} ريال',
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'إجمالي قيمة الطلب:',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${total.toStringAsFixed(0)} ريال يمني',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            if (data['rejectReason'] != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.red.withOpacity(0.1)),
                                ),
                                child: Text(
                                  'سبب رفض الطلب: ${data['rejectReason']}',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            
                            // أزرار التحكم في حالة الطلب
                            Row(
                              children: [
                                if (status == 'قيد الانتظار') ...[
                                  TextButton.icon(
                                    onPressed: () => _updateOrderStatus(orderId, 'جاري التجهيز'),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text(
                                      'قبول وتجهيز',
                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.green.withOpacity(0.1),
                                      foregroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _showRejectDialog(context, orderId),
                                    icon: const Icon(Icons.close, size: 16),
                                    label: const Text(
                                      'رفض الطلب',
                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.red.withOpacity(0.1),
                                      foregroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ] else if (status == 'جاري التجهيز') ...[
                                  TextButton.icon(
                                    onPressed: () => _updateOrderStatus(orderId, 'جاري التوصيل'),
                                    icon: const Icon(Icons.local_shipping_outlined, size: 16),
                                    label: const Text(
                                      'بدء عملية التوصيل',
                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue.withOpacity(0.1),
                                      foregroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ] else if (status == 'جاري التوصيل') ...[
                                  TextButton.icon(
                                    onPressed: () => _updateOrderStatus(orderId, 'تم التسليم'),
                                    icon: const Icon(Icons.check_circle_outline, size: 16),
                                    label: const Text(
                                      'تأكيد التسليم بنجاح',
                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.green.withOpacity(0.1),
                                      foregroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ] else if (status == 'تم التسليم') ...[
                                  const Icon(Icons.done_all, color: Colors.green, size: 20),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'تم تسليم هذا الطلب للعميل بنجاح ✓',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ] else if (status == 'مرفوض') ...[
                                  const Icon(Icons.cancel, color: Colors.red, size: 20),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'تم رفض هذا الطلب وإشعار العميل',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
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
                );
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 2,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurface.withOpacity(0.4),
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
                  activeIcon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_outlined),
                  activeIcon: Icon(Icons.grid_view),
                  label: 'المنتجات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag),
                  label: 'الطلبات',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateOrderStatus(
    String orderId,
    String newStatus, {
    String? rejectReason,
  }) async {
    try {
      final data = {
        'status': newStatus,
        if (rejectReason != null) 'rejectReason': rejectReason,
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تحديث حالة الطلب إلى "$newStatus" ✓',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل تحديث حالة الطلب: $e',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context, String orderId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'رفض طلب العميل',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'يرجى توضيح سبب رفض الطلب للعميل:',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: 'اكتب سبب الرفض هنا...',
                hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(dialogCtx).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'الرجاء كتابة سبب الرفض أولاً.',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                );
                return;
              }
              Navigator.of(dialogCtx).pop();
              await _updateOrderStatus(orderId, 'مرفوض', rejectReason: reason);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'تأكيد الرفض',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
