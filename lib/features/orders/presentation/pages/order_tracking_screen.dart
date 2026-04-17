import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';

class OrderTrackingScreen extends StatelessWidget {
  static const String id = 'order_tracking';
  final Map<String, dynamic> orderData;

  const OrderTrackingScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // الخريطة
            _buildMap(),
            // زر الرجوع الموحد
            _buildTopBar(context, isDark),
            // البطاقة السفلية
            Align(
              alignment: Alignment.bottomCenter,
              child: _TrackingDetailsCard(orderData: orderData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/map_placeholder.png"), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Positioned(
      top: 50, right: 20,
      child: CircleAvatar(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        child: IconButton(
          icon: Icon(Icons.arrow_forward, color: isDark ? Colors.white : AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class _TrackingDetailsCard extends StatelessWidget {
  final Map<String, dynamic> orderData;
  const _TrackingDetailsCard({required this.orderData});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [if(!isDark) const BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          
          // ويدجت المندوب المنظف
          _buildDriverRow(context, isDark),
          const SizedBox(height: 25),

          // التايم لاين (تم استدعاؤه كودجت مستقل)
          const _TimelineWidget(),
          const SizedBox(height: 25),

          // كارد الطلب الصغير
          _buildMiniOrderCard(context, isDark),
        ],
      ),
    );
  }

  Widget _buildDriverRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        const CircleAvatar(radius: 25, backgroundImage: AssetImage("assets/images/driver.png")),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("المندوب: أحمد سعيد", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("15 دقيقة للوصول", style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
        _actionCircle(Icons.phone_in_talk, Colors.green),
      ],
    );
  }

  Widget _actionCircle(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: () {}),
    );
  }

  Widget _buildMiniOrderCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey[50],
        borderRadius: BorderRadius.circular(15), // متوافق مع AppTheme
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(orderData['image'], width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("طلب #${orderData['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(orderData['shop'], style: TextStyle(color: AppColors.primary, fontSize: 11)),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text("التفاصيل", style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

class _TimelineWidget extends StatelessWidget {
  const _TimelineWidget();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Step(label: "تم القبول", icon: Icons.check, active: true),
        _Step(label: "التجهيز", icon: Icons.inventory_2, active: true),
        _Step(label: "في الطريق", icon: Icons.delivery_dining, current: true),
        _Step(label: "التوصيل", icon: Icons.home, last: true),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active, current, last;
  const _Step({required this.label, required this.icon, this.active = false, this.current = false, this.last = false});

  @override
  Widget build(BuildContext context) {
    Color color = current ? Colors.orange : (active ? AppColors.primary : Colors.grey.shade300);
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: current ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}