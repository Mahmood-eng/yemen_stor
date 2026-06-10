import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_stor/features/menu/domain/entities/network.dart';

class NetworkModel extends Network {
  NetworkModel({
    required String id,
    required String name,
    required String type,
  }) : super(id: id, name: name, type: type);

  factory NetworkModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NetworkModel(
      id: doc.id,
      name: data['name'] ?? 'شبكة',
      type: data['type'] ?? '',
    );
  }
}
