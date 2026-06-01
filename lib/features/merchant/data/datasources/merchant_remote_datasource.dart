import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/merchant_shop_model.dart';

abstract class MerchantRemoteDataSource {
  Future<void> registerShop(MerchantShopModel shop);
  Stream<MerchantShopModel?> getMerchantShop(String ownerId);
  Future<void> updateShopStatus(String shopId, String status);
}

class MerchantRemoteDataSourceImpl implements MerchantRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> registerShop(MerchantShopModel shop) async {
    await _firestore.collection('shops').doc(shop.id).set(shop.toJson());
    await _firestore.collection('users').doc(shop.ownerId).set({
      'role': 'merchant',
      'shopId': shop.id,
    }, SetOptions(merge: true));
  }

  @override
  Stream<MerchantShopModel?> getMerchantShop(String ownerId) {
    return _firestore
        .collection('shops')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return MerchantShopModel.fromJson(snapshot.docs.first.data());
    });
  }

  @override
  Future<void> updateShopStatus(String shopId, String status) async {
    await _firestore.collection('shops').doc(shopId).update({'status': status});
  }
}
