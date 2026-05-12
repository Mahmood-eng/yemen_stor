import 'package:yemen_store/features/auth/domain/entities/user.dart';
import 'package:yemen_store/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<User?> call(
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
