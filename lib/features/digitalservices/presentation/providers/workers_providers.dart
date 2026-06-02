import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/workers_remote_datasource.dart';
import '../../data/repositories/workers_repository_impl.dart';
import '../../domain/entities/worker_entity.dart';
import '../../domain/repositories/workers_repository.dart';
import '../../domain/usecases/register_worker_usecase.dart';
import '../../domain/usecases/get_workers_usecase.dart';
import '../../domain/usecases/get_workers_by_city_usecase.dart';
import '../../domain/usecases/get_current_worker_profile_usecase.dart';

// ─────────────────────────────────────────────────────────────
// 📦  Infrastructure Providers
// ─────────────────────────────────────────────────────────────

final workersRemoteDataSourceProvider = Provider<WorkersRemoteDataSource>((_) {
  return WorkersRemoteDataSourceImpl();
});

final workersRepositoryProvider = Provider<WorkersRepository>((ref) {
  return WorkersRepositoryImpl(
    remoteDataSource: ref.read(workersRemoteDataSourceProvider),
  );
});

// ─────────────────────────────────────────────────────────────
// 🧪  UseCase Providers
// ─────────────────────────────────────────────────────────────

final registerWorkerUseCaseProvider = Provider((ref) {
  return RegisterWorkerUseCase(repository: ref.read(workersRepositoryProvider));
});

final getWorkersUseCaseProvider = Provider((ref) {
  return GetWorkersUseCase(repository: ref.read(workersRepositoryProvider));
});

final getWorkersByCityUseCaseProvider = Provider((ref) {
  return GetWorkersByCityUseCase(
      repository: ref.read(workersRepositoryProvider));
});

final getCurrentWorkerProfileUseCaseProvider = Provider((ref) {
  return GetCurrentWorkerProfileUseCase(
      repository: ref.read(workersRepositoryProvider));
});

// ─────────────────────────────────────────────────────────────
// 🏙️  City Filter State Provider
// ─────────────────────────────────────────────────────────────

/// المدينة المختارة حالياً في شاشة القائمة
final selectedCityProvider = StateProvider<String>((ref) => 'كل المدن');

// ─────────────────────────────────────────────────────────────
// 📡  Stream Providers
// ─────────────────────────────────────────────────────────────

/// جلب كل المهنيين (بدون فلتر)
final workersStreamProvider = StreamProvider<List<WorkerEntity>>((ref) {
  return ref.read(getWorkersUseCaseProvider).call();
});

/// جلب المهنيين بحسب المدينة المختارة (يتحدث تلقائياً عند تغيير المدينة)
final workersByCityProvider = StreamProvider<List<WorkerEntity>>((ref) {
  final selectedCity = ref.watch(selectedCityProvider);
  return ref.read(getWorkersByCityUseCaseProvider).call(selectedCity);
});

// ─────────────────────────────────────────────────────────────
// 👤  Current Worker Profile Provider
// ─────────────────────────────────────────────────────────────

/// بروفايل المهني للمستخدم الحالي — null إذا لم يكن مسجلاً كمهني
final currentWorkerProfileProvider =
    FutureProvider<WorkerEntity?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null || userId.isEmpty) return null;

  return ref.read(getCurrentWorkerProfileUseCaseProvider).call(userId);
});

// ─────────────────────────────────────────────────────────────
// 📝  Worker Registration State Notifier
// ─────────────────────────────────────────────────────────────

enum WorkerRegisterStatus { initial, loading, success, error }

class WorkerRegisterState {
  final WorkerRegisterStatus status;
  final String? errorMessage;

  const WorkerRegisterState({
    this.status = WorkerRegisterStatus.initial,
    this.errorMessage,
  });

  WorkerRegisterState copyWith({
    WorkerRegisterStatus? status,
    String? errorMessage,
  }) {
    return WorkerRegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class WorkerRegisterNotifier extends StateNotifier<WorkerRegisterState> {
  final RegisterWorkerUseCase _registerWorkerUseCase;

  WorkerRegisterNotifier(this._registerWorkerUseCase)
      : super(const WorkerRegisterState());

  Future<void> registerWorker(WorkerEntity worker) async {
    state = state.copyWith(status: WorkerRegisterStatus.loading);
    try {
      await _registerWorkerUseCase(worker);
      state = state.copyWith(status: WorkerRegisterStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: WorkerRegisterStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const WorkerRegisterState();
  }
}

final workerRegisterProvider =
    StateNotifierProvider<WorkerRegisterNotifier, WorkerRegisterState>((ref) {
  return WorkerRegisterNotifier(ref.read(registerWorkerUseCaseProvider));
});
