enum OrderStatus { accepted, preparing, onTheWay, delivered }

class TrackingModel {
  final String orderId;
  final String driverName;
  final String driverImage;
  final String estimatedTime;
  final OrderStatus status;
  final double lat;
  final double lng;

  TrackingModel({
    required this.orderId,
    required this.driverName,
    required this.driverImage,
    required this.estimatedTime,
    required this.status,
    required this.lat,
    required this.lng,
  });
}