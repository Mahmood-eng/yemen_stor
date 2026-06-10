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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _agreeToTerms = false;
  String? _selectedCity = "تعز";
  bool _isFormValid = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _displayNameController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = AuthValidation.validateDisplayName(_displayNameController.text).isEmpty &&
          AuthValidation.validateEmail(_emailController.text).isEmpty &&
          AuthValidation.validatePassword(_passwordController.text).isEmpty &&
          _confirmPasswordController.text == _passwordController.text &&
          _selectedCity != null &&
          _agreeToTerms;
    });
  }

  final List<String> _yemeniCities = [
    "صنعاء",
    "تعز",
    "عدن",
    "إب",
    "الحديدة",
    "حضرموت",
    "ذمار",
    "مأرب",
    "صعدة",
    "حجة",
    "عمران",
    "الجوف",
    "المحويت",
    "ريمة",
    "شبوة",
    "أبين",
    "الضالع",
    "لحج",
    "المحافظة الجنوبية",
  ];

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);
    _displayNameController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب الموافقة على الشروط والأحكام')),
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();
    final city = _selectedCity;

    ref
        .read(authNotifierProvider.notifier)
        .signUp(email, password, displayName, city);
  }

  void _handleBiometricAuth() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تنبيه', style: TextStyle(fontFamily: 'Cairo')),
          content: const Text(
            'لا يمكن استخدام البصمة لإنشاء حساب جديد. يرجى ملء البيانات المطلوبة أولاً، وبعد الدخول يمكنك تفعيل البصمة من الإعدادات لتسهيل دخولك مستقبلاً.',
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
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
                          "إنشاء حساب",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 25),

                        AuthTextField(
                          controller: _displayNameController,
                          hintText: "الاسم الكامل",
                          prefixIcon: Icons.person,
                          validator: (value) {
                            final errors = AuthValidation.validateDisplayName(
                              value ?? '',
                            );
                            return errors.isNotEmpty
                                ? errors.first.message
                                : null;
                          },
                        ),
                        const SizedBox(height: 15),

                        AuthTextField(
                          controller: _emailController,
                          hintText: "البريد الإلكتروني",
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final errors = AuthValidation.validateEmail(
                              value ?? '',
                            );
                            return errors.isNotEmpty
                                ? errors.first.message
                                : null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // حقل اختيار المدينة
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCity,
                          alignment: Alignment.centerRight,
                          hint: const Text(
                            "اختر المدينة",
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                          ),
                          items: _yemeniCities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(
                                city,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCity = value);
                            _validateForm();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يجب اختيار المدينة';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
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

                        AuthTextField(
                          controller: _passwordController,
                          hintText: "كلمة المرور",
                          prefixIcon: Icons.lock,
                          obscureText: _obscureText,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                setState(() => _obscureText = !_obscureText),
                          ),
                          validator: (value) {
                            final errors = AuthValidation.validatePassword(
                              value ?? '',
                            );
                            return errors.isNotEmpty
                                ? errors.first.message
                                : null;
                          },
                        ),
                        const SizedBox(height: 15),

                        AuthTextField(
                          controller: _confirmPasswordController,
                          hintText: "تأكيد كلمة المرور",
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmText,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmText = !_obscureConfirmText,
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'كلمة المرور غير متطابقة';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              activeColor: AppColors.primary,
                              onChanged: (value) {
                                setState(() => _agreeToTerms = value!);
                                _validateForm();
                              },
                            ),
                            Expanded(
                              child: Text(
                                "أوافق على الشروط والأحكام",
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: (!_isFormValid || authState.isLoading) ? null : _signUp,
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
                                  "إنشاء حساب",
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
                              "لديك حساب بالفعل؟",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                            ),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: Text(
                                "تسجيل الدخول",
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
