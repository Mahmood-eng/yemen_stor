import 'package:cloud_firestore/cloud_firestore.dart';
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
      userId: worker.userId,
      createdAt: worker.createdAt,
    );
    await remoteDataSource.registerWorker(model);
  }

  @override
  Stream<List<WorkerEntity>> getWorkers() {
    return remoteDataSource.getWorkers();
  }
}
