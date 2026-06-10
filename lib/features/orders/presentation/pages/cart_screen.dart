import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/custom_button.dart';
import 'package:yemen_stor/core/widgets/custom_loading_indicator.dart';
import '../providers/cart_providers.dart';
import '../providers/order_actions_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isPlacingOrder = false;

  // --- Smart Checkout Popup (with Balance & Delivery) ---
  void _showCheckoutConfirmDialog(
    List<CartItem> cartItems,
    double subTotal,
    double deliveryFee,
    double total,
  ) {
    final userAsync = ref.read(userDocumentStreamProvider);
    final userValue = userAsync.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            String _selectedCurrency = 'YER';

            final double balanceYER = userValue?.balanceYER ?? 0.0;
            final double balanceSAR = userValue?.balanceSAR ?? 0.0;
            final double balanceUSD = userValue?.balanceUSD ?? 0.0;

            // Rough conversion for display (actual logic uses YER)
            final Map<String, Map<String, dynamic>> currencies = {
              'YER': {
                'label': 'ريال يمني (YER)',
                'balance': balanceYER,
                'suffix': 'ر.ي',
                'canAfford': balanceYER >= total,
              },
              'SAR': {
                'label': 'ريال سعودي (SAR)',
                'balance': balanceSAR,
                'suffix': 'ر.س',
                'canAfford': balanceSAR * 53 >= total, // rough rate
              },
              'USD': {
                'label': 'دولار أمريكي (USD)',
                'balance': balanceUSD,
                'suffix': '\$',
                'canAfford': balanceUSD * 1900 >= total, // rough rate
              },
            };

            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 30,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'تأكيد الطلب',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? theme.colorScheme.surface : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          _dialogRow('عدد المنتجات', '${cartItems.length} منتج', theme),
                          const Divider(height: 16),
                          _dialogRow('المجموع الفرعي', '${subTotal.toStringAsFixed(0)} ر.ي', theme),
                          const SizedBox(height: 8),
                          _dialogRow(
                            'رسوم التوصيل',
                            deliveryFee > 0 ? '${deliveryFee.toStringAsFixed(0)} ر.ي' : 'مجاني ✓',
                            theme,
                            valueColor: deliveryFee == 0 ? Colors.green : null,
                          ),
                          const Divider(height: 16),
                          _dialogRow(
                            'الإجمالي (YER)',
                            '${total.toStringAsFixed(0)} ر.ي',
                            theme,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Currency Selector
                    Text(
                      'اختر عملة الدفع',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatefulBuilder(builder: (ctx2, setPickerState) {
                      return Column(
                        children: currencies.entries.map((entry) {
                          final key = entry.key;
                          final info = entry.value;
                          final bal = info['balance'] as double;
                          final suffix = info['suffix'] as String;
                          final canAfford = info['canAfford'] as bool;
                          final isSelected = _selectedCurrency == key;

                          return GestureDetector(
                            onTap: () => setPickerState(() => _selectedCurrency = key),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                    : theme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor.withValues(alpha: 0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isSelected ? theme.colorScheme.primary : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      info['label'] as String,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'رصيدك: ${bal.toStringAsFixed(2)} $suffix',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontFamily: 'Cairo',
                                          color: canAfford ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (!canAfford)
                                        Text(
                                          'رصيد غير كافٍ',
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            color: Colors.red,
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 16),
                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isPlacingOrder
                            ? null
                            : () async {
                                final selectedInfo = currencies[_selectedCurrency]!;
                                if (!(selectedInfo['canAfford'] as bool)) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('رصيدك غير كافٍ في هذه العملة، اختر عملة أخرى أو اشحن محفظتك', style: TextStyle(fontFamily: 'Cairo')),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _isPlacingOrder = true);
                                try {
                                  final user = fb_auth.FirebaseAuth.instance.currentUser;
                                  if (user == null) throw Exception('يجب تسجيل الدخول');

                                  // Place the order
                                  final orderId = await ref.read(orderActionsProvider).placeOrder(
                                    cartItems: cartItems,
                                    userId: user.uid,
                                    deliveryAddress: userValue?.addressDetails ?? 'غير محدد',
                                    deliveryFee: deliveryFee,
                                  );

                                  // Deduct balance based on selected currency
                                  final fieldName = 'balance$_selectedCurrency';
                                  double deductAmount = total;
                                  if (_selectedCurrency == 'SAR') deductAmount = total / 53;
                                  if (_selectedCurrency == 'USD') deductAmount = total / 1900;

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .update({fieldName: FieldValue.increment(-deductAmount)});

                                  // Clear cart
                                  await ref.read(cartActionsProvider).clearCart();

                                  if (mounted) {
                                    Navigator.pop(ctx);
                                    context.push(AppRoutes.orderTracking, extra: {'orderId': orderId});
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('فشل في إتمام الطلب: $e', style: const TextStyle(fontFamily: 'Cairo')),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _isPlacingOrder = false);
                                }
                              },
                        icon: _isPlacingOrder
                            ? const SizedBox(width: 20, height: 20, child: CustomLoadingIndicator(size: 20, color: Colors.white))
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _isPlacingOrder ? 'جارٍ تنفيذ الطلب...' : 'تأكيد الطلب والدفع',
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogRow(String label, String value, ThemeData theme, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'Cairo',
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 15 : null,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16 : null,
            color: valueColor ?? (isTotal ? theme.colorScheme.primary : null),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cartAsync = ref.watch(cartStreamProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            "سلة التسوق",
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.primary, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            // زر مسح السلة
            cartAsync.maybeWhen(
              data: (items) => items.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.delete_sweep_outlined, color: Colors.red.shade400),
                      tooltip: 'مسح السلة',
                      onPressed: () async {
                        await ref.read(cartActionsProvider).clearCart();
                      },
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        body: cartAsync.when(
          data: (cartItems) {
            if (cartItems.isEmpty) return _buildEmptyCart(theme);
            final double subTotal = cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
            final double deliveryFee = subTotal > 0 ? 1000.0 : 0.0;
            final double total = subTotal + deliveryFee;

            return Column(
              children: [
                Expanded(child: _buildCartContent(theme, isDark, cartItems)),
                _buildCheckoutSection(theme, isDark, cartItems, subTotal, deliveryFee, total),
              ],
            );
          },
          loading: () => const Center(child: CustomLoadingIndicator()),
          error: (err, stack) => Center(
            child: Text("حدث خطأ في تحميل السلة: $err", style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ),
      ),
    );
  }

  Widget _buildCartContent(ThemeData theme, bool isDark, List<CartItem> cartItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              // صورة المنتج
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                  image: item.imageUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: item.imageUrl.isEmpty
                    ? const Icon(Icons.shopping_basket_outlined, color: AppColors.primary, size: 35)
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.shopName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Cairo',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${item.price.toStringAsFixed(0)} ر.ي",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => ref.read(cartActionsProvider).removeFromCart(item.id),
                  ),
                  Row(
                    children: [
                      _quantityBtn(Icons.add, () {
                        ref.read(cartActionsProvider).updateQuantity(item.id, item.quantity + 1);
                      }, theme),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      _quantityBtn(Icons.remove, () {
                        ref.read(cartActionsProvider).updateQuantity(item.id, item.quantity - 1);
                      }, theme),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildCheckoutSection(
    ThemeData theme,
    bool isDark,
    List<CartItem> cartItems,
    double subTotal,
    double deliveryFee,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow("المجموع الفرعي", "${subTotal.toStringAsFixed(0)} ر.ي", theme),
          const SizedBox(height: 8),
          _summaryRow(
            "رسوم التوصيل",
            deliveryFee > 0 ? "${deliveryFee.toStringAsFixed(0)} ر.ي" : "مجاني",
            theme,
          ),
          const Divider(height: 24),
          _summaryRow("الإجمالي", "${total.toStringAsFixed(0)} ر.ي", theme, isTotal: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showCheckoutConfirmDialog(cartItems, subTotal, deliveryFee, total),
              icon: const Icon(Icons.payment_outlined),
              label: const Text(
                "إتمام الشراء",
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, ThemeData theme, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'Cairo',
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'Cairo',
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_basket_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 24),
          Text(
            "سلة التسوق فارغة",
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ابدأ بإضافة المنتجات التي تعجبك الآن",
            style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Cairo', color: Colors.grey),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 200,
            child: CustomButton(text: "تسوق الآن", onPressed: () => context.go('/home')),
          ),
        ],
      ),
    );
  }
}
