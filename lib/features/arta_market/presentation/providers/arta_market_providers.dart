import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/arta_remote_datasource.dart';
import '../../data/repositories/arta_market_repository_impl.dart';
import '../../domain/repositories/arta_market_repository.dart';
import '../../domain/usecases/add_arta_product_usecase.dart';
import '../../domain/usecases/get_arta_favorites_usecase.dart';
import '../../domain/usecases/get_arta_products_usecase.dart';
import '../../domain/usecases/toggle_arta_favorite_usecase.dart';
import '../../domain/entities/arta_product.dart';

// --- Data Source ---
final artaRemoteDataSourceProvider = Provider<ArtaMarketRemoteDataSource>((ref) {
  return ArtaMarketRemoteDataSource();
});

// --- Repository ---
final artaMarketRepositoryProvider = Provider<ArtaMarketRepository>((ref) {
  final remoteDataSource = ref.read(artaRemoteDataSourceProvider);
  return ArtaMarketRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Use Cases ---
final getArtaProductsUseCaseProvider = Provider<GetArtaProductsUseCase>((ref) {
  return GetArtaProductsUseCase(ref.read(artaMarketRepositoryProvider));
});

final addArtaProductUseCaseProvider = Provider<AddArtaProductUseCase>((ref) {
  return AddArtaProductUseCase(ref.read(artaMarketRepositoryProvider));
});

final toggleArtaFavoriteUseCaseProvider = Provider<ToggleArtaFavoriteUseCase>((ref) {
  return ToggleArtaFavoriteUseCase(ref.read(artaMarketRepositoryProvider));
});

final getArtaFavoritesUseCaseProvider = Provider<GetArtaFavoritesUseCase>((ref) {
  return GetArtaFavoritesUseCase(ref.read(artaMarketRepositoryProvider));
});

// --- Streams (UI State) ---
final artaProductsStreamProvider = StreamProvider<List<ArtaProduct>>((ref) {
  return ref.read(getArtaProductsUseCaseProvider).call();
});

final artaFavoritesStreamProvider = StreamProvider<List<ArtaProduct>>((ref) {
  return ref.read(getArtaFavoritesUseCaseProvider).call();
});

// --- Notifier for Actions (Add Product, Toggle Favorite) ---
class ArtaMarketState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ArtaMarketState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  ArtaMarketState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return ArtaMarketState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ArtaMarketNotifier extends StateNotifier<ArtaMarketState> {
  final AddArtaProductUseCase _addProductUseCase;
  final ToggleArtaFavoriteUseCase _toggleFavoriteUseCase;

  ArtaMarketNotifier(this._addProductUseCase, this._toggleFavoriteUseCase)
      : super(ArtaMarketState());

  Future<void> addProduct(ArtaProduct product) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _addProductUseCase.call(product);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleFavorite(ArtaProduct product) async {
    try {
      await _toggleFavoriteUseCase.call(product);
    } catch (e) {
      // Handle error quietly or show a snackbar via another mechanism
      print("Failed to toggle favorite: $e");
    }
  }
  
  void resetState() {
    state = ArtaMarketState();
  }
}

final artaMarketNotifierProvider = StateNotifierProvider<ArtaMarketNotifier, ArtaMarketState>((ref) {
  return ArtaMarketNotifier(
    ref.read(addArtaProductUseCaseProvider),
    ref.read(toggleArtaFavoriteUseCaseProvider),
  );
});
