import 'package:yemen_stor/features/auth/domain/entities/user.dart';
import 'package:yemen_stor/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<User?> call(String email, String password) {
    return repository.signInWithEmailAndPassword(email, password);
  }
}
