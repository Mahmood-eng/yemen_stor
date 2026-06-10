import '../entities/merchant_shop_entity.dart';

abstract class MerchantRepository {
  Future<void> registerShop(MerchantShopEntity shop);
  Stream<MerchantShopEntity?> getMerchantShop(String ownerId);
  Future<void> updateShopStatus(String shopId, String status);
  Future<void> updateShop(MerchantShopEntity shop);
}
