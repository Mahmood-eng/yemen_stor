import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.originalPrice,
    required super.images,
    required super.category,
    required super.shopId,
    required super.shopName,
    required super.specifications,
    super.inStock = true,
    super.stockQuantity = 0,
    required super.merchantId,
    required super.marketId,
    required super.categoryId,
    required super.exactProductType,
    required super.createdAt,
    super.discount = 0.0,
    super.rating = 0.0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final priceVal = (json['price'] ?? 0.0).toDouble();
    final originalPriceVal = json['originalPrice'] != null
        ? (json['originalPrice'] as num).toDouble()
        : null;
    final discountVal = (json['discount'] ?? 0.0).toDouble();
    final ratingVal = (json['rating'] ?? 0.0).toDouble();

    return ProductModel(
      id: json['id'] ?? json['productId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: priceVal,
      originalPrice: originalPriceVal,
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      inStock: json['inStock'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 0,
      merchantId: json['merchantId'] ?? '',
      marketId: json['marketId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      exactProductType: json['exactProductType'] ?? '',
      createdAt: json['createdAt'],
      discount: discountVal,
      rating: ratingVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'images': images,
      'category': category,
      'shopId': shopId,
      'shopName': shopName,
      'specifications': specifications,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'merchantId': merchantId,
      'marketId': marketId,
      'categoryId': categoryId,
      'exactProductType': exactProductType,
      'createdAt': createdAt,
      'discount': discount,
      'rating': rating,
    };
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  double get discountPercentage {
    if (hasDiscount) {
      return ((originalPrice! - price) / originalPrice!) * 100;
    }
    if (discount > 0) {
      return discount;
    }
    return 0.0;
  }
}
