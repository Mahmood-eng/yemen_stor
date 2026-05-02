import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/CustomTextField.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- Controllers ---
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _acceptTerms = false;
  bool _isPasswordVisible = false;
  String _selectedCity = "تعز";

  static const List<String> _cities = [
    "تعز", "صنعاء", "عدن", "حضرموت", "إب", "المكلا", "ذمار", "الحديدة"
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- دالة إنشاء الحساب ---
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الموافقة على شروط الاستخدام'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signUp(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _selectedCity,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // الانتقال للرئيسية بعد إنشاء الحساب بنجاح
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? theme.scaffoldBackgroundColor : theme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Text(
                  "إنشاء حساب جديد",
                  style: theme.textTheme.displayLarge
                      ?.copyWith(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 30),

                // --- حقل الاسم الكامل ---
                CustomTextField(
                  hintText: "الاسم الكامل",
                  icon: Icons.person_outline,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال الاسم الكامل';
                    }
                    if (value.trim().length < 3) {
                      return 'الاسم قصير جداً';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

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
                    if (value.trim().length < 9) {
                      return 'رقم الهاتف غير صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // --- اختيار المدينة ---
                _buildCityDropdown(theme),
                const SizedBox(height: 15),

                // --- حقل كلمة المرور ---
                CustomTextField(
                  hintText: "كلمة المرور",
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: theme.primaryColor,
                    ),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildTermsCheckbox(theme),

                // --- عرض رسالة الخطأ ---
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

                // --- زر الإنشاء مع مؤشر التحميل ---
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return CustomButton(
                      text: auth.isLoading ? "جاري الإنشاء..." : "إنشاء الحساب",
                      backgroundColor:
                          isDark ? theme.primaryColor : Colors.white,
                      textColor: isDark ? Colors.white : theme.primaryColor,
                      onPressed:
                          (auth.isLoading || !_acceptTerms) ? null : _handleSignUp,
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildLoginRedirect(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityDropdown(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          isExpanded: true,
          dropdownColor: theme.primaryColor,
          style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
          items: _cities
              .map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedCity = val!),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox(ThemeData theme) {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          activeColor: Colors.white,
          checkColor: theme.primaryColor,
          onChanged: (value) => setState(() => _acceptTerms = value!),
        ),
        const Expanded(
          child: Text(
            "أوافق على شروط الاستخدام وسياسة الخصوصية",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("لديك حساب بالفعل؟",
            style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () {
            context.read<AuthProvider>().clearError();
            context.go(AppRoutes.login);
          },
          child: const Text("تسجيل الدخول",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}