import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/core/widgets/CustomTextField.dart';
import 'package:yemen_store/core/widgets/custom_button.dart';
import 'package:yemen_store/features/auth/presentation/widgets/social_divider.dart';
import 'package:yemen_store/features/auth/presentation/widgets/social_icons_row.dart';

class SignUpScreen extends StatefulWidget {
  static const String id = 'signup_screen';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _acceptTerms = false;
  final List<String> _yemenGovernorates = ["تعز", "صنعاء", "عدن", "إب", "الحديدة", "حضرموت", "مأرب"];
  String _selectedCity = "تعز";

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // يعتمد على خلفية الثيم مباشرة
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildLogo(),
            const SizedBox(height: 15),
            
            // استثناء: اللون الأبيض للنصوص فوق الخلفية الكحلية (في الوضع الفاتح)
            Text(
              "إنشاء حساب جديد",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white, 
                fontSize: 24,
              ),
            ),
            const Text(
              "استمتع بتجربة تسوق فريدة مع يمن ستور",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),

            const SizedBox(height: 25),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : AppColors.background,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const CustomTextField(hintText: "الاسم الكامل", icon: Icons.person_outline),
                  const SizedBox(height: 15),
                  const CustomTextField(hintText: "رقم الهاتف أو البريد الإلكتروني", icon: Icons.contact_mail_outlined),
                  const SizedBox(height: 15),

                  // حقل المدينة (يعتمد الآن على inputDecorationTheme من الثيم)
                  _buildCityDropdown(isDark),

                  const SizedBox(height: 15),
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
                  _buildTermsCheckbox(isDark),
                  const SizedBox(height: 20),

                  // الزر يعتمد على elevatedButtonTheme
                  CustomButton(
                    text: "إنشاء الحساب",
                    onPressed: _acceptTerms ? () {
                      context.go(AppRoutes.home);
                    } : null,
                  ),

                  const SizedBox(height: 25),
                  const SocialDivider(),
                  const SizedBox(height: 15),
                  const SocialIconsRow(),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildLoginRedirect(isDark),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 100,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, size: 80, color: Colors.white),
    );
  }

  Widget _buildCityDropdown(bool isDark) {
    // استخدمنا InputDecorator ليرث خصائص التصميم من الثيم العام للحقول
    return InputDecorator(
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        prefixIcon: Icon(Icons.location_on_outlined),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          items: _yemenGovernorates.map((city) => DropdownMenuItem(
            value: city,
            child: Text(city),
          )).toList(),
          onChanged: (val) => setState(() => _selectedCity = val!),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isDark) {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          // الخصائص مسحوبة من checkboxTheme في الثيم
          onChanged: (value) => setState(() => _acceptTerms = value!),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            child: Text(
              "أوافق على شروط الاستخدام وسياسة الخصوصية",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                decoration: TextDecoration.underline,
                // استثناء لوني لتمييز النص كلياً
                color: isDark ? Colors.white70 : AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginRedirect(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("لديك حساب بالفعل؟", style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text(
            "تسجيل الدخول",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}