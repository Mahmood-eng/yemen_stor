import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/CustomTextField.dart';
import '../../../../core/widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _acceptTerms = false;
  String _selectedCity = "تعز";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : theme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Text(
                "إنشاء حساب جديد",
                style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 30),
              const CustomTextField(hintText: "الاسم الكامل", icon: Icons.person_outline),
              const SizedBox(height: 15),
              const CustomTextField(hintText: "رقم الهاتف", icon: Icons.phone_android_outlined),
              const SizedBox(height: 15),
              _buildCityDropdown(theme),
              const SizedBox(height: 15),
              const CustomTextField(hintText: "كلمة المرور", icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 20),
              _buildTermsCheckbox(theme),
              const SizedBox(height: 30),
              CustomButton(
                text: "إنشاء الحساب",
                backgroundColor: isDark ? theme.primaryColor : Colors.white,
                textColor: isDark ? Colors.white : theme.primaryColor,
                onPressed: _acceptTerms ? () {} : null,
              ),
              const SizedBox(height: 20),
              _buildLoginRedirect(),
            ],
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
          items: ["تعز", "صنعاء", "عدن"].map((city) => DropdownMenuItem(
            value: city,
            child: Text(city),
          )).toList(),
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
            style: TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("لديك حساب بالفعل؟", style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text("تسجيل الدخول", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}