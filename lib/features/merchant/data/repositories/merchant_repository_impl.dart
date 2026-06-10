import '../../domain/entities/merchant_shop_entity.dart';
import '../../domain/repositories/merchant_repository.dart';
import '../datasources/merchant_remote_datasource.dart';
import '../models/merchant_shop_model.dart';

class MerchantRepositoryImpl implements MerchantRepository {
  final MerchantRemoteDataSource remoteDataSource;

  MerchantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> registerShop(MerchantShopEntity shop) async {
    final model = MerchantShopModel(
      id: shop.id,
      name: shop.name,
      description: shop.description,
      marketId: shop.marketId,
      marketName: shop.marketName,
      categoryId: shop.categoryId,
      categoryName: shop.categoryName,
      marketType: shop.marketType,
      logoUrl: shop.logoUrl,
      images: shop.images,
      phone: shop.phone,
      address: shop.address,
      ownerName: shop.ownerName,
      documentNumber: shop.documentNumber,
      documentUrl: shop.documentUrl,
      ownerId: shop.ownerId,
      status: shop.status,
      rating: shop.rating,
      createdAt: shop.createdAt,
    );
    await remoteDataSource.registerShop(model);
  }

  @override
  Stream<MerchantShopEntity?> getMerchantShop(String ownerId) {
    return remoteDataSource.getMerchantShop(ownerId);
  }

  @override
  Future<void> updateShopStatus(String shopId, String status) async {
    await remoteDataSource.updateShopStatus(shopId, status);
  }

  @override
  Future<void> updateShop(MerchantShopEntity shop) async {
    final model = MerchantShopModel(
      id: shop.id,
      name: shop.name,
      description: shop.description,
      marketId: shop.marketId,
      marketName: shop.marketName,
      categoryId: shop.categoryId,
      categoryName: shop.categoryName,
      marketType: shop.marketType,
      logoUrl: shop.logoUrl,
      images: shop.images,
      phone: shop.phone,
      address: shop.address,
      ownerName: shop.ownerName,
      documentNumber: shop.documentNumber,
      documentUrl: shop.documentUrl,
      ownerId: shop.ownerId,
      status: shop.status,
      rating: shop.rating,
      createdAt: shop.createdAt,
    );
    await remoteDataSource.updateShop(model);
  }
}
