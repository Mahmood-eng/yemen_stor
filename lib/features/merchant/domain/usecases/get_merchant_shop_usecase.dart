import '../entities/merchant_shop_entity.dart';
import '../repositories/merchant_repository.dart';

class GetMerchantShopUseCase {
  final MerchantRepository repository;

  GetMerchantShopUseCase(this.repository);

  Stream<MerchantShopEntity?> call(String ownerId) {
    return repository.getMerchantShop(ownerId);
  }
}
