import '../../domain/entities/worker_entity.dart';
import '../../domain/repositories/workers_repository.dart';
import '../datasources/workers_remote_datasource.dart';
import '../models/worker_model.dart';

class WorkersRepositoryImpl implements WorkersRepository {
  final WorkersRemoteDataSource remoteDataSource;

  WorkersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> registerWorker(WorkerEntity worker) async {
    final model = WorkerModel(
      id: worker.id,
      name: worker.name,
      profession: worker.profession,
      experienceYears: worker.experienceYears,
      phone: worker.phone,
      city: worker.city,
      address: worker.address,
      bio: worker.bio,
      imageUrl: worker.imageUrl,
      rating: worker.rating,
      status: worker.status,
      isAvailable: worker.isAvailable,
      isVerified: worker.isVerified,
      category: worker.category,
      portfolioLinks: worker.portfolioLinks,
      projectLinks: worker.projectLinks,
      cvUrl: worker.cvUrl,
      certificates: worker.certificates,
      userId: worker.userId,
      createdAt: worker.createdAt,
    );
    await remoteDataSource.registerWorker(model);
  }

  @override
  Stream<List<WorkerEntity>> getWorkers() {
    return remoteDataSource.getWorkers();
  }

  @override
  Stream<List<WorkerEntity>> getWorkersByCity(String city) {
    return remoteDataSource.getWorkersByCity(city);
  }

  @override
  Future<WorkerEntity?> getCurrentWorkerProfile(String userId) async {
    return remoteDataSource.getCurrentWorkerProfile(userId);
  }

  @override
  Future<void> updateWorker(WorkerEntity worker) async {
    final model = WorkerModel(
      id: worker.id,
      name: worker.name,
      profession: worker.profession,
      experienceYears: worker.experienceYears,
      phone: worker.phone,
      city: worker.city,
      address: worker.address,
      bio: worker.bio,
      imageUrl: worker.imageUrl,
      rating: worker.rating,
      status: worker.status,
      isAvailable: worker.isAvailable,
      isVerified: worker.isVerified,
      category: worker.category,
      portfolioLinks: worker.portfolioLinks,
      projectLinks: worker.projectLinks,
      cvUrl: worker.cvUrl,
      certificates: worker.certificates,
      userId: worker.userId,
      createdAt: worker.createdAt,
    );
    await remoteDataSource.updateWorker(worker.id, model.toJson());
  }
}
