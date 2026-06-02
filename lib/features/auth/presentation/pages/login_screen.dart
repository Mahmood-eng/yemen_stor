import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';
import 'package:yemen_stor/core/widgets/custom_button.dart';
import 'package:yemen_stor/features/auth/presentation/providers/auth_provider.dart';
import 'package:yemen_stor/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_stor/features/auth/presentation/utils/auth_validation.dart';
import 'package:yemen_stor/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:yemen_stor/features/auth/presentation/widgets/social_divider.dart';
import 'package:yemen_stor/features/auth/presentation/widgets/social_icons_row.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = true;
  bool _isFormValid = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = AuthValidation.validateEmail(_emailController.text).isEmpty &&
          AuthValidation.validatePassword(_passwordController.text).isEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
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

  Future<void> _handleBiometricAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('use_biometrics') ?? false;

    if (!isEnabled) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('تنبيه', style: TextStyle(fontFamily: 'Cairo')),
            content: const Text(
              'تسجيل الدخول بالبصمة غير مفعل لحسابك. يرجى تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور أولاً، ثم تفعيل البصمة من قائمة الإعدادات.',
              style: TextStyle(fontFamily: 'Cairo', height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        );
      }
      return;
    }

    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (canAuthenticate) {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'الرجاء التحقق من هويتك لتسجيل الدخول',
          biometricOnly: true,
        );

        if (didAuthenticate) {
          // If biometric succeeds, we can't easily fetch their password directly 
          // without having cached it securely previously. However, for a fully working 
          // demo without deep encryption, we might just bypass auth and go to home
          // Note: In a real production app, we would use flutter_secure_storage 
          // to store the token or password.
          // For now, if they pass biometric and it was enabled, we assume they are the owner.
          // Let's do a mock bypass or a message.
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم التحقق بنجاح!')),
            );
            // In a real app we would login silently here.
            // context.go(AppRoutes.home);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('جهازك لا يدعم البصمة أو غير مفعلة')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء المصادقة بالبصمة')),
        );
      }
    }
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
                                context.push(AppRoutes.forgotPassword);
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

                        ElevatedButton(
                          onPressed: (!_isFormValid || authState.isLoading) ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  "تسجيل الدخول",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),

                        const SocialDivider(),
                        const SizedBox(height: 20),

                        SocialIconsRow(
                          onFingerprintTap: _handleBiometricAuth,
                        ),

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
               
