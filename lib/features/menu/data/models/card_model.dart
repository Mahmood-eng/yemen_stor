import '../../domain/entities/card_entity.dart';

class CardModel extends CardEntity {
  CardModel({
    required super.category,
    required super.remaining,
    required super.sold,
    required super.revenue,
    required super.total,
    required super.colorHex,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      category: json['category'] ?? 'غير معروف',
      remaining: json['remaining']?.toInt() ?? 0,
      sold: json['sold']?.toInt() ?? 0,
      revenue: json['revenue']?.toString() ?? '0',
      total: json['total']?.toInt() ?? 0,
      colorHex: json['colorHex'] ?? 'FF000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'remaining': remaining,
      'sold': sold,
      'revenue': revenue,
      'total': total,
      'colorHex': colorHex,
    };
  }
}
