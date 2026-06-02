import '../../domain/entities/arta_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtaProductModel extends ArtaProduct {
  const ArtaProductModel({
    required super.id,
    required super.seller,
    required super.title,
    required super.price,
    required super.location,
    required super.imageUrl,
    required super.phone,
    required super.description,
    required super.createdAt,
    super.isFavorite,
  });

  factory ArtaProductModel.fromJson(Map<String, dynamic> json, String id) {
    return ArtaProductModel(
      id: id,
      seller: json['seller'] ?? 'بائع',
      title: json['title'] ?? 'منتج',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      location: json['location'] ?? 'اليمن',
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1546868871-7041f2a55e12',
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seller': seller,
      'title': title,
      'price': price.toString(), // Stored as string in the previous implementation, let's keep compatibility or save as double
      'location': location,
      'imageUrl': imageUrl,
      'phone': phone,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
