import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:yemen_store/core/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب بيانات الثيم الحالية
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        // لون الخلفية من الثيم
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            _buildDrawerHeader(context, isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildSectionTitle(context, "الحساب الشخصي"),
                  _buildDrawerItem(
                    context,
                    Icons.person_outline,
                    "الملف الشخصي",
                    () {
                      context.go(AppRoutes.profile);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.favorite_border,
                    "مفضلاتي",
                    () {
                      context.go(AppRoutes.favorites);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.account_balance_wallet_outlined,
                    "تغذية الحساب",
                    () {
                      context.go(AppRoutes.wallet);
                    },
                  ),
                  _buildSpecialItem(
                    context,
                    Icons.swap_horiz,
                    "تبديل الحساب",
                    "متجري / شبكتي",
                    theme.colorScheme.primary,
                    () {},
                  ),

                  Divider(
                    indent: 20,
                    endIndent: 20,
                    color: theme.dividerColor.withAlpha((0.1 * 255).round()),
                  ),

                  _buildSectionTitle(context, "خدمات الأعمال"),
                  _buildSpecialItem(
                    context,
                    Icons.wifi_tethering,
                    "إدارة الشبكات",
                    "أضف كروت وشبكتك هنا",
                    theme.colorScheme.secondary,
                    () {
                      context.go(AppRoutes.addPrivateNetwork);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.storefront_outlined,
                    "فتح حساب تاجر",
                    () {
                      context.go(AppRoutes.merchantRegistration);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.credit_card,
                    "دفع الإشتراك الشهري",
                    () {},
                  ),

                  Divider(
                    indent: 20,
                    endIndent: 20,
                    color: theme.dividerColor.withAlpha((0.1 * 255).round()),
                  ),

                  _buildSectionTitle(context, "الإعدادات والدعم"),
                  _buildDrawerItem(
                    context,
                    Icons.settings_outlined,
                    "الإعدادات",
                    () {
                      context.go(AppRoutes.settings);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.info_outline,
                    "حول التطبيق",
                    () {},
                  ),
                ],
              ),
            ),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Container(
        padding: const EdgeInsets.only(
          top: 60,
          bottom: 20,
          right: 20,
          left: 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : theme.primaryColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تسجيل الدخول',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.swap_horiz, color: Colors.white),
              tooltip: 'تبديل الحساب',
            ),
          ],
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name =
            data?['displayName'] ??
            data?['name'] ??
            fb_auth.FirebaseAuth.instance.currentUser?.displayName ??
            'غير معروف';
        final account = data?['accountNumber'] ?? data?['account_no'] ?? '';
        final photo = (data?['photoUrl'] ?? '') as String;

        return Container(
          padding: const EdgeInsets.only(
            top: 60,
            bottom: 20,
            right: 20,
            left: 20,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface
                : theme.colorScheme.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: (photo.isNotEmpty)
                        ? NetworkImage(photo)
                        : null,
                    backgroundColor: theme.colorScheme.onPrimary.withOpacity(
                      0.25,
                    ),
                    child: (photo.isEmpty)
                        ? Icon(Icons.person, color: theme.colorScheme.onPrimary)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      if (account.isNotEmpty)
                        Text(
                          'حساب: $account',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: theme.colorScheme.onPrimary.withOpacity(
                                  0.85,
                                ),
                              ),
                        ),
                    ],
                  ),
                ],
              ),

              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.swap_horiz,
                  color: theme.colorScheme.onPrimary,
                ),
                tooltip: 'تبديل الحساب',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          // حل مشكلة textMain باستخدام ألوان الثيم المباشرة
          color: isDark
              ? theme.colorScheme.onPrimary.withOpacity(0.85)
              : theme.colorScheme.primary,
        ),
      ),
    );
  }

  void _navigateWithDrawerClose(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    Future.microtask(action);
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary, size: 24),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: theme.hintColor),
      onTap: () => _navigateWithDrawerClose(context, onTap),
    );
  }

  Widget _buildSpecialItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: color.withAlpha((0.7 * 255).round()),
          ),
        ),
        onTap: () => _navigateWithDrawerClose(context, onTap),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 10),
            Text(
              "تسجيل الخروج",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
