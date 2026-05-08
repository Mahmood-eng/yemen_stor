import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/core/widgets/custom_button.dart'; // تأكد من وجود هذا الودجت
import 'package:yemen_store/features/auth/presentation/widgets/social_divider.dart';
import 'package:yemen_store/features/auth/presentation/widgets/social_icons_row.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController(); // حقل موحد للبريد أو الهاتف
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false; // خيار الموافقة على الشروط
  String? _selectedCity; // لتخزين المدينة المختارة

  final List<String> _yemeniCities = [
    "صنعاء", "تعز", "عدن", "إب", "الحديدة", "حضرموت", "ذمار", "مأرب", "صعدة", "حجة"
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark
                ? Colors.white
                : Colors.white, // أبيض ليتناسب مع الخلفية الزرقاء
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      // الخلفية ستكون لون الـ scaffoldBackgroundColor من الثيم
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

                // الحاوية البيضاء التي تحتوي على حقول إنشاء الحساب
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "إنشاء حساب جديد",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // حقل الاسم الكامل
                      TextField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: "الاسم الكامل",
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

                      // حقل موحد: البريد الإلكتروني أو رقم الهاتف
                      TextField(
                        controller: _identifierController,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: "رقم الهاتف أو البريد الإلكتروني",
                          prefixIcon: Icon(Icons.contact_mail_outlined, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // حقل اختيار المدينة
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCity,
                        alignment: Alignment.centerRight,
                        hint: const Text("اختر المدينة", style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                        items: _yemeniCities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city, style: const TextStyle(fontFamily: 'Cairo')),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCity = value),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // حقل كلمة المرور
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: "كلمة المرور",
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
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

                      // حقل تأكيد كلمة المرور
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: "تأكيد كلمة المرور",
                          prefixIcon: Icon(
                            Icons.lock_reset_outlined,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
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

                      // خيار الموافقة على الشروط
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            activeColor: AppColors.primary,
                            onChanged: (value) =>
                                setState(() => _acceptTerms = value!),
                          ),
                          const Expanded(
                            child: Text(
                              "أوافق على الشروط والأحكام وسياسة الخصوصية",
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // زر إنشاء حساب
                      CustomButton(
                        text: "إنشاء حساب",
                        onPressed: () {
                          if (_acceptTerms) context.go(AppRoutes.home);
                        },
                      ),
                      const SizedBox(height: 20),

                      // الفاصل "أو سجل عبر"
                      const SocialDivider(),
                      const SizedBox(height: 20),

                      // أزرار تسجيل الدخول الاجتماعي الموحدة
                      const SocialIconsRow(),

                      const SizedBox(height: 25),

                      // "لديك حساب بالفعل؟"
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
                            onPressed: () {
                              context.pop(); // العودة لشاشة تسجيل الدخول
                            },
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
