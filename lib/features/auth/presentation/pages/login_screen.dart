import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/core/widgets/custom_button.dart'; // تأكد من وجود هذا الودجت
import 'package:yemen_store/features/auth/presentation/widgets/social_divider.dart';
import 'package:yemen_store/features/auth/presentation/widgets/social_icons_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false; // إضافة حالة "تذكرني"

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // لون خلفية الشاشة يتغير حسب الثيم
      // الخلفية ستكون لون الـ scaffoldBackgroundColor من الثيم
      body: Container(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.primary,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // شعار التطبيق أو أي عنصر علوي (يمكن إضافته هنا)
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 40),

                // الحاوية البيضاء التي تحتوي على حقول تسجيل الدخول
                Container(
                  padding: const EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C2C2C)
                        : Colors.white, // لون خلفية الحاوية يتغير حسب الثيم
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "تسجيل الدخول",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ), // حجم خط معقول ومتناسق
                      ),
                      const SizedBox(height: 25),

                      // حقل البريد الإلكتروني/رقم الهاتف
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: "البريد الإلكتروني أو رقم الهاتف",
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // حقل كلمة المرور
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: "كلمة المرور",
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // صف "تذكرني" و "نسيت كلمة المرور"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primary,
                                onChanged: (value) =>
                                    setState(() => _rememberMe = value!),
                              ),
                              const Text(
                                "تذكرني",
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // منطق التعامل مع نسيان كلمة المرور
                            },
                            child: Text(
                              "نسيت كلمة المرور؟",
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // زر تسجيل الدخول
                      CustomButton(
                        text: "تسجيل الدخول",
                        onPressed: () {
                          context.go(AppRoutes.home);
                        },
                      ),
                      const SizedBox(height: 20),

                      // الفاصل "أو سجل عبر"
                      const SocialDivider(),
                      const SizedBox(height: 20),

                      // أزرار تسجيل الدخول الاجتماعي الموحدة
                      const SocialIconsRow(),
                      
                      const SizedBox(height: 25),

                      // "ليس لديك حساب؟"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ليس لديك حساب؟",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(AppRoutes.signup);
                            },
                            child: Text(
                              "إنشاء حساب",
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: () {
          // منطق تسجيل الدخول الاجتماعي
        },
      ),
    );
  }
}
