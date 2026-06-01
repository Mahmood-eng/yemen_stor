import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/get_shop_products_usecase.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSourceImpl();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource: remoteDataSource);
});

final addProductUseCaseProvider = Provider<AddProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return AddProductUseCase(repository);
});

final getShopProductsUseCaseProvider = Provider<GetShopProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetShopProductsUseCase(repository);
});

// A stream provider to get all products for a specific shop
final shopProductsStreamProvider = StreamProvider.family<List<ProductEntity>, String>((ref, shopId) {
  final getShopProducts = ref.watch(getShopProductsUseCaseProvider);
  return getShopProducts(shopId);
});
