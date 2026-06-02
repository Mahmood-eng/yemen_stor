import 'package:yemen_stor/features/auth/domain/entities/user_entity.dart';
import 'package:yemen_stor/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity?> call(
    String email,
    String password,
    String displayName,
    String? city,
  ) {
    return repository.signUpWithEmailAndPassword(
      email,
      password,
      displayName,
      city,
    );
  }
}
