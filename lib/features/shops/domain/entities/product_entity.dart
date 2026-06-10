class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final String category; // category name (e.g. subcategory)
  final String shopId;
  final String shopName;
  final Map<String, dynamic> specifications;
  final bool inStock;
  final int stockQuantity;
  final String merchantId;
  final String marketId;
  final String categoryId;
  final String exactProductType; // e.g. "أيفونات", "بناطيل"
  final dynamic createdAt; // DateTime or Timestamp
  final double discount;
  final double rating;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.category,
    required this.shopId,
    required this.shopName,
    required this.specifications,
    this.inStock = true,
    this.stockQuantity = 0,
    required this.merchantId,
    required this.marketId,
    required this.categoryId,
    required this.exactProductType,
    required this.createdAt,
    this.discount = 0.0,
    this.rating = 0.0,
  });
}
