import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_status.dart';

class OrderModel {
  final String id;
  final String userId;
  final String title;       // first item name summary
  final double totalPrice;
  final String imageUrl;    // first item image
  final String storeName;
  final String storeAddress;
  final String marketName;
  final String categoryName;
  final OrderStatus status;
  final DateTime createdAt;
  final List<Map<String, dynamic>> items; // cart items snapshot
  final double deliveryFee;

  OrderModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.totalPrice,
    this.imageUrl = '',
    this.storeName = '',
    this.storeAddress = '',
    this.marketName = '',
    this.categoryName = '',
    required this.status,
    required this.createdAt,
    this.items = const [],
    this.deliveryFee = 0.0,
  });

  String get formattedPrice => '${totalPrice.toStringAsFixed(0)} ر.ي';
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  factory OrderModel.fromJson(Map<String, dynamic> json, String docId) {
    OrderStatus status;
    switch (json['status'] ?? 'processing') {
      case 'onWay':
        status = OrderStatus.onWay;
        break;
      case 'completed':
        status = OrderStatus.completed;
        break;
      case 'canceled':
        status = OrderStatus.canceled;
        break;
      default:
        status = OrderStatus.processing;
    }

    DateTime createdAt = DateTime.now();
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.tryParse(json['createdAt']) ?? DateTime.now();
    }

    return OrderModel(
      id: docId,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      storeName: json['storeName'] ?? '',
      storeAddress: json['storeAddress'] ?? '',
      marketName: json['marketName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      status: status,
      createdAt: createdAt,
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      deliveryFee: (json['deliveryFee'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'totalPrice': totalPrice,
      'imageUrl': imageUrl,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'marketName': marketName,
      'categoryName': categoryName,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
      'items': items,
      'deliveryFee': deliveryFee,
    };
  }
}
