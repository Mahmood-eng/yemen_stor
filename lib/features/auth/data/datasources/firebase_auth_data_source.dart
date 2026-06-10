import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_stor/features/auth/data/datasources/auth_data_source.dart';
import 'package:yemen_stor/features/auth/domain/entities/user_entity.dart';
import 'package:yemen_stor/features/auth/data/models/user_model.dart';

class FirebaseAuthDataSource implements AuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuthDataSource(this._firebaseAuth);

  @override
  Future<UserEntity?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    firebase_auth.User? firebaseUser;
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebaseUser = result.user;
    } catch (e) {
      final errorStr = e.toString();
      // التقاط ومعالجة خطأ الكاستنج الخاص بالـ Pigeon (List<Object?>)
      if (errorStr.contains('PigeonUserDetails') || errorStr.contains('type \'List<Object?>\'')) {
        // عند حدوث هذا الخطأ الداخلي، تكون عملية المصادقة قد نجحت فعلياً
        // لذا نلتقط المستخدم الحالي من الذاكرة بدلاً من الاعتماد على النتيجة المنهارة
        firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser == null) {
          throw Exception('Pigeon Data Error: Could not parse response and fallback failed.');
        }
      } else {
        if (e is firebase_auth.FirebaseAuthException) {
          throw Exception(_handleAuthError(e));
        }
        throw Exception('Failed to sign in: $e');
      }
    }

    if (firebaseUser != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        
        if (doc.exists && doc.data() != null) {
           return UserModel.fromJson(doc.data()!);
        }
      } catch (firestoreError) {
        // Log firestore error if needed, but still return user
      }

      return UserModel.fromFirebaseUser(firebaseUser);
    }
    return null;
  }

  @override
  Future<UserEntity?> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String? city,
  ) async {
    firebase_auth.User? firebaseUser;
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebaseUser = result.user;
    } catch (e) {
      final errorStr = e.toString();
      // معالجة القائمة (List Handling) وخطأ الـ Pigeon
      if (errorStr.contains('PigeonUserDetails') || errorStr.contains('type \'List<Object?>\'')) {
        firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser == null) {
          throw Exception('Pigeon Data Error during sign up.');
        }
      } else {
        if (e is firebase_auth.FirebaseAuthException) {
          throw Exception(_handleAuthError(e));
        }
        throw Exception('Failed to sign up: $e');
      }
    }

    if (firebaseUser != null) {
      // فصل تحديث الـ Profile بـ try-catch مستقل لحماية التنفيذ
      try {
        await firebaseUser.updateDisplayName(displayName);
      } catch (e) {
        // تجاهل أخطاء الكاستنج هنا لضمان استمرار التدفق
      }

      // تأمين تدفق الـ Firestore للـ users collection بحماية مستقلة
      try {
        final counterRef = _firestore.collection('app_data').doc('main_config');

        final nextAcc = await _firestore.runTransaction((transaction) async {
          final snapshot = await transaction.get(counterRef);
          int currentMax = 999;
          if (snapshot.exists &&
              snapshot.data()!.containsKey('lastAccountNumber')) {
            currentMax =
                int.tryParse(
                  snapshot.data()!['lastAccountNumber'].toString(),
                ) ??
                999;
          }
          int next = currentMax + 1;
          transaction.set(counterRef, {
            'lastAccountNumber': next,
          }, SetOptions(merge: true));
          return next;
        });

        final userModel = UserModel(
          id: firebaseUser.uid,
          email: email,
          displayName: displayName,
          city: city,
          accountNumber: nextAcc.toString(),
          role: 'user',
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set({
          ...userModel.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        return userModel;
      } catch (firestoreError) {
        // فشل في حفظ البيانات في الفايرستور
        throw Exception('User created in Auth but failed to save in Firestore: $firestoreError');
      }
    }

    return null;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
          
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }

      return UserModel.fromFirebaseUser(firebaseUser);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
       await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
       throw Exception(_handleAuthError(e));
    } catch (e) {
       throw Exception('Failed to send reset email: $e');
    }
  }

  @override
  Future<void> updateUserProfile(
    String displayName,
    String? phoneNumber,
    String? city,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(displayName);
      } catch (e) {
        // Ignore pigeon exception
      }

      try {
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
          'phoneNumber': phoneNumber,
          'city': city,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Ignore firestore exception on update or handle if needed
      }
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
}
