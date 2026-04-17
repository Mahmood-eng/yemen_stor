import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTrackPressed;

  const OrderCard({super.key, required this.order, required this.onTrackPressed});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Column(
        children: [
          // شريط الحالة والتاريخ
          _buildHeader(order),
          // تفاصيل الطلب
          _buildBody(order, isDark),
          // زر التتبع
          if (order['type'] == "active") _buildTrackButton(onTrackPressed),
          const SizedBox(height: 10),
          // تذييل البطاقة
          _buildFooter(order, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> order) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (order['statusColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              order['status'],
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: order['statusColor'],
              ),
            ),
          ),
          Text(order['date'],
              style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> order, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(order['image'],
                height: 75, width: 75, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("طلب رقم: #${order['id']}",
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(order['items'],
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(
                  "${order['price']} ريال",
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? AppColors.primary : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackButton(VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text("تتبع مسار الطلب",
              style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildFooter(Map<String, dynamic> order, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50],
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          border: Border(
              top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey[200]!))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${order['shop']} - ${order['category']}",
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey),
                ),
                Text(
                  order['market'],
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: Colors.grey,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}