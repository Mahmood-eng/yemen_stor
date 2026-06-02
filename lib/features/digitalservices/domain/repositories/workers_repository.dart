import '../../domain/entities/worker_entity.dart';

abstract class WorkersRepository {
  Future<void> registerWorker(WorkerEntity worker);
  Stream<List<WorkerEntity>> getWorkers();
}
