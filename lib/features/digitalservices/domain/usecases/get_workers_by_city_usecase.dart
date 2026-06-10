import '../../domain/entities/worker_entity.dart';
import '../../domain/repositories/workers_repository.dart';

/// UseCase: جلب المهنيين بحسب المدينة
/// تُمرر 'كل المدن' للحصول على الكل
class GetWorkersByCityUseCase {
  final WorkersRepository repository;

  GetWorkersByCityUseCase({required this.repository});

  Stream<List<WorkerEntity>> call(String city) {
    return repository.getWorkersByCity(city);
  }
}
