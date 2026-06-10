import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetShopProductsUseCase {
  final ProductRepository repository;

  GetShopProductsUseCase(this.repository);

  Stream<List<ProductEntity>> call(String shopId) {
    return repository.getShopProducts(shopId);
  }
}
