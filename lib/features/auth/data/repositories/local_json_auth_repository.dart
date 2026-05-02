// =============================================================
// LocalJsonAuthRepository: التنفيذ الفعلي باستخدام ملف JSON محلي
// عند الانتقال لـ Supabase: أنشئ SupabaseAuthRepository ينفذ AuthRepository
// وغيّر السطر الواحد في main.dart الذي يوفر الـ Repository
// =============================================================

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class LocalJsonAuthRepository implements AuthRepository {
  // اسم ملف قاعدة البيانات المؤقتة
  static const String _dbFileName = 'yemen_store_db.json';
  static const String _sessionKey = 'currentUserId';
  static const String _lastUserKey = 'lastLoggedInUserId';

  // --- تشفير كلمة المرور بـ SHA-256 ---
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  } //هذه الدالة تحول كلمة المرور (مثل "123456") إلى سلسلة طويلة من الحروف والأرقام غير المفهومة.

// لماذا؟ لكي لا يتمكن أي شخص يفتح ملف الـ JSON من رؤية كلمات مرور المستخدمين.

  // --- الحصول على مسار الملف ---
  Future<File> _getDbFile() async {
    final directory = await getApplicationDocumentsDirectory(); //وظيفتها تحديد المسار الآمن للتطبيق على أندرويد أو آيفون.
    return File('${directory.path}/$_dbFileName');
  }

  // --- قراءة كامل قاعدة البيانات ---
  Future<Map<String, dynamic>> _readDb() async {//قراءة كامل قاعدة البيانات
    try {
      final file = await _getDbFile();//يجب أولاً الحصول على كائن الملف (File) من خلال _getDbFile()
      if (!await file.exists()) {
        return {'users': [], _sessionKey: null};//إذا لم يكن الملف موجودًا، قم بإرجاع خريطة فارغة
      }
      final content = await file.readAsString();//قراءة محتوى الملف
      if (content.isEmpty) {
        return {'users': [], _sessionKey: null}; //إذا كان الملف فارغًا، قم بإرجاع خريطة فارغة
      }
      return jsonDecode(content) as Map<String, dynamic>; //فك تشفير محتوى الـ JSON
    } catch (_) {
      return {'users': [], _sessionKey: null}; //إذا حدث خطأ أثناء قراءة الملف، قم بإرجاع خريطة فارغة
    }
  }

  // --- كتابة قاعدة البيانات ---
  Future<void> _writeDb(Map<String, dynamic> data) async { // كتابة قاعدة البيانات
    final file = await _getDbFile(); // الحصول على كائن الملف (File)
    await file.writeAsString(jsonEncode(data), flush: true); // كتابة قاعدة البيانات
  }

  // --- قراءة قائمة المستخدمين ---
  Future<List<UserModel>> _getUsers() async {
    final db = await _readDb(); // قراءة قاعدة البيانات
    final rawList = db['users'] as List<dynamic>? ?? []; // الحصول على قائمة المستخدمين
    return rawList // تحويل قائمة المستخدمين إلى قائمة من UserModel
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>)) // تحويل كل عنصر إلى UserModel
        .toList(); // تحويل قائمة من UserModel إلى قائمة
  }

  // ============================================================
  // تنفيذ عقد AuthRepository
  // ============================================================

  @override
  Future<AuthResult> login({ // تسجيل الدخول
    required String phone, // رقم الهاتف
    required String password, // كلمة المرور
  }) async {
    try {
      final users = await _getUsers(); // الحصول على قائمة المستخدمين
      final hashedPassword = _hashPassword(password); // تجزئة كلمة المرور

      final user = users.cast<UserModel?>().firstWhere( // البحث عن المستخدم
            (u) => u!.phone == phone && u.passwordHash == hashedPassword,
            orElse: () => null, // إذا لم يتم العثور على المستخدم، قم بإرجاع null
          );  

      if (user == null) {
        return const AuthResult.failure('رقم الهاتف أو كلمة المرور غير صحيحة');
      }

      // حفظ Session
      final db = await _readDb(); // قراءة قاعدة البيانات
      db[_sessionKey] = user.id; // حفظ المستخدم
      db[_lastUserKey] = user.id; // الحفظ للبصمة لاحقاً
      await _writeDb(db); // كتابة قاعدة البيانات

      return AuthResult.success(user); // تسجيل الدخول بنجاح
    } catch (e) {
      return AuthResult.failure('حدث خطأ غير متوقع: $e');
    }
  }

  @override
  Future<AuthResult> loginWithBiometrics() async {
    try {
      final db = await _readDb();
      final lastUserId = db[_lastUserKey] as String?;

      if (lastUserId == null) {
        return const AuthResult.failure('لا يوجد حساب محفوظ مسبقاً للدخول بالبصمة');
      }

      final users = await _getUsers();
      final user = users.cast<UserModel?>().firstWhere(
            (u) => u!.id == lastUserId,
            orElse: () => null,
          );

      if (user == null) {
        return const AuthResult.failure('لم يتم العثور على بيانات الحساب القديم');
      }

      // تسجيل الدخول مجدداً
      db[_sessionKey] = user.id;
      await _writeDb(db);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('حدث خطأ غير متوقع: $e');
    }
  }

  @override
  Future<AuthResult> signUp({
    required String fullName,
    required String phone,
    required String city,
    required String password,
  }) async {
    try {
      final users = await _getUsers();

      // التحقق من عدم وجود رقم الهاتف مسبقاً
      final exists = users.any((u) => u.phone == phone);
      if (exists) {
        return const AuthResult.failure('رقم الهاتف مسجل مسبقاً');
      }

      final newUser = UserModel( // إنشاء مستخدم جديد
        id: DateTime.now().millisecondsSinceEpoch.toString(), // إنشاء هوية فريدة
        fullName: fullName, // اسم المستخدم الكامل
        phone: phone, // رقم الهاتف
        city: city, // مدينة المستخدم
        passwordHash: _hashPassword(password), // تجزئة كلمة المرور
        createdAt: DateTime.now(), // تاريخ إنشاء الحساب
      );

      // حفظ المستخدم الجديد
      final db = await _readDb(); // قراءة قاعدة البيانات
      final rawList = (db['users'] as List<dynamic>? ?? []); // الحصول على قائمة المستخدمين
      rawList.add(newUser.toJson()); // إضافة المستخدم الجديد
      db['users'] = rawList; // إضافة المستخدم الجديد
      db[_sessionKey] = newUser.id; // تسجيل الدخول تلقائياً بعد الإنشاء
      db[_lastUserKey] = newUser.id; // الحفظ للبصمة لاحقاً
      await _writeDb(db); // كتابة قاعدة البيانات

      return AuthResult.success(newUser);
    } catch (e) {
      return AuthResult.failure('حدث خطأ أثناء إنشاء الحساب: $e');
    }
  }

  @override
  Future<void> logout() async {
    final db = await _readDb();
    db[_sessionKey] = null; // حذف المستخدم الحالي
    await _writeDb(db); // كتابة قاعدة البيانات
  }

  @override
  Future<UserModel?> getCurrentUser() async { // الحصول على المستخدم الحالي
    final db = await _readDb(); // قراءة قاعدة البيانات
    final currentUserId = db[_sessionKey] as String?;
    if (currentUserId == null) return null; // التحقق من وجود المستخدم

    final users = await _getUsers(); // الحصول على قائمة المستخدمين
    return users.cast<UserModel?>().firstWhere(
          (u) => u!.id == currentUserId, // البحث عن المستخدم
          orElse: () => null, // إذا لم يتم العثور على المستخدم، قم بإرجاع null
        );
  }

  @override
  Future<bool> isLoggedIn() async { // التحقق من حالة تسجيل الدخول
    final user = await getCurrentUser(); // الحصول على المستخدم الحالي
    return user != null; // التحقق من وجود المستخدم
  }

  @override
  Future<AuthResult> updateProfileImage(String imagePath) async { // تحديث صورة الملف الشخصي
    try {
      final currentUser = await getCurrentUser(); // الحصول على المستخدم الحالي
      if (currentUser == null) return const AuthResult.failure('المستخدم غير مسجل الدخول');

      final updatedUser = currentUser.copyWith(profileImage: imagePath); // تحديث صورة الملف الشخصي
      return await updateUser(updatedUser); // تحديث المستخدم
    } catch (e) {
      return AuthResult.failure('حدث خطأ أثناء تحديث الصورة: $e'); // فشل تحديث صورة الملف الشخصي
    }
  }

  @override
  Future<AuthResult> updateUser(UserModel updatedUser) async {
    try {
      final db = await _readDb();
      final rawList = db['users'] as List<dynamic>? ?? [];
      
      final index = rawList.indexWhere((u) => u['id'] == updatedUser.id);
      if (index == -1) return const AuthResult.failure('المستخدم غير موجود');

      rawList[index] = updatedUser.toJson();
      db['users'] = rawList;// تعديل البيانات
      await _writeDb(db);

      return AuthResult.success(updatedUser); // تعديل البيانات بنجاح
    } catch (e) {
      return AuthResult.failure('حدث خطأ أثناء تحديث البيانات: $e');// فشل تعديل البيانات
    }
  }

  @override
  Future<AuthResult> deleteAccount() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return const AuthResult.failure('المستخدم غير مسجل الدخول');

      final db = await _readDb();
      final rawList = db['users'] as List<dynamic>? ?? [];
      
      rawList.removeWhere((u) => u['id'] == currentUser.id);
      
      db['users'] = rawList;
      db[_sessionKey] = null; // إنهاء الجلسة
      await _writeDb(db);

      return const AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure('حدث خطأ أثناء حذف الحساب: $e');
    }
  }
}
