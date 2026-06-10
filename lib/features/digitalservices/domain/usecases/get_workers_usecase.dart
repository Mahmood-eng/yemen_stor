import '../entities/worker_entity.dart';
import '../repositories/workers_repository.dart';

class GetWorkersUseCase {
  final WorkersRepository repository;

  GetWorkersUseCase({required this.repository});

  Stream<List<WorkerEntity>> call() {
    return repository.getWorkers();
  }
}
