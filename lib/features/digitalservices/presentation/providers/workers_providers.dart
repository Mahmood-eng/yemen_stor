import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/workers_remote_datasource.dart';
import '../../data/repositories/workers_repository_impl.dart';
import '../../domain/entities/worker_entity.dart';
import '../../domain/usecases/register_worker_usecase.dart';
import '../../domain/usecases/get_workers_usecase.dart';

// ─── DataSource Provider ───
final workersRemoteDataSourceProvider = Provider<WorkersRemoteDataSource>((_) {
  return WorkersRemoteDataSourceImpl();
});

// ─── Repository Provider ───
final workersRepositoryProvider = Provider((ref) {
  return WorkersRepositoryImpl(
    remoteDataSource: ref.read(workersRemoteDataSourceProvider),
  );
});

// ─── UseCase Providers ───
final registerWorkerUseCaseProvider = Provider((ref) {
  return RegisterWorkerUseCase(repository: ref.read(workersRepositoryProvider));
});

final getWorkersUseCaseProvider = Provider((ref) {
  return GetWorkersUseCase(repository: ref.read(workersRepositoryProvider));
});

// ─── Workers Stream Provider ───
final workersStreamProvider = StreamProvider<List<WorkerEntity>>((ref) {
  final useCase = ref.read(getWorkersUseCaseProvider);
  return useCase();
});

// ─── Worker Registration State ───
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
