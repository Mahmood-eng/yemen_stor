class MerchantShopEntity {
  final String id;
  final String name;
  final String description;
  final String marketId;
  final String marketName;
  final String categoryId;
  final String categoryName;
  final String marketType; // categoryName
  final String logoUrl;
  final List<String> images;
  final String phone;
  final String address;
  final String ownerName;
  final String documentNumber;
  final String documentUrl;
  final String ownerId;
  final String status; // "مفتوح الآن", "مغلق مؤقتاً", etc.
  final double rating;
  final dynamic createdAt;

  MerchantShopEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.marketId,
    required this.marketName,
    required this.categoryId,
    required this.categoryName,
    required this.marketType,
    required this.logoUrl,
    required this.images,
    required this.phone,
    required this.address,
    required this.ownerName,
    required this.documentNumber,
    required this.documentUrl,
    required this.ownerId,
    this.status = 'مفتوح الآن',
    this.rating = 5.0,
    required this.createdAt,
  });
}
