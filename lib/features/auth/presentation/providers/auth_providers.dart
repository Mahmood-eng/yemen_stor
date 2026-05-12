import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_store/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:yemen_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yemen_store/features/auth/domain/repositories/auth_repository.dart';
import 'package:yemen_store/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:yemen_store/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:yemen_store/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:yemen_store/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:yemen_store/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:yemen_store/features/auth/presentation/providers/auth_provider.dart';

// Data Source
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthDataSource(firebaseAuth);
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// Use Cases
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

// State Notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final signInUseCase = ref.watch(signInUseCaseProvider);
  final signUpUseCase = ref.watch(signUpUseCaseProvider);
  final signOutUseCase = ref.watch(signOutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final updateProfileUseCase = ref.watch(updateProfileUseCaseProvider);

  return AuthNotifier(
    signInUseCase: signInUseCase,
    signUpUseCase: signUpUseCase,
    signOutUseCase: signOutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    updateProfileUseCase: updateProfileUseCase,
  );
});
