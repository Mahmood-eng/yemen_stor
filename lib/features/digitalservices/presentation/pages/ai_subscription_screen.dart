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
      'features': ['نموذج GPT-4o الأحدث', 'توليد صور DALL-E 3', 'تحليل بيانات متقدم'],
      'logo': 'assets/images/chatGPT.png',
      'gradient': [Color(0xFF00B09B), Color(0xFF96C93D)],
    },
    {
      'name': 'Gemini Advanced',
      'price': '7000',
      'duration': 'شهر واحد',
      'type': 'تفعيل رسمي',
      'features': ['نموذج Ultra 1.5', 'مساحة 2TB في Google One', 'دمج مع Gmail و Docs'],
      'logo': 'assets/images/gemini.jpg',
      'gradient': [Color(0xFF4285F4), Color(0xFF34A853)],
    },
    {
      'name': 'Grok (X Premium)',
      'price': '6500',
      'duration': 'شهر واحد',
      'type': 'حساب خاص',
      'features': ['وصول مباشر لأخبار X', 'ذكاء ساخر وغير مقيد', 'علامة التوثيق الزرقاء'],
      'logo': 'assets/images/grok.jpg',
      'gradient': [Color(0xFF333333), Color(0xFF666666)],
    },
    {
      'name': 'Midjourney',
      'price': '4500',
      'duration': 'شهر واحد',
      'type': 'حساب مشترك',
      'features': ['توليد صور بدقة خرافية', 'وضع الاسترخاء غير المحدود', 'معرض صور خاص'],
      'logo': 'assets/images/midjouney.png',
      'gradient': [Color(0xFF7B2FF7), Color(0xFFF107A3)],
    },
    {
      'name': 'Claude Pro',
      'price': '7500',
      'duration': 'شهر واحد',
      'type': 'حساب خاص',
      'features': ['أفضل معالجة للنصوص الطويلة', 'دقة عالية في البرمجة', 'تحليل ملفات PDF ضخمة'],
      'logo': 'assets/images/claude.jpg',
      'gradient': [Color(0xFFFF6B35), Color(0xFFFFAB40)],
    },
    {
      'name': 'Perplexity Pro',
      'price': '6800',
      'duration': 'شهر واحد',
      'type': 'حساب خاص',
      'features': ['محرك بحث بالذكاء الاصطناعي', 'مصادر موثوقة لكل إجابة', 'اختيار بين GPT-4 و Claude'],
      'logo': 'assets/images/perplexity.jpg',
      'gradient': [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // ── AppBar ──
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFF6C3EF4),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6C3EF4), Color(0xFF2A5BE8)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // دوائر زخرفية
                      Positioned(
                        top: -30,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        right: -20,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                      ),
                      // المحتوى
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50, right: 20, left: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.psychology_rounded,
                                        color: Colors.white, size: 26),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'الذكاء الاصطناعي',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'أقوى منصات AI بدفع محلي',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _heroBadge('⚡ تفعيل خلال 15 دقيقة'),
                                  const SizedBox(width: 8),
                                  _heroBadge('🔒 دفع آمن'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── قائمة الخدمات ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final service = _services[index];
                    return _AiServiceCard(
                      service: service,
                      theme: theme,
                      isDark: isDark,
                    );
                  },
                  childCount: _services.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AI Service Card
// ─────────────────────────────────────────────
class _AiServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final ThemeData theme;
  final bool isDark;

  const _AiServiceCard({required this.service, required this.theme, required this.isDark});

  void _showOrderSheet(BuildContext context) {
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final gradColors = service['gradient'] as List<Color>;
    final mainColor = gradColors.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // مقبض
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // عنوان الطلب
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradColors),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(service['logo'] as String, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.psychology_rounded, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اشتراك ${service['name']}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${service['price']} ريال يمني',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sheetField(ctx, emailCtrl, 'البريد الإلكتروني', Icons.email_outlined),
              const SizedBox(height: 12),
              _sheetField(ctx, phoneCtrl, 'رقم الواتساب', Icons.phone_android),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    _showSuccessDialog(context, mainColor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'تأكيد وإرسال الطلب',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(BuildContext ctx, TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
    );
  }

  void _showSuccessDialog(BuildContext context, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 50),
              ),
              const SizedBox(height: 16),
              const Text(
                'تم استلام طلبك!',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(
                'سيتم تفعيل حسابك خلال 15 دقيقة.\nتفقد الواتساب قريباً! ⚡',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  height: 1.6,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'حسناً',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradColors = service['gradient'] as List<Color>;
    final mainColor = gradColors.first;
    final features = service['features'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: mainColor.withValues(alpha: 0.15),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            // ── Header بـ gradient ──
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradColors),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                children: [
                  // ── معلومات الخدمة ──
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              mainColor.withValues(alpha: 0.15),
                              mainColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: mainColor.withValues(alpha: 0.2)),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            service['logo'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.psychology_rounded, color: mainColor, size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['name'] as String,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: mainColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                service['type'] as String,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: mainColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                LinearGradient(colors: gradColors).createShader(bounds),
                            child: Text(
                              '${service['price']}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            'YR / شهر',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(height: 1, color: mainColor.withValues(alpha: 0.1)),
                  const SizedBox(height: 12),

                  // ── المميزات ──
                  ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: gradColors),
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 12),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            f,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 14),

                  // ── زر الاشتراك ──
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradColors),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: mainColor.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _showOrderSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'اطلب الاشتراك الآن',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
