import 'dart:async';
import '../../domain/entities/arta_product.dart';
import '../../domain/repositories/arta_market_repository.dart';
import '../datasources/arta_remote_datasource.dart';
import '../models/arta_product_model.dart';

class ArtaMarketRepositoryImpl implements ArtaMarketRepository {
  final ArtaMarketRemoteDataSource remoteDataSource;

  ArtaMarketRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ArtaProduct>> getProductsStream() {
    return remoteDataSource.getProductsStream();
  }

  @override
  Future<void> addProduct(ArtaProduct product) async {
    final model = ArtaProductModel(
      id: product.id,
      seller: product.seller,
      title: product.title,
      price: product.price,
      location: product.location,
      imageUrl: product.imageUrl,
      phone: product.phone,
      description: product.description,
      createdAt: product.createdAt,
    );
    await remoteDataSource.addProduct(model);
  }

  @override
  Future<void> toggleFavorite(ArtaProduct product) async {
    await remoteDataSource.toggleFavorite(product);
  }

  @override
  Stream<List<ArtaProduct>> getFavoritesStream() {
    return remoteDataSource.getFavoritesStream();
  }
}
