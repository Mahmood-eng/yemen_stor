import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:yemen_stor/core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';

    return DateFormat('yyyy/MM/dd', 'en').format(date);
  }

  Future<void> _markAllAsRead() async {
    HapticFeedback.mediumImpact();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final unreadQuery = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    if (unreadQuery.docs.isNotEmpty) {
      await batch.commit();
    }
  }

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
              onPressed: _markAllAsRead,
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
              child: const Text(
                "تحديد الكل",
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
              ),
            ),
          ],
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: colorScheme.primary,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseAuth.instance.currentUser != null
              ? FirebaseFirestore.instance
                    .collection('notifications')
                    .where(
                      'userId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
                    .snapshots()
              : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('حدث خطأ في تحميل الإشعارات', style: TextStyle(fontFamily: 'Cairo')),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(theme);
            }

            final notifications = snapshot.data!.docs.toList();
            notifications.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final doc = notifications[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildNotificationItem(context, doc.id, data);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Color iconColor;
    IconData iconData;
    final bool isRead = data['isRead'] == true;
    final Color bgColor = isRead
        ? colorScheme.surface
        : colorScheme.primary.withOpacity(0.08);

    switch (data['type']) {
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
                data['title'] ?? 'إشعار جديد',
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
              data['body'] ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(data['createdAt'] as Timestamp?),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        onTap: () {
          if (!isRead) {
            HapticFeedback.lightImpact();
            FirebaseFirestore.instance
                .collection('notifications')
                .doc(docId)
                .update({'isRead': true});
          }
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
