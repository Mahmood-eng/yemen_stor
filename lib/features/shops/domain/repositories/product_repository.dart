import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<void> addProduct(ProductEntity product);
  Stream<List<ProductEntity>> getShopProducts(String shopId);
}
