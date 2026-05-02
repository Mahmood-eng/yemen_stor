import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/CustomTextField.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/social_divider.dart';
import '../widgets/social_icons_row.dart';
import 'package:yemen_store/core/providers/settings_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> { //يورث من state of login screen الذي موجود في lib/features/auth/data/repositories/auth_repository_impl.dart
  // --- Controllers للحصول على القيم من حقول النص ---
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- دالة تسجيل الدخول الرئيسية ---
  Future<void> _handleLogin() async {
    // التحقق من صحة الحقول أولاً
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.home);
    }
    // في حال الفشل، سيعرض Consumer رسالة الخطأ تلقائياً
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : theme.primaryColor,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "مرحباً بك مجدداً في Yemen Store",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 40),

                // --- حقل رقم الهاتف ---
                CustomTextField(
                  hintText: "رقم الهاتف",
                  icon: Icons.phone_android_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- حقل كلمة المرور ---
                CustomTextField(
                  hintText: "كلمة المرور",
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: theme.primaryColor,
                    ),
                    onPressed: () =>
                        setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),

                _buildRememberMeAndForgot(theme),

                // --- عرض رسالة الخطأ من AuthProvider ---
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.errorMessage!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 20),

                // --- زر الدخول مع مؤشر التحميل ---
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return CustomButton(
                      text: auth.isLoading ? "جاري التحقق..." : "دخول",
                      backgroundColor:
                          isDark ? theme.primaryColor : Colors.white,
                      textColor: isDark ? Colors.white : theme.primaryColor,
                      onPressed: auth.isLoading ? null : _handleLogin,
                    );
                  },
                ),

                const SizedBox(height: 15),

                // زر البصمة (يظهر دائماً، وإذا لم يكن مفعلاً يتم توجيه المستخدم للإعدادات)
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    return Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    if (!settings.isBiometricEnabled) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("الرجاء تفعيل ميزة البصمة أولاً من شاشة الإعدادات")),
                                      );
                                      return;
                                    }

                                    final success = await auth.loginWithBiometrics();
                                    if (success && context.mounted) {
                                      context.go(AppRoutes.home);
                                    } else if (!success && context.mounted && auth.errorMessage != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(auth.errorMessage!)),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.fingerprint, size: 28),
                            label: const Text(
                              "الدخول بالبصمة",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : theme.primaryColor,
                              backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: theme.primaryColor.withOpacity(0.5), width: 1.5),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 15),
                const SocialDivider(),
                const SizedBox(height: 20),
                const SocialIconsRow(),

                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    context.read<AuthProvider>().clearError();
                    context.push(AppRoutes.signup);
                  },
                  child: const Text(
                    "ليس لديك حساب؟ أنشئ حساباً جديداً",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Image.asset(
      'assets/images/logo.png',
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
                onChanged: (value) =>
                    setState(() => _rememberMe = value!),
              ),
            ),
            const Text("تذكرني",
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text("نسيت كلمة المرور؟",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ],
    );
  }
}