import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/providers/settings_provider.dart';
import 'package:yemen_store/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. المظهر
          _buildSectionTitle(context, "المظهر والعرض"),
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text("تلقائي (حسب النظام)"),
                  value: ThemeMode.system,
                  groupValue: settingsProvider.themeMode,
                  onChanged: (val) => settingsProvider.setThemeMode(val!),
                  activeColor: theme.primaryColor,
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text("الوضع الفاتح"),
                  value: ThemeMode.light,
                  groupValue: settingsProvider.themeMode,
                  onChanged: (val) => settingsProvider.setThemeMode(val!),
                  activeColor: theme.primaryColor,
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text("الوضع الداكن"),
                  value: ThemeMode.dark,
                  groupValue: settingsProvider.themeMode,
                  onChanged: (val) => settingsProvider.setThemeMode(val!),
                  activeColor: theme.primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. الحماية والأمان
          _buildSectionTitle(context, "الحماية والأمان"),
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("الدخول باستخدام البصمة"),
                  subtitle: const Text("تأمين التطبيق والمحفظة"),
                  value: settingsProvider.isBiometricEnabled,
                  onChanged: (val) => settingsProvider.toggleBiometric(val),
                  activeColor: theme.primaryColor,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text("تغيير كلمة المرور"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to change password screen
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. الإشعارات
          _buildSectionTitle(context, "الإشعارات"),
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              title: const Text("تفعيل الإشعارات"),
              subtitle: const Text("الحصول على التنبيهات والعروض الجديدة"),
              value: settingsProvider.notificationsEnabled,
              onChanged: (val) => settingsProvider.toggleNotifications(val),
              activeColor: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // 4. الحساب
          _buildSectionTitle(context, "إدارة الحساب"),
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("حذف الحساب نهائياً", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                _showDeleteAccountDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟ لا يمكن التراجع عن هذا الإجراء وسيتم مسح كافة بياناتك ومحفظتك."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              final authProvider = context.read<AuthProvider>();
              bool success = await authProvider.deleteAccount();
              
              if (success) {
                // تصفير السلة والمفضلة عند حذف الحساب
                if (context.mounted) {
                  context.go('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم حذف الحساب بنجاح")),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authProvider.errorMessage ?? "فشل الحذف")),
                  );
                }
              }
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
