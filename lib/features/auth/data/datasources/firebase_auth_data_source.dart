import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_store/features/auth/data/datasources/auth_data_source.dart';
import 'package:yemen_store/features/auth/domain/entities/user.dart';

class FirebaseAuthDataSource implements AuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuthDataSource(this._firebaseAuth);

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // جلب البيانات الإضافية من Firestore بعد تسجيل الدخول
      if (result.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();
        final data = doc.data();
        return _mapFirebaseUserToUser(
          result.user,
          city: data?['city'],
          phoneNumber: data?['phoneNumber'],
        );
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String? city,
  ) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.updateDisplayName(displayName);

      // حفظ البيانات الإضافية في Firestore
      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'id': result.user!.uid,
          'email': email,
          'displayName': displayName,
          'city': city,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return _mapFirebaseUserToUser(result.user, city: city);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    // جلب البيانات الإضافية من Firestore عند التحقق من الجلسة الحالية
    final doc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    final data = doc.data();

    return _mapFirebaseUserToUser(
      firebaseUser,
      city: data?['city'],
      phoneNumber: data?['phoneNumber'],
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updateUserProfile(
    String displayName,
    String? phoneNumber,
    String? city,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);

      // تحديث البيانات في Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (city != null) 'city': city,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String _handleAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'فشل الاتصال بالشبكة. يرجى التأكد من اتصال الإنترنت.';
      case 'user-not-found':
        return 'لم يتم العثور على حساب بهذا البريد.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجل مسبقاً.';
      default:
        return e.message ?? 'حدث خطأ غير متوقع في Firebase.';
    }
  }

  User? _mapFirebaseUserToUser(
    firebase_auth.User? firebaseUser, {
    String? city,
    String? phoneNumber,
  }) {
    if (firebaseUser == null) return null;
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      phoneNumber: phoneNumber ?? firebaseUser.phoneNumber,
      city: city,
      emailVerified: firebaseUser.emailVerified,
    );
  }
}
