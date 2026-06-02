import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchWhatsApp(BuildContext context) async {
    final uri = Uri.parse(
      'https://wa.me/967733758119',
    ); // Replace with actual support number
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر فتح تطبيق الواتساب',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: YemenStoreAppBar(
        title: const Text('مركز المساعدة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Image or Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 80,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'كيف يمكننا مساعدتك؟',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // FAQ Section
          Text(
            'الأسئلة الشائعة (FAQ)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildFaqItem(
            theme,
            question: 'كيف يمكنني الشراء من التطبيق؟',
            answer:
                'يمكنك تصفح الأسواق والمنتجات، إضافتها إلى السلة، ثم إتمام عملية الدفع لاختيار طريقة الاستلام المناسبة لك.',
          ),
          _buildFaqItem(
            theme,
            question: 'هل يمكنني فتح متجر خاص بي؟',
            answer:
                'نعم، يمكنك التسجيل كتاجر من خلال القائمة الجانبية "فتح حساب تاجر" وسنوفر لك لوحة تحكم كاملة لمتجرك.',
          ),
          _buildFaqItem(
            theme,
            question: 'كيف يتم سداد الإيجار للشبكات والمتاجر؟',
            answer:
                'من خلال شاشة "دفع الإشتراك الشهري" المتوفرة في القائمة الجانبية، حيث يتم خصم المبلغ من رصيد محفظتك مباشرة.',
          ),

          const SizedBox(height: 30),

          // Contact Support Section
          Text(
            'تواصل معنا',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF25D366),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wechat_rounded, color: Colors.white),
              ),
              title: const Text(
                'تواصل عبر الواتساب',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('دعم فني سريع ومباشر'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _launchWhatsApp(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
    ThemeData theme, {
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
