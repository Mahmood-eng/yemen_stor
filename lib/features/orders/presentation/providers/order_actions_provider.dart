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
    if (cartItems.isEmpty) throw Exception('السلة فارغة');

    // Group items by merchantId
    final Map<String, List<CartItem>> groupedItems = {};
    for (var item in cartItems) {
      final merchantId = item.merchantId;
      if (!groupedItems.containsKey(merchantId)) {
        groupedItems[merchantId] = [];
      }
      groupedItems[merchantId]!.add(item);
    }

    String firstOrderId = '';

    // Place an order for each merchant
    for (var entry in groupedItems.entries) {
      final merchantId = entry.key;
      final itemsForMerchant = entry.value;

      final title = itemsForMerchant.first.productName;
      final totalPrice = itemsForMerchant.fold(
        0.0,
        (sum, i) => sum + i.price * i.quantity,
      );
      final imageUrl = itemsForMerchant.first.imageUrl;
      final storeName = itemsForMerchant.first.shopName;
      final shopId = itemsForMerchant.first.shopId;
      final marketId = itemsForMerchant.first.marketId;
      final categoryId = itemsForMerchant.first.categoryId;
      final storeAddress = deliveryAddress; // using passed address for simplicity
      final marketName = '';
      final categoryName = '';

      final mappedItems = itemsForMerchant
          .map(
            (i) => {
              'productId': i.id, // using cart item id as productId is acceptable or i.productId
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
        // Delivery fee applied to the first order or distributed. For now, apply to all or only first.
        // Let's just apply it evenly or full.
        deliveryFee: firstOrderId.isEmpty ? deliveryFee : 0.0, 
        imageUrl: imageUrl,
        storeName: storeName,
        shopId: shopId,
        storeAddress: storeAddress,
        marketName: marketName,
        categoryName: categoryName,
        merchantId: merchantId,
        marketId: marketId,
        categoryId: categoryId,
        items: mappedItems,
      );

      if (firstOrderId.isEmpty) {
        firstOrderId = orderId;
      }
    }

    return firstOrderId;
  }
}
