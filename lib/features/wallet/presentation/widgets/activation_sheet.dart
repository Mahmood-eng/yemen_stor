import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:yemen_store/core/theme/app_colors.dart';

class ActivationSheet extends StatelessWidget {
  final String bankName;
  const ActivationSheet({super.key, required this.bankName});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 15,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView( // لضمان عدم حدوث Overflow عند ظهور الكيبورد
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مقبض السحب العلوي
            Center(
              child: Container(
                width: 50, height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // العنوان والوصف من الكود الأصلي
            Text(
              "ربط وتفعيل حساب ($bankName)",
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              "أدخل بياناتك كما هي مسجلة في تطبيق البنك لربط الحساب",
              style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // 1. حقل اسمك في البنك
            _buildField("اسمك في البنك", Icons.person_outline),
            
            // 2. حقل نوع الحساب
            _buildField("نوع الحساب (جاري، توفير...)", Icons.account_tree_outlined),
            
            // 3. حقل رقم الحساب البنكي
            _buildField("رقم الحساب البنكي", Icons.numbers, isNumber: true),
            
            // 4. حقل الرمز المفعل
            _buildField("الرمز المفعل من تطبيق البنك", Icons.vpn_key_outlined),

            const SizedBox(height: 15),
            
            // 5. قسم إثبات الهوية (رفع الصورة) كما طلبته
            const Text(
              "إثبات الهوية",
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => print("فتح الكاميرا/المعرض لرفع الهوية"),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(15),
                  color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50],
                ),
                child: Column(
                  children: [
                    Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                    const SizedBox(height: 8),
                    const Text(
                      "رفع صورة الهوية (البطاقة الشخصية)",
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // زر إرسال الطلب
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final LocalAuthentication auth = LocalAuthentication();
                  try {
                    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
                    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

                    if (canAuthenticate) {
                      final bool didAuthenticate = await auth.authenticate(
                        localizedReason: 'يرجى التحقق باستخدام البصمة لتفعيل الحساب',
                      );

                      if (didAuthenticate && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تفعيل الحساب بنجاح')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('جهازك لا يدعم البصمة. تم إرسال الطلب.')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('حدث خطأ: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  "إرسال طلب الربط",
                  style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // دالة موحدة لبناء الحقول لتقليل تكرار الكود
  Widget _buildField(String hint, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          // يستخدم التنسيق الموحد من AppTheme تلقائياً
        ),
      ),
    );
  }
}