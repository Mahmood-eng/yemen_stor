

class ShopModel {
  final String id;
  final String name;
  final String description;
  final String status; // "مفتوح الآن" أو "مغلق"
  final double rating;
  final String location;
  final String phone;
  final List<String> images;
  final String marketType; // نوع السوق مثل "إلكترونيات", "أزياء", etc.

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
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'مغلق',
      rating: (json['rating'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      marketType: json['marketType'] ?? '',
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
      'phone': phone,
      'images': images,
      'marketType': marketType,
    };
  }
}

// بيانات تجريبية للمحلات حسب نوع السوق
final Map<String, List<ShopModel>> mockShopsByMarket = {
  "إلكترونيات": [
    ShopModel(
      id: "1",
      name: "سامي عدنان للأجهزة الذكية",
      description: "شارع 26 - أحدث إصدارات iPhone و Samsung",
      status: "مفتوح الآن",
      rating: 5.0,
      location: "شارع 26 سبتمبر، تعز",
      phone: "+967-1-234567",
      images: ["assets/images/shop1.jpg"],
      marketType: "إلكترونيات",
    ),
    ShopModel(
      id: "2",
      name: "تيك جلاكسي (Tech Galaxy)",
      description: "المسبح - متخصصون في إكسسوارات الألعاب",
      status: "مغلق",
      rating: 4.8,
      location: "المسبح، تعز",
      phone: "+967-1-345678",
      images: ["assets/images/shop2.jpg"],
      marketType: "إلكترونيات",
    ),
    ShopModel(
      id: "3",
      name: "أيفون هب تعز (iPhone Hub)",
      description: "شارع جمال - وكيل معتمد لمنتجات Apple",
      status: "مفتوح الآن",
      rating: 4.9,
      location: "شارع جمال، تعز",
      phone: "+967-1-456789",
      images: ["assets/images/shop3.jpg"],
      marketType: "إلكترونيات",
    ),
  ],
  "أزياء": [
    ShopModel(
      id: "4",
      name: "فاشن وورلد (Fashion World)",
      description: "التحرير - ملابس عصرية للرجال والنساء",
      status: "مفتوح الآن",
      rating: 4.7,
      location: "التحرير، تعز",
      phone: "+967-1-567890",
      images: ["assets/images/shop4.jpg"],
      marketType: "أزياء",
    ),
    ShopModel(
      id: "5",
      name: "زينة للأزياء",
      description: "حي الروضة - فساتين زفاف ومناسبات",
      status: "مفتوح الآن",
      rating: 4.6,
      location: "حي الروضة، تعز",
      phone: "+967-1-678901",
      images: ["assets/images/shop5.jpg"],
      marketType: "أزياء",
    ),
  ],
  // يمكن إضافة المزيد حسب الحاجة
};
