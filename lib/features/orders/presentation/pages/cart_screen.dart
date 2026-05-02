import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import 'package:yemen_store/features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_status.dart';
import 'package:yemen_store/core/widgets/custom_button.dart';

class CartScreen extends StatelessWidget {
  static const String id = 'cart_screen';
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("سلة المشتريات"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final items = cartProvider.items;

          if (items.isEmpty) {
            return const Center(
              child: Text("سلة المشتريات فارغة"),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final cartItem = items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(15),
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
                              color: isDark ? Colors.white10 : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(cartItem.product.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),

                          // تفاصيل المنتج
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItem.product.name,
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "\$${cartItem.product.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                
                                // العداد (زيادة ونقصان)
                                Row(
                                  children: [
                                    _buildCounterButton(
                                      icon: Icons.remove, 
                                      isDark: isDark, 
                                      onTap: () {
                                        cartProvider.decrementQuantity(cartItem.product.id);
                                      }
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        "${cartItem.quantity}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    _buildCounterButton(
                                      icon: Icons.add, 
                                      isDark: isDark, 
                                      onTap: () {
                                        cartProvider.addToCart(cartItem.product);
                                      }
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () {
                                        cartProvider.removeFromCart(cartItem.product.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // ملخص السعر والدفع
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("الإجمالي:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          "\$${cartProvider.totalPrice.toStringAsFixed(2)}", 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                      text: "إتمام الشراء",
                      onPressed: () async {
                        final authProvider = context.read<AuthProvider>();
                        final ordersProvider = context.read<OrdersProvider>();
                        
                        // التحقق من الرصيد وخصمه
                        final success = await authProvider.deductBalance(cartProvider.totalPrice);
                        
                        if (!context.mounted) return;

                        if (success) {
                          // إضافة الطلب إلى سجل الطلبات
                          final newOrder = OrderModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString().substring(7), // توليد ID عشوائي
                            title: "طلب شراء - ${cartProvider.itemCount} منتجات",
                            price: cartProvider.totalPrice.toStringAsFixed(2),
                            status: OrderStatus.processing, // قيد الانتظار أو المعالجة
                            imageset: Image.asset(
                              cartProvider.items.first.product.image,
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                            ),
                            storeName: "يمن ستور",
                            time: "الآن",
                          );
                          
                          ordersProvider.addOrder(newOrder);
                          cartProvider.clearCart();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم إرسال الطلب بنجاح وخصم المبلغ من رصيدك!')),
                          );
                          
                          // الانتقال إلى صفحة الطلبات
                          Navigator.of(context).pop();
                          // ملاحظة: يمكنك استدعاء context.push(AppRoutes.orders) إذا أردت نقله مباشرة للطلبات
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authProvider.errorMessage ?? 'الرصيد غير كافٍ لإتمام العملية'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCounterButton({required IconData icon, required bool isDark, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }
}
