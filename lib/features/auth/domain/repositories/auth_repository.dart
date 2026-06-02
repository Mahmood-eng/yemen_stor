import 'package:yemen_stor/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity?> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String? city,
  );
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateUserProfile(
    String displayName,
    String? phoneNumber,
    String? city,
  );
}
