import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_stor/features/auth/domain/entities/user.dart';
import 'package:yemen_stor/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:yemen_stor/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:yemen_stor/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:yemen_stor/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:yemen_stor/features/auth/domain/usecases/update_profile_usecase.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  AuthNotifier({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
  }) : super(AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await getCurrentUserUseCase();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await signInUseCase(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String displayName,
    String? city,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await signUpUseCase(email, password, displayName, city);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await signOutUseCase();
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateProfile(
    String displayName,
    String? phoneNumber,
    String? city,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await updateProfileUseCase(displayName, phoneNumber, city);
      // Refresh user data
      final updatedUser = await getCurrentUserUseCase();
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
