import '../entities/arta_product.dart';
import '../repositories/arta_market_repository.dart';

class GetArtaFavoritesUseCase {
  final ArtaMarketRepository repository;

  GetArtaFavoritesUseCase(this.repository);

  Stream<List<ArtaProduct>> call() {
    return repository.getFavoritesStream();
  }
}
