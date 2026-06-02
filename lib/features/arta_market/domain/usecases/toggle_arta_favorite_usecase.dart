import '../entities/arta_product.dart';
import '../repositories/arta_market_repository.dart';

class ToggleArtaFavoriteUseCase {
  final ArtaMarketRepository repository;

  ToggleArtaFavoriteUseCase(this.repository);

  Future<void> call(ArtaProduct product) {
    return repository.toggleFavorite(product);
  }
}
