import 'package:yemen_stor/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> call(String displayName, String? phoneNumber, String? city) {
    return repository.updateUserProfile(displayName, phoneNumber, city);
  }
}
