import '../repositories/merchant_repository.dart';

class UpdateShopStatusUseCase {
  final MerchantRepository repository;

  UpdateShopStatusUseCase(this.repository);

  Future<void> call(String shopId, String status) async {
    return repository.updateShopStatus(shopId, status);
  }
}
