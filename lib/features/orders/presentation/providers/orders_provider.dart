import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_status.dart';

class OrdersProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [
    OrderModel(
      id: "5421",
      title: "عطر ساواج ديور الرجالي - 100 مل",
      price: "45,000",
      status: OrderStatus.onWay,
      imageset: Image.asset("assets/images/perfume.jpg", width: 85, height: 85, fit: BoxFit.cover),
      storeName: "متجر النخبة للعطور - شارع جمال",
      time: "اليوم، 10:30 ص",
    ),
  ];

  List<OrderModel> get orders => _orders;

  void addOrder(OrderModel order) {
    _orders.insert(0, order); // الإضافة في بداية القائمة
    notifyListeners();
  }
}
