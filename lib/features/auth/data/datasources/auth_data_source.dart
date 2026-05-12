import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:yemen_store/features/auth/domain/entities/user.dart';

abstract class AuthDataSource {
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String? city,
  );
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateUserProfile(
    String displayName,
    String? phoneNumber,
    String? city,
  );
}
