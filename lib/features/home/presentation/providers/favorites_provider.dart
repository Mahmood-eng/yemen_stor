import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<ProductModel> _favorites = [];

  List<ProductModel> get favorites => _favorites;

  bool isFavorite(String productId) {
    return _favorites.any((product) => product.id == productId);
  }

  void toggleFavorite(ProductModel product) {
    final isExist = isFavorite(product.id);
    if (isExist) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }
}
