import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/social_divider.dart';
import '../widgets/social_icons_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // استخدام اللون الرئيسي من الثيم مباشرة
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : theme.primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 80),
              _buildLogo(isDark),
              const SizedBox(height: 40),

              Text(
                "تسجيل الدخول",
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "مرحباً بك مجدداً في Yemen Store",
                style: TextStyle(
                  color: theme.colorScheme.onPrimary.withAlpha(
                    (0.7 * 255).round(),
                  ),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),
              const CustomTextField(
                hintText: "البريد الإلكتروني أو رقم الهاتف",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "كلمة المرور",
                icon: Icons.lock_outline,
                isPassword: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: theme.primaryColor,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),

              _buildRememberMeAndForgot(theme),

              const SizedBox(height: 30),
              CustomButton(
                text: "دخول",
                // تخصيص لون الزر في صفحة التسجيل ليكون بارزاً
                backgroundColor: isDark ? theme.primaryColor : Colors.white,
                textColor: isDark ? Colors.white : theme.primaryColor,
                onPressed: () => context.go(AppRoutes.home),
              ),

              const SizedBox(height: 30),
              const SocialDivider(),
              const SizedBox(height: 20),
              const SocialIconsRow(),

              const SizedBox(height: 30),
              TextButton(
                onPressed: () => context.push(AppRoutes.signup),
                child: const Text(
                  "ليس لديك حساب؟ أنشئ حساباً جديداً",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Image.asset(
      isDark ? 'assets/images/logo.png' : 'assets/images/logo.png',
      height: 120,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.store, size: 100, color: Colors.white),
    );
  }

  Widget _buildRememberMeAndForgot(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Theme(
              data: theme.copyWith(unselectedWidgetColor: Colors.white54),
              child: Checkbox(
                value: _rememberMe,
                activeColor: Colors.white,
                checkColor: theme.primaryColor,
                onChanged: (value) => setState(() => _rememberMe = value!),
              ),
            ),
            const Text(
              "تذكرني",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "نسيت كلمة المرور؟",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
