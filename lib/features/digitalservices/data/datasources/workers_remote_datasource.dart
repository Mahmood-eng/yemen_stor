import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';

abstract class WorkersRemoteDataSource {
  Future<void> registerWorker(WorkerModel worker);
  Stream<List<WorkerModel>> getWorkers();
  Stream<List<WorkerModel>> getWorkersByCity(String city);
  Future<WorkerModel?> getCurrentWorkerProfile(String userId);
  Future<void> updateWorker(String workerId, Map<String, dynamic> data);
}

class WorkersRemoteDataSourceImpl implements WorkersRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> registerWorker(WorkerModel worker) async {
    final docId =
        worker.id.isEmpty ? _firestore.collection('workers').doc().id : worker.id;

    final Map<String, dynamic> workerJson = worker.toJson();
    if (worker.id.isEmpty) {
      workerJson['id'] = docId;
    }

    await _firestore.collection('workers').doc(docId).set(workerJson);

    // تحديث دور المستخدم ليشمل "worker"
    await _firestore.collection('users').doc(worker.userId).set({
      'role': 'worker',
      'workerId': docId,
      'isProfessional': true,
    }, SetOptions(merge: true));
  }

  @override
  Stream<List<WorkerModel>> getWorkers() {
    return _firestore
        .collection('workers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WorkerModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Stream<List<WorkerModel>> getWorkersByCity(String city) {
    // إذا كانت "كل المدن" نعيد الكل، وإلا نفلتر
    if (city == 'كل المدن') return getWorkers();

    return _firestore
        .collection('workers')
        .where('city', isEqualTo: city)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WorkerModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<WorkerModel?> getCurrentWorkerProfile(String userId) async {
    final snapshot = await _firestore
        .collection('workers')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();
    data['id'] = doc.id;
    return WorkerModel.fromJson(data);
  }

  @override
  Future<void> updateWorker(String workerId, Map<String, dynamic> data) async {
    await _firestore.collection('workers').doc(workerId).update(data);
  }
}
