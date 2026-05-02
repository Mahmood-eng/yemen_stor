// =============================================================
// AuthRepository: العقد (Interface) الذي يفصل الـ UI عن التنفيذ
// عند التبديل لـ Supabase، نُنشئ SupabaseAuthRepository يُنفِّذ هذا العقد
// دون المساس بـ AuthProvider أو الـ UI
// =============================================================

import '../../data/models/user_model.dart';

/// نتيجة عملية المصادقة - تحمل إما البيانات أو رسالة خطأ
class AuthResult {
  final UserModel? user;
  final String? errorMessage;
  final bool isSuccess;

  const AuthResult.success(this.user)
      : errorMessage = null,
        isSuccess = true;

  const AuthResult.failure(this.errorMessage)
      : user = null,
        isSuccess = false;
}

/// العقد الأساسي لعمليات المصادقة
abstract class AuthRepository {
  /// تسجيل الدخول برقم الهاتف وكلمة المرور
  Future<AuthResult> login({
    required String phone,
    required String password,
  });

  /// تسجيل الدخول بالبصمة للمستخدم الأخير
  Future<AuthResult> loginWithBiometrics();

  /// إنشاء حساب جديد
  Future<AuthResult> signUp({
    required String fullName,
    required String phone,
    required String city,
    required String password,
  });

  /// تسجيل الخروج
  Future<void> logout();

  /// استرجاع المستخدم المخزن مؤقتاً (Session)
  Future<UserModel?> getCurrentUser();

  /// التحقق هل المستخدم مسجل الدخول
  Future<bool> isLoggedIn();

  /// تحديث صورة الحساب
  Future<AuthResult> updateProfileImage(String imagePath);

  /// تحديث بيانات الحساب
  Future<AuthResult> updateUser(UserModel user);

  /// حذف الحساب نهائياً
  Future<AuthResult> deleteAccount();
}
