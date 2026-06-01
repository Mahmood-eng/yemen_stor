import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/merchant_remote_datasource.dart';
import '../../data/repositories/merchant_repository_impl.dart';
import '../../domain/entities/merchant_shop_entity.dart';
import '../../domain/repositories/merchant_repository.dart';
import '../../domain/usecases/register_shop_usecase.dart';
import '../../domain/usecases/get_merchant_shop_usecase.dart';
import '../../domain/usecases/update_shop_status_usecase.dart';

final merchantRemoteDataSourceProvider = Provider<MerchantRemoteDataSource>((ref) {
  return MerchantRemoteDataSourceImpl();
});

final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  final remoteDataSource = ref.watch(merchantRemoteDataSourceProvider);
  return MerchantRepositoryImpl(remoteDataSource: remoteDataSource);
});

final registerShopUseCaseProvider = Provider<RegisterShopUseCase>((ref) {
  final repository = ref.watch(merchantRepositoryProvider);
  return RegisterShopUseCase(repository);
});

final getMerchantShopUseCaseProvider = Provider<GetMerchantShopUseCase>((ref) {
  final repository = ref.watch(merchantRepositoryProvider);
  return GetMerchantShopUseCase(repository);
});

final updateShopStatusUseCaseProvider = Provider<UpdateShopStatusUseCase>((ref) {
  final repository = ref.watch(merchantRepositoryProvider);
  return UpdateShopStatusUseCase(repository);
});

// A stream provider to load the merchant's registered shop
final merchantShopStreamProvider = StreamProvider.family<MerchantShopEntity?, String>((ref, ownerId) {
  final getMerchantShop = ref.watch(getMerchantShopUseCaseProvider);
  return getMerchantShop(ownerId);
});
