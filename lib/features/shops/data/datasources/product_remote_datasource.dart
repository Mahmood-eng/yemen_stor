import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<void> addProduct(ProductModel product);
  Stream<List<ProductModel>> getShopProducts(String shopId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addProduct(ProductModel product) async {
    // If the product id is empty, generate one
    final docId = product.id.isEmpty 
        ? _firestore.collection('products').doc().id 
        : product.id;
        
    final Map<String, dynamic> productJson = product.toJson();
    if (product.id.isEmpty) {
      productJson['id'] = docId;
      productJson['productId'] = docId;
    }
    
    await _firestore.collection('products').doc(docId).set(productJson);
  }

  @override
  Stream<List<ProductModel>> getShopProducts(String shopId) {
    return _firestore
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    });
  }
}
