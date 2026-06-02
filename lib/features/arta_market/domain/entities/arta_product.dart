class ArtaProduct {
  final String id;
  final String seller;
  final String title;
  final double price;
  final String location;
  final String imageUrl;
  final String phone;
  final String description;
  final DateTime createdAt;
  final bool isFavorite; // Handled dynamically in presentation/domain depending on user context

  const ArtaProduct({
    required this.id,
    required this.seller,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.phone,
    required this.description,
    required this.createdAt,
    this.isFavorite = false,
  });

  ArtaProduct copyWith({
    String? id,
    String? seller,
    String? title,
    double? price,
    String? location,
    String? imageUrl,
    String? phone,
    String? description,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return ArtaProduct(
      id: id ?? this.id,
      seller: seller ?? this.seller,
      title: title ?? this.title,
      price: price ?? this.price,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
