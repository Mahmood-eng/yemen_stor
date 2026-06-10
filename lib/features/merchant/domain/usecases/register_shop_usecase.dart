import '../entities/merchant_shop_entity.dart';
import '../repositories/merchant_repository.dart';

class RegisterShopUseCase {
  final MerchantRepository repository;

  RegisterShopUseCase(this.repository);

  Future<void> call(MerchantShopEntity shop) async {
    return repository.registerShop(shop);
  }
}
