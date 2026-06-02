import '../entities/arta_product.dart';

abstract class ArtaMarketRepository {
  Stream<List<ArtaProduct>> getProductsStream();
  Future<void> addProduct(ArtaProduct product);
  
  /// Toggles favorite state of an Arta Product.
  /// If it exists in favorites, it removes it. Otherwise, it adds it.
  Future<void> toggleFavorite(ArtaProduct product);
  
  /// Gets a stream of favorite products specifically for Arta Market
  Stream<List<ArtaProduct>> getFavoritesStream();
}
