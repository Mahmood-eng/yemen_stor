import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum OrderStatus {
  onWay,      // نشط - في الطريق
  processing, // نشط - جاري التجهيز
  completed,  // مكتمل
  canceled    // ملغي
}

// إضافة خصائص مساعدة للـ Enum لجلب اللون والنص مباشرة
extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.onWay: return "في الطريق";
      case OrderStatus.processing: return "جاري التجهيز";
      case OrderStatus.completed: return "تم التوصيل";
      case OrderStatus.canceled: return "ملغي";
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.onWay:
      case OrderStatus.processing: return AppColors.warning;
      case OrderStatus.completed: return AppColors.success;
      case OrderStatus.canceled: return AppColors.error;
    }
  }
}