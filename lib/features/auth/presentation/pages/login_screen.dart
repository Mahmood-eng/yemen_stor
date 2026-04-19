import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/core/widgets/CustomTextField.dart';
import 'package:yemen_store/core/widgets/custom_button.dart';
import 'package:yemen_store/features/auth/presentation/widgets/social_divider.dart';
import 'package:yemen_store/features/auth/presentation/widgets/social_icons_row.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // يعتمد على خلفية الثيم مباشرة (الوضع الفاتح كحلي والداكن أسود)
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            _buildLogo(isDark),
            const SizedBox(height: 30),

            // حاوية البيانات (الكرت الرئيسي)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : AppColors.background,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "تسجيل الدخول",
                    // استثناء: تكبير الخط قليلاً عن حجم الثيم الافتراضي للعنوان
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 30),

                  // الحقول تسحب تنسيقها تلقائياً من inputDecorationTheme في الثيم
                  const CustomTextField(
                    hintText: "رقم الهاتف أو البريد",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    hintText: "كلمة المرور",
                    icon: Icons.lock_outline,
                    isPassword: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.primary,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _buildRememberMeAndForgot(isDark),

                  const SizedBox(height: 20),

                  // الزر يعتمد على elevatedButtonTheme من الثيم
                  CustomButton(
                    text: "دخول",
                    onPressed: () {
                      context.go(AppRoutes.home);
                    },
                  ),

                  const SizedBox(height: 25),
                  const SocialDivider(),
                  const SizedBox(height: 15),
                  const SocialIconsRow(),
                ],
              ),
            ),

            const SizedBox(height: 25),
            
            // استثناء: نص "إنشاء حساب" يظهر باللون الأبيض ليبرز فوق الخلفية الكحلية
            TextButton(
              onPressed: () => context.push(AppRoutes.signup),
              child: const Text(
                "ليس لديك حساب؟ أنشئ حساباً جديداً",
                style: TextStyle(
                  color: Colors.white, // أبيض دائماً ليناسب الخلفية الكحلية/السوداء
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Image.asset(
      'assets/images/logo.png',
      height: 120,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.store,
        size: 100,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRememberMeAndForgot(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              // يعتمد على checkboxTheme في الثيم
              onChanged: (value) => setState(() => _rememberMe = value!),
            ),
            const Text("تذكرني"),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "هل نسيت كلمة المرور؟",
            style: TextStyle(
              color: Colors.redAccent, // استثناء لوني للتنبيه
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}