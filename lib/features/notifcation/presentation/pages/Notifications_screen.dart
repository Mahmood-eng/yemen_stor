import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Color _primaryColor = const Color(0xFF0D3B66);

  // بيانات تجريبية للإشعارات
  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "تم شحن الرصيد بنجاح",
      "body": "تم إضافة 10,000 ر.ي إلى محفظتك عبر بنك الكريمي. رقم العملية: #88210",
      "time": "منذ 5 دقائق",
      "isRead": false,
      "type": "success", // success, alert, promo
    },
    {
      "title": "فشل سداد فاتورة الكهرباء",
      "body": "نعتذر، تعذر إتمام عملية سداد فاتورة الكهرباء لعدم توفر خدمة المزود حالياً. تم إعادة المبلغ لمحفظتك.",
      "time": "منذ ساعتين",
      "isRead": false,
      "type": "alert",
    },
    {
      "title": "عرض خاص لمحبي الألعاب 🎮",
      "body": "احصل على خصم 15% عند شراء بطاقات Google Play باستخدام رصيد المحفظة. العرض ساري لـ 24 ساعة!",
      "time": "أمس، 09:30 م",
      "isRead": true,
      "type": "promo",
    },
    {
      "title": "تحديث أمني للحساب",
      "body": "لقد قمت بتغيير عنوان التوصيل الخاص بك بنجاح من إعدادات الملف الشخصي.",
      "time": "15 مارس 2026",
      "isRead": true,
      "type": "info",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Text(
            "الإشعارات",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: _primaryColor, fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            // زر تحديد الكل كمقروء
            TextButton(
              onPressed: () {},
              child: const Text("تحديد الكل", style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.blue)),
            )
          ],
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: _primaryColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _notifications.isEmpty 
          ? _buildEmptyState() 
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationItem(_notifications[index]);
              },
            ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item) {
    Color iconColor;
    IconData iconData;
    Color bgColor = item['isRead'] ? Colors.white : const Color(0xFFE3F2FD).withOpacity(0.4);

    // تحديد شكل الإشعار بناءً على نوعه
    switch (item['type']) {
      case 'success':
        iconColor = Colors.green;
        iconData = Icons.check_circle_outline;
        break;
      case 'alert':
        iconColor = Colors.redAccent;
        iconData = Icons.error_outline;
        break;
      case 'promo':
        iconColor = Colors.orange;
        iconData = Icons.local_offer_outlined;
        break;
      default:
        iconColor = _primaryColor;
        iconData = Icons.notifications_none_outlined;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: item['isRead'] ? Colors.grey.shade200 : _primaryColor.withOpacity(0.1)),
        boxShadow: [
          if (item['isRead'] == false)
            BoxShadow(color: _primaryColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item['title'],
                style: TextStyle(
                  fontFamily: 'Cairo', 
                  fontWeight: item['isRead'] ? FontWeight.w600 : FontWeight.bold,
                  fontSize: 14,
                  color: _primaryColor
                ),
              ),
            ),
            if (!item['isRead'])
              const CircleAvatar(radius: 4, backgroundColor: Colors.blue),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              item['body'],
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              item['time'],
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            item['isRead'] = true;
          });
        },
      ),
    );
  }

  // واجهة في حال لا توجد إشعارات
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text("لا توجد إشعارات حالياً", 
            style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }
}