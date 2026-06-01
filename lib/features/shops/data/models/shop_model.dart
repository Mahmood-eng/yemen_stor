class ShopModel {
  final String id;
  final String name;
  final String description;
  final String status; // "مفتوح الآن" أو "مغلق" أو "pending"
  final double rating;
  final String location;
  final String phone;
  final List<String> images;
  final String marketType; // اسم الفئة
  final String marketId;   // معرف السوق
  final String categoryId; // معرف الفئة
  final String ownerId;    // معرف المالك (المستخدم)
  final String logoUrl;    // شعار المتجر

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.rating,
    required this.location,
    required this.phone,
    required this.images,
    required this.marketType,
    this.marketId = '',
    this.categoryId = '',
    this.ownerId = '',
    this.logoUrl = '',
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'مغلق',
      rating: (json['rating'] ?? 0.0).toDouble(),
      location: json['location'] ?? json['address'] ?? '',
      phone: json['phone'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      marketType: json['marketType'] ?? json['categoryName'] ?? '',
      marketId: json['marketId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'rating': rating,
      'location': location,
      'address': location,
      'phone': phone,
      'images': images,
      'marketType': marketType,
      'marketId': marketId,
      'categoryId': categoryId,
      'ownerId': ownerId,
      'logoUrl': logoUrl,
    };
  }
}
