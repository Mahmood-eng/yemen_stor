import 'package:yemen_stor/features/auth/data/datasources/auth_data_source.dart';
import 'package:yemen_stor/features/auth/domain/entities/user_entity.dart';
import 'package:yemen_stor/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password) {
    return dataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<UserEntity?> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String? city,
  ) {
    return dataSource.signUpWithEmailAndPassword(
      email,
      password,
      displayName,
      city,
    );
  }

  @override
  Future<void> signOut() {
    return dataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return dataSource.getCurrentUser();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return dataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> updateUserProfile(
    String displayName,
    String? phoneNumber,
    String? city,
  ) {
    return dataSource.updateUserProfile(displayName, phoneNumber, city);
  }
}
