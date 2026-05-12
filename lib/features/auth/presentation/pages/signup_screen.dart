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
  String? _selectedCity;
  final _formKey = GlobalKey<FormState>();

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
                          value: _selectedCity,
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
                          onChanged: (value) =>
                              setState(() => _selectedCity = value),
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
                              onChanged: (value) =>
                                  setState(() => _agreeToTerms = value!),
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

                        CustomButton(
                          text: authState.isLoading
                              ? "جاري الإنشاء..."
                              : "إنشاء حساب",
                          onPressed: authState.isLoading ? null : _signUp,
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
