import '../entities/arta_product.dart';
import '../repositories/arta_market_repository.dart';

class GetArtaProductsUseCase {
  final ArtaMarketRepository repository;

  GetArtaProductsUseCase(this.repository);

  Stream<List<ArtaProduct>> call() {
    return repository.getProductsStream();
  }
}
