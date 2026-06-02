import '../entities/merchant_shop_entity.dart';
import '../repositories/merchant_repository.dart';

class UpdateShopUseCase {
  final MerchantRepository repository;

  UpdateShopUseCase(this.repository);

  Future<void> call(MerchantShopEntity shop) {
    return repository.updateShop(shop);
  }
}
