import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/core/widgets/custom_button.dart';
import 'package:yemen_store/features/auth/presentation/providers/auth_provider.dart';
import 'package:yemen_store/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_store/features/auth/presentation/utils/auth_validation.dart';
import 'package:yemen_store/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:yemen_store/features/auth/presentation/widgets/social_divider.dart';
import 'package:yemen_store/features/auth/presentation/widgets/social_icons_row.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    ref.read(authNotifierProvider.notifier).signIn(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.user != null) {
        context.go(AppRoutes.home);
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      body: Container(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.primary,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "تسجيل الدخول",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 25),

                        AuthTextField(
                          controller: _emailController,
                          hintText: "البريد الإلكتروني أو رقم الهاتف",
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final errors = AuthValidation.validateEmail(value ?? '');
                            return errors.isNotEmpty ? errors.first.message : null;
                          },
                        ),
                        const SizedBox(height: 15),

                        AuthTextField(
                          controller: _passwordController,
                          hintText: "كلمة المرور",
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureText,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                          validator: (value) {
                            final errors = AuthValidation.validatePassword(value ?? '');
                            return errors.isNotEmpty ? errors.first.message : null;
                          },
                        ),
                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  activeColor: AppColors.primary,
                                  onChanged: (value) => setState(() => _rememberMe = value!),
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
                                // TODO: Implement forgot password
                              },
                              child: const Text(
                                "نسيت كلمة المرور؟",
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 223, 3, 3),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        CustomButton(
                          text: authState.isLoading ? "جاري التحميل..." : "تسجيل الدخول",
                          onPressed: authState.isLoading ? null : _signIn,
                        ),
                        const SizedBox(height: 20),

                        const SocialDivider(),
                        const SizedBox(height: 20),

                        const SocialIconsRow(),

                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "ليس لديك حساب؟",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push(AppRoutes.signup),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
               
