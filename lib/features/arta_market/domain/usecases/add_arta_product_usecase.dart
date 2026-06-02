import '../entities/arta_product.dart';
import '../repositories/arta_market_repository.dart';

class AddArtaProductUseCase {
  final ArtaMarketRepository repository;

  AddArtaProductUseCase(this.repository);

  Future<void> call(ArtaProduct product) {
    return repository.addProduct(product);
  }
}
