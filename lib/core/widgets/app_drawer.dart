import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/features/home/presentation/pages/favorites_screen.dart';
import 'package:yemen_store/features/profile/presentation/pages/profile_screen.dart';
import 'package:yemen_store/features/wallet/presentation/pages/recharge_wallet_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
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
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.favorite_border,
                    "مفضلاتي",
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.account_balance_wallet_outlined,
                    "تغذية الحساب",
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RechargeWalletScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(indent: 20, endIndent: 20),
                  _buildSectionTitle(context, "خدمات الأعمال"),
                  _buildSpecialItem(
                    context,
                    Icons.wifi_tethering,
                    "إدارة الشبكات",
                    "أضف كروت وشبكتك هنا",
                    Colors.orange.shade800,
                    () {},
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.storefront_outlined,
                    "فتح حساب تاجر",
                    () {},
                  ),
                  const Divider(indent: 20, endIndent: 20),
                  _buildSectionTitle(context, "الإعدادات والدعم"),
                  _buildDrawerItem(
                    context,
                    Icons.settings_outlined,
                    "الإعدادات",
                    () {},
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
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.only(
          top: 60,
          bottom: 20,
          right: 20,
          left: 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "محمود المقطري",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  "ID: #992837",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 24),
      title: Text(
        title,
        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 14),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
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
        color: color.withOpacity(0.1),
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
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: const [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              "تسجيل الخروج",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
