

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice; // السعر الأصلي إذا كان هناك خصم
  final List<String> images;
  final String category; // نوع المنتج مثل "هواتف", "ملابس", etc.
  final String shopId; // معرف المحل
  final String shopName; // اسم المحل
  final Map<String, dynamic> specifications; // مواصفات المنتج
  final bool inStock;
  final int stockQuantity;

  ProductModel({
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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      inStock: json['inStock'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }
}

// بيانات تجريبية للمنتجات حسب نوع المحل
final Map<String, List<ProductModel>> mockProductsByShop = {
  "1": [
    // سامي عدنان للأجهزة الذكية
    ProductModel(
      id: "p1",
      name: "iPhone 15 Pro Max",
      description: "أحدث إصدار من Apple مع كاميرا احترافية",
      price: 1200.0,
      originalPrice: 1300.0,
      images: ["assets/images/iphone15.jpg"],
      category: "هواتف ذكية",
      shopId: "1",
      shopName: "سامي عدنان للأجهزة الذكية",
      specifications: {
        "الشاشة": "6.7 بوصة Super Retina XDR",
        "المعالج": "A17 Pro",
        "الكاميرا": "48MP رئيسية",
        "البطارية": "4680 mAh",
        "التخزين": "256GB",
      },
      inStock: true,
      stockQuantity: 5,
    ),
    ProductModel(
      id: "p2",
      name: "Samsung Galaxy S24 Ultra",
      description: "هاتف ذكي قوي مع قلم S Pen",
      price: 1100.0,
      images: ["assets/images/s24ultra.jpg"],
      category: "هواتف ذكية",
      shopId: "1",
      shopName: "سامي عدنان للأجهزة الذكية",
      specifications: {
        "الشاشة": "6.8 بوصة Dynamic AMOLED 2X",
        "المعالج": "Snapdragon 8 Gen 3",
        "الكاميرا": "200MP رئيسية",
        "البطارية": "5000 mAh",
        "التخزين": "512GB",
      },
      inStock: true,
      stockQuantity: 3,
    ),
  ],
  "4": [
    // فاشن وورلد
    ProductModel(
      id: "p3",
      name: "قميص رجالي أنيق",
      description: "قميص قطني بألوان متعددة",
      price: 25.0,
      images: ["assets/images/shirt.jpg"],
      category: "ملابس رجالية",
      shopId: "4",
      shopName: "فاشن وورلد",
      specifications: {
        "المادة": "قطن 100%",
        "الألوان": "أبيض، أسود، أزرق",
        "المقاسات": "S, M, L, XL",
      },
      inStock: true,
      stockQuantity: 20,
    ),
    ProductModel(
      id: "p4",
      name: "فستان نسائي عصري",
      description: "فستان صيفي مريح وأنيق",
      price: 45.0,
      originalPrice: 60.0,
      images: ["assets/images/dress.jpg"],
      category: "ملابس نسائية",
      shopId: "4",
      shopName: "فاشن وورلد",
      specifications: {"المادة": "شيفون", "الطول": "طويل", "التصميم": "عصري"},
      inStock: true,
      stockQuantity: 15,
    ),
  ],
  // يمكن إضافة المزيد حسب الحاجة
};
