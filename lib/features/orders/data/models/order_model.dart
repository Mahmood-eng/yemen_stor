import 'package:flutter/material.dart';

import 'order_status.dart';

class OrderModel {
  final String id;
  final String title;
  final String price;
  final Widget imageset;
  final String storeName;
  final String time;
  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.title,
    required this.price,
    required this.imageset,
    required this.storeName,
    required this.time,
    required this.status,
  });
}