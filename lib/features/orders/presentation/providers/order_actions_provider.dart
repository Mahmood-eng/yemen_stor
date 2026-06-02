import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_stor/features/orders/presentation/providers/cart_providers.dart';
import 'package:yemen_stor/features/orders/presentation/providers/order_providers.dart';
import '../../data/datasources/order_remote_datasource.dart';

/// Provider exposing actions related to orders (placing, cancelling)
final orderActionsProvider = Provider<OrderActions>((ref) {
  final remote = ref.read(orderRemoteDataSourceProvider);
  return OrderActions(remoteDatasource: remote);
});

class OrderActions {
  final OrderRemoteDataSource remoteDatasource;
  OrderActions({required this.remoteDatasource});

  /// Places an order based on current cart items.
  /// Returns the generated order id.
  Future<String> placeOrder({
    required List<CartItem> cartItems,
    required String userId,
    required String deliveryAddress,
    required double deliveryFee,
  }) async {
    // Build a summary title from first item
    final title = cartItems.isNotEmpty
        ? cartItems.first.productName
        : 'طلب من اليمن ستور';
    final totalPrice = cartItems.fold(
      0.0,
      (sum, i) => sum + i.price * i.quantity,
    );
    final imageUrl = cartItems.isNotEmpty ? cartItems.first.imageUrl : '';
    final storeName = cartItems.isNotEmpty ? cartItems.first.shopName : '';
    final storeAddress = deliveryAddress; // using passed address for simplicity
    final marketName = '';
    final categoryName = '';
    final items = cartItems
        .map(
          (i) => {
            'productId': i.id,
            'productName': i.productName,
            'quantity': i.quantity,
            'price': i.price,
            'imageUrl': i.imageUrl,
          },
        )
        .toList();
    final orderId = await remoteDatasource.placeOrder(
      title: title,
      totalPrice: totalPrice,
      deliveryFee: deliveryFee,
      imageUrl: imageUrl,
      storeName: storeName,
      storeAddress: storeAddress,
      marketName: marketName,
      categoryName: categoryName,
      items: items,
    );
    return orderId;
  }
}
