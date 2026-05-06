import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // بيانات تجريبية للإشعارات
  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "تم شحن الرصيد بنجاح",
      "body":
          "تم إضافة 10,000 ر.ي إلى محفظتك عبر بنك الكريمي. رقم العملية: #88210",
      "time": "منذ 5 دقائق",
      "isRead": false,
      "type": "success", // success, alert, promo
    },
    {
      "title": "فشل سداد فاتورة الكهرباء",
      "body":
          "نعتذر، تعذر إتمام عملية سداد فاتورة الكهرباء لعدم توفر خدمة المزود حالياً. تم إعادة المبلغ لمحفظتك.",
      "time": "منذ ساعتين",
      "isRead": false,
      "type": "alert",
    },
    {
      "title": "عرض خاص لمحبي الألعاب 🎮",
      "body":
          "احصل على خصم 15% عند شراء بطاقات Google Play باستخدام رصيد المحفظة. العرض ساري لـ 24 ساعة!",
      "time": "أمس، 09:30 م",
      "isRead": true,
      "type": "promo",
    },
    {
      "title": "تحديث أمني للحساب",
      "body":
          "لقد قمت بتغيير عنوان التوصيل الخاص بك بنجاح من إعدادات الملف الشخصي.",
      "time": "15 مارس 2026",
      "isRead": true,
      "type": "info",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              theme.appBarTheme.backgroundColor ?? colorScheme.surface,
          elevation: 0.5,
          title: Text(
            "الإشعارات",
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
              child: const Text(
                "تحديد الكل",
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
              ),
            ),
          ],
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: _notifications.isEmpty
            ? _buildEmptyState(theme)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationItem(context, _notifications[index]);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Color iconColor;
    IconData iconData;
    final bool isRead = item['isRead'] as bool;
    final Color bgColor = isRead
        ? colorScheme.surface
        : colorScheme.primary.withOpacity(0.08);

    switch (item['type']) {
      case 'success':
        iconColor = AppColors.success;
        iconData = Icons.check_circle_outline;
        break;
      case 'alert':
        iconColor = AppColors.error;
        iconData = Icons.error_outline;
        break;
      case 'promo':
        iconColor = AppColors.warning;
        iconData = Icons.local_offer_outlined;
        break;
      default:
        iconColor = colorScheme.primary;
        iconData = Icons.notifications_none_outlined;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isRead
              ? theme.dividerColor
              : colorScheme.primary.withOpacity(0.14),
        ),
        boxShadow: [
          if (!isRead)
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item['title'],
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Cairo',
                  fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (!isRead)
              CircleAvatar(radius: 4, backgroundColor: colorScheme.primary),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              item['body'],
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['time'],
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
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
  Widget _buildEmptyState(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.35),
          ),
          const SizedBox(height: 20),
          Text(
            "لا توجد إشعارات حالياً",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Cairo',
              color: colorScheme.onSurface.withOpacity(0.65),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
