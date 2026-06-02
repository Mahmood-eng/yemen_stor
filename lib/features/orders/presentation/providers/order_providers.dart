import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/models/order_model.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource();
});

/// Stream of all user orders (real-time)
final userOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.read(orderRemoteDataSourceProvider).getUserOrders();
});

/// Real-time single order by id (for tracking screen)
final singleOrderStreamProvider =
    StreamProvider.family<OrderModel?, String>((ref, orderId) {
  return ref.read(orderRemoteDataSourceProvider).getOrderById(orderId);
});
