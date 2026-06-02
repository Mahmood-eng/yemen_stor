import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';

abstract class WorkersRemoteDataSource {
  Future<void> registerWorker(WorkerModel worker);
  Stream<List<WorkerModel>> getWorkers();
}

class WorkersRemoteDataSourceImpl implements WorkersRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> registerWorker(WorkerModel worker) async {
    final docId = worker.id.isEmpty 
        ? _firestore.collection('workers').doc().id 
        : worker.id;
        
    final Map<String, dynamic> workerJson = worker.toJson();
    if (worker.id.isEmpty) {
      workerJson['id'] = docId;
    }
    
    await _firestore.collection('workers').doc(docId).set(workerJson);
    
    // Update user role to include "worker"
    await _firestore.collection('users').doc(worker.userId).set({
      'role': 'worker',
      'workerId': docId,
    }, SetOptions(merge: true));
  }

  @override
  Stream<List<WorkerModel>> getWorkers() {
    return _firestore
        .collection('workers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkerModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    });
  }
}
