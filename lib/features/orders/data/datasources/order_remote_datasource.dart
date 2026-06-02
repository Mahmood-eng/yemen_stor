import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/order_status.dart';

class OrderRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all orders belonging to the current user (legacy - used for tracking)
  Stream<List<OrderModel>> getUserOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// تبويب النشطة: processing + onWay
  Stream<List<OrderModel>> getActiveOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereIn: ['processing', 'onWay'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// تبويب المكتملة
  Stream<List<OrderModel>> getCompletedOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// تبويب الملغاة
  Stream<List<OrderModel>> getCanceledOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'canceled')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Single order stream by id (for real-time tracking)
  Stream<OrderModel?> getOrderById(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OrderModel.fromJson(doc.data()!, doc.id);
    });
  }

  /// Place a new order and return the generated order id
  Future<String> placeOrder({
    required String title,
    required double totalPrice,
    required double deliveryFee,
    required String imageUrl,
    required String storeName,
    required String storeAddress,
    required String marketName,
    required String categoryName,
    required List<Map<String, dynamic>> items,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');

    final docRef = await _firestore.collection('orders').add({
      'userId': user.uid,
      'title': title,
      'totalPrice': totalPrice,
      'deliveryFee': deliveryFee,
      'imageUrl': imageUrl,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'marketName': marketName,
      'categoryName': categoryName,
      'status': OrderStatus.processing.name,
      'createdAt': FieldValue.serverTimestamp(),
      'items': items,
    });
    return docRef.id;
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.canceled.name,
    });
  }
}
