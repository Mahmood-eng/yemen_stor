import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/providers/theme_provider.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/core/widgets/yemen_store_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Stream<Map<String, dynamic>?> _userDocStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: YemenStoreAppBar(title: const Text('الإعدادات'),
       leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.push(AppRoutes.home),
        ),),
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
              'الدعم',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('مركز المساعدة'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {},
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('حول التطبيق'),
                subtitle: const Text('إصدار 1.0.0'),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
