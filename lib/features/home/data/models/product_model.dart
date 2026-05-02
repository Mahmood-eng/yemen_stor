class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final double rating;
  final int reviewsCount;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.category = 'عام',
    this.rating = 4.5,
    this.reviewsCount = 120,
  });
}
