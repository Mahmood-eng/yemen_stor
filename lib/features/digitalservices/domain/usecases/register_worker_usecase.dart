import '../entities/worker_entity.dart';
import '../repositories/workers_repository.dart';

class RegisterWorkerUseCase {
  final WorkersRepository repository;

  RegisterWorkerUseCase({required this.repository});

  Future<void> call(WorkerEntity worker) {
    return repository.registerWorker(worker);
  }
}
