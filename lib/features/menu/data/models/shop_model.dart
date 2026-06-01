import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_stor/features/menu/domain/entities/shop.dart';

class ShopModel extends Shop {
  ShopModel({
    required String id,
    required String name,
    required String marketName,
    required String categoryName,
  }) : super(id: id, name: name, marketName: marketName, categoryName: categoryName);

  factory ShopModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ShopModel(
      id: doc.id,
      name: data['name'] ?? 'متجر',
      marketName: data['marketName'] ?? '',
      categoryName: data['categoryName'] ?? '',
    );
  }
}
