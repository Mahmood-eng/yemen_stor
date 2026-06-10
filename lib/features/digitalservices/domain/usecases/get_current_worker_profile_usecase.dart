import '../../domain/entities/worker_entity.dart';
import '../../domain/repositories/workers_repository.dart';

/// UseCase: جلب بروفايل المهني الخاص بالمستخدم المسجّل
/// يُعيد null إذا لم يكن المستخدم مسجلاً كمهني
class GetCurrentWorkerProfileUseCase {
  final WorkersRepository repository;

  GetCurrentWorkerProfileUseCase({required this.repository});

  Future<WorkerEntity?> call(String userId) {
    return repository.getCurrentWorkerProfile(userId);
  }
}
