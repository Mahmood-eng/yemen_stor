import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addProduct(ProductEntity product) async {
    final model = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      originalPrice: product.originalPrice,
      images: product.images,
      category: product.category,
      shopId: product.shopId,
      shopName: product.shopName,
      specifications: product.specifications,
      inStock: product.inStock,
      stockQuantity: product.stockQuantity,
      merchantId: product.merchantId,
      marketId: product.marketId,
      categoryId: product.categoryId,
      exactProductType: product.exactProductType,
      createdAt: product.createdAt,
      discount: product.discount,
      rating: product.rating,
    );
    await remoteDataSource.addProduct(model);
  }

  @override
  Stream<List<ProductEntity>> getShopProducts(String shopId) {
    return remoteDataSource.getShopProducts(shopId);
  }
}
