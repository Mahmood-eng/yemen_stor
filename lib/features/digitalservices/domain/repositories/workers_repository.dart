import '../../domain/entities/worker_entity.dart';

abstract class WorkersRepository {
  /// تسجيل مهني جديد
  Future<void> registerWorker(WorkerEntity worker);

  /// جلب كل المهنيين (stream)
  Stream<List<WorkerEntity>> getWorkers();

  /// جلب المهنيين بحسب المدينة
  Stream<List<WorkerEntity>> getWorkersByCity(String city);

  /// جلب بروفايل المهني الخاص بالمستخدم الحالي (عبر userId)
  Future<WorkerEntity?> getCurrentWorkerProfile(String userId);

  /// تحديث بيانات المهني
  Future<void> updateWorker(WorkerEntity worker);
}
