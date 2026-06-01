import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/custom_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // بيانات تجريبية للسلة
  final List<Map<String, dynamic>> _cartItems = [
    {
      "id": "1",
      "name": "iPhone 15 Pro Max",
      "price": 1200.0,
      "quantity": 1,
      "image": Icons.smartphone,
      "shop": "سامي عدنان للأجهزة",
    },
    {
      "id": "2",
      "name": "ساعة ذكية Ultra",
      "price": 150.0,
      "quantity": 2,
      "image": Icons.watch,
      "shop": "متجر الإلكترونيات",
    },
  ];

  double get _subTotal => _cartItems.fold(
    0,
    (sum, item) => sum + (item['price'] * item['quantity']),
  );
  double get _deliveryFee => 5.0;
  double get _total => _subTotal + _deliveryFee;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            "سلة التسوق",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: _cartItems.isEmpty
            ? _buildEmptyCart()
            : _buildCartContent(isDark),
        bottomNavigationBar: _cartItems.isEmpty
            ? null
            : _buildCheckoutSection(isDark),
      ),
    );
  }

  Widget _buildCartContent(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // صورة المنتج (أيقونة مؤقتة)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(item['image'], color: AppColors.primary, size: 35),
              ),
              const SizedBox(width: 15),
              // تفاصيل المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      item['shop'],
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "\$${item['price']}",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              // التحكم في الكمية
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _cartItems.removeAt(index)),
                  ),
                  Row(
                    children: [
                      _quantityBtn(Icons.add, () {
                        setState(() => item['quantity']++);
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "${item['quantity']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _quantityBtn(Icons.remove, () {
                        if (item['quantity'] > 1) {
                          setState(() => item['quantity']--);
                        }
                      }),
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

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildCheckoutSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow("المجموع الفرعي", "\$${_subTotal.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          _summaryRow("رسوم التوصيل", "\$${_deliveryFee.toStringAsFixed(2)}"),
          const Divider(height: 24),
          _summaryRow(
            "الإجمالي",
            "\$${_total.toStringAsFixed(2)}",
            isTotal: true,
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: "إتمام عملية الشراء",
            onPressed: () {
              // محاكاة إتمام الطلب بنجاح
              context.push(AppRoutes.orderSuccess);
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_basket_outlined,
              size: 80,
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "سلة التسوق فارغة",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "ابدأ بإضافة المنتجات التي تعجبك الآن",
            style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 200,
            child: CustomButton(
              text: "تسوق الآن",
              onPressed: () => context.go('/home'),
            ),
          ),
        ],
      ),
    );
  }
}
