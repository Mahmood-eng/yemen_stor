import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;
  final String shopId;
  final String shopName;
  final String userId;
  final String merchantId;
  final String marketId;
  final String categoryId;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.shopId,
    required this.shopName,
    required this.userId,
    required this.merchantId,
    required this.marketId,
    required this.categoryId,
  });

  factory CartItem.fromJson(Map<String, dynamic> json, String id) {
    return CartItem(
      id: id,
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? json['shop'] ?? '',
      userId: json['userId'] ?? '',
      merchantId: json['merchantId'] ?? '',
      marketId: json['marketId'] ?? '',
      categoryId: json['categoryId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'shopId': shopId,
      'shopName': shopName,
      'userId': userId,
      'merchantId': merchantId,
      'marketId': marketId,
      'categoryId': categoryId,
    };
  }
}

// Stream provider to listen to active cart documents for current user
final cartStreamProvider = StreamProvider<List<CartItem>>((ref) {
  final user = fb_auth.FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value([]);
  }
  return FirebaseFirestore.instance
      .collection('cart')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => CartItem.fromJson(doc.data(), doc.id)).toList();
      });
});

class CartNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
    required String shopId,
    required String shopName,
    required String merchantId,
    required String marketId,
    required String categoryId,
    int quantity = 1,
  }) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartQuery = await _firestore
        .collection('cart')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (cartQuery.docs.isNotEmpty) {
      final doc = cartQuery.docs.first;
      final currentQuantity = doc.data()['quantity'] ?? 1;
      await doc.reference.update({'quantity': currentQuantity + quantity});
    } else {
      await _firestore.collection('cart').add({
        'userId': user.uid,
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
        'shopId': shopId,
        'shopName': shopName,
        'merchantId': merchantId,
        'marketId': marketId,
        'categoryId': categoryId,
      });
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await _firestore.collection('cart').doc(cartItemId).update({
        'quantity': quantity,
      });
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _firestore.collection('cart').doc(cartItemId).delete();
  }

  Future<void> clearCart() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final cartQuery = await _firestore
        .collection('cart')
        .where('userId', isEqualTo: user.uid)
        .get();

    final batch = _firestore.batch();
    for (var doc in cartQuery.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

final cartActionsProvider = Provider((ref) => CartNotifier());
