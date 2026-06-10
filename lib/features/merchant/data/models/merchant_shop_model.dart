import '../../domain/entities/merchant_shop_entity.dart';

class MerchantShopModel extends MerchantShopEntity {
  MerchantShopModel({
    required super.id,
    required super.name,
    required super.description,
    required super.marketId,
    required super.marketName,
    required super.categoryId,
    required super.categoryName,
    required super.marketType,
    required super.logoUrl,
    required super.images,
    required super.phone,
    required super.address,
    required super.ownerName,
    required super.documentNumber,
    required super.documentUrl,
    required super.ownerId,
    super.status = 'مفتوح الآن',
    super.rating = 5.0,
    required super.createdAt,
  });

  factory MerchantShopModel.fromJson(Map<String, dynamic> json) {
    return MerchantShopModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      marketId: json['marketId'] ?? '',
      marketName: json['marketName'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      marketType: json['marketType'] ?? json['categoryName'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      phone: json['phone'] ?? '',
      address: json['address'] ?? json['location'] ?? '',
      ownerName: json['ownerName'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      documentUrl: json['documentUrl'] ?? '',
      ownerId: json['ownerId'] ?? '',
      status: json['status'] ?? 'مغلق',
      rating: (json['rating'] ?? 5.0).toDouble(),
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'marketId': marketId,
      'marketName': marketName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'marketType': marketType,
      'logoUrl': logoUrl,
      'images': images,
      'phone': phone,
      'address': address,
      'location': address,
      'ownerName': ownerName,
      'documentNumber': documentNumber,
      'documentUrl': documentUrl,
      'ownerId': ownerId,
      'status': status,
      'rating': rating,
      'createdAt': createdAt,
    };
  }
}
