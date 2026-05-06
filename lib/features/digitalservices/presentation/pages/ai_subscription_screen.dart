import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiSubscriptionScreen extends StatelessWidget {
  static const String id = 'ai_subscription_screen';
  const AiSubscriptionScreen({super.key});

  static final List<Map<String, dynamic>> _services = [
    {
      'name': 'ChatGPT Plus',
      'price': '7500',
      'duration': 'شهر واحد',
      'type': 'حساب خاص',
      'features': [
        'نموذج GPT-4o الأحدث',
        'توليد صور DALL-E 3',
        'تحليل بيانات متقدم',
      ],
      'logo': 'assets/images/chatGPT.png',
      'color': Colors.teal,
    },
    {
      'name': 'Gemini Advanced',
      'price': '7000',
      'duration': 'شهر واحد',
      'type': 'تفعيل رسمي',
      'features': [
        'نموذج Ultra 1.5',
        'مساحة 2TB في Google One',
        'دمج مع Gmail و Docs',
      ],
      'logo': 'assets/images/gemini.jpg',
      'color': Colors.blue,
    },
    {
      'name': 'Grok (X Premium)',
      'price': '6500',
      'duration': 'شهر واحد',
      'type': 'حساب خاص',
      'features': [
        'وصول مباشر لأخبار X',
        'ذكاء ساخر وغير مقيد',
        'علامة التوثيق الزرقاء',
      ],
      'logo': 'assets/images/grok.jpg',
      'color': Colors.black,
    },
    {
      'name': 'Midjourney',
      'price': '4500',
      'duration': 'شهر واحد',
      'type': 'حساب مشترك',
      'features': [
        'توليد صور بدقة خرافية',
        'وضع الاسترخاء غير المحدود',
        'معرض صور خاص',
      ],
      'logo': 'assets/images/midjouney.png',
      'color': Colors.deepPurple,
    },
    {
      'name': 'Claude Pro',
      'price': '7500',
      'duration': 'شهر واحد',
      'type': 'حساب خاص',
      'features': [
        'أفضل معالجة للنصوص الطويلة',
        'دقة عالية في البرمجة',
        'تحليل ملفات PDF ضخمة',
      ],
      'logo': 'assets/images/claude.jpg',
      'color': Colors.orange,
    },
    {
      'name': 'Perplexity Pro',
      'price': '6800',
      'duration': 'شهر واحد',
      'type': 'حساب خاص',
      'features': [
        'محرك بحث بالذكاء الاصطناعي',
        'مصادر موثوقة لكل إجابة',
        'اختيار بين GPT-4 و Claude',
      ],
      'logo': 'assets/images/perplexity.jpg',
      'color': Colors.cyan,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          title: Text(
            'الذكاء الإصطناعي   ',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              _buildHeroCard(theme),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _AiServiceCard(
                    service: _services[index],
                    theme: theme,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'عصر الذكاء الاصطناعي وصل!',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اشترك الآن في أقوى منصات الذكاء الاصطناعي بدفع محلي سريع وآمن عبر يمن ستور.',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'تفعيل فوري خلال 15 دقيقة ⚡',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final ThemeData theme;

  const _AiServiceCard({required this.service, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = service['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.08), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(service['logo'], fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service['type'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${service['price']} YR',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(service['duration'], style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: List<Widget>.from(
                    (service['features'] as List<String>).map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 14, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () =>
                        _showOrderSheet(context, service, theme, color),
                    child: const Text(
                      'اطلب الاشتراك الآن',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderSheet(
    BuildContext context,
    Map<String, dynamic> service,
    ThemeData theme,
    Color color,
  ) {
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تفعيل اشتراك ${service['name']}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'يرجى إدخال بيانات التواصل لإكمال طلبك بأسرع وقت.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              _buildInputField(
                emailController,
                'البريد الإلكتروني (Gmail)',
                Icons.email_outlined,
                theme,
              ),
              const SizedBox(height: 14),
              _buildInputField(
                phoneController,
                'رقم الواتساب للتواصل',
                Icons.phone_android,
                theme,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مبلغ الطلب:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${service['price']} ريال يمني',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    _showSuccessDialog(context, theme, service['name'], color);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'تأكيد وإرسال الطلب',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.colorScheme.primary),
            hintText: label,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    ThemeData theme,
    String serviceName,
    Color color,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                Text(
                  'شكراً لك!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'تم استلام طلبك بنجاح. سيتم مراجعته وتفعيل حسابك خلال 15 دقيقة القادمة. تفقد الواتساب قريباً!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => context.pop(),
                    child: const Text(
                      'حسناً',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
