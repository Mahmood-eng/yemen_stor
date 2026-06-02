import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: YemenStoreAppBar(
        title: const Text('حول التطبيق'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo / App Icon placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.store_mall_directory_rounded,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'يمن ستور (Yemen Store)',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 40),

            _buildInfoCard(
              theme,
              title: 'رؤيتنا',
              icon: Icons.visibility_outlined,
              content:
                  'نسعى في يمن ستور إلى تقديم منصة تجارية متكاملة تجمع بين التجارة الإلكترونية، خدمات الشبكات، والخدمات المهنية في تطبيق واحد يخدم كافة فئات المجتمع بطريقة سهلة وآمنة.',
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              theme,
              title: 'مميزات التطبيق',
              icon: Icons.star_border_rounded,
              content:
                  '• أسواق متعددة ومتاجر متنوعة\n• بيع وشراء كروت شبكات الواي فاي\n• تقديم وطلب الخدمات المهنية بسهولة\n• محفظة رقمية مدمجة وسريعة الاستجابة\n• إدارة كاملة للتجار والخدمات في لوحة تحكم واحدة',
            ),

            const SizedBox(height: 40),

            Text(
              'جميع الحقوق محفوظة © 2026',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.8,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
