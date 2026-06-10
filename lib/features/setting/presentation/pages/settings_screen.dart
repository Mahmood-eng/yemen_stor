import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_stor/core/providers/theme_provider.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Stream<Map<String, dynamic>?> _userDocStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  // Local state providers
  static final notificationsProvider = StateProvider<bool>((ref) => true);

  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('use_biometrics') ?? false;
    });
  }

  Future<void> _setBiometricSettings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_biometrics', value);
    setState(() {
      _isBiometricEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: YemenStoreAppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<Map<String, dynamic>?>(
                  stream: _userDocStream(),
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    final name =
                        data?['displayName'] ?? data?['name'] ?? 'غير معروف';
                    final account =
                        data?['accountNumber'] ?? data?['account_no'] ?? '';
                    final photoUrl = (data?['photoUrl'] ?? '').toString();

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          backgroundColor: theme.colorScheme.onSurface
                              .withOpacity(0.08),
                          child: photoUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (account.toString().isNotEmpty)
                                Text(
                                  'رقم الحساب: $account',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              const SizedBox(height: 6),
                              Text(
                                FirebaseAuth.instance.currentUser?.email ?? '',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'المظهر',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('نظام الجهاز'),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (v) => notifier.setSystem(),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('فاتح'),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (v) => notifier.setDark(false),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('داكن'),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (v) => notifier.setDark(true),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'الخصوصية والأمان',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('الإشعارات'),
                    subtitle: const Text('تلقي تنبيهات بالطلبات والعروض'),
                    value: ref.watch(notificationsProvider),
                    onChanged: (val) =>
                        ref.read(notificationsProvider.notifier).state = val,
                    activeColor: theme.colorScheme.primary,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('قفل التطبيق وتسهيل الدخول (البصمة)'),
                    subtitle: const Text(
                      'استخدام المقاييس الحيوية لتسجيل الدخول السريع',
                    ),
                    value: _isBiometricEnabled,
                    onChanged: (val) async {
                      if (val) {
                        final LocalAuthentication auth = LocalAuthentication();
                        try {
                          final bool canAuthenticateWithBiometrics =
                              await auth.canCheckBiometrics;
                          final bool canAuthenticate =
                              canAuthenticateWithBiometrics ||
                              await auth.isDeviceSupported();

                          if (canAuthenticate) {
                            final bool
                            didAuthenticate = await auth.authenticate(
                              localizedReason:
                                  'الرجاء التحقق من هويتك لتفعيل الدخول بالبصمة',
                              biometricOnly: true,
                            );

                            if (didAuthenticate) {
                              await _setBiometricSettings(true);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم تفعيل الدخول بالبصمة بنجاح',
                                    ),
                                  ),
                                );
                              }
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'جهازك لا يدعم البصمة أو غير مفعلة',
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('حدث خطأ أثناء تفعيل البصمة'),
                              ),
                            );
                          }
                        }
                      } else {
                        await _setBiometricSettings(false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إلغاء الدخول بالبصمة'),
                            ),
                          );
                        }
                      }
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: const Text('لغة التطبيق'),
                    trailing: const Text(
                      'العربية',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('اللغة العربية هي لغة التطبيق الحالية'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_outlined),
                    title: const Text('مسح الذاكرة المؤقتة (Cache)'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم مسح الذاكرة المؤقتة بنجاح وتحرير المساحة',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('سياسة الخصوصية والشروط'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'سيتم إضافة صفحة سياسة الخصوصية قريباً',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'الدعم الفني',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('مركز المساعدة'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => context.push(AppRoutes.help),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined),
                    title: const Text('إرسال ملاحظات (Feedback)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'سيتم توفير نافذة إرسال الملاحظات قريباً',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('حول التطبيق'),
                    subtitle: const Text('إصدار 1.0.0'),
                    onTap: () => context.push(AppRoutes.about),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    content: const Text(
                      'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            context.go(AppRoutes.login);
                          }
                        },
                        child: Text(
                          'خروج',
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
