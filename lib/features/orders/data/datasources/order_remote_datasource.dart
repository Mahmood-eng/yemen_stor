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
    required String shopId,
    required String storeAddress,
    required String marketName,
    required String categoryName,
    required String merchantId,
    required String marketId,
    required String categoryId,
    required List<Map<String, dynamic>> items,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');

    final batch = _firestore.batch();
    final docRef = _firestore.collection('orders').doc();

    batch.set(docRef, {
      'userId': user.uid,
      'title': title,
      'totalPrice': totalPrice,
      'deliveryFee': deliveryFee,
      'imageUrl': imageUrl,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'marketName': marketName,
      'categoryName': categoryName,
      'merchantId': merchantId,
      'marketId': marketId,
      'categoryId': categoryId,
      'status': OrderStatus.processing.name,
      'createdAt': FieldValue.serverTimestamp(),
      'items': items,
    });

    // إشعار للمستخدم
    final userNotifRef = _firestore.collection('notifications').doc();
    batch.set(userNotifRef, {
      'userId': user.uid,
      'title': 'تم استلام طلبك',
      'body': 'طلبك من $storeName قيد التجهيز الآن.',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'order_placed',
    });

    // إشعار للتاجر (صاحب المحل) إذا كان لدينا merchantId
    if (merchantId.isNotEmpty) {
      final merchantNotifRef = _firestore.collection('notifications').doc();
      batch.set(merchantNotifRef, {
        'merchantId': merchantId,
        'shopId': shopId,
        'title': 'طلب جديد!',
        'body': 'لديك طلب جديد بقيمة $totalPrice ر.ي. يرجى تجهيزه.',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'new_order',
      });
    }

    await batch.commit();

    return docRef.id;
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.canceled.name,
    });
  }
}
