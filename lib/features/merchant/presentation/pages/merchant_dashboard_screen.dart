import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';
import 'package:yemen_stor/features/merchant/presentation/widgets/merchant_metric_card.dart';
import 'package:yemen_stor/features/merchant/presentation/widgets/merchant_order_tile.dart';
import '../providers/merchant_providers.dart';
import '../../domain/entities/merchant_shop_entity.dart';

class MerchantDashboardScreen extends ConsumerStatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  ConsumerState<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends ConsumerState<MerchantDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
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
                'الرجاء تسجيل الدخول أولاً للوصول للوحة التحكم',
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
              'حدث خطأ في تحميل بيانات المتجر: $error',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ),
        data: (shop) {
          if (shop == null) {
            return _buildNoShopScreen(context, theme, textTheme, colorScheme);
          }

          final storeName = shop.name;
          final status = shop.status;
          final rating = shop.rating;
          final shopId = shop.id;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: YemenStoreAppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لوحة تحكم التاجر',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        storeName,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.65),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'تبديل الحساب للزبون',
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- بطاقة حالة المحل والوصف ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أهلاً بك مجدداً، متجر $storeName',
                            style: textTheme.titleMedium?.copyWith(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            shop.description.isNotEmpty ? shop.description : 'لا يوجد وصف مضاف للمتجر حالياً.',
                            style: textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Cairo',
                              color: colorScheme.onSurface.withOpacity(0.65),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: status == 'مفتوح الآن' || status == 'نشط'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'Cairo',
                                    color: status == 'مفتوح الآن' || status == 'نشط' ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    status == 'مفتوح الآن' || status == 'نشط' ? 'إغلاق المتجر مؤقتاً' : 'فتح المتجر الآن',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontFamily: 'Cairo',
                                      color: colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Switch(
                                    value: status == 'مفتوح الآن' || status == 'نشط',
                                    activeColor: Colors.green,
                                    onChanged: (val) async {
                                      final newStatus = val ? 'مفتوح الآن' : 'مغلق مؤقتاً';
                                      try {
                                        // Update status using Clean Architecture update shop status use case
                                        final updateStatus = ref.read(updateShopStatusUseCaseProvider);
                                        await updateStatus(shopId, newStatus);
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('فشل في تحديث حالة المتجر: $e', style: const TextStyle(fontFamily: 'Cairo')),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // --- بطاقات الإحصائيات (Metrics) ---
                    Row(
                      children: [
                        Expanded(
                          child: MerchantMetricCard(
                            title: 'تقييم المتجر',
                            value: rating.toStringAsFixed(1),
                            trailing: Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < rating.round() ? Icons.star : Icons.star_border,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('orders')
                                .where('shopId', isEqualTo: shopId)
                                .where('status', isEqualTo: 'قيد الانتظار')
                                .snapshots(),
                            builder: (context, snapshot) {
                              final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              return MerchantMetricCard(
                                title: 'الطلبات الجديدة',
                                value: count.toString(),
                                trailing: Icon(Icons.shopping_bag_outlined, color: colorScheme.primary),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('products')
                                .where('shopId', isEqualTo: shopId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              return MerchantMetricCard(
                                title: 'إجمالي المنتجات',
                                value: count.toString(),
                                trailing: Icon(Icons.inventory_2_outlined, color: colorScheme.primary),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MerchantMetricCard(
                            title: 'حالة العمل',
                            value: status == 'مفتوح الآن' || status == 'نشط' ? 'مفتوح' : 'مغلق',
                            trailing: Icon(Icons.insights_outlined, color: colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    
                    // --- آخر الطلبات الواردة ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'آخر الطلبات المستلمة',
                          style: textTheme.titleMedium?.copyWith(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push(AppRoutes.merchantOrders);
                          },
                          child: Text(
                            'كل الطلبات >',
                            style: TextStyle(fontFamily: 'Cairo', color: colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .where('shopId', isEqualTo: shopId)
                          .orderBy('createdAt', descending: true)
                          .limit(3)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                            ),
                            child: const Center(
                              child: Text(
                                'لا توجد طلبات واردة للمتجر حالياً',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }

                        final orders = snapshot.data!.docs;
                        return Column(
                          children: orders.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final id = doc.id;
                            final customer = data['customerName'] ?? data['customer'] ?? 'عميل يمن ستور';
                            final orderStatus = data['status'] ?? 'قيد الانتظار';

                            Color statusColor = Colors.amber;
                            switch (orderStatus) {
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

                            final displayId = id.length > 8 ? id.substring(0, 8) : id;

                            return MerchantOrderTile(
                              orderId: displayId,
                              customerName: customer,
                              status: orderStatus,
                              statusColor: statusColor,
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurface.withOpacity(0.4),
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

  Widget _buildNoShopScreen(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: YemenStoreAppBar(
          title: const Text(
            'لوحة تحكم التاجر',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 100,
                  color: colorScheme.primary.withOpacity(0.6),
                ),
                const SizedBox(height: 24),
                Text(
                  'لا يوجد متجر مرتبط بحسابك',
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'يبدو أنك لم تقم بإنشاء متجر بعد، أو أن حسابك غير مسجل كتاجر. يمكنك إنشاء متجر جديد الآن والبدء في بيع منتجاتك!',
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Cairo',
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.merchantRegistration),
                  icon: const Icon(Icons.add_business_outlined),
                  label: const Text(
                    'أنشئ متجرك الآن',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text(
                    'العودة للرئيسية',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
