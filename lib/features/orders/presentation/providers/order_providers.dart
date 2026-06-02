import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/models/order_model.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource();
});

/// Stream of all user orders (used by tracking screen)
final userOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.read(orderRemoteDataSourceProvider).getUserOrders();
});

/// Real-time single order by id (for tracking screen)
final singleOrderStreamProvider =
    StreamProvider.family<OrderModel?, String>((ref, orderId) {
  return ref.read(orderRemoteDataSourceProvider).getOrderById(orderId);
});

/// تبويب النشطة: processing + onWay (whereIn query - no composite index issue)
final activeOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.read(orderRemoteDataSourceProvider).getActiveOrders();
});

/// تبويب المكتملة: completed
final completedOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.read(orderRemoteDataSourceProvider).getCompletedOrders();
});

/// تبويب الملغاة: canceled
final canceledOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.read(orderRemoteDataSourceProvider).getCanceledOrders();
});

