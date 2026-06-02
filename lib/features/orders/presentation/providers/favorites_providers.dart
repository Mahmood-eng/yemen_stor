import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final String description;
  final String userId;

  FavoriteItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.userId,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json, String id) {
    return FavoriteItem(
      id: id,
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'userId': userId,
    };
  }
}

// Stream provider to listen to active favorites for current user
final favoritesStreamProvider = StreamProvider<List<FavoriteItem>>((ref) {
  final user = fb_auth.FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value([]);
  }
  return FirebaseFirestore.instance
      .collection('favorites')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => FavoriteItem.fromJson(doc.data(), doc.id)).toList();
      });
});

class FavoritesNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleFavorite({
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
    required String description,
  }) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();
    } else {
      await _firestore.collection('favorites').add({
        'userId': user.uid,
        'productId': productId,
        'productName': productName,
        'price': price,
        'imageUrl': imageUrl,
        'description': description,
      });
    }
  }

  Future<void> removeFromFavorites(String productId) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();
    }
  }

  Future<bool> isFavorite(String productId) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final query = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }
}

final favoritesActionsProvider = Provider((ref) => FavoritesNotifier());
