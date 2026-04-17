import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';

class CartScreen extends StatefulWidget {
  static const String id = 'cart_screen';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // البيانات (يفضل مستقبلاً جلبها من Controller)
  List<Map<String, dynamic>> cartItems = [
    {"name": "آيفون 15 برو", "price": 1200.0, "qty": 1, "img": "assets/images/iphon17.png"},
    {"name": "سماعات AirPod", "price": 80.0, "qty": 2, "img": "assets/images/airpods.png"},
  ];

  double get total => cartItems.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("سلة المشتريات")),
        body: cartItems.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) => _CartItemTile(
                        item: cartItems[index],
                        onDelete: () => setState(() => cartItems.removeAt(index)),
                        onQtyChanged: (val) => setState(() => cartItems[index]['qty'] = val),
                      ),
                    ),
                  ),
                  _buildCheckoutSection(context),
                ],
              ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [if(!isDark) const BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("الإجمالي النهائي:", style: Theme.of(context).textTheme.titleMedium),
                Text("$total \$", 
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary, fontSize: 22)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("إتمام عملية الشراء"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 15),
          const Text("سلتك فارغة حالياً", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ويدجت فرعي لعنصر السلة ليكون الكود أنظف
class _CartItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final Function(int) onQtyChanged;

  const _CartItemTile({required this.item, required this.onDelete, required this.onQtyChanged});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15), // متوافق مع الحواف في ملف الثيم
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          _buildImage(isDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("${item['price']} \$", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          _buildQtyControl(context),
        ],
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    return Container(
      width: 70, height: 70,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(item['img'], fit: BoxFit.contain),
    );
  }

  Widget _buildQtyControl(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _actionBtn(Icons.add, () => onQtyChanged(item['qty'] + 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text("${item['qty']}"),
            ),
            _actionBtn(Icons.remove, () { if (item['qty'] > 1) onQtyChanged(item['qty'] - 1); }),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onPressed: onDelete,
        )
      ],
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}