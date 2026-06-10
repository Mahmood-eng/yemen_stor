import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yemen_stor/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:yemen_stor/features/menu/presentation/cubit/menu_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // ─── منطق تبديل الحساب ─────────────────────────────────────────────────────
  void _showAccountSwitchDialog(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Load accounts via MenuCubit
    final menuCubit = context.read<MenuCubit>();
    menuCubit.loadAccounts(uid);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        final colorScheme = theme.colorScheme;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FutureBuilder(
              future: Future.wait([
                // جلب المتاجر المملوكة
                FirebaseFirestore.instance
                    .collection('shops')
                    .where('ownerId', isEqualTo: uid)
                    .get(),
                // جلب الشبكات المملوكة
                FirebaseFirestore.instance
                    .collection('networks')
                    .where('ownerId', isEqualTo: uid)
                    .get(),
              ]),
              builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                // ─── حالة التحميل ───────────────────────────────────────────
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'جارٍ التحقق من حساباتك...',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }

                // ─── خطأ ────────────────────────────────────────────────────
                if (snapshot.hasError) {
                  return _buildDialogError(dialogCtx, theme);
                }

                final shops = snapshot.data![0].docs;
                final networks = snapshot.data![1].docs;

                // ─── لا توجد حسابات ─────────────────────────────────────────
                if (shops.isEmpty && networks.isEmpty) {
                  return _buildNoAccountsDialog(dialogCtx, context, theme);
                }

                // ─── عرض الحسابات ───────────────────────────────────────────
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // رأس النافذة
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colorScheme.primary.withOpacity(
                            0.12,
                          ),
                          child: Icon(
                            Icons.swap_horiz,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تبديل الحساب',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'اختر حسابك للانتقال إليه',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          icon: const Icon(Icons.close),
                          iconSize: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- المحلات ---
                    if (shops.isNotEmpty) ...[
                      _buildSectionHeader(
                        'متاجري',
                        Icons.storefront_outlined,
                        theme,
                      ),
                      const SizedBox(height: 8),
                      ...shops.map((shopDoc) {
                        final data = shopDoc.data() as Map<String, dynamic>;
                        final shopName = data['name'] ?? 'متجر';
                        final marketName = data['marketName'] ?? '';
                        final categoryName = data['categoryName'] ?? '';
                        return _buildAccountTile(
                          context: context,
                          dialogCtx: dialogCtx,
                          icon: Icons.storefront,
                          title: shopName,
                          subtitle: marketName.isNotEmpty
                              ? '$marketName / $categoryName'
                              : 'متجر',
                          iconColor: colorScheme.primary,
                          onTap: () {
                            Navigator.of(dialogCtx).pop();
                            context.go(AppRoutes.merchantDashboard);
                          },
                        );
                      }),
                      const SizedBox(height: 12),
                    ],

                    // --- الشبكات ---
                    if (networks.isNotEmpty) ...[
                      _buildSectionHeader(
                        'شبكاتي',
                        Icons.wifi_tethering,
                        theme,
                      ),
                      const SizedBox(height: 8),
                      ...networks.map((netDoc) {
                        final data = netDoc.data() as Map<String, dynamic>;
                        final netName = data['name'] ?? 'شبكة';
                        final netType = data['type'] ?? '';
                        return _buildAccountTile(
                          context: context,
                          dialogCtx: dialogCtx,
                          icon: Icons.wifi_tethering,
                          title: netName,
                          subtitle: netType.isNotEmpty ? netType : 'شبكة',
                          iconColor: Colors.teal,
                          onTap: () {
                            Navigator.of(dialogCtx).pop();
                            context.go(AppRoutes.manageCards);
                          },
                        );
                      }),
                    ],
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTile({
    required BuildContext context,
    required BuildContext dialogCtx,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconColor.withOpacity(0.12),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAccountsDialog(
    BuildContext dialogCtx,
    BuildContext navCtx,
    ThemeData theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.account_circle_outlined,
          size: 56,
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: 14),
        Text(
          'لا يوجد حساب تجاري',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'لم نجد أي متجر أو شبكة مسجلة لحسابك. افتح حساباً الآن!',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(dialogCtx).pop();
            navCtx.go(AppRoutes.merchantRegistration);
          },
          icon: const Icon(Icons.storefront_outlined, size: 18),
          label: const Text('فتح حساب تاجر'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(dialogCtx).pop();
            navCtx.go(AppRoutes.addPrivateNetwork);
          },
          icon: const Icon(Icons.wifi_tethering, size: 18),
          label: const Text('إضافة شبكة واي فاي'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }

  Widget _buildDialogError(BuildContext dialogCtx, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 12),
        Text('حدث خطأ أثناء التحقق', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  // ─── البناء الرئيسي ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
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
                  _buildSectionTitle(context, 'الحساب الشخصي'),
                  _buildDrawerItem(
                    context,
                    Icons.person_outline,
                    'الملف الشخصي',
                    () => context.go(AppRoutes.profile),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.favorite_border,
                    'مفضلاتي',
                    () => context.go(AppRoutes.favorites),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.account_balance_wallet_outlined,
                    'تغذية الحساب',
                    () => context.go(AppRoutes.wallet),
                  ),
                  // ── تبديل الحساب ──────────────────────────────────────────
                  _buildSpecialItem(
                    context,
                    Icons.swap_horiz,
                    'تبديل الحساب',
                    'متجري / شبكتي',
                    theme.colorScheme.primary,
                    () => _showAccountSwitchDialog(context),
                  ),

                  Divider(
                    indent: 20,
                    endIndent: 20,
                    color: theme.dividerColor.withAlpha((0.1 * 255).round()),
                  ),

                  _buildSectionTitle(context, 'خدمات الأعمال'),
                  _buildSpecialItem(
                    context,
                    Icons.wifi_tethering,
                    'أضف شبكة wifi',
                    'بيع كروت شبكتك عبر التطبيق',
                    theme.colorScheme.primary,
                    () => context.go(AppRoutes.addPrivateNetwork),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.storefront_outlined,
                    'فتح حساب تاجر',
                    () => context.go(AppRoutes.merchantRegistration),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.credit_card,
                    'دفع الإشتراك الشهري',
                    () => context.go(AppRoutes.rentPayment),
                  ),

                  Divider(
                    indent: 20,
                    endIndent: 20,
                    color: theme.dividerColor.withAlpha((0.1 * 255).round()),
                  ),

                  _buildSectionTitle(context, 'الإعدادات والدعم'),
                  _buildDrawerItem(
                    context,
                    Icons.settings_outlined,
                    'الإعدادات',
                    () => context.go(AppRoutes.settings),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.help_outline_rounded,
                    'مركز المساعدة',
                    () => context.go(AppRoutes.help),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.info_outline_rounded,
                    'حول التطبيق',
                    () => context.go(AppRoutes.about),
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
      return _buildGuestHeader(context, isDark, theme);
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
        final photo = (data?["photoUrl"] ?? '') as String;

        return _buildHeaderContainer(
          context: context,
          isDark: isDark,
          theme: theme,
          name: name,
          account: account,
          photo: photo,
        );
      },
    );
  }

  Widget _buildGuestHeader(BuildContext context, bool isDark, ThemeData theme) {
    return _buildHeaderContainer(
      context: context,
      isDark: isDark,
      theme: theme,
      name: 'مرحباً',
      account: '',
      photo: '',
    );
  }

  Widget _buildHeaderContainer({
    required BuildContext context,
    required bool isDark,
    required ThemeData theme,
    required String name,
    required String account,
    required String photo,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, right: 20, left: 20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.25),
                child: photo.isEmpty
                    ? Icon(Icons.person, color: theme.colorScheme.onPrimary)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (account.isNotEmpty)
                    Text(
                      'رقم حسابك: $account',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // ── أيقونة تبديل الحساب في الرأس ──────────────────────────────────
          IconButton(
            onPressed: () => _showAccountSwitchDialog(context),
            icon: Icon(Icons.swap_horiz, color: theme.colorScheme.onPrimary),
            tooltip: 'تبديل الحساب',
          ),
        ],
      ),
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
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo')),
              content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟', style: TextStyle(fontFamily: 'Cairo')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await fb_auth.FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                  child: const Text('خروج', style: TextStyle(color: Colors.red, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        child: Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            const SizedBox(width: 10),
            Text(
              'تسجيل الخروج',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
