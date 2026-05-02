// =============================================================
// AuthProvider: طبقة State Management
// يتواصل فقط مع AuthRepository (العقد) وليس مع التنفيذ المباشر
// هذا يجعل الـ UI محمياً من أي تغيير في مصدر البيانات
// =============================================================

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus {
  initial,    // الحالة الأولية عند فتح التطبيق
  loading,    // جاري التحقق أو تسجيل الدخول
  authenticated, // مستخدم مسجل الدخول
  unauthenticated, // لا يوجد مستخدم
  error,      // حدث خطأ
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  // ============================================================
  // الحالة الداخلية (State)
  // ============================================================
  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // ============================================================
  // Getters (ما تراه الـ UI)
  // ============================================================
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ============================================================
  // التهيئة: يُستدعى عند بدء التطبيق للتحقق من Session المحفوظ
  // ============================================================
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // تسجيل الدخول
  // ============================================================
  Future<bool> login({ // تسجيل الدخول
    required String phone, // رقم الهاتف
    required String password, // كلمة المرور
  }) async {
    _clearError(); // مسح الخطأ
    _setLoading(true); // تفعيل التحميل

    final result = await _repository.login( // تسجيل الدخول
      phone: phone,
      password: password,
    );

    _setLoading(false); // إيقاف التحميل

    if (result.isSuccess) { // إذا تم تسجيل الدخول بنجاح
      _currentUser = result.user; // تعيين المستخدم الحالي
      _status = AuthStatus.authenticated; // تعيين حالة المستخدم إلى authenticated
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return true; // إرجاع true
    } else { // إذا لم يتم تسجيل الدخول بنجاح
      _status = AuthStatus.error; // تعيين حالة المستخدم إلى error
      _errorMessage = result.errorMessage; // تعيين رسالة الخطأ
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return false; // إرجاع false
    }
  }

  // ============================================================
  // تسجيل الدخول بالبصمة
  // ============================================================
  Future<bool> loginWithBiometrics() async {
    _clearError();
    _setLoading(true);

    try {
      final localAuth = LocalAuthentication();
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        _errorMessage = "جهازك لا يدعم المصادقة بالبصمة";
        _setLoading(false);
        return false;
      }

      final authenticated = await localAuth.authenticate(
        localizedReason: 'الرجاء التحقق من هويتك لتسجيل الدخول',
        persistAcrossBackgrounding: true,
        biometricOnly: true,
      );

      if (!authenticated) {
        _errorMessage = "فشلت عملية التحقق";
        _setLoading(false);
        return false;
      }

      final result = await _repository.loginWithBiometrics();
      _setLoading(false);

      if (result.isSuccess) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = result.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _status = AuthStatus.error;
      _errorMessage = "حدث خطأ غير متوقع أثناء فحص البصمة";
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // إنشاء الحساب
  // ============================================================
  Future<bool> signUp({
    required String fullName,
    required String phone,
    required String city,
    required String password,
  }) async {
    _clearError(); // مسح الخطأ
    _setLoading(true); // تفعيل التحميل

    final result = await _repository.signUp( // إنشاء حساب جديد
      fullName: fullName, // اسم المستخدم
      phone: phone, // رقم الهاتف
      city: city, // المدينة
      password: password, // كلمة المرور
    );

    _setLoading(false); // إيقاف التحميل

    if (result.isSuccess) { // إذا تم إنشاء الحساب بنجاح
      _currentUser = result.user; // تعيين المستخدم الحالي
      _status = AuthStatus.authenticated; // تعيين حالة المستخدم إلى authenticated
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return true; // إرجاع true
    } else { // إذا لم يتم إنشاء الحساب بنجاح
      _status = AuthStatus.error; // تعيين حالة المستخدم إلى error
      _errorMessage = result.errorMessage; // تعيين رسالة الخطأ
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return false; // إرجاع false
    }
  }

  // ============================================================
  // تسجيل الخروج
  // ============================================================
  Future<void> logout() async { // تسجيل الخروج
    _setLoading(true); // تفعيل التحميل
    await _repository.logout(); // تسجيل الخروج
    _currentUser = null; // إلغاء تعيين المستخدم الحالي
    _status = AuthStatus.unauthenticated; // تعيين حالة المستخدم إلى unauthenticated
    _setLoading(false); // إيقاف التحميل
  }

  // ============================================================
  // حذف الحساب
  // ============================================================
  Future<bool> deleteAccount() async {
    _setLoading(true);
    final result = await _repository.deleteAccount();
    if (result.isSuccess) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = result.errorMessage;
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // تحديث الصورة الشخصية
  // ============================================================
  Future<bool> updateProfileImage(String imagePath) async { // تحديث الصورة الشخصية
    _setLoading(true); // تفعيل التحميل
    
    final result = await _repository.updateProfileImage(imagePath); // تحديث الصورة الشخصية
    
    _setLoading(false); // إيقاف التحميل
    
    if (result.isSuccess) { // إذا تم تحديث الصورة الشخصية بنجاح
      _currentUser = result.user; // تعيين المستخدم الحالي
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return true; // إرجاع true
    } else { // إذا لم يتم تحديث الصورة الشخصية بنجاح
      _errorMessage = result.errorMessage; // تعيين رسالة الخطأ
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return false; // إرجاع false
    }
  }

  // ============================================================
  // تحديث بيانات الحساب
  // ============================================================
  Future<bool> updateProfile({ // تحديث بيانات الحساب
    required String fullName, // اسم المستخدم
    required String phone, // رقم الهاتف
    required String city, // المدينة
  }) async { // تحديث بيانات الحساب
    if (_currentUser == null) return false; // إذا لم يكن هناك مستخدم حالي

    _setLoading(true); // تفعيل التحميل
    
    final updatedUser = _currentUser!.copyWith(
      fullName: fullName, // اسم المستخدم
      phone: phone, // رقم الهاتف
      city: city, // المدينة
    ); // تحديث بيانات الحساب
    
    final result = await _repository.updateUser(updatedUser); // تحديث بيانات الحساب
    
    _setLoading(false); // إيقاف التحميل
    
    if (result.isSuccess) { // إذا تم تحديث بيانات الحساب بنجاح
      _currentUser = result.user; // تعيين المستخدم الحالي
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return true; // إرجاع true
    } else { // إذا لم يتم تحديث بيانات الحساب بنجاح
      _errorMessage = result.errorMessage; // تعيين رسالة الخطأ
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return false; // إرجاع false
    }
  }

  // ============================================================
  // خصم من الرصيد
  // ============================================================
  Future<bool> deductBalance(double amount) async { // خصم من الرصيد
    if (_currentUser == null) return false; // إذا لم يكن هناك مستخدم حالي

    if (_currentUser!.balance < amount) { // إذا لم يكن الرصيد كافيًا
      _errorMessage = 'الرصيد غير كافٍ'; // تعيين رسالة الخطأ
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return false; // إرجاع false
    }

    _setLoading(true); // تفعيل التحميل
    
    final updatedUser = _currentUser!.copyWith(
      balance: _currentUser!.balance - amount,
    ); // خصم من الرصيد
    
    final result = await _repository.updateUser(updatedUser); // تحديث بيانات الحساب
    
    _setLoading(false); // إيقاف التحميل
    
    if (result.isSuccess) { // إذا تم خصم من الرصيد بنجاح
      _currentUser = result.user; // تعيين المستخدم الحالي
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return true; // إرجاع true
    } else { // إذا لم يتم خصم من الرصيد بنجاح
      _errorMessage = result.errorMessage; // تعيين رسالة الخطأ
      notifyListeners(); // إخطار المستمعين بتغيير الحالة
      return false; // إرجاع false
    }
  }

  // ============================================================
  // مساعدات خاصة
  // ============================================================
  void _setLoading(bool value) { // تفعيل التحميل
    _isLoading = value; // تعيين حالة التحميل
    notifyListeners(); // إخطار المستمعين بتغيير الحالة
  }

  void _clearError() { // مسح رسالة الخطأ
    _errorMessage = null;
    _status = AuthStatus.initial;
  }

  /// مسح رسالة الخطأ يدوياً (مفيد عند عودة المستخدم للحقول)
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
