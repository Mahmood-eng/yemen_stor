import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/arta_product_model.dart';
import '../../domain/entities/arta_product.dart';

class ArtaMarketRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ArtaMarketRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  Stream<List<ArtaProductModel>> getProductsStream() {
    return _firestore
        .collection('arta_products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ArtaProductModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> addProduct(ArtaProductModel product) async {
    await _firestore.collection('arta_products').add(product.toJson());
  }

  Future<void> toggleFavorite(ArtaProduct product) async {
    if (_userId.isEmpty) return; // or throw exception depending on auth requirement

    final favoriteRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('user_arta_favorites')
        .doc(product.id);

    final doc = await favoriteRef.get();
    if (doc.exists) {
      await favoriteRef.delete();
    } else {
      final model = ArtaProductModel(
        id: product.id,
        seller: product.seller,
        title: product.title,
        price: product.price,
        location: product.location,
        imageUrl: product.imageUrl,
        phone: product.phone,
        description: product.description,
        createdAt: product.createdAt,
      );
      await favoriteRef.set(model.toJson());
    }
  }

  Stream<List<ArtaProductModel>> getFavoritesStream() {
    if (_userId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('user_arta_favorites')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ArtaProductModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
